# PDK setup
# Change these variables to match your PDK
set PDK_PATH "/import/yukari1/pdk/TSMC/28/CMOS/HPC+/stclib/9-track/tcbn28hpcplusbwp30p140-set/tcbn28hpcplusbwp30p140_190a_FE"
set LIB_PATH "$PDK_PATH/TSMCHOME/digital/Front_End/timing_power_noise/NLDM/tcbn28hpcplusbwp30p140_180a"
set_db lib_search_path $LIB_PATH
set_db library "$LIB_PATH/tcbn28hpcplusbwp30p140tt0p9v25c.lib"

read_hdl -sv "lzc_unopt.sv"
elaborate "lzc_unopt"
syn_generic

report_area
report_power
report_timing -unconstrained

exit
