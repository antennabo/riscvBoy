# 🚀 riscvBoy

**riscvBoy** is a personal RISC-V CPU project implementing a simple, classic **5-stage pipeline** core based on the **RV32I** instruction set.  
Designed for learning and experimentation, this project is written in Verilog and includes simulation support.

---

## 📌 Features
- Harvard architecture
- Supports **RV32I** base instruction set
- **5-stage pipeline** architecture:
  - IF (Instruction Fetch)
  - ID (Instruction Decode)
  - EX (Execute)
  - MEM (Memory Access)
  - WB (Write Back)
- Basic hazard detection and data forwarding
- Modular and readable RTL design
- Simple testbench with simulation and waveform output

---

## 🧪 How to Run Simulation

### 📁 Navigate to testbench folder:

```bash
cd tb/simple_platform
```

### ▶️ Run simulation:

```bash
python3 run_test.py -f
```

This will:
- Compile the testbench files
- Run simulation
- Generate waveform: `cpu_wave.vcd`
- Log output: `sim_result.log`

### 📖 View the result:

```bash
gvim sim_result.log     # or use any text editor
gtkwave cpu_wave.vcd    # view waveform
```

---

## 🔧 Project Structure

```
riscvBoy/
├── rtl/                   # Verilog source files
├── tb/
│   ├── isa_lib/           # Instruction test library (if used)
│   └── simple_platform/   # Testbench and simulation scripts
│       ├── tb_top.sv
│       ├── run_test.py
│       └── sim_result.log
```

---

## 🎯 Project Goals

- Learn and implement a classic RISC-V pipeline
- Explore Verilog RTL design and modular SoC structure
- Build a base for future extensions (e.g. peripherals, debug logic, SoC integration)

---

---

## 🛠️ Environment

- **Python**: 3.12+
- **Simulator**: [Icarus Verilog (iverilog)](http://iverilog.icarus.com/)

Make sure both `iverilog` and `vvp` are installed and accessible in your system's PATH.

