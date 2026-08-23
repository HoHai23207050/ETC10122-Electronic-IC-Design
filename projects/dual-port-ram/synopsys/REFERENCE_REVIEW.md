# Source recheck: course files and external references

## Assignment and teacher-flow evidence

- The MinerU extraction identifies this as topic 14: 2-port RAM, m-bit data by
  2^n addresses, with Verilog, simulation, synthesis, layout, and DRC/LVS.
- The supplied Lab 2a trace uses the SAED32 logical library
  saed32rvt_tt1p05v25c.db, compile_ultra -no_autoungroup, and writes mapped
  Verilog, DDC, SDC, SDF, and SVF. This project emits the same artifact types.
- The supplied Lab 4 evidence runs ICC2 clock_opt, reports clock QoR, and saves
  blocks. This project follows floorplan, placement, CTS, route, and checkpoint
  reports.

## External references checked

1. https://github.com/teekamkhandelwal/Dual_port_ram

   It is a dual-clock RAM with two procedural writers to one memory array and
   no specified same-address collision result. It is not adopted: the course
   constraints use one clock, and the two-writer style is a poor portable
   baseline for a standard-cell Synopsys implementation.

2. https://github.com/EECS150/asic_labs_fa21

   It confirms the physical sequence from RTL through GDS and treats power,
   hard-memory integration, DRC, and LVS as technology-specific work. That
   evidence supports the separate PDK configuration and signoff adapters here.

3. https://github.com/ashwin6696/DUAL-PORT-SRAM-90NM

   Its published archive contains a Cadence 90 nm RTL-to-GDS run. It confirms
   the need for a power grid and timing reports before placement, after CTS, and
   after routing. Its Cadence/90 nm scripts and layer map are not reused because
   they are incompatible with Synopsys/SAED32. Its synthesis log also contains a
   failed SDC command, so constraints were not copied blindly.

## Retained design contract

- One shared clock and two symmetric read/write ports.
- Registered synchronous reads with READ_FIRST behavior.
- Same-address simultaneous writes are invalid traffic; no final data value is
  promised.
- The default is 16 words by 8 bits; depth is 2^ADDR_WIDTH.
- With only the course standard-cell library, this is a synthesized register
  file made from flip-flops and multiplexers, not a compiled two-port SRAM macro.

## What makes the layout

Verilog describes behavior; it does not draw mask polygons. Design Compiler maps
the implementation to SAED32 standard cells. ICC2 combines that mapped netlist,
the generated SDC, physical reference libraries, a technology file, and the
course PDK adapters. Those inputs produce the placed and routed layout.

The P/G adapter and GDS export adapter are separate because their interface is
technology-specific. This gives the portable implementation locality while
preventing invented library paths, power rings, layer maps, or DRC/LVS claims.
