# DRC/LVS boundary

`ram_2port.v` and ICC2 can create a standard-cell implementation layout, but
they cannot generate a valid signoff DRC/LVS deck. The deck is owned by the
technology PDK and is specific to the exact process/library used by the lab.

Before asserting DRC/LVS clean in the report, obtain from the instructor or
the laboratory's existing project:

1. The exact physical reference libraries and technology file used by ICC2.
2. The PDK-qualified GDS export procedure and layer map.
3. The ICV or Calibre DRC runset and LVS runset, including the required
   `TOP_CELL`, GDS/OASIS input, schematic/netlist input, and power/ground net
   names.

Populate `ICV_DRC_RUNSET`, `ICV_LVS_RUNSET`, and `GDS_LAYER_MAP` in
`synopsys/config/technology_setup.tcl` only with those official files. Do not
reuse a runset from a different technology node, and do not label an ICC2
`check_routes` result as foundry DRC/LVS.
