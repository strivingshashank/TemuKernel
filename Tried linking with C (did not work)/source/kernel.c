static inline void ClearScreen(void) {
  asm volatile(
    ".code16gcc\n\t"
    "mov $0x00, %%ah\n\t"
    "mov $0x03, %%al\n\t"
    "int $0x10\n\t"
    ".code32"
    :
    :
    : "ax"
  );
}

static inline void WriteCharacter(char character) {
  asm volatile(
    ".code16gcc\n\t"
    "mov $0x0e, %%ah\n\t"
    "mov %0, %%al\n\t"
    "int $0x10\n\t"
    ".code32"
    :
    : "r"(character)
    : "ax"
  );
}

// extern void ClearScreen(void);
// extern void WriteCharacter(char character);

void KernelMain(void) {
  ClearScreen();
  WriteCharacter('D');
  // WriteCharacter('D');
  // WriteCharacter('D');
  // WriteCharacter('D');

  while (1);
}
