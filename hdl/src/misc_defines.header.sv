`ifndef src__slash__misc_defines_header_sv
`define src__slash__misc_defines_header_sv

// src/misc_defines.header.sv

`define WIDTH_TO_MSB_POS(some_width) ((some_width) - 1)
`define ARR_SIZE_TO_LAST_INDEX(some_size) ((some_size) - 1)

`ifdef ICARUS
`define OPT_DEBUG
`define OPT_DEBUG_INSTR_DECODER
`define OPT_DEBUG_MEM_ACCESS
`define OPT_DEBUG_REGISTER_FILE
//`define OPT_HAVE_SINGLE_CYCLE_MULTIPLY
`endif		// ICARUS

// Temporary
`define OPT_DEBUG_REGISTER_FILE

`define OPT_HAVE_STAGE_REGISTER_READ

`ifndef OPT_HAVE_STAGE_REGISTER_READ
`define OPT_HAVE_SINGLE_CYCLE_MULTIPLY
`endif		// OPT_HAVE_STAGE_REGISTER_READ

`endif		// src__slash__misc_defines_header_sv
