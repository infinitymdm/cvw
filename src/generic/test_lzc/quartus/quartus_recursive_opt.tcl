package require ::quartus::project
package require ::quartus::flow

set PROJECT_NAME "lzc_recursive_opt"
set PWD [pwd]

project_new $PROJECT_NAME -overwrite
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "$PWD/quartus/output_files"
set_global_assignment -name TOP_LEVEL_ENTITY "lzc"
set_global_assignment -name SYSTEMVERILOG_FILE "$PWD/../lzc.sv"
execute_flow -analysis_and_elaboration
project_close
