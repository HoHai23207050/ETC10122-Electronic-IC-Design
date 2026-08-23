# Home layout demo with OpenLane 2

This is an optional home demonstration of an ASIC RTL-to-GDSII flow.  It is **not** a replacement for the required Synopsys ICC2 layout, SAED32 technology files, or final DRC/LVS evidence from the university laboratory.

OpenLane will use the open Sky130 PDK.  The RAM RTL is expected to synthesize as a small standard-cell register file (flip-flops, decoders, and multiplexers), not as a custom SRAM memory macro.

## Prerequisites

- Windows 10 version 2004 or newer / Windows 11.
- WSL2 with Ubuntu.
- Docker Desktop with the WSL2 engine and Ubuntu integration enabled.
- At least 8 GB RAM; 16 GB is the practical target.

## One-time installation

Run this in **PowerShell** and restart if Windows requests it:

```powershell
wsl --install -d Ubuntu
```

Install Docker Desktop.  During installation choose **Use WSL 2 instead of Hyper-V**.  In Docker Desktop, enable WSL Integration for Ubuntu.

Open an Ubuntu terminal and run:

```bash
sudo apt-get update
sudo apt-get upgrade
sudo apt install -y build-essential python3 python3-venv python3-pip python3-tk curl make git
python3 -m pip install --user openlane
python3 -m openlane --dockerized --smoke-test
```

The smoke test must complete before attempting this design.  The first run downloads the OpenLane container and open PDK data, so it needs a stable network connection and substantial free disk space.

## Run this RAM layout demo

Copy the project to the Linux home directory first; this avoids Windows-mounted-path performance problems.

```bash
cp -r /mnt/d/ThietKeViMachDienTu/ram_2port_eda_playground ~/ram_2port_eda_playground
python3 -m openlane --dockerized ~/ram_2port_eda_playground/openlane_config.json
```

The configuration uses a relaxed 20 ns clock for the first physical-design trial.  Do not use its area/timing values as the official SAED32 report.

## Inspect and capture results

When the flow completes:

```bash
python3 -m openlane --dockerized --last-run --flow openinklayout ~/ram_2port_eda_playground/openlane_config.json
```

In KLayout, capture the top-level GDSII layout.  Then inspect the run directory under `~/ram_2port_eda_playground/runs/` and keep:

- final GDSII/DEF layout;
- synthesis, timing, and area reports;
- Magic and KLayout DRC reports;
- Netgen LVS report.

For an academic report, label these outputs clearly as **OpenLane/Sky130 home demonstration**.  The official results remain the VCS → Design Compiler → Formality/post-synthesis → ICC2 flow with the lecturer's SAED32 library and verification decks.
