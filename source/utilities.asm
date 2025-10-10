%ifndef UTILITIES_INCLUDED
%define UTILITIES_INCLUDED 1

<<<<<<< Updated upstream
; ======================================== Wrappers ========================================
%macro COMPARE_STRING_BUFFERS 2
  push si
  push di

  mov si, %1
  mov di, %2
  call _compareStrings

  pop di
  pop si
%endmacro

%macro HANG 0
  jmp $
%endmacro

; ======================================== Routines ========================================
; ---------------------------------------- _compareStrings ------------------------------------------
; Before Call:
;   - SI = &string1
;   - DI = &string2
; After Call:
;   - If strings are equal -> AX = 0x01
;   - If strings are not equal -> AX = 0x00
_compareStrings:
  push bx

.compareLoop:
  mov al, [si]
  mov bl, [di]

  cmp al, bl
  jne .notEqual

  cmp al, 0 ; This checks for both of the strings (since, AL and BL are equal at this point).  
  je .equal

  inc si
  inc di

  jmp .compareLoop

.done:
  pop bx
  ret  

.equal:
  mov ax, 0x01 ; Implies that the strings were equal.
  jmp .done

.notEqual:
  mov ax, 0x00 ; Implies that the strings were not equal.
  jmp .done

%endif
=======
%include "constants.asm"

; ======================================== Wrappers ========================================
; --------------------------------------------------------------------------------
; Macro:      COMPARE_STRING_BUFFERS
; --------------------------------------------------------------------------------
; Purpose:      Compare two strings
; Inputs:       %1 - stringBuffer1
;               %2 - stringBuffer2
; Outputs:      AX - status flag (1 = equal, 0 = not equal)
; Clobbers:     ES, BX, AX, SI, DI(temporarily)
; Notes:        Wraps _compareStrings
; --------------------------------------------------------------------------------
%macro COMPARE_STRING_BUFFERS 2
    push si
    push di

    mov si, %1
    mov di, %2
    call _compareStrings

    pop di
    pop si
%endmacro

%macro HANG 0
    jmp $
%endmacro

; ======================================== Routines ========================================
; --------------------------------------------------------------------------------
; Routine:      _compareStrings
; --------------------------------------------------------------------------------
; Purpose:      Compare two strings
; Inputs:       SI - first string
;               DI - second string
; Outputs:      AX - status flag (1 = equal, 0 = not equal)
; Clobbers:     ES, BX, AX, SI, DI(temporarily)
; Notes:        Used by wrapper COMPARE_STRING_BUFFERS
; --------------------------------------------------------------------------------
_compareStrings:
    push bx
    push si
    push di

.compareLoop:
    mov al, [si]
    mov bl, [di]

    cmp al, bl
    jne .notEqual

    cmp al, 0 ; This checks for both of the strings (since, AL and BL are equal at this point).    
    je .equal

    inc si
    inc di

    jmp .compareLoop

.return:
    pop di
    pop si
    pop bx
    ret    

.equal:
    mov ax, 1 ; Implies that the strings were equal.
    jmp .return

.notEqual:
    mov ax, 0 ; Implies that the strings were not equal.
    jmp .return

%endif

>>>>>>> Stashed changes
