[bits 16]

; ----------------------- MACROS -----------------------
CARRIAGE_RETURN equ 0x0D
BACKSPACE equ 0x08 

; -------------------- ClearScreen ---------------------
; Before Call:
;   - NOTHING
; After Call:
;   - Cleared screen with cursor at top
ClearScreen:
  push ax

  mov ah, 0x00 ; Set video mode function.
  mov al, 0x03 ; Sets 80*25 2-color mode.
  int 0x10 ; Video interrupt from BIOS.

.return:
  pop ax
  ret

; -------------------- ReadLine ------------------------
; Before Call:
;   - NOTHING
; After Call:
;   - Read character from keyboard buffer (blocking) and store in the lineBuffer.
ReadLine:
  push ax
  push dx
  push si
  push di

  mov di, lineBuffer ; Input buffer is ready to be written.

.readLoop:
  mov ah, 0x00 ; Function - Read character (Blocking)
  int 0x16 ; BIOS Interrupt - Keyboard

  cmp al, 0x00 ; Is Extened key code?
  jne .readASCII

  mov si, .extenedCodeMessage
  call WriteString

  mov dx, 0x00
  mov dl, ah
  call WriteHex
  call WriteNewline

  jmp .readLoop
  
.return:
  pop di
  pop si
  pop dx
  pop ax
  ret

.readASCII:
  cmp al, CARRIAGE_RETURN ; Carriage Return?
  je .readCarriageReturn

  cmp al, BACKSPACE ; Backspace?
  je .readBackspace
  
  jmp .readCharacter

.readCarriageReturn:
  mov byte [di], 0x00 ; Add a NULL character after Carriage Return.
  mov di, lineBuffer ; Reset DI for next input.
  jmp .return ; Return to caller.

.readBackspace:
  cmp di, lineBuffer ; Is DI pointing at the beginning of lineBuffer?
  je .readLoop ; If yes, don't bother, move ahead with reading.
  
  dec di
  mov byte [di], 0x00
  jmp .readLoop

.readCharacter:
  stosb
  jmp .readLoop

.extenedCodeMessage: db "Extended Code: ", 0

; ----------------- ReadLineVisual -----------------
; Before Call:
;   - NOTHING
; After Call:
;   - Read character from keyboard buffer (blocking) and store in the lineBuffer also, write on the screen.
ReadLineVisual:
  push ax
  push dx
  push si
  push di

  mov di, lineBuffer ; Input buffer is ready to be written.

.readLoop:
  mov ah, 0x00 ; Function - Read character (Blocking)
  int 0x16 ; BIOS Interrupt - Keyboard

  cmp al, 0x00 ; Is Extened key code?
  jne .readASCII

  mov si, .extenedCodeMessage
  call WriteString

  mov dx, 0x00
  mov dl, ah
  call WriteHex
  call WriteNewline

  jmp .readLoop
  
.return:
  pop di
  pop si
  pop dx
  pop ax
  ret

.readASCII:
  cmp al, CARRIAGE_RETURN ; Carriage Return?
  je .readCarriageReturn

  cmp al, BACKSPACE ; Backspace?
  je .readBackspace
  
  jmp .readCharacter

.readCarriageReturn:
  mov byte [di], 0x00 ; Add a NULL character after Carriage Return.
  mov di, lineBuffer ; Reset DI for next input.
  call WriteNewline
  jmp .return ; Return to caller.

.readBackspace:
  cmp di, lineBuffer ; Is DI pointing at the beginning of lineBuffer?
  je .readLoop ; If yes, don't bother, move ahead with reading.
  
  dec di
  mov byte [di], 0x00

  call WriteCharacter
  call WriteSpace
  call WriteCharacter
  
  jmp .readLoop

.readCharacter:
  stosb
  call WriteCharacter
  jmp .readLoop

.extenedCodeMessage: db "Extended Code: ", 0

; ----------------- WriteCharacter ---------------------
; Before Call:
;   - AL = Character to be printed
; After Call:
;   - Character printed on screen
WriteCharacter:
  push ax

  mov ah, 0x0e ; 0x0e value in AH indicates "Write a character".
  int 0x10 ; This calls the Video function interrupt from the BIOS.

