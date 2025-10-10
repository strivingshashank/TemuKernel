%ifndef UTILITIES_INCLUDED
%define UTILITIES_INCLUDED 1

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