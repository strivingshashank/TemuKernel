/* ======================================================
   Simple linker script for TemuOS
   ====================================================== */

OUTPUT_FORMAT("binary")
ENTRY(InitializeBootloader)           /* Entry point of the bootloader */

/* ======================================================
   Sections layout
   ====================================================== */
SECTIONS
{
    /* Start at boot sector address (BIOS loads bootloader here) */
    . = 0x7C00;

    /* Bootloader code section */
    .boot :
    {
        *(.boot)        /* All code marked .boot in NASM */
    }

    /* Kernel code section */
    .text :
    {
        *(.text)        /* Normal kernel code */
    }

    /* Initialized data */
    .data :
    {
        *(.data)
    }

    /* Uninitialized data */
    .bss :
    {
        *(.bss)
        *(COMMON)       /* Include common / uninitialized symbols */
    }
}