.return:
  pop ax
  ret

; -------------------- WriteSpace ----------------------
; Before Call:
;   - NOTHING
; After Call:
;   - Space (character) printed on screen
WriteSpace:
  push ax

  mov al, ' '
  call WriteCharacter

  pop ax
  ret

; -------------------- WriteString ---------------------
; Before Call:
;   - Set SourceIndex (SI) to point the string to be printed.
; After Call:
;   - String printed on screen
WriteString:
  push ax

.writeLoop:
  lodsb ; Load from [SourceIndex] to AL.
  cmp al, 0x00 ; Compare for end of string.
  je .return ; Return if string ended.

  cmp al, CARRIAGE_RETURN ; Carriage Return?
  je .writeCarriageReturn

  cmp al, BACKSPACE ; Backspace?
  je .writeBackspace

  jmp .writeCharacter

.writeCarriageReturn:
  call WriteNewline
  jmp .return

.writeBackspace:
  ; Write backspace logic here.
  jmp .writeLoop

.writeCharacter:
  call WriteCharacter
  jmp .writeLoop ; Loop until end of string is reached.

.return:
  pop ax
  ret

; ------------------- WriteStringNL --------------------
; Before Call:
;   - Set SourceIndex (SI) to point the string to be printed.
; After Call:
;   - String printed on screen and move the carriage to next line.
WriteStringNL:
  call WriteString
  call WriteNewline

.return:
  ret

; -------------------- WriteHex ------------------------
; Before Call:
;   - Set DX as the hex number to be printed as string 
; After Call:
;   - HEX as string literal printed on screen
WriteHex:
  push ax
  push bx

  mov bx, .hexMap ; BX now stores the memory address of hexMap at [0].

  mov al, '0'
  call WriteCharacter ; Purely for decoration of "0x" before the HEX string.
  mov al, 'x'
  call WriteCharacter

  mov al, dh ; Extract DH from DX to AL.
  call .writeByte

  mov al, dl
  call .writeByte

.return:
  pop bx
  pop ax
  ret
  
.writeByte:
  push ax
  
  mov ah, al ; Copy AL to AH for further operations. (Operations (bit-shifting and indexing) is performed via AH.)
  shr ah, 4 ; Extract the higher nibble of AH by shifting, effectively reducing AH to 0x0_; '_' is a placeholder for previous value.

  mov al, ah
  xlat ; AL = [BX + AL]. Move ahead AH times from the address pointed by BX. This gives us the respective character pointed.
  call WriteCharacter

  pop ax

  mov ah, al
  shl ah, 4 ; This shifting discards the higher nibble and shift the lower nibble in place of higher nibble.
  shr ah, 4 ; Shift the new higher nibble (ex-lower nibble) as new lower nibble.

  mov al, ah
  xlat ; AL = [BX + AL]. Move ahead AH times from the address pointed by BX. This gives us the respective character pointed.
  call WriteCharacter

  ret

.hexMap: db "0123456789abcdef" ; This maps the hex values of their respective character in the memory.


; ------------------- WriteNewline ---------------------
; Before Call:
;   - NOTHING
; After Call:
;   - Newline printed on screen
WriteNewline:
  push ax

  mov al, 0x0a ; ASCII - Line feed
  call WriteCharacter

  mov al, 0x0d ; ASCII - Carriage return
  call WriteCharacter

.return:
  pop ax
  ret

; ------------------- WriteLine ------------------------
; Before Call:
;   - NOTHING
; After Call:
;   - String in lineBuffer is written on screen.
WriteLine:
  push si

  mov si, lineBuffer
  call WriteString
  
.return:
  pop si
  ret

; ------------------- WriteLineNL ------------------------
; Before Call:
;   - NOTHING
; After Call:
;   - String in lineBuffer is written on screen.
WriteLineNL:
  push si

  mov si, lineBuffer
  call WriteStringNL
  
.return:
  pop si
  ret

; -------------------- Externals -----------------------
%include "labels.asm"

