[bits 16]

global Kernel
extern KernelMain

; -------------------- Kernel --------------------
Kernel:
; -------------------- Initializations --------------------
.segmentInitialization:
  cli ; Disable maskable interrupts so that stack initializes without interruption. Although, this is not needed for such a small project but this is considered a good practice.

  ; -------------------- Initialize Data Segment (DS) --------------------
  ; To be 0 for correct offsetting from the origin.
  xor ax, ax ; Zeroes the AX. Equivalent to "mov ax, 0".
  mov ax, cs ; This and the following instruction equals DS to CS because the labels are relative to CS (b/c we used them as part of the source "code" and not data segment seperately.)
  mov ds, ax

  ; -------------------- Initialize Stack Segment (SS) -------------------- 
  mov ax, 0x9000
  mov ss, ax ; SS initialized at 0x9000
  mov sp, 0xffff ; With a size of 0xffff (65535)10
  mov bp, sp ; Points BP to SP, not needed for now though.
  nop ; Gives CPU another free cycle to adjust the hidden SS register. (Uff, so much going on...)

  ; -------------------- Initialize Extra Segment (ES) -------------------- 
  mov ax, ds
  mov es, ax ; ES initialized at 0x1000
  mov bx, 0x0000  
  
  sti ; Re-enable maskable interrupts.

.jumpToKernel:
  call KernelMain
  jmp $

; -------------------- Externals --------------------

