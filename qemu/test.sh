#!/bin/bash

# Check if a filename argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <filename (without extension)>"
    exit 1
fi

# Define variables based on user input
BASE_NAME="$1"   # User-provided filename (without extension)
ASM_FILE="${BASE_NAME}.s"  # Assembly source file
OBJ_FILE="${BASE_NAME}.o"  # Object file
BIN_FILE="${BASE_NAME}"    # Final executable file
GDB_PORT=1234              # QEMU GDB debugging port

# 1. Assemble the source file
echo "Assembling $ASM_FILE..."
riscv64-linux-gnu-as -g -o $OBJ_FILE $ASM_FILE
if [ $? -ne 0 ]; then
    echo "Error: Assembly failed!"
    exit 1
fi

# 2. Link the object file
echo "Linking $OBJ_FILE..."
riscv64-linux-gnu-ld -g -o $BIN_FILE $OBJ_FILE
if [ $? -ne 0 ]; then
    echo "Error: Linking failed!"
    exit 1
fi

riscv64-unknown-elf-objdump -d test | awk '{print $2}' > test.hex
# 3. Run the executable in QEMU with GDB debugging enabled
echo "Running $BIN_FILE with QEMU (GDB on port $GDB_PORT)..."
qemu-riscv64 -g $GDB_PORT ./$BIN_FILE


