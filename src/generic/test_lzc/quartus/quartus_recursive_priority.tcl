package require ::quartus::project
package require ::quartus::flow
package require ::quartus::sta

set PROJECT_NAME "lzc_recursive_priority"
set PWD [pwd]

project_new $PROJECT_NAME -overwrite
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "$PWD/quartus/outputs_recursive_priority"
set_global_assignment -name TOP_LEVEL_ENTITY "lzc"
set_global_assignment -name SYSTEMVERILOG_FILE "$PWD/lzc_priority.sv"
execute_flow -analysis_and_elaboration
execute_flow -compile
create_timing_netlist -post_map
report_datasheet
project_close
