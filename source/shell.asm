%ifndef SHELL_INCLUDED
%define SHELL_INCLUDED 1

%include "io.asm"
%include "data.asm"
%include "utilities.asm"

Shell:
<<<<<<< Updated upstream
.readCommand:
  PRINT_STRING_BUFFER .string_shellPrompt

  SCAN_STRING_BUFFER buffer_line

  ; Needs working here
  
  COMPARE_STRING_BUFFERS buffer_line, .string_commandExit  
  cmp ax, 0x01
  je .exit

  COMPARE_STRING_BUFFERS buffer_line, .string_commandClear
  cmp ax, 0x01
  je .clear

  jmp .commandNotFound

.return:
  ret

.exit:
  PRINT_STRING_BUFFER .string_messageExit
  PRINT_NEWLINE
  jmp .return

.clear:
  CLEAR_SCREEN
  jmp .readCommand

.commandNotFound:
  PRINT_STRING_BUFFER .string_messageCommandNotFound
  PRINT_STRING_BUFFER buffer_line
  PRINT_NEWLINE
  jmp .readCommand
=======
; .readCommand
; .processCommand
; jmp .readCommand

.readCommand:
    PRINT_STRING_BUFFER .string_shellPrompt
    SCAN_STRING_BUFFER buffer_line
    ; Needs working here

.processCommand:
    ; Command: exit
    COMPARE_STRING_BUFFERS buffer_line, .string_commandExit    
    cmp ax, 0x01
    je .command_exit

    ; Command: clear
    COMPARE_STRING_BUFFERS buffer_line, .string_commandClear
    cmp ax, 0x01
    je .command_clear

    ; Command: -
    jmp .command_notFound

.return:
    pop ax
    ret

.command_exit:
    PRINT_STRING_BUFFER .string_messageExit
    PRINT_NEWLINE
    jmp .return

.command_clear:
    CLEAR_SCREEN
    jmp .readCommand

.command_notFound:
    PRINT_STRING_BUFFER .string_messageCommandNotFound
    PRINT_STRING_BUFFER buffer_line
    PRINT_NEWLINE
    jmp .readCommand
>>>>>>> Stashed changes

.string_shellPrompt: db "temu > ", 0
.string_commandClear: db "clear", 0
.string_commandExit: db "exit", 0
.string_messageExit: db "Tata, see ya!", 0
.string_messageCommandNotFound: db "No command: ", 0

%endif