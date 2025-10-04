[bits 16] ; Boots in real mode (16-bit), not required here though becasue, NASM loads to real mode by default.

[org 0x7c00] ; This is a directive. It tells the assembler the start location of our boot sector. This way, the assembler can offset further instructions as per the need rather than assuming [0x0000] to be the start address.

; ========== INITIALIZATIONS ==========
InitializeBootloader:
  cli ; Disable maskable interrupts so that stack initializes without interruption. Although, this is not needed for such a small project but this is considered a good practice.

  ; ========== Initialize Data Segment (DS) ==========
  ; To be 0 for correct offsetting from the origin.
  xor ax, ax ; Zeroes the AX. Equivalent to "mov ax, 0".
  mov ax, cs ; This and the following instruction equals DS to CS because the labels are relative to CS (b/c we used them as part of the source "code" and not data segment seperately.)
  mov ds, ax

  ; ========== Initialize Stack Segment (SS) ========== 
  mov ax, 0x9000
  mov ss, ax ; SS initialized at 0x9000
  mov sp, 0xffff ; With a size of 0xffff (65535)10
  mov bp, sp ; Points BP to SP, not needed for now though.
  nop ; Gives CPU another free cycle to adjust the hidden SS register. (Uff, so much going on...)

  ; ========== Initialize Extra Segment (ES) ========== 
  mov ax, 0x1000
  mov es, ax ; ES initialized at 0x1000
  mov bx, 0x0000  
  
  sti ; Re-enable maskable interrupts.

; ========== Load Functional Labels ========== 
mov [currentBootDrive], dl ; The BIOS stores current boot number in DL at boot.

; ========== JUMP TO StartBootloader ==========
jmp StartBootloader

; ========== CONTRUCTION AHEAD ==========
; ReadKernel usage:
;   - Set DL as the drive number to be read from prior calling this routine.
;   - Set AL as the number of sector to be read from the drive.
ReadKernel:
  pusha

  mov ah, 0x02 ; Read-disk intruction.
  
  mov dl, [currentBootDrive] ; Read from drive number.
  mov al, 0x03 ; Number of sectors to read.
  mov ch, 0x00 ; Select cylinder number (Base 0; 1st cylinder).         'C'
  mov dh, 0x00 ; Use the head on the opposite side (Base 0; 1st head).  'H'
  mov cl, 0x02 ; Select sector number (Base 1; 4th sector).             'S'
  
  mov bx, 0x0000 ; Read data to ES:BX -> ES:0000
  
  int 0x13 ; BIOS interrupt for Disk operations.

  jc .KernelReadFailure
  cmp al, 0x03
  jne .KernelReadFailure

  call .KernelReadSuccess

  popa
  ret

.KernelReadSuccess:
  mov si, kernelReadSuccessMessage
  call PrintStringNL

  ret

.KernelReadFailure:
  mov dh, ah
  call PrintHex
  call PrintSpace

  mov si, kernelReadFailureMessage
  call PrintStringNL
  
  hlt ; Dead end

JumpToKernel:
  jmp 0x1000:0000 ; Actual far jump to the kernel sector.

; Disk-related labels
currentBootDrive: db 0
kernelReadFailureMessage: db "Kernel read error!", 0
kernelReadSuccessMessage: db "Kernel read successful!", 0

; ========== START ROUTINE ==========
StartBootloader:
  ; ========== Demonstration ==========
  call ClearScreen

  mov si, bootingMessage
  call PrintStringNL

  call ReadKernel
  call JumpToKernel
  
  hlt

; Infinite pause (cause, why not?)
Pause:
  jmp Pause

; ========== EXTERNALS ==========
%include "screen.asm"

; ========== BOOT SECTOR PADDING ==========
times 510-($-$$) db 0 ; This fills the remaining bytes (upto 510 bytes, the last two bytes (to make it a whole of 512 bytes) are set below) of the boot sector with 0.
dw 0xaa55 ; 0xaa55 is a special code for the bootloader to tell that the boot sector has ended.

; ========== FLAGGING GIBBERISH ==========
; times 256 dw 0xdada
; times 256 dw 0xface