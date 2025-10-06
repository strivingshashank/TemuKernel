global WriteCharacter
global ClearScreen

WriteCharacter:
  push bp
  
  mov bp, sp
  mov al, [bp+4]

  mov ah, 0x0e ; 0x0e value in AH indicates "Write a character".
  int 0x10 ; This calls the Video function interrupt from the BIOS.

.return:
  pop bp
	ret
	
ClearScreen:
  mov ah, 0x00 ; Set video mode function.
  mov al, 0x03 ; Sets 80*25 2-color mode.
  int 0x10 ; Video interrupt from BIOS.

.return:
  ret
