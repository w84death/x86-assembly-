#!/bin/bash

# Check if an argument is provided
if [ $# -eq 0 ]; then
    echo "Usage: $0 <filename_without_extension>"
    exit 1
fi

# Assign the argument to a variable
filename=$1

# Assemble the .asm file to .bin using NASM
nasm -f bin "${filename}.asm" -o "${filename}.bin"

# Check if NASM succeeded
if [ $? -ne 0 ]; then
    echo "Assembly failed."
    exit 1
fi

# Run the resulting .bin file using QEMU
qemu-system-i386 -drive format=raw,file="${filename}.bin"

# Check if QEMU exited successfully
if [ $? -ne 0 ]; then
    echo "QEMU execution failed."
    exit 1
fi


# To make a floppy just use this:
# dd if=game.bin of=floppy.img bs=512 count=1 conv=notrunc
# then burn the floppy (im using Windows PC for that...)