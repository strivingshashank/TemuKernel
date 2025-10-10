%ifndef IO_INCLUDED
%define IO_INCLUDED 1

%include "constants.asm"

; ======================================== Wrappers ========================================

; --------------------------------------------------------------------------------
; Macro:      CLEAR_SCREEN
; --------------------------------------------------------------------------------
; Purpose:      Clear the screen and set cursor to top-left
; Inputs:       None
; Outputs:      None
; Clobbers:     AX (temporarily)
; Notes:        Wraps _clearScreen
; Usage Example: CLEAR_SCREEN
; --------------------------------------------------------------------------------
%macro CLEAR_SCREEN 0
    call _clearScreen
%endmacro

; --------------------------------------------------------------------------------
; Macro:      SCAN_CHARACTER
; --------------------------------------------------------------------------------
; Purpose:      Read a single character from keyboard (blocking)
; Inputs:       None
; Outputs:      AL - character read
; Clobbers:     AH (temporarily)
; Notes:        Wraps _scanCharacter
; Usage Example: SCAN_CHARACTER
; --------------------------------------------------------------------------------
%macro SCAN_CHARACTER 0
    call _scanCharacter
%endmacro

; --------------------------------------------------------------------------------
; Macro:      SCAN_STRING_BUFFER
; --------------------------------------------------------------------------------
; Purpose:      Read a string from keyboard into buffer
; Inputs:       %1 - Destination string buffer
; Outputs:      DI - offset into buffer updated during read
; Clobbers:     DI (temporarily), AX, DX, SI (used internally)
; Notes:        Wraps _scanStringBuffer
; Usage Example: SCAN_STRING_BUFFER buffer_line
; --------------------------------------------------------------------------------
%macro SCAN_STRING_BUFFER 1
    push di

    %ifidni %1, di
        call _scanStringBuffer
    %else
        mov di, %1
        call _scanStringBuffer
    %endif

    pop di
%endmacro

; --------------------------------------------------------------------------------
; Macro:      PRINT_CHARACTER
; --------------------------------------------------------------------------------
; Purpose:      Print a single character to the screen
; Inputs:       %1 - Character or register containing character
; Outputs:      Character printed
; Clobbers:     AL, AH (temporarily), AX (if pushed)
; Notes:        Wraps _printCharacter
; Usage Example: PRINT_CHARACTER 'A'
; --------------------------------------------------------------------------------
%macro PRINT_CHARACTER 1
    %ifidni %1, al
        call _printCharacter
    %else
        push ax
        
        mov al, %1
        call _printCharacter

        pop ax
    %endif
%endmacro

; --------------------------------------------------------------------------------
; Macro:      PRINT_STRING_BUFFER
; --------------------------------------------------------------------------------
; Purpose:      Print null-terminated string from memory to screen
; Inputs:       %1 - Source string buffer
; Outputs:      String printed
; Clobbers:     SI, AX (temporarily)
; Notes:        Wraps _printStringBuffer
; Usage Example: PRINT_STRING_BUFFER buffer_line
; --------------------------------------------------------------------------------
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

; --------------------------------------------------------------------------------
; Macro:      PRINT_NEWLINE
; --------------------------------------------------------------------------------
; Purpose:      Print a newline (CR + LF)
; Inputs:       None
; Outputs:      Newline printed
; Clobbers:     AL (temporarily)
; Notes:        Wraps _printNewline
; Usage Example: PRINT_NEWLINE
; --------------------------------------------------------------------------------
%macro PRINT_NEWLINE 0
    call _printNewline
%endmacro

; --------------------------------------------------------------------------------
; Macro:      PRINT_HEX
; --------------------------------------------------------------------------------
; Purpose:      Print a 16-bit hex value as string
; Inputs:       %1 - Hex value (register or immediate)
; Outputs:      Hex printed on screen
; Clobbers:     AX, DX, BX (temporarily)
; Notes:        Wraps _printHex
; Usage Example: PRINT_HEX AX
; --------------------------------------------------------------------------------
%macro PRINT_HEX 1
    push dx
    
    mov dx, %1
    call _printHex
    
    pop dx
%endmacro

; ======================================== Routines ========================================

; --------------------------------------------------------------------------------
; Routine:      _clearScreen
; --------------------------------------------------------------------------------
; Purpose:      Clear the screen and reset cursor to top-left
; Inputs:       None
; Outputs:      Screen cleared
; Clobbers:     AX (temporarily)
; Notes:        Uses BIOS video interrupt
; --------------------------------------------------------------------------------
_clearScreen:
    push ax
    
    mov ah, 0x00
    mov al, 0x03
    int 0x10
    
    pop ax
    ret

