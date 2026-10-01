# RV32I 5-Stage Pipelined RISC-V SoC

A complete 32-bit RV32I processor and SoC implemented in Verilog HDL, featuring a classic 5-stage pipeline, forwarding and hazard handling, privileged machine-mode support, traps and interrupts, 64-bit performance counters, memory-mapped peripherals, UART TX/RX, and integrated verification.

The project was developed and verified using Icarus Verilog and GTKWave.

---

## Project Overview

This project implements a 32-bit RV32I processor using a classic five-stage pipeline:

```text
IF -> ID -> EX -> MEM -> WB
```

The processor is extended into an integrated SoC containing:

- RV32I processor core
- 5-stage pipelined datapath
- Forwarding logic
- Hazard detection and stall control
- Branch and jump handling
- Load/store support
- LUI and AUIPC
- CSR instructions
- Machine-mode trap handling
- ECALL exception handling
- MRET return-from-trap
- Machine timer interrupt
- UART RX external interrupt
- Interrupt masking
- Interrupt priority handling
- 64-bit performance counters
- System bus
- Data RAM
- GPIO
- UART TX
- UART RX
- MMIO status and control registers
- Integrated verification testbenches

---

## System Architecture

![RV32I SoC System Architecture](docs/images/01_system_architecture.png)

The processor is organized around a five-stage pipeline with dedicated control, forwarding, hazard detection, memory, CSR, interrupt, and peripheral logic.

### Pipeline

```text
                 +----------------------+
                 |   Instruction RAM    |
                 +----------+-----------+
                            |
                            v
+------+       +------+   +------+   +------+   +------+
|  IF  | ----> |  ID  |-> |  EX  |-> | MEM  |-> |  WB  |
+------+       +------+   +------+   +------+   +------+
                  |          |          |          |
                  |          |          |          |
                  v          v          v          v
              Register     ALU       Data RAM   Register
               File      Branches      /MMIO      Write
```

---

# Main Features

## 1. RV32I Processor Core

The processor implements the core functionality required for the project RV32I instruction set.

Supported instruction groups include:

### Integer arithmetic

- ADD
- SUB
- ADDI

### Logical operations

- AND
- OR
- XOR
- ANDI
- ORI
- XORI

### Shift operations

- SLL
- SRL
- SRA
- SLLI
- SRLI
- SRAI

### Comparison operations

- SLT
- SLTU
- SLTI
- SLTIU

### Load and Store

- LW
- SW

### Branch instructions

- BEQ
- BNE
- BLT
- BGE
- BLTU
- BGEU

### Jump instructions

- JAL
- JALR

### Upper immediate instructions

- LUI
- AUIPC

---

# 2. Five-Stage Pipeline

The processor uses the standard five-stage pipeline:

```text
Instruction Fetch
       |
       v
Instruction Decode
       |
       v
Execute
       |
       v
Memory Access
       |
       v
Write Back
```

Pipeline registers are used between stages:

```text
IF/ID
ID/EX
EX/MEM
MEM/WB
```

The pipeline supports:

- Data forwarding
- Load-use hazard detection
- Pipeline stalls
- Branch handling
- Jump handling
- Pipeline flushing
- Write-back forwarding
- Branch operand forwarding

---

# 3. Forwarding and Hazard Handling

The processor contains dedicated forwarding and hazard detection logic.

### Forwarding paths

```text
EX/MEM -> EX
MEM/WB -> EX
```

Forwarding is also used for branch comparisons and store data.

### Hazard handling

The hazard detection logic identifies situations where an instruction must wait for an earlier instruction.

Typical example:

```text
LW   x5, 0(x1)
ADD  x6, x5, x2
```

The dependent instruction is stalled when the load result is not yet available.

The pipeline control handles:

- Load-use hazards
- Data dependencies
- Branch dependencies
- Store-data dependencies

---

# 4. Privileged Architecture

The processor includes machine-mode privileged functionality.

![Privileged Architecture](docs/images/02_privileged_interrupt_architecture.png)

Implemented machine-mode CSRs include:

