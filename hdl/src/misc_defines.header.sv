`ifndef src__slash__misc_defines_header_sv
`define src__slash__misc_defines_header_sv

// src/misc_defines.header.sv

`define WIDTH_TO_MSB_POS(some_width) ((some_width) - 1)
`define ARR_SIZE_TO_LAST_INDEX(some_size) ((some_size) - 1)

`ifdef ICARUS
`define DEBUG
`define DEBUG_INSTR_DECODER
`define DEBUG_MEM_ACCESS
`define DEBUG_REGISTER_FILE
//`define USE_SINGLE_CYCLE_MULTIPLY
`endif		// ICARUS

// Temporary
//`define DEBUG_REGISTER_FILE

`define USE_SINGLE_CYCLE_MULTIPLY
`define HAVE_REGISTER_READ_STAGE

`endif		// src__slash__misc_defines_header_sv
