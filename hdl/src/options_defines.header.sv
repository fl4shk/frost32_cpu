// src/options_defines.header.sv

`ifdef ICARUS
`define OPT_DEBUG
`define OPT_DEBUG_INSTR_DECODER
`define OPT_DEBUG_MEM_ACCESS
`define OPT_DEBUG_REGISTER_FILE
//`define OPT_HAVE_SINGLE_CYCLE_MULTIPLY
`endif		// ICARUS

// Temporary
`define OPT_DEBUG_REGISTER_FILE

//`ifdef OPT_NEW_PIPELINE
//`define OPT_HAVE_STAGE_INSTR_FETCH
//
//`else
//`define OPT_HAVE_STAGE_REGISTER_READ
//
//`ifndef OPT_HAVE_STAGE_REGISTER_READ
//`define OPT_HAVE_SINGLE_CYCLE_MULTIPLY
//`endif		// !OPT_HAVE_STAGE_REGISTER_READ
