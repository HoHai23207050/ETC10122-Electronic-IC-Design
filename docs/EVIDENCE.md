# Verified evidence and limitations

## Recorded implementation results

| Check | Result |
|---|---:|
| RTL simulation | 12/12 checks; 0 errors |
| Design Compiler inventory | 46 ports; 626 nets; 596 cells; 0 macros |
| Cell area | 2,134.809647 |
| Cell plus net area | 2,755.747303 |
| Post-synthesis Formality | 160 passing; 0 failing |
| Post-synthesis simulation | 12/12 passing |
| ICC2 internal checks | 0 illegal placements; 0 open nets; 0 route violations; 0 internal shorts/opens |
| Post-route timing | +174.712677 ns setup; +0.053265 ns hold |
| Post-PnR Formality | 160 passing; 0 failing |

## Claim boundaries

- The full ICV deck retained 84 M1/VIA1 violations. The project therefore does
  not claim full-deck DRC closure.
- No extracted LVS result was available. Internal connectivity checks and
  Formality are not presented as LVS.
- Antenna checking reported zero violations only for analyzed nets. Thirty
  top-level nets were skipped because their pin models lacked gate-area
  information, so antenna closure is not claimed.
- The implementation is not represented as tapeout-ready or foundry-qualified.
- All values are tied to the documented course run and should be regenerated
  if RTL, constraints, libraries, or scripts change.