| CSR | Address | Purpose |
|---|---:|---|
| MSTATUS | 0x300 | Machine status |
| MIE | 0x304 | Machine interrupt enable |
| MTVEC | 0x305 | Machine trap vector |
| MSCRATCH | 0x340 | Machine scratch register |
| MEPC | 0x341 | Machine exception program counter |
| MCAUSE | 0x342 | Machine trap cause |
| MTVAL | 0x343 | Machine trap value |
| MIP | 0x344 | Machine interrupt pending |
| CYCLE | 0xC00 | Cycle counter |
| TIME | 0xC01 | Time counter |
| INSTRET | 0xC02 | Instructions retired |
| CYCLEH | 0xC80 | Upper cycle counter |
| TIMEH | 0xC81 | Upper time counter |
| INSTRETH | 0xC82 | Upper instruction-retired counter |

---

# 5. CSR Instructions

The processor supports CSR read/write operations required by the project.

Implemented CSR operations include:

```text
CSRRW
CSRRS
CSRRC

CSRRWI
CSRRSI
CSRRCI
```

The CSR execution logic supports:

- Register-based CSR operands
- Immediate CSR operands
- CSR read-back
- CSR write masking
- Zero-register behavior for CSRRS/CSRRC style operations

---

# 6. Trap and Exception Handling

The processor supports machine-mode traps and exceptions.

Implemented functionality includes:

- Trap entry
- MEPC capture
- MCAUSE capture
- MTVAL handling
- MTVEC trap redirection
- MSTATUS update
- MRET return
- ECALL exception
- Illegal instruction trap infrastructure

### ECALL Flow

```text
Program
   |
   | ECALL
   v
Trap Detection
   |
   v
MEPC <- faulting instruction PC
MCAUSE <- ECALL cause
   |
   v
PC <- MTVEC
   |
   v
Trap Handler
   |
   v
MRET
   |
   v
PC <- MEPC
```

---

# 7. ECALL Verification

The ECALL and MRET mechanism was verified using a dedicated testbench.

The verified sequence is:

```text
ECALL
  |
  v
Trap Entry
  |
  +--> MEPC
  |
  +--> MCAUSE
  |
  +--> MTVEC
  |
  v
Trap Handler
  |
  v
MRET
  |
  v
Program Resume
```

## ECALL -> Trap -> MRET Waveform

![ECALL Trap MRET Waveform](docs/images/05_ecall_trap_mret_waveform.png)

The waveform shows the trap and return sequence at the RTL simulation level.

---

# 8. Interrupt Architecture

The SoC contains interrupt sources for:

- Machine timer
- UART RX

The interrupt system supports:

- Interrupt pending detection
- Interrupt enable masking
- MSTATUS.MIE global interrupt enable
- MIE source masking
- MIP pending status
- Interrupt trap entry
- Interrupt cause generation
- Interrupt priority

The current interrupt cause encoding includes:

```text
Timer Interrupt:
0x80000007

UART RX External Interrupt:
0x8000000B
```

UART RX external interrupt has priority when both UART RX and timer interrupt sources are pending.

---

# 9. Machine Timer Interrupt

A machine timer peripheral is integrated into the processor.

The timer generates an interrupt when the configured timer condition is reached.

The timer interrupt path is:

```text
Machine Timer
      |
      v
Timer Pending
      |
      v
MIP[7]
      |
      v
MIE[7]
      |
      v
MSTATUS.MIE
      |
      v
Interrupt Taken
      |
      v
MTVEC
```

Interrupt masking was verified independently.

---

# 10. UART RX Interrupt

UART RX is integrated as an external interrupt source.

The UART RX path is:

```text
UART RX
   |
   v
Received Byte
   |
   v
RX Data Valid
   |
   v
Interrupt Pending
   |
   v
MIP[11]
   |
   v
MIE[11]
   |
   v
MSTATUS.MIE
   |
   v
External Interrupt
   |
   v
Trap Handler
   |
   v
MRET
```

The UART RX interrupt supports:

- RX byte reception
- RX data-valid detection
- Pending interrupt latch
- Interrupt enable control
- Interrupt clearing
- External interrupt generation
- Machine-mode interrupt handling
- MRET return

---

# 11. UART RX Interrupt -> Handler -> MRET

A dedicated waveform was created to verify the UART RX interrupt path.

