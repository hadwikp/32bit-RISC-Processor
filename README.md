# 32-bit RISC Processor Design & FPGA Implementation

## Overview
This repository contains the complete RTL design, simulation, and hardware implementation of a custom 32-bit RISC-like processor written in Verilog. Developed over a 5-week iterative design cycle, the project spans from the initial Instruction Set Architecture (ISA) definition and Arithmetic Logic Unit (ALU) design to a fully autonomous system running custom machine code on a Nexys A7 FPGA. 

The processor features a custom hardwired control unit, a robust memory subsystem utilizing FPGA Block RAM (BRAM), and a multiplexed Design-for-Testability (DFT) I/O interface. The final implementation successfully executes complex, multi-cycle algorithmic workloads autonomously at the board's native 100MHz clock speed.

## Architecture Specifications
* **Data Path:** 32-bit architecture for all operations, memory addresses, and data buses.
* **Register File:** Sixteen 32-bit general-purpose registers (`R0` to `R15`), organized with two read ports and one write port. `R0` is hardwired to `0`.
* **Control Registers:** 32-bit Program Counter (PC) and 32-bit Stack Pointer (SP).
* **Memory Subsystem:** Byte-addressable memory requiring word-aligned access (multiples of 8) for 32-bit loads and stores. Both Instruction ROM and Data RAM are synthesized using on-chip BRAM.

## Instruction Set Architecture (ISA)
The custom ISA supports diverse addressing modes including Register, Immediate, Base, PC-relative, and Indirect.
* **Arithmetic & Logic:** `ADD`, `SUB`, `AND`, `OR`, `XOR`, `NOR`, `NOT`, `SL`, `SRL`, `SRA`, `INC`, `DEC`, `SLT`, `SGT`, `LUI`, and immediate variants.
* **Hardware Accelerators:** Includes a dedicated `HAM` instruction to compute the Hamming Weight (population count) of a 32-bit word in hardware.
* **Memory & Transfer:** `LD`, `ST` (Base addressing), `MOVE`, and conditional move `CMOV`.
* **Control Flow:** Unconditional branch (`BR`), conditional branches (`BMI`, `BPL`, `BZ`), and processor halting (`HALT`).

## Repository Structure & Project Milestones

The repository is structured to reflect the systematic, phase-by-phase development of the processor:

* **`/Objective1&2_ALU`**: Contains the custom 32-bit ALU Verilog source, datapath schematics, and instruction encoding formats.
* **`/Objective3_DataPath_Integration`**: Features the integrated core (ALU + 16-register bank) and a multiplexed DFT display utilizing 16 FPGA LEDs to verify 32-bit register-to-register operations via hardware switches.
* **`/Objective4_Memory_operations`**: Houses the BRAM Data RAM modules. Includes manual-stepping logic to verify base-addressing modes for `LD` and `ST` instructions via a two-button execute/reset interface.
* **`/Objective5`**: Upgrades the processor to an autonomous Run/Idle Finite State Machine (FSM). Integrates a BRAM Instruction ROM to fetch and execute a "Sum of Integers" program autonomously at the 100MHz system clock.
* **`/ObjectiveFinal`**: The capstone algorithmic validation. Contains the generated bitstreams and BRAM initialization files (`.coe`) for executing two independent workloads:
  1. **Booth's Multiplication:** Evaluates a 16-bit signed integer multiplier/multiplicand, storing a 32-bit product.
  2. **Total Hamming Weight:** Iterates over a 5-word memory array, utilizing the hardware `HAM` instruction to accumulate the set-bit count.


## Technologies Used
* **Hardware Description Language:** Verilog
* **Target Hardware:** Nexys 4 DDR / Nexys A7 FPGA (Xilinx Artix-7)
* **Development Tools:** Xilinx Vivado (Synthesis, Simulation, BRAM IP Generation)
