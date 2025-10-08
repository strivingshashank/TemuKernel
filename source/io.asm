%ifndef IO_INCLUDED
%define IO_INCLUDED 1

%include "constants.asm"

; ======================================== Wrappers ========================================
%macro CLEAR_SCREEN 0
  call _clearScreen
%endmacro

%macro SCAN_CHARACTER 0
  call _scanCharacter
%endmacro

; IN: Destination string buffer
%macro SCAN_STRING_BUFFER 1 ; Needs handling 
  push di

  %ifidni %1, di
    call _scanStringBuffer
  %else
    mov di, %1
    call _scanStringBuffer
  %endif

  pop di
%endmacro

; IN: Character / Register (with character)
%macro PRINT_CHARACTER 1
  %ifidni %1, al ; Check if the passes argument is AL (case-insensitive).
    call _printCharacter
  %else
    push ax
    mov al, %1
    call _printCharacter
    pop ax
  %endif
%endmacro

; IN: Source string buffer
%macro PRINT_STRING_BUFFER 1
  push si

  %ifidni %1, si
    call _printStringBuffer
  %else
    mov si, %1
    call _printStringBuffer
  %endif
  
  pop si
%endmacro

%macro PRINT_NEWLINE 0
  call _printNewline
%endmacro

; IN: Hex value / Register (with hex value)
%macro PRINT_HEX 1
  push dx
  mov dx, 0x00 ; Helps if the input register is 8-bit
  mov dx, %1
  call _printHex
  pop dx
%endmacro

; ======================================== Routines ========================================
; ---------------------------------------- _clearScreen ------------------------------------------
; Before Call:
;   - NOTHING
; After Call:
;   - Cleared screen with cursor at top
_clearScreen:
  push ax
  mov ah, 0x00 ; Set video mode function.
  mov al, 0x03 ; Sets 80*25 2-color mode.
  int 0x10 ; Video interrupt from BIOS.
  pop ax
  ret

_scanCharacter:
  ; AL = Character read
  mov ah, 0x00 ; Function - Read character (Blocking)
  int 0x16 ; BIOS Interrupt - Keyboard
  ret

; ---------------------------------------- _scanStringBuffer ----------------------------------------
; Before Call:
;   - NOTHING
; After Call:
;   - Read character from keyboard buffer (blocking) and store in the buffer_line also, write on the screen.
_scanStringBuffer:
  push ax
  push dx
  push si
  push di

.scanLoop:
  SCAN_CHARACTER ; Wait until a character is entered.

  cmp al, 0x00 ; Is Extened key code?
  jne .scanASCII

  PRINT_STRING_BUFFER .extenedCodeMessage

  PRINT_HEX ax
  PRINT_NEWLINE

  jmp .scanLoop
  
.return:
  pop di
  pop si
  pop dx
  pop ax
  ret

.scanASCII:
  cmp al, CARRIAGE_RETURN ; Carriage Return?
  je .scanCarriageReturn

  cmp al, BACKSPACE ; Backspace?
  je .scanBackspace
  
  jmp .scanCharacter

.scanCarriageReturn:
  mov byte [di], 0x00 ; Add a NULL character after Carriage Return.
  mov di, buffer_line ; Reset DI for next input.
  PRINT_NEWLINE
  jmp .return ; Return to caller.

.scanBackspace:
  cmp di, buffer_line ; Is DI pointing at the beginning of buffer_line?
  je .scanLoop ; If yes, don't bother, move ahead with reading.
  
  dec di
  mov byte [di], 0x00

  PRINT_CHARACTER BACKSPACE
  PRINT_CHARACTER ' '
  PRINT_CHARACTER BACKSPACE
  
  jmp .scanLoop

.scanCharacter:
  stosb
  PRINT_CHARACTER al
  jmp .scanLoop

.extenedCodeMessage: db "Extended Code: ", 0

; ---------------------------------------- _printCharacter ----------------------------------------
; Before Call:
;   - AL = Character to be printed
; After Call:
;   - Character printed on screen
_printCharacter:
  ; push ax
  mov ah, 0x0e ; 0x0e value in AH indicates "Write a character".
  int 0x10 ; This calls the Video function interrupt from the BIOS.
  ret

; ---------------------------------------- _printStringBuffer ----------------------------------------
; Before Call:
;   - Set SourceIndex (SI) to point the string to be printed.
; After Call:
;   - String printed on screen
_printStringBuffer:
  push ax

.writeLoop:
  lodsb ; Load from [SourceIndex] to AL.
  cmp al, 0x00 ; Compare for end of string.
  je .return ; Return if string ended.

  cmp al, CARRIAGE_RETURN ; Carriage Return?
  je .printCarriageReturn

  cmp al, BACKSPACE ; Backspace?
  je .printBackspace

  jmp .printCharacter

.printCarriageReturn:
  PRINT_NEWLINE
  jmp .return

.printBackspace:
  ; Write backspace logic here.
  jmp .writeLoop

.printCharacter:
  PRINT_CHARACTER al
  jmp .writeLoop ; Loop until end of string is reached.

.return:
  pop ax
  ret

; ---------------------------------------- _printHex ------------------------------------------------
; Before Call:
;   - Set DX as the hex number to be printed as string 
; After Call:
;   - HEX as string literal printed on screen
_printHex:
  push ax
  push bx

  mov bx, .hexMap ; BX now stores the memory address of hexMap at [0].

  ; Purely for decoration of "0x" before the HEX string.
  PRINT_CHARACTER '0'
  PRINT_CHARACTER 'x'

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
  PRINT_CHARACTER al

  pop ax

  mov ah, al
  shl ah, 4 ; This shifting discards the higher nibble and shift the lower nibble in place of higher nibble.
  shr ah, 4 ; Shift the new higher nibble (ex-lower nibble) as new lower nibble.

  mov al, ah
  xlat ; AL = [BX + AL]. Move ahead AH times from the address pointed by BX. This gives us the respective character pointed.
  PRINT_CHARACTER al

  ret

.hexMap: db "0123456789abcdef" ; This maps the hex values of their respective character in the memory.

; -------------------------------------- _printNewline --------------------------------------
; Before Call:
;   - NOTHING
; After Call:
;   - Newline printed on screen
_printNewline:
  PRINT_CHARACTER LINE_FEED
  PRINT_CHARACTER CARRIAGE_RETURN
  ret

%endif