![UART RX Interrupt Waveform](docs/images/06_uart_irq_mret_waveform.png)

The waveform focuses on:

```text
clk
uart_rx_irq
uart_rx_interrupt_pending
interrupt_taken
mcause
mepc_value
mtvec_value
mret_taken
```

This verifies the complete external interrupt flow from UART RX through trap entry and back to normal execution using MRET.

---

# 12. 64-bit Performance Counters

The processor includes 64-bit performance counters.

Implemented counters:

```text
CYCLE
TIME
INSTRET
STALL
```

The counters are maintained as 64-bit values:

```text
63                       32 31                        0
+--------------------------+---------------------------+
|        Upper 32 bits     |       Lower 32 bits       |
+--------------------------+---------------------------+
```

Implemented CSR access includes:

```text
CYCLE
CYCLEH

TIME
TIMEH

INSTRET
INSTRETH
```

The current implementation exposes TIME as an alias of the cycle counter.

The internal performance monitoring also tracks pipeline stall cycles.

---

# 13. System Bus

The SoC contains a system bus connecting the CPU to memory and memory-mapped peripherals.

```text
                 +----------------+
                 |   RV32I CPU    |
                 +-------+--------+
                         |
                         v
                 +---------------+
                 |   System Bus  |
                 +-------+-------+
                         |
        +----------------+----------------+
        |                |                |
        v                v                v
   Instruction        Data RAM          MMIO
      RAM                              |
                                       |
                           +-----------+-----------+
                           |           |           |
                           v           v           v
                         GPIO       UART TX     UART RX
```

---

# 14. MMIO Address Map

![MMIO Memory Map](docs/images/03_mmio_memory_map.png)

The integrated SoC uses the following memory-mapped peripheral addresses:

| Address | Peripheral | Access |
|---|---|---|
| 0x10000000 | GPIO | Write |
| 0x10000004 | UART TX | Write |
| 0x10000008 | UART RX | Read |
| 0x10000010 | STATUS | Read |
| 0x10000014 | CONTROL | Write |

The MMIO decoder selects the appropriate peripheral based on the address.

---

# 15. GPIO

GPIO is accessible through the MMIO interface.

Example:

```text
CPU
 |
 | Write 0x10000000
 v
MMIO Decoder
 |
 v
GPIO Peripheral
```

The final SoC regression verifies GPIO MMIO writes.

Example regression transaction:

```text
MMIO WRITE:
addr  = 0x10000000
wdata = 0x00000055
```

---

# 16. UART TX

UART TX is memory mapped at:

```text
0x10000004
```

A CPU write to the UART TX address sends the lower byte through the UART transmitter.

The UART TX peripheral uses:

```text
CLKS_PER_BIT = 4
```

The transmission status is exposed through the internal UART busy signal.

The final regression verifies that UART TX completes transmission.

---

# 17. UART RX

UART RX is memory mapped at:

```text
0x10000008
```

The RX peripheral supports:

- Serial reception
- Received data storage
- Data-valid indication
- MMIO read access
- RX interrupt generation

The final regression verifies reception of:

```text
0x5A
```

---

# 18. STATUS Register

The STATUS register is located at:

```text
0x10000010
```

It provides peripheral status information through the MMIO interface.

The final regression verifies STATUS access.

Example:

```text
MMIO READ:
addr  = 0x10000010
rdata = 0x00000001
```

---

# 19. CONTROL Register

The CONTROL register is located at:

```text
0x10000014
```

It is used for peripheral control functionality.

The final regression verifies UART RX interrupt enable control.

Example:

```text
MMIO WRITE:
addr  = 0x10000014
wdata = 0x00000001
```

---

# 20. Verification Architecture

Verification was implemented using multiple dedicated Verilog testbenches.

The verification environment covers:

```text
CPU
 |
 +-- ALU
 +-- Register File
 +-- Immediate Generator
 +-- Forwarding
 +-- Hazard Detection
 +-- Branch / Jump
 +-- Load / Store
 |
 +-- CSR
 +-- Trap
 +-- ECALL
 +-- MRET
 +-- Timer IRQ
 +-- UART RX IRQ
 |
 +-- System Bus
 +-- RAM
 +-- GPIO
 +-- UART TX
 +-- UART RX
 |
 +-- Performance Counters
 |
 +-- Full SoC Regression
```

