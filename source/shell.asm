Shell:
  push si
  push di

.readCommand:
  mov si, .shellPrompt
  call WriteString

  call ReadLineVisual
  mov si, lineBuffer
      
  mov di, .commandExit
  call CompareStrings
  cmp ax, 0x01
  je .exit

  mov di, .commandClear
  call CompareStrings
  cmp ax, 0x01
  je .clear

  jmp .commandNotFound

.return:
  pop di
  pop si
  ret

.exit:
  ; Exit logic
  mov si, .messageExit
  call WriteStringNL  
  jmp .return

.clear:
  ; Clear logic
  call ClearScreen
  jmp .readCommand

; .echo:
  ; Echo logic

.commandNotFound:
  mov si, .messageCommandNotFound
  call WriteString
  call WriteLineNL
  jmp .readCommand

.shellPrompt: db "temu > ", 0
.commandClear: db "clear", 0
.commandExit: db "exit", 0
; .commandEcho: db "echo", 0
.messageExit: db "Tata, see ya!", 0
.messageCommandNotFound: db "No command: ", 0
.characterQuestionMark: db "?", 0