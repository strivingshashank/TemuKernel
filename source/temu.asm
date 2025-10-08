[bits 16]

%include "shell.asm"
%include "io.asm"
%include "data.asm"

Temu:
  CLEAR_SCREEN

  PRINT_STRING_BUFFER string_welcomeMessage
  PRINT_NEWLINE

  call Shell
  
  ret

