#!/usr/bin/env bash
# Teacher-style RTL simulation with VCS. Run from any directory:
#   bash synopsys/vcs/run_rtl_vcs.sh

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)
WORK_DIR="$SCRIPT_DIR/work_rtl"

mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

vcs -full64 -gui -debug_all \
    "$PROJECT_ROOT/tb/ram_2port_tb.v" \
    "$PROJECT_ROOT/rtl/ram_2port.v" \
    -o simv

./simv | tee rtl_simulation.log
