# Design Compiler flow for the ram_2port coursework design.
# Prerequisite: copy synopsys/config/technology_setup.tcl.template to
# synopsys/config/technology_setup.tcl and set DB_LIBRARY_DIR if required.

set SCRIPT_DIR  [file dirname [file normalize [info script]]]
set CONFIG_FILE [file normalize [file join $SCRIPT_DIR .. config technology_setup.tcl]]

if {![file readable $CONFIG_FILE]} {
    error "Missing $CONFIG_FILE. Copy technology_setup.tcl.template first."
}
source $CONFIG_FILE

proc require_readable {label path} {
    if {$path eq "" || ![file readable $path]} {
        error "$label is not readable: '$path'"
    }
}

require_readable "RTL source" $RTL_FILE
require_readable "SDC constraints" $SDC_FILE
require_readable "Target .db library" $TARGET_LIBRARY_FILE

set DC_DIR         [file join $PROJECT_ROOT synopsys dc]
set DC_WORK_DIR    [file join $DC_DIR work]
set DC_OUTPUT_DIR  [file join $DC_DIR output]
set DC_REPORT_DIR  [file join $DC_DIR reports]
set MAPPED_NETLIST [file join $DC_OUTPUT_DIR ${TOP_MODULE}_mapped.v]
set MAPPED_DDC     [file join $DC_OUTPUT_DIR ${TOP_MODULE}_mapped.ddc]
set ICC2_SDC       [file join $DC_OUTPUT_DIR ${TOP_MODULE}_icc2.sdc]
set MAPPED_SDF     [file join $DC_OUTPUT_DIR ${TOP_MODULE}_mapped.sdf]
set SVF_FILE       [file join $DC_OUTPUT_DIR ${TOP_MODULE}.svf]

file mkdir $DC_WORK_DIR
file mkdir $DC_OUTPUT_DIR
file mkdir $DC_REPORT_DIR
define_design_lib WORK -path $DC_WORK_DIR

# Matches the Lab 2a logical-library convention.
lappend search_path $DB_LIBRARY_DIR
set target_library [list $TARGET_LIBRARY]
set link_library   [list * $TARGET_LIBRARY]

set_svf $SVF_FILE
analyze -format verilog [list $RTL_FILE]
elaborate -lib WORK $TOP_MODULE
current_design $TOP_MODULE
link
check_design

source -echo $SDC_FILE
check_timing

# Same synthesis switch used in the teacher's tutorial. The RAM array is
# implemented as a flip-flop/multiplexer standard-cell network unless a real
# SRAM macro is added separately to the technology library.
set case_analysis_with_logic_constants true
set_fix_multiple_port_nets -all
compile_ultra -no_autoungroup
set_svf -off

redirect -file [file join $DC_REPORT_DIR ${TOP_MODULE}_area.rpt] {
    report_area -hierarchy
}
redirect -file [file join $DC_REPORT_DIR ${TOP_MODULE}_timing_max.rpt] {
    report_timing -delay_type max -max_paths 20
}
redirect -file [file join $DC_REPORT_DIR ${TOP_MODULE}_timing_min.rpt] {
    report_timing -delay_type min -max_paths 20
}
redirect -file [file join $DC_REPORT_DIR ${TOP_MODULE}_qor.rpt] {
    report_qor
}
redirect -file [file join $DC_REPORT_DIR ${TOP_MODULE}_constraints.rpt] {
    report_constraint -all_violators
}

set verilogout_equation false
write_file -format verilog -hierarchy -output $MAPPED_NETLIST
write_file -format ddc     -hierarchy -output $MAPPED_DDC
write_sdc -nosplit $ICC2_SDC
write_sdf $MAPPED_SDF

puts "DC completed. Gate netlist: $MAPPED_NETLIST"
puts "Next: configure REFERENCE_LIBS/TECH_FILE, then run synopsys/icc2/run_icc2.tcl."
quit
