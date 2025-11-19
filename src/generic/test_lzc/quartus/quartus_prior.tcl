package require ::quartus::project
package require ::quartus::flow
package require ::quartus::sta

set PROJECT_NAME "lzc_prior"
set PWD [pwd]

project_new $PROJECT_NAME -overwrite
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY "$PWD/quartus/outputs_prior"
set_global_assignment -name TOP_LEVEL_ENTITY "lzc_prior"
set_global_assignment -name SYSTEMVERILOG_FILE "$PWD/lzc_prior.sv"
if {[catch {execute_flow -analysis_and_elaboration} result]} {
    # We expect an error here
    project_close
}
project_close
