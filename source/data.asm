%ifndef DATA_INCLUDED
%define DATA_INCLUDED 1

%include "constants.asm"

string_bootingMessage: db "Booting into kernel...", 0
string_welcomeMessage: db "Welcome to TemuOS!", 0
string_exitMessage: db "TemuOS is da best.", 0

buffer_line: times BUFFER_LINE_SIZE db 0

%endif

