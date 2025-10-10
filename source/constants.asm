%ifndef CONSTANTS_INCLUDED
%define CONSTANTS_INCLUDED 1

; -------------------- Memory Constants --------------------
MAX_SEGMENT_SIZE equ 0xffff
CODE_DATA_SEGMENT equ 0x07e0
; EXTRA_SEGMENT equ 0x07e0
EXTRA_SEGMENT equ CODE_DATA_SEGMENT
HEAP_SEGMENT equ 0x27e0
STACK_SEGMENT equ 0x37e0

BUFFER_LINE_SIZE equ 80

; -------------------- Data Constants --------------------
LINE_FEED equ 0x0a
CARRIAGE_RETURN equ 0x0D
BACKSPACE equ 0x08 

%endif