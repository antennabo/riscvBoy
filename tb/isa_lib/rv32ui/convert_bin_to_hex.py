import sys
import os
import subprocess

def convert_elf_to_hex(base_name):
    elf_file = base_name  # ELF 原文件
    bin_file = base_name + ".bin"  # 输出的 .bin 文件
    hex_file = base_name + ".hex"  # 输出的 .hex 文件

    # 确保 ELF 文件存在
    if not os.path.isfile(elf_file):
        print(f"Error: ELF file '{elf_file}' not found.")
        return

    # 执行 `riscv64-unknown-elf-objcopy` 生成 `.bin` 文件
    try:
        subprocess.run(["riscv64-unknown-elf-objcopy", "-O", "binary", elf_file, bin_file], check=True)
        print(f"转换完成：{elf_file} -> {bin_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error running objcopy: {e}")
        return

    # 读取二进制文件
    try:
        with open(bin_file, "rb") as f:
            binary = f.read()
    except FileNotFoundError:
        print(f"Error: Could not open '{bin_file}'.")
        return

    # 按 4 字节（32-bit）转换成 HEX
    hex_lines = []
    for i in range(0, len(binary), 4):
        word = binary[i:i+4]
        hex_word = ''.join(f"{b:02x}" for b in reversed(word))  # 小端模式（Little-Endian）
        hex_lines.append(hex_word)

    # 保存为 Verilog 可读格式
    with open(hex_file, "w") as f:
        f.write("\n".join(hex_lines))

    print(f"转换完成：{bin_file} -> {hex_file}")

# 处理输入参数
if len(sys.argv) < 2:
    print("Usage: python elf_to_hex.py <input_file_without_extension> or <file_list.f>")
    sys.exit(1)

input_arg = sys.argv[1]

# 如果输入是 `.f` 文件，则读取所有 ELF 文件名
if input_arg.endswith(".f"):
    if not os.path.isfile(input_arg):
        print(f"Error: File list '{input_arg}' not found.")
        sys.exit(1)

    with open(input_arg, "r") as f:
        elf_files = [line.strip() for line in f.readlines() if line.strip()]
    
    for elf in elf_files:
        convert_elf_to_hex(elf)
else:
    # 直接处理单个 ELF 文件
    convert_elf_to_hex(input_arg)
