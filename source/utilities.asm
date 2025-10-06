[bits 16]

Hang:
  jmp $

CompareStrings:
  ; push ax
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

.return:
  pop bx
  ret  

.equal:
  mov ax, 0x01 ; Implies that the strings were equal.
  jmp .return

.notEqual:
  ; mov si, notEqualMessage
  ; call Wricmpring
  mov ax, 0x00 ; Implies that the strings were not equal.
  jmp .return
