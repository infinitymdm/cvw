package require ::quartus::project
package require ::quartus::flow

set PROJECT_NAME "lzc_prior"
set PWD [pwd]

project_new $PROJECT_NAME -overwrite
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "$PWD/quartus/output_files"
set_global_assignment -name TOP_LEVEL_ENTITY "lzc_prior"
set_global_assignment -name SYSTEMVERILOG_FILE "$PWD/lzc_prior.sv"
execute_flow -analysis_and_elaboration
project_close
