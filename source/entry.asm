[bits 16]
[org 0x0000]

jmp SegmentInitialization

%include "temu.asm"

; ======================================== Segments Initialization ========================================
SegmentInitialization:
    cli ; Disable maskable interrupts so that stack initializes without interruption. Although, this is not needed for such a small project but this is considered a good practice.

    ; -------------------- Initialize Data Segment (DS) --------------------
    ; To be 0 for correct offsetting from the origin.
    mov ax, cs
    ; mov ax, CODE_DATA_SEGMENT
    mov ds, ax
    mov es, ax
    mov si, 0x00
    mov di, 0x00
    ; -------------------- Initialize Stack Segment (SS) -------------------- 
    mov ax, STACK_SEGMENT
    mov ss, ax ; SS initialized at 0x9000
    mov sp, MAX_SEGMENT_SIZE ; With a size of 0xffff (65535)10
    mov bp, sp ; Points BP to SP, not needed for now though.
    nop ; Gives CPU another free cycle to adjust the hidden SS register. (Uff, so much going on...)

    sti ; Re-enable maskable interrupts.

; ======================================== Entry ========================================
Entry:
    call Temu
    HANG
    
