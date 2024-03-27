; Available for change
%assign KERNEL_SIZE 31            ; 0x1 - 0x80 (512 bytes to 40KiB)
%assign BOOT_DRIVE 0              ; Just create a 

[bits 16]                         ; BITS = 16
org 0x7c00                        ; boot_offset = 0x7c00
            mov  ah,  0x0e        ; Set to tty mode
            mov  bx,  bootmsg     ; $bx = &bootmsg
            call print
disk_load:  pusha                 ; We bouta use the stack
            mov  dl, BOOT_DRIVE   ; Setting the boot drive to use
            push dx               ; Pushing the two values on the stack for later use
            mov  ah, 0x02         ; ah <- 0x13 func. 0x02 = 'read'
            mov  al, KERNEL_SIZE  ; al <- num of sectors to read (0x1 - 0x80) We could probably work this at the kernel32 if need more
            mov  cl, 0x02         ; cl <- sector (0x01 - 0x11)
                                  ; * Since this (bootsector) is sector 0x01, we jump to 0x02
            mov  ch, 0x00         ; Checking the first cylinder 
            mov  dh, 0x0          ; dh <- Head number (0x0, 0xF)
                                  ; [es:bx] <- pointer to where the data will be stored
                                  ; Caller will set it up for us
            int  0x13             ; Calling the interrupt
            jc   disk_error       ; Error stored in carry bit

            pop  dx
            cmp  al, dh           ; BIOS also sets $al to the # of sectors read. Comp it.
            jne  sectors_error    ; Get error if they do not match
            popa                  ; Success!
                                  ; Moving to 32-bit
switch_32:  cli                   ; Disable interrupts
            lgdt [gdtdesc]        ; load gdt descriptor
            mov  eax, cr0         ; editing the control register 0
            or   eax, 0x1         ; $cr0 | 1 sets to 32-bit
            mov  cr0, eax         ; putting cr0 back
            jmp  CODE_SEG:init_32 ; Far jump initing 32-bit
            jmp  $                ; Should never be executed
print:  
            mov  al,  [bx]        ; Set al to bootmsg[offset]
            int  0x10             ; putc($al)

            inc  bx               ; bx += 1
            cmp  al,  0           ; if(bootmsg == NULL)
            jne  print            ;   goto print_lp0

            ret                   ; Going back to where they should be
disk_error: 
            mov  ah, 0x0e         ; Getting a new line
            mov  al, 0x0a         ; $al = '\n'
            int  0x10
            mov  al, 0x0d         ; Carriage return
            int  0x10
            mov  bx, diskmsg      ; Getting the message
            call print
            mov  al, 0x0a
            int  0x10
            mov  al, 0x0d
            int  0x10
            mov  dh, ah           ; Printing the code
            call print_hex        ; Check error at http://stanislavs.org/helppc/int_13-1.html            

            hlt                   ; Stopping and
            jmp $                 ; Staying there
sectors_error:
            mov  bx, sectorsmsg
            call print

            hlt
            jmp $

; Not my code. https://github.com/cfenollosa/os-tutorial/blob/master/23-fixes/boot/print_hex.asm
; receiving the data in 'dx'
print_hex: 
           pusha
           mov cx, 0              ; our index variable
hex_loop:  cmp cx, 4              ; loop 4 times
           je end
           mov ax, dx             ; we will use 'ax' as our working register
           and ax, 0x000f         ; 0x1234 -> 0x0004 by masking first three to zeros
           add al, 0x30           ; add 0x30 to N to convert it to ASCII "N"
           cmp al, 0x39           ; if > 9, add extra 8 to represent 'A' to 'F'
           jle step2
           add al, 7              ; 'A' is ASCII 65 instead of 58, so 65-58=7
step2:     mov bx, HEX_OUT + 5    ; base + length
           sub bx, cx             ; our index variable
           mov [bx], al           ; copy the ASCII char on 'al' to the position pointed by 'bx'
           ror dx, 4              ; 0x1234 -> 0x4123 -> 0x3412 -> 0x2341 -> 0x1234
           add cx, 1              ; increment index and loop
           jmp hex_loop
end:       mov bx, HEX_OUT
           call print
           popa
           ret

[bits 32]                         ; Now initing 32-bit mode
init_32:  mov  ax,  DATA_SEG      ; Updating seg registers
          mov  ds,  ax
          mov  ss,  ax
          mov  es,  ax
          mov  fs,  ax
          mov  gs,  ax

          mov  ebp, 0x90000       ; Moving the stack up to 0x90000
          mov  esp, ebp
begin_32: call KERNEL_OFFSET      ; Give control to kernel32
          jmp $                   ; Jump back if needed

; Just some GDT information
gdt_start: dd 0x0                 ; 4 byte
           dd 0x0                 ; 4 byte

gdt_code:  dw 0xffff              ; Seg len, bits 0-15
           dw 0                   ; seg base, bits 0-15
           db 0                   ; seg base, bits 16-23
           db 10011010b           ; flags (8 bits)
           db 11001111b           ; flags (4 bits) + seg len, bits 16-19
           db 0x0                 ; seg base, bits 24-31

gdt_data:  dw 0xffff
           dw 0x0
           db 0x0
           db 10010010b
           db 11001111b
           db 0x0

gdt_end:

gdtdesc:        dw gdt_end - gdt_start - 1
                dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG eqt gdt_data - gdt_start

bootmsg:
    db "Booted into legacy mode!", 0
diskmsg: 
    db "Disk read error! Could not read kernel!", 0
sectorsmsg: 
    db "Sectors error!", 0
HEX_OUT: 
    db '0x0000',0                 ; reserve memory for our new string

times 510 - ($ - $$) db 0
dw 0xaa55
