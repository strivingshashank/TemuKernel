[bits 16]

BUFFER_SIZE equ 80

section .data 
; ------------------ SECTION .DATA -------------------
bootingMessage: db "Booting into kernel...", 0
welcomeMessage: db "Welcome to TemuOS!", 0
exitMessage: db "TemuOS is da best.", 0

testString: db "shashank", 0
notEqualMessage: db "Strings are not equal.", 0

section .bss
; ------------------ SECTION .BSS -------------------
lineBuffer: resb BUFFER_SIZE

