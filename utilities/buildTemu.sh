#!/bin/bash
set -e  # exit immediately on error

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJECT_ROOT="$SCRIPT_DIR/.."

BIN_DIR="$PROJECT_ROOT/bin"
SRC_DIR="$PROJECT_ROOT/source"

BOOT_BIN="$BIN_DIR/bootloader.bin"
KERNEL_BIN="$BIN_DIR/kernel.bin"
TEMU_IMG="$BIN_DIR/TemuOS.img"

# Ensure bin/ exists
mkdir -p "$BIN_DIR"

echo "[1] Assembling bootloader..."
nasm -f bin "$SRC_DIR/bootloader.asm" -o "$BOOT_BIN" -I"$SRC_DIR/"

echo "[1.5] Assembling kernel..."
nasm -f bin "$SRC_DIR/kernel.asm" -o "$KERNEL_BIN" -I"$SRC_DIR/"

echo "[2] Creating floppy image..."
# Create a blank 1.44MB floppy image
dd if=/dev/zero of="$TEMU_IMG" bs=512 count=2880 status=none

# Write bootloader into sector 0
dd if="$BIN_DIR/bootloader.bin" of="$TEMU_IMG" bs=512 count=1 conv=notrunc status=none

# Append kernel right after it (starting from sector 1)
dd if="$BIN_DIR/kernel.bin" of="$TEMU_IMG" bs=512 seek=1 conv=notrunc

echo "[3] Booting with QEMU..."
# qemu-system-i386 -fda "$TEMU_IMG", -drive format=raw
qemu-system-i386 -drive file="$TEMU_IMG",format=raw,if=floppy

