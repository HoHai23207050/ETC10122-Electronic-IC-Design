# Reproducibility guide

## 1. Inspect the design contract

Read [`../projects/dual-port-ram/README.md`](../projects/dual-port-ram/README.md)
before changing RTL or stimuli. In particular, preserve registered reads,
`READ_FIRST` behavior, output-only reset, and the prohibition on simultaneous
same-address writes.

## 2. Run portable RTL verification

Use EDA Playground or an installed Verilog simulator. The testbench is
self-checking and expects 12 completed checks with zero errors.

## 3. Configure the authorized campus environment

Copy the technology template to a local, untracked configuration and supply
only paths licensed to you. Do not commit `.db`, `.ndm`, GDS, rule decks, or
standard-cell models.

## 4. Execute one stage at a time

Run VCS, Design Compiler, Formality, ICC2, and physical verification in that
order. Stop after each stage to inspect warnings, timing, compare points, and
generated artifacts. A successful command is not by itself evidence of a clean
design.

## 5. Report with scoped language

Record tool version, library corner, constraints, input hashes, and exact log
lines. Distinguish ICC2 legality and route checks from full-deck DRC, and
distinguish Formality from extracted LVS.
