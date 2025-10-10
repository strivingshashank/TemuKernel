%ifndef MEMORY_INCLUDED
%define MEMORY_INCLUDED 1

%include "constants.asm"
%include "utilities.asm"

; ======================================== Wrappers ========================================
; -----------------------------------------------------------------------------
; Macro:        SET_EXTRA_SEGMENT
; -----------------------------------------------------------------------------
; Purpose:      Set ES = passed segment address
; Inputs:       %1 - segment address to set ES
; Outputs:      -
; Clobbers:     ES, AX (in-macro)
; Notes:        -
; Usage Example: 
;               SET_EXTRA_SEGMENT HEAP_SEGMENT  ; ES = HEAP_SEGMENT
; -----------------------------------------------------------------------------
%macro SET_EXTRA_SEGMENT 1
    push ax

    mov ax, %1
    mov es, ax

    pop ax
%endmacro

; -----------------------------------------------------------------------------
; Macro:        RESET_EXTRA_SEGMENT
; -----------------------------------------------------------------------------
; Purpose:      Reset ES back to EXTRA_SEGMENT
; Inputs:       -
; Outputs:      -
; Clobbers:     ES, AX (in-macro)
; Notes:        -
; Usage Example: 
;               RESET_EXTRA_SEGMENT
; -----------------------------------------------------------------------------
%macro RESET_EXTRA_SEGMENT 0
    push ax

    mov ax, EXTRA_SEGMENT
    mov es, ax

    pop ax
%endmacro

; -----------------------------------------------------------------------------
; Macro:        ALLOCATE_MEMORY
; -----------------------------------------------------------------------------
; Purpose:      Allocate memory from HEAP_SEGMENT
; Inputs:       %1 - number of bytes to allocate (16-bit)
; Outputs:      AX - status flag (1 = success, 0 = failure)
;               DI - offset of allocated memory (if success)
; Clobbers:     BX, ES (temporarily), AX, DI
; Notes:        Wraps _allocateMemory
; Usage Example: 
;               ALLOCATE_MEMORY 34        ; request 34 bytes from heap
; -----------------------------------------------------------------------------
%macro ALLOCATE_MEMORY 1
    mov ax, %1
    call _allocateMemory
%endmacro

; -----------------------------------------------------------------------------
; Macro:        READ_HEAP
; -----------------------------------------------------------------------------
; Purpose:      Read value (16-bit) at an offset in HEAP_SEGMENT
; Inputs:       %1 - offset to read from in HEAP_SEGMENT
; Outputs:      AX - value at offset
; Clobbers:     ES (temporarily), DI (in-macro), AX
; Notes:        Wraps _readHeap
; Usage Example: 
;               READ_HEAP 0x31fc            ; Read address 0x31fc from HEAP_SEGMENT
;               READ_HEAP bx                ; Read address pointed by BX
;               READ_HEAP word [.labelName] ; Read address pointed by [.labelName]
; -----------------------------------------------------------------------------
%macro READ_HEAP 1
    push di

    mov di, %1
    call _readHeap

    pop di
%endmacro

; -----------------------------------------------------------------------------
; Macro:        WRITE_HEAP
; -----------------------------------------------------------------------------
; Purpose:      Write in HEAP_SEGMENT
; Inputs:       %1 - offset to write to in HEAP_SEGMENT
;               %2 - value to write
; Outputs:      -
; Clobbers:     ES (temporarily), AX, DI (in-macro)
; Notes:        Wraps _writeHeap
; Usage Example: 
;               WRITE_HEAP 0x31fc 43   ; Read address 0x31fc from HEAP_SEGMENT
; -----------------------------------------------------------------------------
%macro WRITE_HEAP 2
    push ax
    push di

    mov di, %1
    mov ax, %2
    call _writeHeap

    pop di
    pop ax
%endmacro

; ======================================== Routines ========================================
; --------------------------------------------------------------------------------
; Routine:      _allocateMemory
; --------------------------------------------------------------------------------
; Purpose:      Allocate memory from HEAP_SEGMENT
; Inputs:       AX - number of bytes
; Outputs:      AX - status flag (1 = success, 0 = failure)
;               DI - offset of allocated memory (if success)
; Clobbers:     BX, ES (temporarily), AX, DI
; Notes:        Wrapped by ALLOCATE_MEMORY
; --------------------------------------------------------------------------------
_allocateMemory:
    push bx
    SET_EXTRA_SEGMENT HEAP_SEGMENT

    ; Subtract current heap pointer (which represents memory used) from total memory.
    mov bx, MAX_SEGMENT_SIZE
    sub bx, word [.heapPointer]
    ; Update .availableMemory
    mov word [.availableMemory], bx

    ; Handle no available memory
    cmp word [.availableMemory], ax
    jb .notSufficientMemory

    jmp .allocateMemory
    
.return:
    RESET_EXTRA_SEGMENT
    pop bx
    ret

.notSufficientMemory:
    mov ax, 0 ; Flagging status of request (failure)
    jmp .return

.allocateMemory:
    mov di, word [.heapPointer]
    add word [.heapPointer], ax
    sub word [.availableMemory], ax
    mov ax, 1 ; Flagging status of request (success)
    jmp .return

.heapPointer: dw 0 ; 16-bit heap offset
.availableMemory: dw 0

; --------------------------------------------------------------------------------
; Routine:      _readHeap
; --------------------------------------------------------------------------------
; Purpose:      Read value (16-bit) at an offset in HEAP_SEGMENT
; Inputs:       DI - offset to read from
; Outputs:      AX - value at the offset
; Clobbers:     ES (temporarily)
; Notes:        Wrapped by READ_HEAP
; --------------------------------------------------------------------------------
_readHeap:
    SET_EXTRA_SEGMENT HEAP_SEGMENT

    mov ax, word [di]

    RESET_EXTRA_SEGMENT    
    ret

; -----------------------------------------------------------------------------
; Routine:        _writeHeap
; -----------------------------------------------------------------------------
; Purpose:      Write in HEAP_SEGMENT
; Inputs:       DI - offset to write to in HEAP_SEGMENT
;               AX - value to write
; Outputs:      -
; Clobbers:     ES (temporarily)
; Notes:        Wrapped by WRITE_HEAP
; -----------------------------------------------------------------------------
_writeHeap:
    SET_EXTRA_SEGMENT HEAP_SEGMENT

    mov [di], ax

    RESET_EXTRA_SEGMENT
    ret

%endif

