[org 0x7E00] 
[bits 16]

command equ 0x0500
bootDrive equ 0x0600        
diskBuffer equ 0x1000       ; zona de memoria para leer
SECTOR_NOTA equ 18          ; 1 = boot, 2 a 17 = kernel, 18 = libre

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

        mov si, command             ;create
        mov di, create
        call compare
        je createCommand

        mov si, command             ;load
        mov di, load
        call compare
        je loadCommand

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

    createCommand:
        mov si, msgText
        call print
        call readCommand    ; reutiliza tu función: el texto queda en command
        mov ah, 0x03        ; BIOS: escribir en el disco
        mov al, 1           ; 1 sector
        mov ch, 0           ; cilindro 0
        mov cl, SECTOR_NOTA ; sector 18
        mov dh, 0           ; cabeza 0
        mov dl, [bootDrive] ; qué disco
        mov bx, command     ; qué memoria escribir
        int 0x13
        mov bh, 0           ; BX ha cambiado: vuelve a dejar la página 0
        jc diskFail
        jmp cmd
    
    loadCommand:
        mov ah, 0x02        ; BIOS: leer del disco
        mov al, 1
        mov ch, 0
        mov cl, SECTOR_NOTA
        mov dh, 0
        mov dl, [bootDrive]
        mov bx, diskBuffer  ; dónde dejar lo leído
        int 0x13
        mov bh, 0
        jc diskFail
        mov si, diskBuffer
        call print
        mov si, salto
        call print
        jmp cmd

    diskFail:
        mov si, msgDiskFail
        call print
        jmp cmd


; ---- TEXTOS ----
osName: db "KaesarOS", 13, 10, 0
prompt: db "K>  ", 0
salto: db 13, 10, 0
unknow: db "Comando desconocido.", 13, 10, 0
msgOff: db "Error al apagar.", 0
msgText: db "Texto: ", 0
msgDiskFail: db "Error de disco.", 13, 10, 0


help: db "help", 0
cls: db "cls", 0
clear: db "clear", 0
reboot: db "reboot", 0
shutdown: db "shutdown", 0
create: db "create", 0
load: db "load", 0



    ;--- Help Commands ----
helpLine1: db "help => Comando para mas ayuda.", 13, 10
            db "cls / clear => Comando para limpiar la pantalla.", 13, 10
            db "reboot => Reinicio del sistema.", 13, 10
            db "shutdown => Apagar el equipo.", 13, 10
            db "create => Crear archivo.", 13, 10
            db "load => Cargar archivo.", 13, 10, 0

times 16*512-($-$$) db 0
times 32*512 db 0