---

# 21. Six-Stage Verification Roadmap

The project verification was organized into six stages.

| Stage | Verification | Status |
|---|---|---|
| Stage 1 | Timer Interrupt + Interrupt Masking | Complete |
| Stage 2 | Exceptions + Trap Handling + MRET | Complete |
| Stage 3 | Privileged CSR + ECALL | Complete |
| Stage 4 | 64-bit Performance Counters | Complete |
| Stage 5 | Integrated Interrupt + Trap + CSR Verification | Complete |
| Stage 6 | Full SoC Integration + Final Regression | Complete |

---

# 22. Stage 1 - Timer Interrupt and Masking

Stage 1 verifies:

- Machine timer
- Timer interrupt generation
- MIE masking
- MSTATUS.MIE
- Interrupt pending behavior
- Interrupt enable/disable behavior

The timer interrupt path was verified independently before integration into the complete SoC.

---

# 23. Stage 2 - Trap Handling and MRET

Stage 2 verifies:

- Exception generation
- Trap entry
- MEPC capture
- MCAUSE capture
- MTVEC redirection
- Trap handler execution
- MRET
- Program resumption

---

# 24. Stage 3 - Privileged CSR and ECALL

Stage 3 verifies:

```text
CSRRW
CSRRS
CSRRC
CSRRWI
CSRRSI
CSRRCI
```

It also verifies:

```text
MSTATUS
MIE
MTVEC
MEPC
MCAUSE
MSCRATCH
ECALL
MRET
```

The Stage 3 regression verifies that the processor correctly enters the ECALL handler and resumes execution after MRET.

---

# 25. Stage 4 - Performance Counters

Stage 4 verifies:

- 64-bit cycle counter
- 64-bit instruction-retired counter
- Stall counter
- CSR read access
- Lower 32-bit counter reads
- Upper 32-bit counter reads

Example counter representation:

```text
CYCLE   = 64-bit
INSTRET = 64-bit
STALL   = 64-bit
```

---

# 26. Stage 5 - Integrated Interrupt, Trap and CSR Verification

Stage 5 combines:

```text
CSR
 +
Trap
 +
Interrupt
 +
Timer
 +
MRET
```

The integration verifies that the privileged architecture operates correctly when multiple mechanisms interact.

---

# 27. Stage 6 - Full SoC Integration

Stage 6 combines the complete processor and peripheral system:

```text
RV32I CPU
   |
   +-- 5-stage pipeline
   +-- Forwarding
   +-- Hazard handling
   +-- Branch / Jump
   +-- CSR
   +-- Trap
   +-- ECALL
   +-- MRET
   +-- Timer Interrupt
   +-- UART RX Interrupt
   +-- Performance Counters
   |
   +-- Instruction RAM
   +-- Data RAM
   +-- System Bus
   +-- MMIO
   +-- GPIO
   +-- UART TX
   +-- UART RX
```

---

# 28. Final Stage 6 Regression

![Stage 6 Final Regression](docs/images/04_stage6_regression.png)

The final regression verifies the complete integrated SoC.

The regression covers:

```text
CPU execution
RAM store/load
GPIO MMIO
UART TX
UART RX
UART RX interrupt
CSR
ECALL
Trap handling
MRET
Performance counters
MMIO control
Interrupt priority
```

---

# 29. Final Regression Output

The final Stage 6 regression produced:

