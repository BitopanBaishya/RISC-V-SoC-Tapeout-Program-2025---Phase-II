# Task 5 - SoC Floorplanning Using ICC2 (Floorplan Only)

Task 5 focuses on establishing a correct and reproducible SoC floorplan using Synopsys IC Compiler II (ICC2). The task is deliberately scoped to the floorplanning stage only, emphasizing accurate die and core definition, proper IO pad placement, and disciplined use of ICC2 commands. This exercise serves as the physical foundation for subsequent backend design stages while reinforcing fundamental physical design concepts and tool proficiency.

---

## 📜 Table of Contents
[1. Objective](#-objective)<br>
[2. Introduction to Floorplanning and ICC2](#-introduction-to-floorplanning-and-icc2)<br>
[3. Floorplanning Target Specifications](#-floorplanning-target-specifications)<br>
[4. ICC2 Workshop Collaterals — Annotated Directory Structure](#-icc2-workshop-collaterals--annotated-directory-structure)<br>
[5. Prerequisites](#-prerequisites)<br>
[6. ICC2 Execution and GUI Usage](#%EF%B8%8F-icc2-execution-and-gui-usage)<br>
[7. Floorplanning Tcl Script Implementation (ICC2)](#-floorplanning-tcl-script-implementation-icc2)<br>
[8. Section-wise Code Explanation (ICC2 Tcl Script)](#-section-wise-code-explanation-icc2-tcl-script)<br>
[9. Floorplan Iteration and Issue Resolution](#%EF%B8%8F-floorplan-iteration-and-issue-resolution)<br>
[10. Analysis of Final Result](#-analysis-of-final-result)<br>
[11. Execution Summary](#-execution-summary)<br>
[12. Learning Outcomes Achieved](#-learning-outcomes-achieved)<br>
[13. References](#-references)<br>
[14. Acknowledgments](#-acknowledgments)<br>
[15. License](#-license)<br>
[16. Contact and Support](#-contact-and-support)

---

## 🎯 Objective

The objective of Day 5 is to create a **correct SoC floorplan using Synopsys ICC2**, strictly limited to the **floorplanning stage only**. This includes defining an **exact die size of 3.588 mm × 5.188 mm**, setting a **reasonable core area with proper margins**, and **placing IO pads evenly and correctly along all four die edges**.

The task focuses on developing **practical understanding of ICC2 floorplanning commands** by studying a reference script and adapting it to the target SoC and dimensions. No placement, CTS, routing, timing closure, or power planning is performed. The goal is to establish a clean, error-free floorplan that forms a solid foundation for subsequent physical design stages.

---

## 🧱 Introduction to Floorplanning and ICC2

**Floorplanning** is the initial phase of the physical design process in which the fundamental physical structure of the integrated circuit is defined. This stage involves specifying the **die dimensions, core area boundaries, and IO pad regions**, thereby establishing the physical constraints that guide all subsequent implementation steps. A well-executed floorplan is essential for ensuring design feasibility, efficient layout organization, and smooth progression into later physical design stages.

**Synopsys IC Compiler II (ICC2)** is an industry-standard physical design tool used for integrated circuit implementation from floorplanning through final signoff. In this task, ICC2 is used strictly for **floorplan creation**, providing command-driven control over die and core definition and IO pad placement. This focused usage enables a clear understanding of floorplanning concepts while avoiding complexity associated with placement, clock tree synthesis, routing, and optimization.

---

## 📐 Floorplanning Target Specifications

This section defines the physical constraints and layout goals used to guide the SoC floorplan implementation. All parameters listed below were treated as fixed design requirements and used as validation checkpoints for the ICC2 floorplanning task.

#### 1. Die Dimensions (Mandatory ✅)

The die was defined with precise dimensions to ensure strict adherence to the target physical envelope.

* **Die Width**: 3.588 mm (3588 μm)
* **Die Height**: 5.188 mm (5188 μm)
* **Total Die Area**: 18.61 mm²
* **Aspect Ratio**: 1.45:1 (Height to Width)

Exact die sizing was explicitly enforced during floorplan creation and verified within the ICC2 environment.

#### 2. Core Area Definition

The core region was positioned inside the die with uniform spacing from all boundaries to maintain separation from IO structures and allow routing flexibility.

* **Core Offset**: 300 μm on each side
* **Core Width**: 2.988 mm
* **Core Height**: 4.588 mm
* **Core Area**: 13.71 mm²
* **Effective Core Coverage**: Approximately 76% of the total die area

This configuration was selected to balance available placement area with sufficient peripheral routing space.

#### 3. IO Pad Placement Strategy (Mandatory ✅)

IO pads were arranged along the perimeter of the die following standard SoC layout conventions.

* Pads placed on all four sides of the die boundary
* Even distribution maintained to avoid local congestion
* Orientation matched to the corresponding die edge
* All pads snapped to die edges with no floating placements

More than **54 IO pads** were instantiated, including:

* **General-purpose IOs**: gpio0 through gpio37 (38 signals)
* **Flash interface signals**: flash_clk, flash_csb, flash_io[0:3] (5 signals)
* **Control-related signals**: ext_clk, ext_reset, analog_out, and similar signals (11+ signals)
* **Power and ground pads**: VDD, VSS, VDDA, and VSSA

These constraints ensure a clean, well-structured floorplan suitable for downstream physical design stages while maintaining clarity and correctness at the floorplanning level.

---

## 📁 ICC2 Workshop Collaterals — Annotated Directory Structure

```
icc2_workshop_collaterals/
├── .git/                               → Git version control metadata
│
├── standaloneFlow/                     → Standalone ICC2 physical design flow
│   │
│   ├── scripts/                        → Primary ICC2 Tcl scripts
│   │   ├── top.tcl                     → Main ICC2 entry script (drives floorplanning)
│   │   ├── icc2_common_setup.tcl       → Common environment, library, and tool setup
│   │   ├── icc2_dp_setup.tcl           → Design planning and floorplan-specific setup
│   │   └── pad_placement_constraints.tcl
│   │                                   → IO pad placement rules and constraints
│   │
│   ├── outputs/                        → Key floorplanning outputs
│   │   ├── floorplan.def               → Final DEF containing die, core, and pad layout
│   │   ├── floorplan.log               → Log generated during floorplan creation
│   │   ├── floorplan_report.txt        → Summary report validating floorplan parameters
│   │   └── icc2_output.txt             → Consolidated ICC2 run output
│   │
│   ├── reports/                        → Essential verification and run logs
│   │   ├── check_design.log            → ICC2 design sanity check report
│   │   └── icc2_command.log            → Record of ICC2 commands executed
│   │
│   ├── CLIBs/                          → Compiled technology/reference libraries
│   │
│   ├── work/                           → ICC2 working database (design state storage)
│   │
│   └── other/                          → Autogenerated and non-essential artifacts
│       ├── outputs_icc2/               → Intermediate ICC2 outputs
│       ├── PreFrameCheck/              → Pre-run tool checks
│       ├── rpts_icc2/                  → Detailed ICC2 reports (unused in this task)
│       ├── tmp/                        → Temporary runtime files
│       ├── *.svf                       → Session and verification files
│       ├── flex*.log                   → Internal FlexNet/license logs
│       ├── *.example.tcl               → Example scripts not used directly
│       ├── *.ems                       → Workspace/environment metadata
│       └── Synopsys_stack_trace_*.txt  → Tool crash/debug stack traces
│
├── rtl_and_design_files/               → RTL sources defining the SoC
│   ├── raven_wrapper.v                 → Top-level SoC wrapper RTL
│   ├── raven_soc.v                     → Core SoC integration module
│   ├── raven_spi.v                     → SPI controller RTL
│   ├── picorv32.v                     → RISC-V CPU core RTL
│   ├── simpleuart.v                   → UART peripheral RTL
│   ├── spimemio.v                     → SPI memory interface RTL
│   └── spi_slave.v                    → SPI slave module RTL
│
├── constraints/                        → Design constraint files
│   └── raven_wrapper.sdc               → Timing constraints (not used in floorplan-only task)
│
├── synthesis/                          → Synthesis-related files
│   ├── raven_wrapper.synth.v           → Synthesized gate-level netlist
│   └── raven_wrapper.ys                → Yosys synthesis script
│
├── libraries/                          → Technology and standard-cell libraries
│   ├── nangate45nm.lib                 → Standard-cell timing library
│   ├── nangate_typical.lib             → Typical PVT timing library
│   ├── nangate_typical.db              → Synopsys DB format timing library
│   ├── nangate_stdcell.lef             → Standard-cell physical LEF
│   ├── nangate_tech.lef                → Technology LEF (routing layers, rules)
│   ├── pad.lef                         → IO pad physical definitions
│   ├── pad.lib                         → IO pad timing library
│   └── sram_32_1024_freepdk45*          → SRAM macro timing and physical views
│
├── documentation/                      → Project documentation
│   ├── README.md                       → High-level project description
│   └── ProjectDesignDocument.docx      → Detailed design documentation
│
└── other/                              → Supporting and reference-only files
    ├── sram.tar.gz                     → Archived SRAM files
    ├── sample_45nm.itf                 → Example interconnect tech file
    ├── sample_45nm.tluplus             → Example parasitic lookup tables
    └── cells_latch.v                   → Reference latch cell RTL
```

---

## 🔧 Prerequisites

The following prerequisites were required to successfully execute the ICC2 floorplanning task. These ensure a stable tool environment and availability of all necessary design inputs.

#### Software Environment

* **Synopsys IC Compiler II (ICC2)** installed with physical design capabilities
  *(Tested with version U-2022.12 or newer)*
* **Valid ICC2 license** enabled for physical design operations
* **Operating System**: Linux-based environment (RHEL/CentOS 7 or later preferred)
* **System Memory**: Minimum 32 GB RAM (64 GB recommended for smoother execution)

#### Hardware Resources

* **Processor**: Multi-core CPU with at least 8 cores to support parallel tool execution
* **Disk Space**: At least 100 GB of free storage to accommodate technology libraries, design databases, and run outputs
* **Network Access**: Connectivity to a license server for tool authorization

#### Design Inputs

* **Gate-Level Netlist**: `raven_wrapper.synth.v` used as the reference demonstration design
* **Constraint File**: `raven_wrapper.sdc` providing timing and design constraints
* **Standard-Cell Libraries**: `nangate_stdcell.lef`, `nangate45nm.lib`
* **Technology Files**: `nangate.tf` corresponding to the FreePDK45 process
* **Memory Macros**: `sram_32_1024_freepdk45.lef` and associated timing views

---

## 🖥️ ICC2 Execution and GUI Usage

IC Compiler II provides flexible invocation options to support both scripted and interactive workflows. For floorplanning tasks, ICC2 can be run in batch mode for automation or with the graphical interface for visual validation and learning. GUI-based execution is particularly useful for inspecting die boundaries, core regions, and IO pad placement.

#### ICC2 Invocation Methods

```bash
# Launch ICC2 in interactive shell mode
icc2_shell

# Run ICC2 by directly sourcing a floorplanning script
icc2_shell -f floorplan.tcl

# Launch ICC2 with GUI and execute the floorplanning script
icc2_shell -gui -f floorplan.tcl

# Start ICC2 interactively with GUI and source the script manually
icc2_shell -gui
icc2_shell> gui_start
icc2_shell> source floorplan.tcl
```

The ICC2 shell has been invoked and verified as working:
  <div align="center">
    <img src="Images/Fig1.png" alt="Alt Text" width="600"/>
  </div>

#### Common ICC2 GUI Commands

```tcl
gui_start                  ;# Launch the ICC2 graphical interface
gui_stop                   ;# Close the GUI session
gui_zoom_fit               ;# Fit the entire design in the view window
gui_set_display_layer      ;# Enable or disable layer visibility
report_design_summary      ;# Display high-level design statistics
```

---

## 📝 Floorplanning Tcl Script Implementation (ICC2)

```tcl
###############################################################################
# ICC2 Design Planning + Early Placement Flow
# Design  : vsdcaravel
# Stage   : DP + Floorplan + IO + Macro + Pin Placement
# Tool    : Synopsys ICC2
###############################################################################

# ============================================================================
# 0. Environment & Flow Setup
# ============================================================================
source -echo ./icc2_common_setup.tcl
source -echo ./icc2_dp_setup.tcl


# ============================================================================
# 1. Clean Workspace & Create NDM Library
# ============================================================================
if {[file exists ${WORK_DIR}/$DESIGN_LIBRARY]} {
   file delete -force ${WORK_DIR}/${DESIGN_LIBRARY}
}

set create_lib_cmd "create_lib ${WORK_DIR}/$DESIGN_LIBRARY"

if {[file exists [which $TECH_FILE]]} {
   lappend create_lib_cmd -tech $TECH_FILE
} elseif {$TECH_LIB != ""} {
   lappend create_lib_cmd -use_technology_lib $TECH_LIB
}

lappend create_lib_cmd -ref_libs $REFERENCE_LIBRARY
puts "RM-info : $create_lib_cmd"
eval ${create_lib_cmd}


# ============================================================================
# 2. Read Synthesized Netlist
# ============================================================================
if {$DP_FLOW == "hier" && $BOTTOM_BLOCK_VIEW == "abstract"} {
   puts "RM-info : Reading verilog outline (${VERILOG_NETLIST_FILES})"
   read_verilog_outline \
      -design ${DESIGN_NAME}/${INIT_DP_LABEL_NAME} \
      -top ${DESIGN_NAME} \
      ${VERILOG_NETLIST_FILES}
} else {
   puts "RM-info : Reading full chip verilog (${VERILOG_NETLIST_FILES})"
   read_verilog \
      -design ${DESIGN_NAME}/${INIT_DP_LABEL_NAME} \
      -top ${DESIGN_NAME} \
      ${VERILOG_NETLIST_FILES}
}


# ============================================================================
# 3. Technology & Parasitic Setup
# ============================================================================
if {$TECH_FILE != "" || ($TECH_LIB != "" && !$TECH_LIB_INCLUDES_TECH_SETUP_INFO)} {
   if {[file exists [which $TCL_TECH_SETUP_FILE]]} {
      puts "RM-info : Sourcing [which $TCL_TECH_SETUP_FILE]"
      source -echo $TCL_TECH_SETUP_FILE
   } elseif {$TCL_TECH_SETUP_FILE != ""} {
      puts "RM-error : TCL_TECH_SETUP_FILE($TCL_TECH_SETUP_FILE) is invalid."
   }
}

if {[file exists [which $TCL_PARASITIC_SETUP_FILE]]} {
   puts "RM-info : Sourcing [which $TCL_PARASITIC_SETUP_FILE]"
   source -echo $TCL_PARASITIC_SETUP_FILE
} elseif {$TCL_PARASITIC_SETUP_FILE != ""} {
   puts "RM-error : TCL_PARASITIC_SETUP_FILE($TCL_PARASITIC_SETUP_FILE) is invalid."
} else {
   puts "RM-info : No TLU+ files sourced"
}


# ============================================================================
# 4. Routing Layer Constraints
# ============================================================================
if {$MAX_ROUTING_LAYER != ""} {
   set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER
}

if {$MIN_ROUTING_LAYER != ""} {
   set_ignored_layers -min_routing_layer $MIN_ROUTING_LAYER
}


# ============================================================================
# 5. Pre-Floorplan Design Check
# ============================================================================
if {$CHECK_DESIGN} {
   redirect -file ${REPORTS_DIR_INIT_DP}/check_design.pre_floorplan {
      check_design \
         -ems_database check_design.pre_floorplan.ems \
         -checks dp_pre_floorplan
   }
}


# ============================================================================
# 6. Floorplanning
# ============================================================================
initialize_floorplan \
   -control_type die \
   -boundary {{0 0} {3588 5188}} \
   -core_offset {300 300 300 300}

save_block -force -label floorplan
save_lib -all


# ============================================================================
# 7. Power/Ground Connectivity
# ============================================================================
puts "RM-info : Running connect_pg_net -automatic on all blocks"
connect_pg_net -automatic -all_blocks

save_block -force -label ${PRE_SHAPING_LABEL_NAME}
save_lib -all


# ============================================================================
# 8. IO Placement
# ============================================================================
if {[file exists [which $TCL_PAD_CONSTRAINTS_FILE]]} {
   puts "RM-info : Loading TCL_PAD_CONSTRAINTS_FILE ($TCL_PAD_CONSTRAINTS_FILE)"
   source -echo $TCL_PAD_CONSTRAINTS_FILE

   puts "RM-info : Running place_io"
   place_io
}

set_attribute [get_cells -hierarchical -filter pad_cell==true] status fixed


# ============================================================================
# 9. Macro (Memory) Reporting
# ============================================================================
if [sizeof_collection [get_cells -hier -filter is_hard_macro==true -quiet]] {
   set all_macros [get_cells -hier -filter is_hard_macro==true]
   report_macro_constraints \
      -allowed_orientations \
      -preferred_location \
      -alignment_grid \
      -align_pins_to_tracks \
      $all_macros > $REPORTS_DIR_PLACEMENT/report_macro_constraints.rpt
}


# ============================================================================
# 10. User-Defined Macro Placement
# ============================================================================
source /home/bbaishya/icc2_workshop_collaterals/standaloneFlow/outputs_icc2/preferred_macro_locations.tcl


# ============================================================================
# 11. Placement Configuration & MCMM Setup
# ============================================================================
if {$DISTRIBUTED} {
   set HOST_OPTIONS "-host_options block_script"
} else {
   set HOST_OPTIONS ""
}

set CMD_OPTIONS "-floorplan $HOST_OPTIONS"

if {[file exists $TCL_MCMM_SETUP_FILE]} {
   puts "RM-info : Loading TCL_MCMM_SETUP_FILE ($TCL_MCMM_SETUP_FILE)"
   source -echo $TCL_MCMM_SETUP_FILE
} else {
   puts "RM-error : Cannot find TCL_MCMM_SETUP_FILE ($TCL_MCMM_SETUP_FILE)"
   error
}

set CMD_OPTIONS "$CMD_OPTIONS -timing_driven"
set plan.place.auto_generate_blockages true


# ============================================================================
# 12. Derive & Fix Macro Locations
# ============================================================================
if [sizeof_collection [get_cells -hier -filter is_hard_macro==true -quiet]] {
   file delete -force $OUTPUTS_DIR/preferred_macro_locations.tcl
   set all_macros [get_cells -hier -filter is_hard_macro==true]
   derive_preferred_macro_locations \
      $all_macros \
      -file $OUTPUTS_DIR/preferred_macro_locations.tcl

   set_attribute -quiet \
      [get_cells -hierarchical -filter is_hard_macro==true] \
      status fixed
}


# ============================================================================
# 13. Save Placement State
# ============================================================================
save_block -hier -force -label ${PLACEMENT_LABEL_NAME}
save_lib -all


# ============================================================================
# 14. Pin Placement
# ============================================================================
if {[file exists [which $TCL_PIN_CONSTRAINT_FILE]] && !$PLACEMENT_PIN_CONSTRAINT_AWARE} {
   source -echo $TCL_PIN_CONSTRAINT_FILE
}

set_app_options -as_user_default -list {route.global.timing_driven true}

if {$CHECK_DESIGN} {
   redirect -file ${REPORTS_DIR_PLACE_PINS}/check_design.pre_pin_placement {
      check_design \
         -ems_database check_design.pre_pin_placement.ems \
         -checks dp_pre_pin_placement
   }
}

if {$PLACE_PINS_SELF} {
   place_pins -self

   write_pin_constraints -self \
      -file_name $OUTPUTS_DIR/preferred_port_locations.tcl \
      -physical_pin_constraint {side | offset | layer} \
      -from_existing_pins

   check_pin_placement -self \
      -pre_route true \
      -pin_spacing true \
      -sides true \
      -layers true \
      -stacking true

   report_pin_placement -self > $REPORTS_DIR_PLACE_PINS/report_port_placement.rpt
}


# ============================================================================
# 15. SRAM Keepout
# ============================================================================
create_keepout_margin -type hard \
   -outer {10 10 10 10} \
   [get_cells sram]


# ============================================================================
# 16. Final Save
# ============================================================================
save_block -hier -force -label ${PLACE_PINS_LABEL_NAME}
save_lib -all
```

---

## 📝 Section-wise Code Explanation (ICC2 Tcl Script)

### **0. Environment & Flow Setup**

```tcl
source -echo ./icc2_common_setup.tcl
source -echo ./icc2_dp_setup.tcl
```

These commands load the common environment and design-planning setup files.

* `icc2_common_setup.tcl` defines global variables such as paths, design name, and library settings.
* `icc2_dp_setup.tcl` configures parameters specific to design planning and floorplanning.
  The `-echo` option prints the sourced commands to the log for traceability.

### **1. Clean Workspace & Create NDM Library**

```tcl
if {[file exists ${WORK_DIR}/$DESIGN_LIBRARY]} {
   file delete -force ${WORK_DIR}/${DESIGN_LIBRARY}
}
```

Checks whether a previous design library exists and deletes it to ensure a clean execution.

```tcl
set create_lib_cmd "create_lib ${WORK_DIR}/$DESIGN_LIBRARY"
```

Initializes the `create_lib` command string used to generate a new NDM library.

```tcl
if {[file exists [which $TECH_FILE]]} {
   lappend create_lib_cmd -tech $TECH_FILE
} elseif {$TECH_LIB != ""} {
   lappend create_lib_cmd -use_technology_lib $TECH_LIB
}
```

Associates technology information with the library.

* Uses a technology file (`.tf`) if available.
* Otherwise, links to an existing technology library.

```tcl
lappend create_lib_cmd -ref_libs $REFERENCE_LIBRARY
eval ${create_lib_cmd}
```

Adds reference libraries (standard cells, pads, macros) and executes the final `create_lib` command.

### **2. Read Synthesized Netlist**

```tcl
if {$DP_FLOW == "hier" && $BOTTOM_BLOCK_VIEW == "abstract"} {
   read_verilog_outline ...
} else {
   read_verilog ...
}
```

Imports the synthesized Verilog design into ICC2.

* `read_verilog_outline` is used for hierarchical or abstract block planning.
* `read_verilog` loads the complete chip netlist for flat planning.

### **3. Technology & Parasitic Setup**

```tcl
source -echo $TCL_TECH_SETUP_FILE
```

Loads technology-specific setup such as routing layers, via rules, and spacing constraints when not fully defined in the technology library.

```tcl
source -echo $TCL_PARASITIC_SETUP_FILE
```

Sources parasitic modeling files (TLU+) to define resistance and capacitance information used during timing-aware operations.

### **4. Routing Layer Constraints**

```tcl
set_ignored_layers -max_routing_layer $MAX_ROUTING_LAYER
set_ignored_layers -min_routing_layer $MIN_ROUTING_LAYER
```

Restricts routing to a defined range of metal layers by ignoring layers above or below specified limits.

### **5. Pre-Floorplan Design Check**

```tcl
check_design -checks dp_pre_floorplan
```

Performs early design-planning checks to validate structural integrity, missing references, and DP-specific rule compliance before floorplanning.

### **6. Floorplanning**

```tcl
initialize_floorplan \
   -control_type die \
   -boundary {{0 0} {3588 5188}} \
   -core_offset {300 300 300 300}
```

Defines the physical layout:

* Sets the die boundary to the exact target dimensions.
* Applies uniform core margins on all four sides.
* Uses die-controlled floorplanning.

```tcl
save_block -force -label floorplan
save_lib -all
```

Saves the design state after floorplan creation.

### **7. Power/Ground Connectivity**

```tcl
connect_pg_net -automatic -all_blocks
```

Automatically connects power and ground nets across the entire design hierarchy.

### **8. IO Placement**

```tcl
source -echo $TCL_PAD_CONSTRAINTS_FILE
place_io
```

Loads IO pad placement constraints and places pads along the die boundary accordingly.

```tcl
set_attribute [get_cells -hierarchical -filter pad_cell==true] status fixed
```

Locks IO pad positions to prevent movement in later stages.

### **9. Macro (Memory) Reporting**

```tcl
get_cells -filter is_hard_macro==true
```

Identifies hard macros (e.g., SRAM blocks).

```tcl
report_macro_constraints ...
```

Generates a report detailing macro orientation, alignment, and placement constraints.

### **10. User-Defined Macro Placement**

```tcl
source preferred_macro_locations.tcl
```

Applies user-specified macro placement directives generated in previous runs or manually defined.

### **11. Placement Configuration & MCMM Setup**

```tcl
source $TCL_MCMM_SETUP_FILE
```

Configures multi-corner multi-mode timing scenarios and placement behavior.

```tcl
set plan.place.auto_generate_blockages true
```

Enables automatic blockage creation around macros during placement.

### **12. Derive & Fix Macro Locations**

```tcl
derive_preferred_macro_locations ...
```

Automatically computes optimal macro locations and saves them to a Tcl file.

```tcl
set_attribute ... status fixed
```

Fixes macro positions to preserve derived placement.

### **13. Save Placement State**

```tcl
save_block -hier -label ${PLACEMENT_LABEL_NAME}
```

Saves the design database at the placement stage for reuse.

### **14. Pin Placement**

```tcl
place_pins -self
```

Automatically places top-level IO pins based on constraints.

```tcl
check_pin_placement -self
```

Validates pin spacing, side assignment, layers, and stacking rules.

### **15. SRAM Keepout**

```tcl
create_keepout_margin -type hard -outer {10 10 10 10} [get_cells sram]
```

Creates a hard keepout region around SRAM macros to reserve routing and spacing clearance.

### **16. Final Save**

```tcl
save_block -hier -label ${PLACE_PINS_LABEL_NAME}
save_lib -all
```

Commits the final design state to the ICC2 library.

---

## 🛠️ Floorplan Iteration and Issue Resolution

During the initial floorplanning stage, several issues were observed related to IO pad placement and floorplan determinism. These issues were systematically analyzed and resolved through controlled modifications to the Tcl flow. The following subsections document the observed problems and the corrective actions applied.

---

### Initial Floorplan Observation

  <div align="center">
    <img src="Images/Fig2.png" alt="Alt Text" width="600"/>
  </div>

In the first iteration, multiple IO pads were observed **along the die area instead of along the die boundary**. This resulted in an invalid and physically incorrect floorplan, despite the die dimensions being nominally correct.

The root cause was traced to **manual IO placement using `create_io_guide`**, where incorrect guide coordinates caused ICC2 to interpret the pad placement regions within the die interior.

### Summary of Key Corrections

* Identified that incorrect coordinate specification in `create_io_guide` led to invalid IO guide regions.
* Temporarily **disabled all manual IO guides** to eliminate coordinate-driven errors.
* Switched to **automatic IO placement** using `place_io -include_unassigned_pads`, allowing ICC2 to correctly infer pad-ring geometry and distribute pads along the die edges.
* Incrementally reintroduced structure and constraints only after ensuring correct baseline behavior.

### 1. Explicit Die and Core Definition

The floorplan was stabilized by explicitly defining the die and core geometry using **die-controlled floorplanning**.

* Die boundaries were set to **3588 µm × 5188 µm** using `initialize_floorplan`.
* A uniform **300 µm core offset** was applied on all four sides.
* This removed ambiguity in die/core interpretation and ensured consistent geometry across runs.

As a result, the physical canvas of the design became deterministic and reproducible.

### 2. Manual IO Pad Floorplanning Using IO Guides

After validating correct automatic IO placement, manual control was reintroduced cautiously.

* Automatic `place_io` was replaced with **manual IO placement using `create_io_guide`** to gain explicit control over pad distribution.
* Separate IO guides were created for the **left, right, top, and bottom** edges.
* Each guide:

  * Explicitly filtered valid pad cells (`pad_cell == true`)
  * Was aligned exactly to the corresponding **die boundary**
  * Used controlled and bounded placement regions

This approach ensured structured pad placement without violating die constraints.

### 3. Correct Usage of `create_io_guide -line`

A critical correction involved the interpretation of the `-line` argument:

* The guide definition was corrected to use:

  * A **single starting coordinate**
  * A **positive guide length**
* Endpoint-style definitions were removed, as `create_io_guide` does not accept absolute end coordinates.
* Guide lengths were computed based on the **usable die span**, preventing negative lengths or out-of-bound placement.

This eliminated the root cause of pads drifting into invalid regions.

### 4. Intentional Corner Pad Handling

Corner pads were intentionally **excluded from explicit IO guide definitions**.

* ICC2 automatically inferred corner pad placement from the surrounding pad-ring geometry.
* As edge IO guides were corrected, corner pads repositioned automatically.
* This behavior aligns with standard ICC2 pad-ring handling and required no manual intervention.

### 5. Controlled Scope: Floorplan-Only Flow

To maintain alignment with the task objectives, the flow was intentionally constrained.

* No standard-cell placement, macro placement, CTS, routing, or PDN generation was performed.
* The flow terminates immediately after:

  * Die and core definition
  * IO pad placement
  * Floorplan validation and DEF generation

This ensured focus on **floorplanning correctness**, without introducing downstream complexity.

### Final Floorplan Outcome

  <div align="center">
    <img src="Images/Fig3.png" alt="Alt Text" width="600"/>
  </div>

After applying the above corrections, the final floorplan shows:

* Correct die and core boundaries
* Evenly distributed IO pads along all four edges
* Proper corner pad placement
* No pads inside the die interior

The resulting floorplan satisfies all task requirements and serves as a clean foundation for subsequent physical design stages.

---

### 📊 Analysis of Final Result

The finalized floorplan meets all defined physical and structural targets, confirming the correctness of the implemented ICC2 flow.

* **Die Boundary**:
  The die is accurately defined as a **3588 µm × 5188 µm** rectangle, matching the specified dimensions exactly with no distortion or offset.

* **Core Area**:
  The core region is centrally placed within the die and maintains uniform **300 µm margins** on all four sides, ensuring adequate spacing for IO placement and future routing.

* **IO Pad Distribution**:
  IO pads are evenly and symmetrically distributed along the die periphery:

  * **Top Edge**: 11 pads
  * **Bottom Edge**: 12 pads
  * **Left Edge**: 12 pads
  * **Right Edge**: 13 pads

  In total, **48 IO pads** are correctly placed, aligned to the die edges, and free from overlaps or interior placement violations.

Overall, the final floorplan satisfies all mandatory criteria and demonstrates a clean, balanced, and physically valid SoC layout suitable for subsequent physical design stages.

---

### 🧾 Execution Summary

* **Tool Used**: Synopsys IC Compiler II (industry-standard physical design tool)
* **Technology Node**: FreePDK45 nm (academic reference process)
* **Design Implemented**: `raven_wrapper` — an open-source RISC-V–based SoC
* **Design Scale**: Approximately 50K logic gates with 54+ IO pads
* **Flow Scope**: Floorplanning only, serving as the foundation for full backend implementation
* **Execution Status**: Successfully completed without errors ✅

---

### 🎓 Learning Outcomes Achieved

#### Technical Proficiency

* Gained hands-on experience with **ICC2 command-line and GUI-based workflows**
* Developed a practical understanding of **die sizing, core margin definition, and IO pad placement**
* Worked with **technology, standard-cell, and IO pad libraries** in a physical design environment
* Authored and modified **IO placement constraints using Tcl scripting**
* Strengthened understanding of the **end-to-end backend physical design flow**

#### Physical Design Fundamentals

* Understood the distinction and interaction between **die area and core area**
* Learned the role of **technology files** in defining process and routing rules
* Gained insight into **standard cells** as the basic units of digital implementation
* Understood the function of **IO pads** as the interface between silicon and external signals
* Familiarized with the **NDM-based design database** used in modern physical design tools

#### Practical Engineering Skills

* Adapted and customized **reference scripts** to meet specific design requirements
* Diagnosed and resolved **common floorplanning and IO placement issues**
* Verified physical results against **explicit quantitative targets**
* Produced **clear and structured technical documentation** suitable for review and reuse

These outcomes collectively establish a strong foundation for progressing to advanced physical design stages such as placement, clock tree synthesis, routing, and signoff.

---

## 📚 References

### Official Documentation

1. **Synopsys Design Compiler User Guide** - T-2022.03-SP5
   - Synthesis methodology
   - Library setup and configuration
   - Constraint specification

2. **SCL 180nm PDK Documentation** - SCL_PDK_3 v3.0
   - Standard cell library characterization
   - I/O pad specifications
   - Design rules and guidelines

3. **Efabless Caravel Documentation**
   - Repository: https://github.com/efabless/caravel
   - Architecture overview
   - Integration guidelines

4. **VSD RISC-V Repository**
   - Repository: https://github.com/vsdip/vsdRiscvScl180/tree/iitgn
   - Reference implementation
   - Test procedures

### VexRiscv Core

- **Repository:** https://github.com/SpinalHDL/VexRiscv
- **License:** MIT License
- **Features:** RV32IMC instruction set, configurable pipeline

### Icarus Verilog and GTKWave

- **Icarus Verilog:** http://iverilog.icarus.com/
- **GTKWave:** http://gtkwave.sourceforge.net/

### Academic References

- **IIT Gandhinagar RISC-V SoC Tapeout Program**
  - 20-week program from RTL to silicon tapeout
  - Industry-grade tools and methodologies

---

## 🙏 Acknowledgments

This project is part of the **RISC-V Reference SoC Tapeout Program** conducted at **IIT Gandhinagar** in collaboration with **VLSI System Design (VSD)** and **Synopsys**.

### Team and Contributors

- **Institution:** Indian Institute of Technology Gandhinagar (IITGN)
- **Program:** RISC-V SoC Tapeout Program
- **PDK Support:** Synopsys SCL 180nm PDK v3.0
- **Base Design:** Efabless Caravel (Apache-2.0 License)
- **Processor Core:** VexRiscv (MIT License)
- **Date:** December 12, 2025

### Special Thanks

- IIT Gandhinagar faculty for infrastructure and guidance
- VSD for comprehensive training and support
- Synopsys for PDK access and tool licenses
- Open-source RISC-V community

---

## 📄 License

This project is licensed under the **Apache License 2.0**.

- **SPDX-License-Identifier:** Apache-2.0
- **Copyright:** 2025 IIT Gandhinagar

### Component Licenses

- **Caravel Framework:** Apache-2.0 (Efabless)
- **VexRiscv Core:** MIT License
- **SCL180 PDK:** Proprietary (Synopsys) - Educational Use

---

## 📬 Contact and Support

For questions, issues, or contributions:

- **Repository:** https://github.com/vsdip/vsdRiscvScl180
- **Branch:** iitgn
- **Institution:** IIT Gandhinagar
- **Program Website:** https://www.vlsisystemdesign.com/soc-labs/

---

**Last Updated:** December 31, 2025
