[bits 16]

; ======================================================
; ----------------- InitializeSegments -----------------
; ======================================================
InitializeSegments:
  cli ; Disable maskable interrupts during the time of initialization.

  ; Initialize Data Segment
  mov ax, cs
  mov ds, ax

  mov ax, 0x9000
  mov ss, ax
  mov sp, 0xffff
  mov bp, sp

  mov ax, 0x2000
  mov es, ax

  sti ; Disable maskable interrupts during the time of initialization.

; ======================================================
; -------------------- StartKernel ---------------------
; ======================================================
StartKernel:
  mov si, welcomeMessage
  call PrintStringNL

  hlt

; ======================================================
; --------------------- Externals ----------------------
; ======================================================
%include "screen.asm"
