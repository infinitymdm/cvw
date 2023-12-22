# Device information
dev_family := "artix7"
dev_model := "xc7a100t"
dev_submodel := dev_model + "csg324-1"

# Project X-ray tools
xray_dir := "~/software/prjxray"
xray_utils_dir := xray_dir + "/utils"
xray_tools_dir := xray_dir + "/build/tools"
xray_db_dir := xray_dir + "/database"

# nextpnr-xilinx tools
nextpnr_dir := "~/software/nextpnr-xilinx"

# synlig tools (yosys, surelog, etc)
synlig_dir := "~/software/synlig/out/release/bin"
yosys := synlig_dir + "/yosys"

design := "wally"
isa := "rv64gc"
top := "fpgaTop"
config := "config/"+isa+"/config.vh config/shared/BranchPredictorType.vh config/shared/config-shared.vh config/shared/parameter-defs.vh"
sources := "fpga/src/fpgaTopArtyA7.sv src/cvw.sv `find src/* -name *.sv`"
constraints := ""

env:
	echo "XRAY_DATABASE={{dev_family}} XRAY_PART={{dev_submodel}} source {{xray_utils_dir}}/environment.sh"

build-chipdb:
	pypy3 {{nextpnr_dir}}/xilinx/python/bbaexport.py --device {{dev_submodel}} --bba {{dev_model}}.bba
	bbasm --l {{dev_model}}.bba {{dev_model}}.bin

# Synthesize and layout the design
synth:
	{{yosys}} -q \
		-p "plugin -i systemverilog" \
		-p "read_systemverilog {{config}} {{sources}}" \
		-p "synth_xilinx -flatten -nowidelut -abc9 -arch xc7 -top {{top}}" \
		-p "write_json {{design}}.json"
	nextpnr-xilinx -q --chipdb {{dev_model}}.bin --xdc constraints/arty.xdc --json {{design}}.json --write {{design}}_routed.json --fasm {{design}}.fasm
	{{xray_utils_dir}}/fasm2frames.py --db-root {{xray_db_dir}}/{{dev_family}} --part {{dev_submodel}} {{design}}.fasm > {{design}}.frames
	{{xray_tools_dir}}/xc7frames2bit --part_file {{xray_db_dir}}/{{dev_family}}/{{dev_submodel}}/part.yaml --part_name {{dev_submodel}} --frm_file {{design}}.frames --output_file {{design}}.bit

# Upload the synthesized bitstream to the device
upload:
	openFPGALoader -b arty {{design}}.bit
