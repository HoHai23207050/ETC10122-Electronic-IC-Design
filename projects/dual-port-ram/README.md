# True dual-port RAM

This project implements a parameterized synchronous dual-port memory for the
ETC10122 digital IC flow.

## Interface contract

- Default organization: 16 words × 8 bits.
- One shared rising-edge clock and two symmetric ports.
- Independent read enable, write enable, address, write data, and registered
  read data on each port.
- Active-high asynchronous reset for the two output registers only; the memory
  array is intentionally not reset.
- Same-cycle read and write to one address uses `READ_FIRST` semantics.
- Simultaneous writes to the same address are illegal stimulus.
- Read outputs retain their previous values while their read enables are low.

## Layout

```text
rtl/          Synthesizable Verilog
tb/           Self-checking 12-check testbench
constraints/  Baseline SDC
scripts/      Design Compiler template
synopsys/     VCS, DC, Formality, ICC2, and scoped ICV guidance
```

## Quick simulation

On EDA Playground, select Verilog and Icarus Verilog, place
`tb/ram_2port_tb.v` in the testbench pane, place `rtl/ram_2port.v` in the design
pane, and run. A correct execution ends with 12 checks and zero errors.

On a machine with Icarus Verilog:

```bash
iverilog -g2012 -o build/ram_2port_tb \
  rtl/ram_2port.v tb/ram_2port_tb.v
vvp build/ram_2port_tb
```

## ASIC handoff

The portable scripts deliberately omit licensed SAED libraries and rule decks.
Configure `synopsys/config/technology_setup.tcl.template` for the authorized
campus installation, then run the stages individually and review every report.
The project is a synthesized register-file implementation unless an explicitly
verified two-port memory macro is selected.

The verified release and its boundaries are summarized in
[`../../docs/EVIDENCE.md`](../../docs/EVIDENCE.md).
