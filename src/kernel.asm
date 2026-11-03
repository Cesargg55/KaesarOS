[org 0x7E00] 
[bits 16]

command equ 0x0500

    ; ---- PREPARACION ----

    mov bh, 0


    ; --- Code ---

    mov ax,0x0003           ; clear
    int 0x10


    mov si, osName
    call print
    jmp cmd               

    ; ---- FUNCIONES ----
    print:            
        mov ah, 0x0E
    .again:                  
        lodsb               
        cmp al, 0           ; If
        je .end             ; If True = End
        int 0x10            ; If False = Write
        jmp .again          
    .end:
        ret       

    readCommand:
        mov di, command 
        .key:
            mov ah, 0x00
            int 0x16
            cmp al, 13          ; If key = enter
            je .enter
            cmp al, 8           ; If key = backspace
            je .backspace
            cmp di, command + 60    ; If Command Variable is full (max 60 characters)
            je .key             ; ignora tecla
            stosb               ; save key in command Variable
            mov ah, 0x0E
            int 0x10            ; print screen
            jmp .key

        .backspace:
            cmp di, command     ; estamos al principio?
            je .key             ; si -> no hay nada que borrar
            dec di              ; el dedo retrocede una cajita
            mov ah, 0x0E
            mov al, 8
            int 0x10            ; atras
            mov al, ' '
            int 0x10            ; espacio encima
            mov al, 8
            int 0x10            ; atras
            jmp .key

        .enter:
            mov al, 0
            stosb               ; pon el 0 del final: "aqui se acaba"
            mov si, salto
            call print          ; baja de linea
            ret

    compare:
        .other:
            mov al, [si]        ; letra de la frase 1
            cmp al, [di]        ; es igual a la letra de la frase 2?
            jne .end            ; distinta -> salir ("no son iguales")
            cmp al, 0           ; es el final?
            je .end             ; si, y las dos acaban -> salir ("son iguales")
            inc si              ; los dos dedos avanzan
            inc di
            jmp .other
        .end:
            ret

    cmd:                        ; Funcion de Terminal
        mov si, prompt
        call print
        call readCommand

        mov si, command
        mov di, help
        call compare
        je helpCommand

        ;CLS
        mov si, command
        mov di, cls
        call compare
        je clsCommand

        mov si, command
        mov di, clear
        call compare
        je clsCommand

        mov si, command             ;reboot
        mov di, reboot
        call compare
        je rebootCommand

        mov si, command             ;shutdown
        mov di, shutdown
        call compare
        je shutdownCommand

        mov si, unknow          ; No es un comando conocido
        call print
        jmp cmd

        ; --- Comandos Propios ---

    helpCommand:
        mov si, helpLine1
        call print
        jmp cmd

    clsCommand:
        mov ax, 0x0003      ; AH=0 (cambiar modo de video), AL=3 (texto 80x25)
        int 0x10           
        jmp cmd

    rebootCommand:
    .wait:
        in al, 0x64
        test al, 2
        jnz .wait
        mov al, 0xFE
        out 0x64, al
        jmp 0xFFFF:0x0000

    shutdownCommand:
        mov ax, 0x2000      ; orden de apagar
        mov dx, 0x604       
        out dx, ax          
        mov si, msgOff      ; si seguimos aquí, no se ha apagado
        call print
    .stop:
        hlt                 ; duerme la CPU hasta la siguiente interrupción
        jmp .stop


; ---- TEXTOS ----
osName: db "KaesarOS", 13, 10, 0
prompt: db "K>  ", 0
salto: db 13, 10, 0
unknow: db "Comando desconocido.", 13, 10, 0
msgOff: db "Error al apagar.", 0


help: db "help", 0
cls: db "cls", 0
clear: db "clear", 0
reboot: db "reboot", 0
shutdown: db "shutdown", 0


    ;--- Help Commands ----
helpLine1: db "help => Comando para mas ayuda.", 13, 10
            db "cls / clear => Comando para limpiar la pantalla.", 13, 10
            db "reboot => Reinicio del sistema.", 13, 10
            db "shutdown => Apagar el equipo.", 13, 10, 0

times 16*512-($-$$) db 0