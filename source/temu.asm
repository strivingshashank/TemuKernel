[bits 16]

<<<<<<< Updated upstream
%include "shell.asm"
%include "io.asm"
%include "data.asm"

Temu:
  CLEAR_SCREEN

  PRINT_STRING_BUFFER string_welcomeMessage
  PRINT_NEWLINE

  call Shell
  
  ret
=======
%include "constants.asm"
%include "shell.asm"
%include "io.asm"
%include "data.asm"
%include "memory.asm"

Temu:
    CLEAR_SCREEN

    PRINT_STRING_BUFFER string_welcomeMessage
    PRINT_NEWLINE

    call Shell
    
    ret
>>>>>>> Stashed changes

