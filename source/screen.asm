; ======================================================
; ----------------------- LABELS -----------------------
; ======================================================
; Boot labels:
welcomeMessage: db "Welcome to TemuOS!", 0
exitMessage: db "TemuOS is da best.", 0
bootingMessage: db "Booting into kernel...", 0

; HEX_PRINT:
hexMap: db "0123456789abcdef" ; This maps the hex values of their respective character in the memory.

; ======================================================
; -------------------- PrintChar -----------------------
; ======================================================
; Before Call:
;   - AL = Character to be printed
; After Call:
;   - Character printed on screen
PrintChar:
  push ax

  mov ah, 0x0e ; 0x0e value in AH indicates "Write a character".
  int 0x10 ; This calls the Video function interrupt from the BIOS.
  pop ax
  ret

; ======================================================
; -------------------- PrintSpace ----------------------
; ======================================================
; Before Call:
;   - NOTHING
; After Call:
;   - Space (character) printed on screen
PrintSpace:
  push ax

  mov al, ' '
  call PrintChar

  pop ax
  ret

; ======================================================
; -------------------- PrintString ---------------------
; ======================================================
; Before Call:
;   - Set SourceIndex (SI) to point the string to be printed.
; After Call:
;   - String printed on screen
PrintString:
  push ax

.printLoop:
  lodsb ; Load from [SourceIndex] to AL.
  cmp al, 0 ; Compare for end of string.
  je .done ; Return if string ended.

  call PrintChar

  jmp .printLoop ; Loop until end of string is reached.

.done:
  pop ax
  ret

; ======================================================
; ------------------- PrintStringNL --------------------
; ======================================================
; Before Call:
;   - Set SourceIndex (SI) to point the string to be printed.
; After Call:
;   - String printed on screen and move the carriage to next line.
PrintStringNL:
  call PrintString
  call PrintNewline

  ret

; ======================================================
; -------------------- PrintHex ------------------------
; ======================================================
; Before Call:
;   - Set DX as the hex number to be printed as string 
; After Call:
;   - HEX as string literal printed on screen
PrintHex:
  pusha

  mov bx, hexMap ; BX now stores the memory address of hexMap at [0].

  mov al, '0'
  call PrintChar ; Purely for decoration of "0x" before the HEX string.
  mov al, 'x'
  call PrintChar

  mov al, dh ; Extract DH from DX to AL.
  call .printByte

  mov al, dl
  call .printByte

  popa
  ret
  
.printByte:
  push ax
  
  mov ah, al ; Copy AL to AH for further operations. (Operations (bit-shifting and indexing) is performed via AH.)
  shr ah, 4 ; Extract the higher nibble of AH by shifting, effectively reducing AH to 0x0_; '_' is a placeholder for previous value.

  mov al, ah
  xlat ; AL = [BX + AL]. Move ahead AH times from the address pointed by BX. This gives us the respective character pointed.
  call PrintChar

  pop ax

  mov ah, al
  shl ah, 4 ; This shifting discards the higher nibble and shift the lower nibble in place of higher nibble.
  shr ah, 4 ; Shift the new higher nibble (ex-lower nibble) as new lower nibble.

  mov al, ah
  xlat ; AL = [BX + AL]. Move ahead AH times from the address pointed by BX. This gives us the respective character pointed.
  call PrintChar

  ret

; ======================================================
; -------------------- ClearScreen ---------------------
; ======================================================
; Before Call:
;   - NOTHING
; After Call:
;   - Cleared screen with cursor at top
ClearScreen:
  push ax

  mov ah, 0x00 ; Set video mode function.
  mov al, 0x03 ; Sets 80*25 color mode.

  int 0x10 ; Video interrupt from BIOS.

  pop ax
  ret

; ======================================================
; ------------------- PrintNewline ---------------------
; ======================================================
; Before Call:
;   - NOTHING
; After Call:
;   - Newline printed on screen
PrintNewline:
  push ax

  mov al, 0x0a ; ASCII - Line feed
  call PrintChar

  mov al, 0x0d ; ASCII - Carriage return
  call PrintChar

  pop ax
  ret