; --------------------------------------------------------------------------------
; Routine:      _scanCharacter
; --------------------------------------------------------------------------------
; Purpose:      Read a single character from keyboard (blocking)
; Inputs:       None
; Outputs:      AL - character read
; Clobbers:     AH (temporarily)
; Notes:        Uses BIOS keyboard interrupt
; --------------------------------------------------------------------------------
_scanCharacter:
    mov ah, 0x00
    int 0x16
    ret

; --------------------------------------------------------------------------------
; Routine:      _scanStringBuffer
; --------------------------------------------------------------------------------
; Purpose:      Read string from keyboard, handle CR/Backspace, and echo characters
; Inputs:       DI - destination buffer offset
; Outputs:      DI - updated buffer offset
; Clobbers:     AX, DX, SI, DI (temporarily)
; Notes:        Reads characters until carriage return; echoes input
; --------------------------------------------------------------------------------
_scanStringBuffer:
    push ax
    push dx
    push si
    push di

.scanLoop:
    SCAN_CHARACTER

    cmp al, 0
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
    cmp al, CARRIAGE_RETURN
    je .scanCarriageReturn

    cmp al, BACKSPACE
    je .scanBackspace
    
    jmp .scanCharacter

.scanCarriageReturn:
    mov byte [di], 0
    mov di, buffer_line
    
    PRINT_NEWLINE
    
    jmp .return

.scanBackspace:
    cmp di, buffer_line
    je .scanLoop
    
    dec di
    mov byte [di], 0
    
    PRINT_CHARACTER BACKSPACE
    PRINT_CHARACTER ' '
    PRINT_CHARACTER BACKSPACE
    
    jmp .scanLoop

.scanCharacter:
    stosb
    PRINT_CHARACTER al
    
    jmp .scanLoop

.extenedCodeMessage: db "Extended Code: ", 0

; --------------------------------------------------------------------------------
; Routine:      _printCharacter
; --------------------------------------------------------------------------------
; Purpose:      Print single character in AL to screen
; Inputs:       AL - character
; Outputs:      Character displayed
; Clobbers:     AH (temporarily)
; Notes:        Uses BIOS video interrupt
; --------------------------------------------------------------------------------
_printCharacter:
    mov ah, 0x0e
    int 0x10
    ret

; --------------------------------------------------------------------------------
; Routine:      _printStringBuffer
; --------------------------------------------------------------------------------
; Purpose:      Print null-terminated string starting at SI
; Inputs:       SI - source string offset
; Outputs:      String displayed
; Clobbers:     AX (temporarily)
; Notes:        Handles CR and Backspace characters
; --------------------------------------------------------------------------------
_printStringBuffer:
    push ax

.writeLoop:
    lodsb
    cmp al, 0
    je .return

    cmp al, CARRIAGE_RETURN
    je .printCarriageReturn

    cmp al, BACKSPACE
    je .printBackspace

    jmp .printCharacter

.printCarriageReturn:
    PRINT_NEWLINE
    jmp .return

.printBackspace:
    ; Write backspace logic here
    jmp .writeLoop

.printCharacter:
    PRINT_CHARACTER al
    jmp .writeLoop

.return:
    pop ax
    ret

; --------------------------------------------------------------------------------
; Routine:      _printHex
; --------------------------------------------------------------------------------
; Purpose:      Print 16-bit value in DX as hex
; Inputs:       DX - value to print
; Outputs:      Hex characters displayed
; Clobbers:     AX, BX (temporarily)
; Notes:        Prepends "0x" and converts nibbles to characters
; --------------------------------------------------------------------------------
_printHex:
    push ax
    push bx

    mov bx, .hexMap

    PRINT_CHARACTER '0'
    PRINT_CHARACTER 'x'

    mov al, dh
    call .writeByte

    mov al, dl
    call .writeByte

.return:
    pop bx
    pop ax
    ret
    
.writeByte:
    push ax
    mov ah, al
    shr ah, 4
    mov al, ah
    xlat
    
    PRINT_CHARACTER al

    pop ax
    mov ah, al
    shl ah, 4
    shr ah, 4
    mov al, ah
    xlat
    
    PRINT_CHARACTER al
    ret

.hexMap: db "0123456789abcdef"

; --------------------------------------------------------------------------------
; Routine:      _printNewline
; --------------------------------------------------------------------------------
; Purpose:      Print newline (LF + CR)
; Inputs:       None
; Outputs:      Newline displayed
; Clobbers:     AL (temporarily)
; Notes:        Wraps PRINT_CHARACTER
; --------------------------------------------------------------------------------
_printNewline:
    PRINT_CHARACTER LINE_FEED
    PRINT_CHARACTER CARRIAGE_RETURN
    ret

%endif
