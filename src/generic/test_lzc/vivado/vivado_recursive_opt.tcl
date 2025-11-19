read_verilog ../lzc.sv
synth_design -top lzc
opt_design
report_utilization
report_timing
report_power
