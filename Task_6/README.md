# Task 6 - Backend Flow Bring-Up with 100 MHz Performance Target

Task 6 focuses on

---

## 📜 Table of Contents
[1. Objective](#-objective)<br>
[2. Implementation Design Profile](#-implementation-design-profile)<br>
[3. Backend Technology Environment](#%EF%B8%8F-backend-technology-environment)<br>
[4. Backend Flow Topology](#-backend-flow-topology)<br>

---

## 🎯 Objective

The objective of this task is to **establish and validate a complete end-to-end backend implementation flow** capable of supporting a **100 MHz (10 ns) performance target**, using **Synopsys ICC2, Star-RC, and PrimeTime** on the same design used for floorplanning.

This task emphasizes **flow correctness over timing closure**, focusing on:

* Proper backend tool setup and execution order
* Correct input/output formats and directory organization
* Clean and verifiable handoff between **placement & routing → parasitic extraction → post-route STA**
* Successful timing analysis using **post-route parasitics (SPEF)**

The goal is to demonstrate that the **entire backend flow runs cleanly and consistently**, producing valid post-route timing reports at the target frequency, without requiring signoff-quality closure.

---

## 🧩 Implementation Design Profile

### 1. Top-Level Architecture

The backend flow is exercised on a **hierarchical SoC-style wrapper** that integrates multiple functional blocks under a single top module. The design complexity is intentionally non-trivial to realistically stress placement, routing, and timing stages.

* **Top Module:** `raven_wrapper`
* **Design Complexity:** 45,000+ standard cells
* **Integrated Memory:** One SRAM block (32 × 1024 bits, FreePDK45)
* **Process Node:** FreePDK45 (45 nm)
* **Standard Cell Set:** Nangate Open Cell Library
* **Die Footprint:** 3588 µm × 5188 µm
* **Core Region:** 2988 µm × 4588 µm with a 300 µm die-to-core offset
* **Target Utilization:** 65%

This setup mirrors a mid-scale SoC wrapper, making it suitable for validating backend tool interoperability and flow robustness.

### 2. Clocking Model & Timing Intent

The design is constrained to a **single performance target of 100 MHz**, with uniform timing intent applied across all clock sources. Each clock is defined independently to correctly capture asynchronous interactions within the system.

| Clock Signal | Frequency | Period  | Duty Cycle   |
| ------------ | --------- | ------- | ------------ |
| `ext_clk`    | 100 MHz   | 10.0 ns | 50% (0–5 ns) |
| `pll_clk`    | 100 MHz   | 10.0 ns | 50% (0–5 ns) |
| `spi_sck`    | 100 MHz   | 10.0 ns | 50% (0–5 ns) |

To approximate realistic chip-level IO conditions, conservative interface constraints were applied:

* **Input transition times:** 0.1 ns (min), 0.5 ns (max)
* **Input delays (referenced to `ext_clk`):** 0.2 ns (min), 0.6 ns (max)

These constraints ensure stable timing analysis during post-route STA with extracted parasitics.

### 3. Routing Stack & Power Distribution Strategy

The physical implementation leverages a **ten-layer metal stack** with alternating preferred routing directions to balance routability, performance, and power integrity.

| Metal Layer | Preferred Direction | Primary Role                         |
| ----------- | ------------------- | ------------------------------------ |
| M1          | Horizontal          | Standard cell rails and local wiring |
| M2          | Vertical            | Local signal routing                 |
| M3          | Horizontal          | Macro and block pin access           |
| M4          | Vertical            | Signal routing                       |
| M5          | Horizontal          | Signal routing                       |
| M6          | Vertical            | Signal routing                       |
| M7          | Horizontal          | Signal routing                       |
| M8          | Vertical            | Upper-level signal routing           |
| M9          | Vertical            | Global power vertical straps         |
| M10         | Horizontal          | Global power horizontal straps       |

A **two-layer global power grid** is formed using M9 and M10, ensuring robust power delivery across the die. Signal routing is confined to M1–M8, with structured layer usage to mitigate congestion and maintain timing predictability.

---

## 🛠️ Backend Technology Environment

### 1. Toolchain & Execution Platform

The backend implementation and validation flow was executed using a **production-grade Synopsys toolchain**, ensuring industry-aligned methodology and data handoff consistency across all stages.

| Tool                     | Version       | Role in Flow                                                 |
| ------------------------ | ------------- | ------------------------------------------------------------ |
| Synopsys IC Compiler II  | U-2022.12-SP3 | Placement, clock tree synthesis, routing, and power planning |
| Synopsys Star-RC         | 2022.12       | Post-route parasitic extraction                              |
| Synopsys PrimeTime       | 2022.12       | Static timing analysis with extracted parasitics             |
| Synopsys Design Compiler | Reference     | Netlist generation (synthesis input)                         |

All tools were executed on a **64-bit Linux environment**, with licenses managed through the standard Synopsys licensing framework.

### 2. Design Inputs & Technology Models

The physical design flow is driven by a well-defined set of RTL-derived and technology-specific inputs, ensuring consistency across placement, extraction, and timing analysis stages.

**Synthesized Netlist**

* `raven_wrapper.synth.v`
  Generated using Design Compiler, comprising approximately **45,000 standard cell instances** along with a **single SRAM macro**.

**Technology Definition**

* `nangate.tf`
  Defines the process technology parameters, including **metal stack (M1–M10)**, site definitions, and routing rules.

**Physical Library Models**

* `nangate_stdcell.lef`
  Physical abstracts for the Nangate Open Cell Library.
* `sram_32_1024_freepdk45.lef`
  LEF representation of the SRAM macro.

**Timing Characterization**

* `nangate_typical.db`
  Typical-corner timing model for standard cells.
* `sram_32_1024_freepdk45_TT_1p0V_25C_lib.db`
  SRAM timing model at TT, 1.0 V, 25 °C.

**Parasitic Extraction Models**

* **TLU+ files**
  Used to define RC extraction corners and ensure accurate post-route parasitic modeling during Star-RC and PrimeTime analysis.

---

## 🔁 Backend Flow Topology

### Intended End-to-End Execution Path

The backend implementation follows a **strictly ordered, handoff-driven flow**, where each step consumes the validated outputs of the previous stage. Rather than treating the flow as isolated phases, the execution is organized as a **continuous sequence of implementation and analysis steps**, ensuring data integrity and tool interoperability throughout.

```
┌──────────────────────────────┐
│ Synthesis Deliverables       │
│ - Gate-level Verilog netlist │
│ - Timing libraries (.db)     │
│ - Technology definitions    │
└───────────────┬──────────────┘
                │
                v
┌────────────────────────────────────────┐
│ Floorplan Initialization (ICC2)        │
│ - Define die and core boundaries       │
│ - Place IO pads and SRAM macro         │
│ - Apply placement blockages            │
│ Output: Initialized floorplan DEF     │
└───────────────┬────────────────────────┘
                │
                v
┌────────────────────────────────────────┐
│ Power Grid Construction (ICC2)         │
│ - Define VDD/VSS networks              │
│ - Build power rings and straps         │
│ - Validate power connectivity          │
│ Output: Power-aware floorplan DEF     │
└───────────────┬────────────────────────┘
                │
                v
┌────────────────────────────────────────┐
│ Standard Cell Placement (ICC2)         │
│ - Place 45K+ standard cells            │
│ - Perform basic placement optimization│
│ Output: Placed DEF and updated netlist│
└───────────────┬────────────────────────┘
                │
                v
┌────────────────────────────────────────┐
│ Clock Tree Implementation (ICC2)       │
│ - Build clock distribution networks   │
│ - Control skew and insertion delay    │
│ Output: CTS-updated netlist            │
└───────────────┬────────────────────────┘
                │
                v
┌────────────────────────────────────────┐
│ Signal Routing (ICC2)                  │
│ - Execute global and detailed routing  │
│ - Resolve routing and DRC violations  │
│ Output: Routed DEF and post-route netlist│
└───────────────┬────────────────────────┘
                │
                v
┌────────────────────────────────────────┐
│ Parasitic Extraction (Star-RC)         │
│ - Extract interconnect RC parasitics   │
│ - Generate SPEF including clock nets  │
│ Output: Post-route SPEF                │
└───────────────┬────────────────────────┘
                │
                v
┌────────────────────────────────────────┐
│ Post-Route Timing Analysis (PrimeTime) │
│ - Apply 100 MHz timing constraints    │
│ - Analyze setup, hold, skew, WNS/TNS  │
│ Output: Comprehensive timing reports  │
└────────────────────────────────────────┘
```

---

## 📊 Implementation Progress Snapshot

### 🔍 Backend Step Completion Overview

| Backend Step            | Current State | Progress | Primary Artifacts Generated                     | Automation Script   |
| ----------------------- | ------------- | -------- | ----------------------------------------------- | ------------------- |
| Design Initialization   | ✔️ Completed  | 100%     | Design library creation, hierarchy resolution   | `import_design.tcl` |
| Floorplan Definition    | ✔️ Completed  | 100%     | Die/core geometry, IO and macro placement       | `floorplan.tcl`     |
| Power Network Setup     | ✔️ Completed  | 100%     | Power rings, global mesh structures             | `create_power.tcl`  |
| Standard Cell Placement | ✔️ Completed  | 100%     | Timing-aware and congestion-optimized placement | `placement.tcl`     |
| Clock Distribution      | ✔️ Completed  | 100%     | CTS insertion with controlled skew              | `cts.tcl`           |
| Signal Routing          | ⏸️ Pending    | 0%       | Not initiated                                   | `route.tcl`         |
| Physical Verification   | ⏸️ Pending    | 0%       | DRC and LVS checks not yet executed             | `verify.tcl`        |
| Signoff Validation      | ⏸️ Pending    | 0%       | Final signoff analysis not started              | `signoff.tcl`       |
| Manufacturing Readiness | ⏸️ Pending    | 0%       | Tapeout preparation not initiated               | `mdk.tcl`           |


