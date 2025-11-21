# PDK setup
# Change these variables to match your PDK
set PDK_PATH "/import/yukari1/pdk/TSMC/28/CMOS/HPC+/stclib/9-track/tcbn28hpcplusbwp30p140-set/tcbn28hpcplusbwp30p140_190a_FE"
set LIB_PATH "$PDK_PATH/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp30p140_180a/tcbn28hpcplusbwp30p140tt0p9v25c.db"
set_app_var target_library $LIB_PATH
set_app_var link_library $LIB_PATH

analyze -f sverilog "lzc_unopt.sv"
elaborate "lzc_unopt"
compile_ultra

report_area
report_power
report_timing

exit
