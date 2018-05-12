`ifndef src__slash__instr_decoder_defines_header_sv
`define src__slash__instr_decoder_defines_header_sv

// src/instr_decoder_defines.header.sv

`include "src/misc_defines.header.sv"

`define WIDTH__INSTR_OP_GROUP 4
`define MSB_POS__INSTR_OP_GROUP `WIDTH_TO_MSB_POS(`WIDTH__INSTR_OP_GROUP)

`define WIDTH__INSTR_OPER 4
`define MSB_POS__INSTR_OPER `WIDTH_TO_MSB_POS(`WIDTH__INSTR_OPER)

//`define WIDTH__INSTR_REG_INDEX 4
//`define MSB_POS__INSTR_REG_INDEX 

`define WIDTH__INSTR_IMM_VALUE 16
`define MSB_POS__INSTR_IMM_VALUE `WIDTH_TO_MSB_POS(`WIDTH__INSTR_IMM_VALUE)

`endif		// src__slash__instr_decoder_defines_header_sv
