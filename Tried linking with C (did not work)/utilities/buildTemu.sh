#!/bin/bash
set -e

# Directories
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$SCRIPT_DIR/.."

SRC_DIR="$PROJECT_ROOT/source"
BIN_DIR="$PROJECT_ROOT/bin"

mkdir -p "$BIN_DIR"

# Source files
BOOTLOADER="$SRC_DIR/bootloader.asm"
KERNEL_C="$SRC_DIR/kernel.c"

# Output files
BOOT_BIN="$BIN_DIR/bootloader.bin"
KERNEL_BIN="$BIN_DIR/kernel.bin"
IMAGE="$BIN_DIR/TemuOS.img"

# 1️⃣ Assemble bootloader as flat binary
nasm -f bin "$BOOTLOADER" -o "$BOOT_BIN"

# 2️⃣ Assemble all other .asm files in source as ELF32 object files
ASM_OBJECTS=()
for asmfile in "$SRC_DIR"/*.asm; do
    if [[ "$asmfile" != "$BOOTLOADER" ]]; then
        objfile="$BIN_DIR/$(basename "${asmfile%.asm}.o")"
        nasm -f elf32 "$asmfile" -o "$objfile"
        ASM_OBJECTS+=("$objfile")
    fi
done

# 3️⃣ Compile kernel.c as 32-bit code
# gcc -m16 -fno-pic -ffreestanding -c "$KERNEL_C" -o "$BIN_DIR/kernel.o"
gcc -m16 -ffreestanding -fno-pic -fno-omit-frame-pointer -mpreferred-stack-boundary=2 -c "$KERNEL_C" -o bin/kernel.o
# gcc -m32 -ffreestanding -c "$KERNEL_C" -o "$BIN_DIR/kernel.o"

# 4️⃣ Link kernel.o and all ASM objects into a flat binary for kernel
# ld -m elf_i386 -Ttext 0x0000 -o "$KERNEL_BIN" "$BIN_DIR/kernel.o" "${ASM_OBJECTS[@]}" --oformat binary
ld -m elf_i386 -Ttext 0x0000 -o "$KERNEL_BIN" "$BIN_DIR/kernel.o" "${ASM_OBJECTS[@]}" --oformat binary -e Kernel
# ld -m elf_i386 -Ttext 0x0000 -o "$KERNEL_BIN" bin/kernel.o bin/startKernel.o bin/io.o --oformat binary

# 5️⃣ Create blank 1.44MB floppy image
dd if=/dev/zero of="$IMAGE" bs=512 count=2880 status=none

# 6️⃣ Write bootloader into sector 0
dd if="$BOOT_BIN" of="$IMAGE" bs=512 count=1 conv=notrunc

# 7️⃣ Append kernel starting from sector 1
dd if="$KERNEL_BIN" of="$IMAGE" bs=512 seek=1 conv=notrunc

# 8️⃣ Boot with QEMU
qemu-system-i386 -drive file="$IMAGE",format=raw,if=floppy
