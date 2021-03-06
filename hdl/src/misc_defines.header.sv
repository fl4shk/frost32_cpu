`ifndef src__slash__misc_defines_header_sv
`define src__slash__misc_defines_header_sv

// src/misc_defines.header.sv

`define WIDTH_TO_MSB_POS(some_width) ((some_width) - 1)
`define ARR_SIZE_TO_LAST_INDEX(some_size) ((some_size) - 1)

`include "src/options_defines.header.sv"
`default_nettype none

`endif		// src__slash__misc_defines_header_sv
