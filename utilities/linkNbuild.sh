#!/bin/bash
set -e  # Exit immediately on error

SRC_DIR="./source"
BIN_DIR="./bin"

mkdir -p "$BIN_DIR"

echo "[1] Assembling bootloader as flat binary..."
nasm -f bin "$SRC_DIR/bootloader.asm" -o "$BIN_DIR/bootloader.bin"

echo "[2] Assembling kernel modules as ELF object files..."
for f in "$SRC_DIR"/*.asm; do
    [[ "$f" == "$SRC_DIR/bootloader.asm" ]] && continue
    base=$(basename "$f" .asm)
    echo "  -> Assembling $base.asm"
    nasm -f elf32 "$f" -o "$BIN_DIR/$base.o"
done

echo "[3] Linking kernel modules into single flat binary..."
# -e Kernel sets entry point to Kernel label in kernel.asm
ld -m elf_i386 -Ttext 0x1000 -o "$BIN_DIR/kernel.bin" "$BIN_DIR"/*.o --oformat binary -e Kernel

echo "[4] Creating floppy image..."
# Blank 1.44MB floppy image
dd if=/dev/zero of="$BIN_DIR/TemuOS.img" bs=512 count=2880 status=none
# Write bootloader (sector 0)
dd if="$BIN_DIR/bootloader.bin" of="$BIN_DIR/TemuOS.img" bs=512 count=1 conv=notrunc status=none
# Write kernel (from sector 1)
dd if="$BIN_DIR/kernel.bin" of="$BIN_DIR/TemuOS.img" bs=512 seek=1 conv=notrunc status=none

echo "[5] Booting with QEMU..."
qemu-system-i386 -drive file="$BIN_DIR/TemuOS.img",format=raw,if=floppy
