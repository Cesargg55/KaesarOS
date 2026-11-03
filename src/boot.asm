[org 0x7C00]
[bits 16]

    ; ---- PREPARACION ----
    xor ax, ax
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00


    mov ah, 0x02            ; Bios: Read disk
    mov al, 16              ; sectores
    mov ch, 0               
    mov cl, 2
    mov dh, 0
    mov bx, 0x7E00          
    int 0x13
    jc diskError

    mov ax,0x0003
    int 0x10

    mov si, logo
    call print

    mov ah, 0x86
    mov cx, 0x000F
    mov dx, 0x4240
    int 0x15


    jmp 0x7E00


    diskError:
        mov si, msgDisk
        call print
        jmp $

    print:           
        mov bh, 0 
        mov ah, 0x0E
    .again:                  
        lodsb               
        cmp al, 0           ; If
        je .end             ; If True = End
        int 0x10            ; If False = Write
        jmp .again          
    .end:
        ret       
           
msgDisk: db "Error leyendo el disco.", 13, 10, 0

logo: db " _  __                           ____        ", 13, 10  
        db "| |/ /                          / __ \      ", 13, 10  
        db "| ' / __ _  ___  ___  __ _ _ __| |  | |___  ", 13, 10  
        db "|  < / _` |/ _ \/ __|/ _` | '__| |  | / __| ", 13, 10  
        db "| . \ (_| |  __/\__ \ (_| | |  | |__| \__ \ ", 13, 10  
        db "|_|\_\__,_|\___||___/\__,_|_|   \____/|___/ ", 13, 10, 0                                          
                                            

times 510-($-$$) db 0
dw 0xAA55