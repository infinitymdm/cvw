read_verilog lzc_priority.sv
synth_design -top lzc
opt_design
report_utilization
report_timing
report_power