```text
======================================================
       STAGE 6 - FULL RISC-V SOC REGRESSION
======================================================

MMIO WRITE: addr=10000000 wdata=00000055 gpio_sel=1 control_sel=0
MMIO WRITE: addr=10000004 wdata=00000041 gpio_sel=0 control_sel=0
MMIO READ: addr=10000010 rdata=00000001 gpio_sel=0 uart_rx_sel=0 status_sel=1 control_sel=0
MMIO WRITE: addr=10000014 wdata=00000001 gpio_sel=0 control_sel=1

---------------- CPU REGRESSION ----------------
PASS: Arithmetic immediate
PASS: RAM store/load
PASS: Integrated CPU execution
PASS: Post-trap program execution

---------------- GPIO ----------------
PASS: GPIO MMIO write

---------------- DATA RAM ----------------
PASS: Data RAM transaction

---------------- UART TX ----------------
PASS: UART TX peripheral completed transmission

---------------- CONTROL ----------------
PASS: UART RX interrupt enable

---------------- CSR ----------------
PASS: MTVEC configured
MSTATUS = 0x00000088

---------------- TRAP / ECALL ----------------
PASS: ECALL MCAUSE = 11

---------------- PERFORMANCE ----------------
CYCLE   = 0x0000000000000131
INSTRET = 0x000000000000011b
STALL   = 0x0000000000000000
PASS: 64-bit cycle counter active
PASS: 64-bit instret counter active

---------------- UART RX ----------------
PASS: UART RX received 0x5A

---------------- FINAL CSR STATE ----------------
MSTATUS = 0x00000080
MIE     = 0xfffff800
MCAUSE  = 0x8000000b
MEPC    = 0x00000108
MTVEC   = 0x00000100

---------------- FINAL CPU STATE ----------------
x5  = 0x000000aa
x17 = 0xxxxxxxxx
x20 = 0x000000bb
x21 = 0x0000000b
x22 = 0x00000088
x23 = 0x00000088

======================================================
       STAGE 6 FULL SOC REGRESSION PASS

       RV32I CPU + CSR + TRAP + IRQ
       + PERFORMANCE COUNTERS
       + RAM + GPIO + UART TX/RX
       + MMIO + INTERRUPT PRIORITY
       + MRET + ECALL

       PROJECT FINAL REGRESSION PASS
======================================================
```

---

# 30. Waveform Verification

GTKWave was used to inspect important RTL behaviors.

The project includes dedicated waveform captures for:

- ECALL
- Trap entry
- MRET
- UART RX interrupt
- Interrupt pending
- Interrupt handler entry
- Interrupt return

The waveform images are included in this repository under:

```text
docs/images/
```

---

# 31. ECALL Trap Waveform

The ECALL waveform demonstrates the transition from normal execution into the machine-mode trap handler and back through MRET.

![ECALL Trap MRET Waveform](docs/images/05_ecall_trap_mret_waveform.png)

---

# 32. UART External Interrupt Waveform

The UART interrupt waveform demonstrates the complete interrupt sequence:

```text
UART RX
   |
   v
IRQ Pending
   |
   v
Interrupt Taken
   |
   v
Trap Entry
   |
   v
Handler
   |
   v
MRET
   |
   v
Normal Execution
```

![UART RX Interrupt Waveform](docs/images/06_uart_irq_mret_waveform.png)

---

# 33. Repository Structure

```text
riscv-5-stage-pipeline/
|
+-- rtl/
|   |
|   +-- alu.v
|   +-- alu_control.v
|   +-- control_unit.v
|   +-- forwarding_unit.v
|   +-- hazard_detection_unit.v
|   +-- branch_unit.v
|   +-- jump_unit.v
|   +-- register_file.v
|   +-- immediate_generator.v
|   +-- program_counter.v
|   |
|   +-- pipeline_if_id.v
|   +-- pipeline_id_ex.v
|   +-- pipeline_ex_mem.v
|   +-- pipeline_mem_wb.v
|   |
|   +-- riscv_core.v
|   +-- riscv_csr.v
|   +-- riscv_soc.v
|   |
|   +-- machine_timer.v
|   +-- soc_bus.v
|   +-- soc_ram.v
|   |
|   +-- mmio_decoder.v
|   +-- mmio_gpio.v
|   +-- mmio_uart_tx.v
|   +-- mmio_uart_rx.v
|
+-- tb/
|   |
|   +-- riscv_core_tb.v
|   +-- riscv_exception_tb.v
|   +-- riscv_stage3_tb.v
|   +-- riscv_stage4_tb.v
|   +-- riscv_stage5_tb.v
|   +-- riscv_stage6_soc_tb.v
|   +-- riscv_timer_interrupt_tb.v
|   +-- riscv_uart_rx_tb.v
|   +-- riscv_uart_tx_tb.v
|   +-- riscv_uart_irq_mret_tb.v
|   +-- ...
|
+-- docs/
|   |
|   +-- images/
|       |
|       +-- 01_system_architecture.png
|       +-- 02_privileged_interrupt_architecture.png
|       +-- 03_mmio_memory_map.png
|       +-- 04_stage6_regression.png
|       +-- 05_ecall_trap_mret_waveform.png
|       +-- 06_uart_irq_mret_waveform.png
|
+-- run_final_regression.ps1
+-- .gitignore
+-- README.md
```

