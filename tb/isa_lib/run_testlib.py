import sys
import os
import subprocess
import re

def convert_elf_to_hex(base_name):
    """
    Converts an ELF executable to a HEX file for Verilog simulation.
    
    Args:
        base_name (str): The base name of the ELF file (without extensions).
    
    Outputs:
        - <base_name>.bin (Binary file)
        - <base_name>.hex (Hexadecimal file for Verilog memory initialization)
    """
    elf_file = base_name  # ELF input file
    bin_file = base_name + ".bin"  # Output binary file
    hex_file = base_name + ".hex"  # Output hex file

    if not os.path.isfile(elf_file):
        print(f"Error: ELF file '{elf_file}' not found.")
        return

    try:
        # Convert ELF to raw binary
        subprocess.run(["riscv64-unknown-elf-objcopy", "-O", "binary", elf_file, bin_file], check=True)
        print(f"Conversion successful: {elf_file} -> {bin_file}")
    except subprocess.CalledProcessError as e:
        print(f"Error running objcopy: {e}")
        return

    try:
        # Read the binary file
        with open(bin_file, "rb") as f:
            binary = f.read()
    except FileNotFoundError:
        print(f"Error: Could not open '{bin_file}'.")
        return

    # Convert binary to HEX format (little-endian 32-bit words)
    hex_lines = []
    for i in range(0, len(binary), 4):
        word = binary[i:i+4]
        hex_word = ''.join(f"{b:02x}" for b in reversed(word))  # Convert to little-endian hex
        hex_lines.append(hex_word)

    # Save the HEX file in Verilog-compatible format
    with open(hex_file, "w") as f:
        f.write("\n".join(hex_lines))

    print(f"Conversion successful: {bin_file} -> {hex_file}")

def run_qemu_simulation(elf_file, output_file="registers.txt"):
    """
    Runs QEMU to simulate the RISC-V ELF file and extracts CPU register values.
    
    Args:
        elf_file (str): The ELF file to be simulated.
        output_file (str): File to save the extracted register values.
    
    Output:
        - registers.txt (Contains the final values of all 32 registers x0-x31)
    """
    if not os.path.isfile(elf_file):
        print(f"Error: ELF file '{elf_file}' not found.")
        return

    print(f"Running QEMU simulation: {elf_file}")
    
    try:
        # Execute QEMU with CPU state logging
        qemu_output = subprocess.run(
            ["qemu-riscv32", "-cpu", "rv32", "-nographic", "-d", "cpu", elf_file],
            capture_output=True, text=True, check=True
        ).stdout

        # Extract register values (x0 to x31) from the QEMU log
        with open(output_file, "w") as f:
            for line in qemu_output.split("\n"):
                match = re.search(r"(x\d+)\s*=\s*([0-9a-fA-F]+)", line)
                if match:
                    f.write(f"{match.group(1)} {match.group(2)}\n")

        print(f"Register values saved to {output_file}")

    except subprocess.CalledProcessError as e:
        print(f"Error running QEMU: {e}")
        return

if __name__ == "__main__":
    """
    Main script execution:
    - Converts ELF to HEX (default)
    - If `-sim` argument is provided, it runs QEMU simulation and extracts register values.
    - If an `.f` file is given, it processes multiple ELF files listed in the file.
    """
    if len(sys.argv) < 2:
        print("Usage: python elf_to_hex.py <input_file_without_extension> [-sim] or <file_list.f> [-sim]")
        sys.exit(1)

    # Parse command-line arguments
    input_arg = sys.argv[1]
    run_simulation = "-sim" in sys.argv

    # If input is an .f file, process multiple ELF files
    if input_arg.endswith(".f"):
        if not os.path.isfile(input_arg):
            print(f"Error: File list '{input_arg}' not found.")
            sys.exit(1)

        # Read all ELF filenames from the .f file
        with open(input_arg, "r") as f:
            elf_files = [line.strip() for line in f.readlines() if line.strip()]

        for elf in elf_files:
            convert_elf_to_hex(elf)
            if run_simulation:
                run_qemu_simulation(elf)

    else:
        # Process a single ELF file
        convert_elf_to_hex(input_arg)
        if run_simulation:
            run_qemu_simulation(input_arg)