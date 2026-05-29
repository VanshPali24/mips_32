# 32-bit MIPS Pipelined Processor

A hardware implementation of a 32-bit MIPS processor featuring a classic 5-stage pipeline, full forwarding network for data hazards, load-use stall detection, and a branch-not-taken strategy for control hazards.

---

## Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Pipeline Stages](#pipeline-stages)
- [Hazard Handling](#hazard-handling)
  - [Data Hazards — Forwarding Unit](#data-hazards--forwarding-unit)
  - [Load-Use Hazard — Stall / Hazard Detection Unit](#load-use-hazard--stall--hazard-detection-unit)
  - [Control Hazards — Branch Not Taken](#control-hazards--branch-not-taken)
- [Pipeline Registers](#pipeline-registers)
- [Supported Instructions](#supported-instructions)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Simulation & Testing](#simulation--testing)
- [Design Decisions](#design-decisions)

---

## Overview

This project implements a fully functional 32-bit MIPS processor modelled on the classic Patterson & Hennessy architecture. The processor executes instructions in a 5-stage pipeline and handles all common pipeline hazards:

| Feature | Implementation |
|---|---|
| Architecture | 32-bit MIPS |
| Pipeline Depth | 5 stages |
| Data Hazard Mitigation | Full forwarding (EX-EX and MEM-EX paths) |
| Load-Use Hazard | Hazard Detection Unit + pipeline stall |
| Control Hazard | Branch Not Taken + single-cycle flush on misprediction |

---

## Architecture

```
        ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐   ┌──────┐
   ─────►  IF  ├───►  ID  ├───►  EX  ├───► MEM  ├───►  WB  ├─────
        └──────┘   └──────┘   └──────┘   └──────┘   └──────┘
           ▲                      ▲           ▲
           │      Forwarding ─────┘───────────┘
           │
           └──── Hazard Detection (stall on load-use)
```

Control signals, register values, and intermediate results are carried through dedicated **pipeline registers** (IF/ID, ID/EX, EX/MEM, MEM/WB) between every stage.

---

## Pipeline Stages

### 1. Instruction Fetch (IF)
- Fetches the 32-bit instruction from instruction memory at the current Program Counter (PC).
- Increments PC by 4 (PC + 4) for sequential execution.
- On a stall, holds the PC and the IF/ID register; on a branch flush, inserts a NOP (bubble).

### 2. Instruction Decode / Register Fetch (ID)
- Decodes the fetched instruction and reads the two source registers (`rs`, `rt`) from the 32-entry register file.
- Generates all control signals for downstream stages.
- Performs sign-extension of the 16-bit immediate field to 32 bits.
- The Hazard Detection Unit monitors this stage to insert stalls when a load-use dependency is detected.

### 3. Execute (EX)
- The ALU performs the operation specified by the control signals (arithmetic, logical, shift, comparison).
- Selects ALU operands from the register file outputs or the Forwarding Unit's MUX outputs.
- Computes the effective memory address for load/store instructions (`base + offset`).
- The Forwarding Unit is entirely combinational logic living in this stage.

### 4. Memory Access (MEM)
- Reads from or writes to data memory for `lw` / `sw` instructions.
- All non-memory instructions pass through this stage unchanged.
- The branch resolution also completes here — if a taken branch is detected, the incorrectly fetched instruction in IF is flushed.

### 5. Write Back (WB)
- Writes the result (ALU output or memory read data) back to the destination register in the register file.
- The write happens in the first half of the clock cycle; the register read in ID happens in the second half, enabling same-cycle forwarding for certain cases.

---

## Hazard Handling

### Data Hazards — Forwarding Unit

The Forwarding Unit eliminates most data hazards without stalling by detecting when a later pipeline stage holds a result that an earlier instruction in EX currently needs.

**EX-EX Forwarding** — forwards the ALU result from EX/MEM directly to the EX stage ALU input:

```
Condition:  EX/MEM.RegWrite
        AND EX/MEM.RegisterRd ≠ 0
        AND EX/MEM.RegisterRd = ID/EX.RegisterRs (or Rt)
```

**MEM-EX Forwarding** — forwards the result from MEM/WB (either ALU result or memory data) to the EX stage ALU input:

```
Condition:  MEM/WB.RegWrite
        AND MEM/WB.RegisterRd ≠ 0
        AND MEM/WB.RegisterRd = ID/EX.RegisterRs (or Rt)
        AND (EX-EX forwarding condition is NOT satisfied)
```

Two 3-to-1 MUXes (`ForwardA`, `ForwardB`) in the EX stage select the correct operand:

| MUX Select | Source |
|---|---|
| `00` | Register file output (no forwarding) |
| `10` | EX/MEM pipeline register (EX-EX) |
| `01` | MEM/WB pipeline register (MEM-EX) |

---

### Load-Use Hazard — Stall / Hazard Detection Unit

A `lw` instruction cannot forward its result until after the MEM stage, one cycle later than an ALU instruction. When the instruction immediately following a `lw` needs the loaded value, a **one-cycle stall (bubble)** is inserted.

**Detection logic:**

```
Stall if:  ID/EX.MemRead = 1
       AND (ID/EX.RegisterRt = IF/ID.RegisterRs
            OR ID/EX.RegisterRt = IF/ID.RegisterRt)
```

**On a stall:**
- PC is held (not incremented).
- IF/ID pipeline register is held (instruction is re-fetched next cycle).
- ID/EX pipeline register is zeroed (NOP bubble inserted into EX stage).

**Example:**
```mips
lw   $t0, 0($s1)    # MEM stage reads data
add  $t2, $t0, $t3  # needs $t0 → stall inserted here
```

---

### Control Hazards — Branch Not Taken

The processor uses a **branch-not-taken** static prediction strategy:

1. The processor always fetches the instruction at PC + 4 (the fall-through path) after a branch.
2. Branch outcome and target address are resolved in the **MEM stage**.
3. If the branch is **not taken** — no action needed; the fetched instruction is correct.
4. If the branch **is taken** — the one incorrectly fetched instruction (now in IF/ID) is **flushed** by zeroing the IF/ID register (inserting a NOP/bubble), and the PC is updated to the branch target.

**Penalty:** at most **1 cycle** per taken branch.

```
Cycle:   1      2      3      4      5
BEQ:    [IF]  [ID]   [EX]  [MEM]  [WB]
PC+4:         [IF]   [ID]  [EX]* ← flushed if branch taken
Target:               ---   [IF]   [ID]  ...
```

---

## Pipeline Registers

| Register | Fields Carried |
|---|---|
| **IF/ID** | PC+4, Instruction[31:0] |
| **ID/EX** | PC+4, ReadData1, ReadData2, SignExtImm, Rs, Rt, Rd, Control signals |
| **EX/MEM** | PC+4, ALUResult, WriteData, RegisterRd, Control signals |
| **MEM/WB** | ALUResult, ReadData (memory), RegisterRd, Control signals |

---

## Supported Instructions

### R-Type
| Instruction | Operation |
|---|---|
| `add` | Rd = Rs + Rt |
| `sub` | Rd = Rs − Rt |
| `and` | Rd = Rs AND Rt |
| `or` | Rd = Rs OR Rt |
| `slt` | Rd = (Rs < Rt) ? 1 : 0 |

### I-Type
| Instruction | Operation |
|---|---|
| `lw` | Rt = Mem[Rs + SignExt(imm)] |
| `sw` | Mem[Rs + SignExt(imm)] = Rt |
| `beq` | if (Rs == Rt) PC = PC+4+SignExt(imm)<<2 |

---

## Getting Started

### Prerequisites

- Quartus Prime Altera (Lite Version)
- ModelSim (for simulation)

### Build & Simulate



### Loading a Custom Program

--to be added

## Simulation & Testing

The testbench suite covers the following scenarios:

| Test Case | Description |
|---|---|
| Sequential execution | Basic R-type and I-type instruction flow |
| EX-EX forwarding | Back-to-back ALU instructions with shared registers |
| MEM-EX forwarding | ALU instruction two cycles after a producer |
| Load-use stall | `lw` immediately followed by a dependent instruction |
| Branch not taken | Branch evaluates false; fall-through is correct |
| Branch taken + flush | Branch evaluates true; incorrectly fetched instruction is squashed |
| Combined hazards | Interleaved loads, branches, and ALU ops |

Run individual testbenches:

--to be added

## Design Decisions

**Branch resolved in MEM vs EX** — Resolving the branch in MEM keeps the datapath simple and avoids special-case forwarding into the branch comparator. The cost is a maximum of one flush cycle per taken branch, which is acceptable for this implementation.

**Register file write-then-read** — The register file supports writing in the first half of the clock cycle and reading in the second half, eliminating the WB→ID data hazard without a forwarding path.

**No delayed branching** — The MIPS ISA historically used a branch delay slot. This implementation does not use a delay slot; the branch-not-taken strategy with flush is used instead for simplicity and clarity.

**Structural hazards** — Separate instruction and data memories (Harvard architecture) are used to avoid structural hazards in the IF and MEM stages.

---

## References

- Patterson, D. A., & Hennessy, J. L. — *Computer Organization and Design: The Hardware/Software Interface* (MIPS Edition)
- MIPS32® Architecture Reference Manual
