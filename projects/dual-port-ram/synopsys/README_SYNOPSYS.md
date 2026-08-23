# Synopsys handoff: RTL to standard-cell layout

This folder is the source set to copy to the university Synopsys environment.
It follows the course sequence found in the Lab 2/4 materials:

```text
ram_2port.v + ram_2port.sdc
        │
        ├─ dc_shell-t  → mapped Verilog, DDC, SDF, SVF, timing/area reports
        ├─ fm_shell    → RTL-to-gate equivalence report
        └─ icc2_shell  → floorplan → placement → CTS → routing → DEF/layout
```

## One-time configuration in the laboratory

From the project root on the school Linux machine:

```bash
cp synopsys/config/technology_setup.tcl.template synopsys/config/technology_setup.tcl
```

Open `synopsys/config/technology_setup.tcl`. The template contains the exact
SAED32 logical-library path recorded in the supplied Lab 2a trace; first check
that it is readable on the school server. For ICC2, ask for (or copy from a
working lab `load.tcl`) the matching physical `REFERENCE_LIBS` and, if used,
the `TECH_FILE`. Also obtain the PDK-qualified `ICC2_PG_SCRIPT` and
`ICC2_GDS_EXPORT_SCRIPT`. The flow deliberately halts when physical libraries
are absent and does not invent their paths.

Load the same Synopsys environment used in the teacher's tutorial, then run:

```bash
source /home/share/Env/synopsys_setup.env
dc_shell-t -f synopsys/dc/run_dc.tcl | tee synopsys/dc/dc.log
fm_shell -f synopsys/formal/run_formality.tcl | tee synopsys/formal/formality.log
icc2_shell -f synopsys/icc2/run_icc2.tcl | tee synopsys/icc2/icc2.log
```

The last command opens ICC2 when `ICC2_OPEN_GUI` is `1`. Use the design block
saved in `synopsys/icc2/work/ram_2port.dlib` to show placement, CTS, and routed
layout. A configured P/G adapter adds the technology-specific power grid; a
configured GDS adapter exports GDSII. The output reports are written below `synopsys/dc/reports`,
`synopsys/formal/reports`, and `synopsys/icc2/reports`.

## VCS verification at school

The RTL testbench now checks same-port and cross-port same-address READ_FIRST
behavior. Run it with the teacher-style VCS command wrapper:

```bash
bash synopsys/vcs/run_rtl_vcs.sh
```

After Design Compiler, run gate-level simulation only with the exact SAED32
Verilog cell model supplied by the school:

```bash
bash synopsys/vcs/run_postsyn_vcs.sh /actual/path/to/saed32nm.v
```

## Important scope statement for the project report

This RTL is a 16-word × 8-bit **true dual-port synchronous RAM model** at the
default parameters. With only the course standard-cell library, Design
Compiler realizes it as registers and multiplexers; ICC2 then creates a
**standard-cell layout**. It is not a dense compiled 2-port SRAM macro.

A real SRAM macro requires the foundry/memory compiler's matching timing
library (`.lib`/`.db`), physical abstract (`LEF`/`NDM`), GDS, and simulation
model. Do not state that the current implementation is a compiled SRAM unless
the teacher supplies and the design instantiates such a macro.

## DRC/LVS

`check_legality` and `check_routes` are implementation checks, not signoff
DRC/LVS. Final DRC/LVS needs the exact ICV/Calibre decks supplied for the lab
PDK. The required boundary and evidence are documented in
[`icv/README_DRC_LVS.md`](icv/README_DRC_LVS.md).

## EDA Playground remains separate

For browser simulation, paste only:

- `rtl/ram_2port.v` into **Design**;
- `tb/ram_2port_tb.v` into **Testbench**.

Choose **SystemVerilog/Verilog**, **Icarus Verilog 12.0**, tick **Open EPWave
after run**, then run. EDA Playground validates the RTL testbench; it does not
contain the licensed PDK, Design Compiler, or ICC2 required for physical layout.
