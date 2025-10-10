[bits 16]
[org 0x7c00]

TEMU_LOAD_SEGMENT equ 0x07e0 ; Converts to -> 0x7e00 (physical address)
TEMU_SECTOR_COUNT equ 0x40 ; 64 Sectors, for safety. (Needs fixing...)

%macro READ_DISK 0
<<<<<<< Updated upstream
  ; BIOS Interrupt
  mov ah, 0x02   ; BIOS read disk
  int 0x13
%endmacro

Bootloader:
  ; To be 0 for correct offsetting from the origin.
  xor ax, ax ; Zeroes the AX. Equivalent to "mov ax, 0".
  mov ax, cs ; This and the following instruction equals DS to CS because the labels are relative to CS (b/c we used them as part of the source "code" and not data segment seperately.)
  mov ds, ax
  mov [currentBootDrive], dl ; BIOS returns the current boot drive number in DL after startup.

ReadTemu:
  ; ES Setup
  mov ax, TEMU_LOAD_SEGMENT
  mov es, ax ; ES initialized at 0x1000 for the kernel to be loaded.
  mov bx, 0x00  ; 0 offset from ES

  ; Drive Setup
  mov dl, [currentBootDrive] ; Read from drive number.
  mov al, TEMU_SECTOR_COUNT ; Number of sectors to read.
  mov ch, 0x00 ; Select cylinder number (Base 0; 1st cylinder).         'C'
  mov dh, 0x00 ; Use the head on the opposite side (Base 0; 1st head).  'H'
  mov cl, 0x02 ; Select sector number (Base 1; 2nd sector).             'S'
  
  READ_DISK

  ; Error handling
  jc .fail

  cmp al, TEMU_SECTOR_COUNT
  jne .fail
  
  ; jmp 0x1000:0000 ; Make the actual jump to the kernel.
  jmp TEMU_LOAD_SEGMENT:0x0000 ; Make the actual jump to the kernel.


.fail:
  mov al, '!'
  int 0x10
  jmp $ ; infinite loop on failure
  
=======
    ; BIOS Interrupt
    mov ah, 0x02     ; BIOS read disk
    int 0x13
%endmacro

Bootloader:
    ; To be 0 for correct offsetting from the origin.
    xor ax, ax ; Zeroes the AX. Equivalent to "mov ax, 0".
    mov ax, cs ; This and the following instruction equals DS to CS because the labels are relative to CS (b/c we used them as part of the source "code" and not data segment seperately.)
    mov ds, ax
    mov [currentBootDrive], dl ; BIOS returns the current boot drive number in DL after startup.

ReadTemu:
    ; ES Setup
    mov ax, TEMU_LOAD_SEGMENT
    mov es, ax ; ES initialized at 0x1000 for the kernel to be loaded.
    mov bx, 0x00    ; 0 offset from ES

    ; Drive Setup
    mov dl, [currentBootDrive] ; Read from drive number.
    mov al, TEMU_SECTOR_COUNT ; Number of sectors to read.
    mov ch, 0x00 ; Select cylinder number (Base 0; 1st cylinder).       'C'
    mov dh, 0x00 ; Use the head on the opposite side (Base 0; 1st head).    'H'
    mov cl, 0x02 ; Select sector number (Base 1; 2nd sector).           'S'
    
    READ_DISK

    ; Error handling
    jc .fail

    cmp al, TEMU_SECTOR_COUNT
    jne .fail
    
    ; jmp 0x1000:0000 ; Make the actual jump to the kernel.
    jmp TEMU_LOAD_SEGMENT:0x0000 ; Make the actual jump to the kernel.


.fail:
    mov al, '!'
    int 0x10
    jmp $ ; infinite loop on failure
    
>>>>>>> Stashed changes
currentBootDrive: db 0

times 510-($-$$) db 0 ; Pad the rest of the boot sector.
dw 0xaa55 ; End with boot sector code.
