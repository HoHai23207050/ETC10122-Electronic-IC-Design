#!/usr/bin/env bash
# Gate-level simulation after Design Compiler. Provide the SAED32 Verilog cell
# model from the school lab as the first argument:
#   bash synopsys/vcs/run_postsyn_vcs.sh /path/to/saed32nm.v

set -eu

if [ "$#" -ne 1 ] || [ ! -r "$1" ]; then
    echo "Usage: bash synopsys/vcs/run_postsyn_vcs.sh /path/to/saed32nm.v" >&2
    exit 2
fi

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
WORK_DIR="$SCRIPT_DIR/work_postsyn"
NETLIST="$PROJECT_ROOT/synopsys/dc/output/ram_2port_mapped.v"

if [ ! -r "$NETLIST" ]; then
    echo "Missing mapped netlist. Run: dc_shell-t -f synopsys/dc/run_dc.tcl" >&2
    exit 2
fi

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

vcs -full64 -gui -debug_all \
    "$PROJECT_ROOT/tb/ram_2port_tb.v" \
    "$NETLIST" \
    "$1" \
    -o simv

./simv | tee postsyn_simulation.log
