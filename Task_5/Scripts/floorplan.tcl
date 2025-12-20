############################################
# Task 5  : SoC Floorplanning Using ICC2
# Design  : vsdcaravel
# Tool    : Synopsys ICC2 2022.12
############################################

# -------------------------------------------------
# Basic variables (edit paths if needed)
# -------------------------------------------------
set DESIGN_NAME vsdcaravel
set ROOT_DIR "/home/bbaishya/vsdRiscvScl180"
set WORK_DIR "$ROOT_DIR/floorplan"
set NETLIST     "$ROOT_DIR/synthesis/output/vsdcaravel_synthesis.v"
set WORK_LIB    "$WORK_DIR/work_lib.ndm"
set REFERENCE_LIBRARY  "/home/Synopsys/pdk/SCL_PDK_3/work/run1/icc2_workshop_collaterals/standaloneFlow/work/raven_wrapperNangate/lib.ndm"

# -------------------------------------------------
# Create NDM design library
# -------------------------------------------------
if {[file exists $WORK_LIB]} {
    file delete -force $WORK_LIB
}

create_lib $WORK_LIB \
    -ref_libs $REFERENCE_LIBRARY

open_lib $WORK_LIB

# -------------------------------------------------
# Read synthesized netlist
# -------------------------------------------------
read_verilog -top $DESIGN_NAME $NETLIST
link_block

# -------------------------------------------------
# Floorplan parameters (MICRONS)
# Die Size  : 3588 µm × 5188 µm
# Core Margin : 200 µm on all sides
#
# NOTE:
# This ICC2 version requires die-controlled initialization
# using -control_type die and -boundary syntax.
# -------------------------------------------------
set DIE_WIDTH   3588
set DIE_HEIGHT  5188
set CORE_MARGIN 200

# -------------------------------------------------
# Create Floorplan (EXPLICIT)
# -------------------------------------------------
initialize_floorplan \
    -control_type die \
    -boundary {{0 0} {3588 5188}} \
    -core_offset {200 200 200 200}

# -------------------------------------------------
# IO Pad Placement (manual, evenly distributed)
# Replace PAD_* with actual pad cell names
# -------------------------------------------------

# Top IO region (along top die edge)
create_placement_blockage \
  -name IO_BOTTOM \
  -type hard \
  -boundary {{0 0} {3588 100}}

# Top IO region (along top die edge)
create_placement_blockage \
  -name IO_TOP \
  -type hard \
  -boundary {{0 5088} {3588 5188}}

# Left IO region (along left die edge)
create_placement_blockage \
  -name IO_LEFT \
  -type hard \
  -boundary {{0 100} {100 5088}}

# Right IO region (along right die edge)
create_placement_blockage \
  -name IO_RIGHT \
  -type hard \
  -boundary {{3488 100} {3588 5088}}

# Fix IO pads
set_attribute [get_cells -filter pad_cell==true] status fixed

# -------------------------------------------------
# Write DEF file
# -------------------------------------------------
write_def "$WORK_DIR/outputs/vsdcaravel_floorplan.def"

# -------------------------------------------------
# Save floorplan
# -------------------------------------------------
save_block -as floorplan_only

# -------------------------------------------------
# Automatically Launch GUI for inspection
# -------------------------------------------------
gui_start
get_ports
place_pins -self