---

# 34. Tools and Environment

The project was developed and simulated using:

| Tool | Purpose |
|---|---|
| Verilog HDL | RTL implementation |
| Icarus Verilog 12.0 | Simulation |
| GTKWave 3.3.100 | Waveform analysis |
| Visual Studio Code | Development |
| Git | Version control |
| GitHub | Source code repository |

---

# 35. Running the Project

## Run the final regression

From the project root:

```powershell
.\run_final_regression.ps1
```

The script compiles and runs the verification stages using Icarus Verilog.

The final regression checks for:

```text
PASS
FAIL
ERROR COUNT
```

and reports the overall project status.

---

# 36. Manual Simulation

A typical Icarus Verilog simulation can be run using:

```powershell
iverilog -g2012 -o simulation rtl\*.v tb\riscv_core_tb.v
vvp simulation
```

For waveform generation:

```powershell
vvp simulation
gtkwave *.vcd
```

Generated simulation files are intentionally ignored by Git.

---

# 37. Final Verification Coverage

The final regression covers the following feature groups:

```text
RV32I ALU
Branch / Jump
Forwarding
Hazards
Load / Store

LUI / AUIPC
SLT / SLTU
Immediate ALU
Shift Operations

CSR
MSTATUS
MIE
MIP
MTVEC
MEPC
MCAUSE
MTVAL

ECALL
Trap Entry
MRET
Machine Timer
IRQ Masking
IRQ Priority

64-bit CYCLE
TIME
INSTRET
Stall Counter

RAM
System Bus
MMIO
GPIO
STATUS
CONTROL

UART TX
UART RX
UART RX IRQ
External Interrupt
```

---

# 38. Project Status

```text
Stage 1  - Timer Interrupt + Interrupt Masking             COMPLETE
Stage 2  - Exceptions + Trap Handling + MRET              COMPLETE
Stage 3  - Privileged CSR + ECALL                         COMPLETE
Stage 4  - 64-bit Performance Counters                    COMPLETE
Stage 5  - Integrated Interrupt + Trap + CSR Verification COMPLETE
Stage 6  - Full SoC Integration + Final Regression        COMPLETE
```

Final project verification status:

```text
PROJECT FINAL REGRESSION PASS
```

---

# 39. Key Design Highlights

The project demonstrates practical RTL design concepts including:

- Five-stage CPU pipeline design
- Pipeline register implementation
- Datapath and control separation
- Forwarding
- Hazard detection
- Pipeline stalls
- Pipeline flushing
- Branch and jump control
- Memory interface design
- System bus design
- MMIO decoding
- Peripheral integration
- UART transmitter design
- UART receiver design
- Interrupt generation
- Interrupt masking
- Interrupt priority
- Machine-mode CSR implementation
- Trap entry and return
- ECALL exception handling
- MRET handling
- 64-bit performance monitoring
- RTL simulation
- Self-checking verification
- Waveform-based debugging

---

# 40. Conclusion

This project integrates a pipelined RV32I processor with a machine-mode privileged architecture and a small memory-mapped SoC platform.

The final implementation combines:

```text
RV32I CPU
+
5-Stage Pipeline
+
Forwarding
+
Hazard Handling
+
CSR
+
Trap / Exception Handling
+
ECALL / MRET
+
Machine Timer
+
Interrupt Masking
+
Interrupt Priority
+
64-bit Performance Counters
+
RAM
+
MMIO
+
GPIO
+
UART TX/RX
+
UART RX External Interrupt
+
Integrated Verification
```

The complete six-stage verification flow and final SoC regression were successfully executed.

---

## Author

**Kathir**

ECE | RTL Design and Verification

Focus areas:

```text
Digital Design
Verilog / SystemVerilog
RTL Design
CPU Architecture
RISC-V
SoC Design
Functional Verification
Hardware Debugging
```