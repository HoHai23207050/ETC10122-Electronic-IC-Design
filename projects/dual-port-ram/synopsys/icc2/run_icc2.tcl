# ICC2 implementation flow for the ram_2port coursework design.
# It creates a core-only standard-cell layout: floorplan -> placement -> CTS ->
# routing. It deliberately stops before claiming PDK signoff DRC/LVS.

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

proc require_path_list {label paths} {
    if {[llength $paths] == 0} {
        error "$label is empty. Fill it in technology_setup.tcl; a logical .db alone cannot create layout."
    }
    foreach path $paths {
        if {![file exists $path]} {
            error "$label path does not exist: '$path'"
        }
    }
}

set MAPPED_NETLIST [file join $PROJECT_ROOT synopsys dc output ${TOP_MODULE}_mapped.v]
set ICC2_SDC       [file join $PROJECT_ROOT synopsys dc output ${TOP_MODULE}_icc2.sdc]
set ICC2_DIR       [file join $PROJECT_ROOT synopsys icc2]
set DESIGN_LIBRARY [file join $ICC2_DIR work ${TOP_MODULE}.dlib]
set RESULT_DIR     [file join $ICC2_DIR output]
set REPORT_DIR     [file join $ICC2_DIR reports]

require_readable "Mapped netlist (run DC first)" $MAPPED_NETLIST
require_readable "ICC2 SDC (run DC first)" $ICC2_SDC
require_path_list "ICC2 physical REFERENCE_LIBS" $REFERENCE_LIBS
if {$TECH_FILE ne "" && ![file readable $TECH_FILE]} {
    error "TECH_FILE is set but unreadable: '$TECH_FILE'"
}

file mkdir [file join $ICC2_DIR work]
file mkdir $RESULT_DIR
file mkdir $REPORT_DIR
if {[file exists $DESIGN_LIBRARY]} {
    error "Existing ICC2 design library: $DESIGN_LIBRARY. Move or remove it deliberately before a clean rerun."
}

# The course's ICC2 CTS script begins after load.tcl. Here that loaded state is
# constructed explicitly from the mapped netlist, SDC, and physical PDK views.
if {$TECH_FILE eq ""} {
    create_lib -ref_libs $REFERENCE_LIBS $DESIGN_LIBRARY
} else {
    create_lib -technology $TECH_FILE -ref_libs $REFERENCE_LIBS $DESIGN_LIBRARY
}
read_verilog -top $TOP_MODULE $MAPPED_NETLIST
read_sdc $ICC2_SDC
link_block
save_block

# Core-only floorplan. The technology determines actual units and row/site.
initialize_floorplan -core_utilization $CORE_UTILIZATION -core_offset $CORE_OFFSET

# P/G cannot be portably guessed. The optional adapter is sourced after the
# floorplan so it can use the configured core, POWER_NET, and GROUND_NET.
if {$ICC2_PG_SCRIPT ne ""} {
    require_readable "ICC2 P/G adapter" $ICC2_PG_SCRIPT
    puts "Sourcing P/G adapter: $ICC2_PG_SCRIPT"
    source -echo $ICC2_PG_SCRIPT
} else {
    puts "WARNING: no ICC2_PG_SCRIPT. Continuing for routed-layout visualization only; this run has no P/G signoff evidence."
}
place_pins -self

place_opt
save_block
redirect -file [file join $REPORT_DIR ${TOP_MODULE}_post_place_qor.rpt] {
    report_qor -summary
}

# Follows the Lab 4 sequence: check clocks, then clock_opt (CTS and final opt).
check_clock_trees
clock_opt -to route_clock
clock_opt -from final_opto
save_block
redirect -file [file join $REPORT_DIR ${TOP_MODULE}_post_cts_qor.rpt] {
    report_qor -summary
}
redirect -file [file join $REPORT_DIR ${TOP_MODULE}_clock_qor.rpt] {
    report_clock_qor
}

route_auto
route_opt
save_block

check_legality -verbose
check_routes
redirect -file [file join $REPORT_DIR ${TOP_MODULE}_post_route_qor.rpt] {
    report_qor -summary
}
redirect -file [file join $REPORT_DIR ${TOP_MODULE}_post_route_timing.rpt] {
    report_timing -max_paths 20
}
redirect -file [file join $REPORT_DIR ${TOP_MODULE}_post_route_constraints.rpt] {
    report_constraint -all_violators
}

write_def [file join $RESULT_DIR ${TOP_MODULE}_route.def]
write_verilog -include all [file join $RESULT_DIR ${TOP_MODULE}_route.v]
write_sdc [file join $RESULT_DIR ${TOP_MODULE}_route.sdc]

if {$ICC2_GDS_EXPORT_SCRIPT ne ""} {
    require_readable "ICC2 GDS export adapter" $ICC2_GDS_EXPORT_SCRIPT
    puts "Sourcing GDS export adapter: $ICC2_GDS_EXPORT_SCRIPT"
    source -echo $ICC2_GDS_EXPORT_SCRIPT
} else {
    puts "No GDSII export adapter configured. The saved ICC2 block and DEF are the layout handoff artifacts."
}

puts "ICC2 completed. Open block '$TOP_MODULE' in $DESIGN_LIBRARY to view the routed layout."
puts "DRC/LVS signoff still requires the course-provided ICV/Calibre runsets."

if {$ICC2_OPEN_GUI} {
    start_gui
} else {
    exit
}
