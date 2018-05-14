`ifndef src__slash__register_file_defines_header_sv
`define src__slash__register_file_defines_header_sv

// src/register_file_defines.header.sv

`include "src/misc_defines.header.sv"

`define WIDTH__REG_FILE_SEL 4
`define MSB_POS__REG_FILE_SEL `WIDTH_TO_MSB_POS(`WIDTH__REG_FILE_SEL)

`define WIDTH__REG_FILE_DATA 32
`define MSB_POS__REG_FILE_DATA `WIDTH_TO_MSB_POS(`WIDTH__REG_FILE_DATA)

`define WIDTH__REG_FILE_NUM_PORTS 2
`define MSB_POS__REG_FILE_NUM_PORTS \
	`WIDTH_TO_MSB_POS(`WIDTH__REG_FILE_NUM_PORTS)

`endif		// src__slash__register_file_defines_header_sv
