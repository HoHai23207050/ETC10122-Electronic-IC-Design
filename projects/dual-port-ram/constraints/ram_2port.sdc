# Starter SDC for the default synchronous RAM implementation.
# Update the period, uncertainty, I/O delay, and output load to the values
# assigned by the instructor before treating timing reports as final results.

create_clock -name clk -period 10.000 [get_ports {clk}]
set_clock_uncertainty 0.200 [get_clocks {clk}]

set data_inputs [remove_from_collection [all_inputs] [get_ports {clk}]]
set_input_delay  1.000 -clock clk $data_inputs
set_output_delay 1.000 -clock clk [all_outputs]
set_load 0.050 [all_outputs]
