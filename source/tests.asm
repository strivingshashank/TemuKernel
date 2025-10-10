WriteDate:
  push ax
  push si

  mov ah, 0x04
  int 0x1a
  jc .deadClockBattery

  call WriteHex
  jmp .return

.deadClockBattery:
  mov si, .messageDeadClockBattery
  call WriteStringNL 

.return:
  pop si
  pop ax
  ret

.messageDeadClockBattery: db "Dead clock battery.", 0

WriteTime:
  push ax
  push dx

  mov ah, 0x02
  int 0x1a
  jc .deadClockBattery

  push dx

  mov dx, cx
  call WriteHex
  
  pop dx

  call WriteHex

  ; mov al, ch
  ; call WriteCharacter

  ; mov al, ':'
  ; call WriteCharacter

  ; mov al, cl
  ; call WriteCharacter

  ; mov al, ':'
  ; call WriteCharacter

  ; mov al, dh
  ; call WriteCharacter

  ; mov al, ':'
  ; call WriteCharacter

  ; call WriteNewline

  jmp .return

.deadClockBattery:
  mov si, .messageDeadClockBattery
  call WriteStringNL 

.return:
  pop dx
  pop ax
  ret

.messageDeadClockBattery: db "Dead clock battery.", 0

HexToDecimal:
    

.return:
  ret