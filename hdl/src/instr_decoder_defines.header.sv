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

`define WIDTH__INSTRUCTION 32
`define MSB_POS__INSTRUCTION `WIDTH_TO_MSB_POS(`WIDTH__INSTRUCTION)

`define WIDTH__INSTR_REG_INDEX 4
`define MSB_POS__INSTR_REG_INDEX `WIDTH_TO_MSB_POS(`WIDTH__INSTR_REG_INDEX)

`define WIDTH__INSTR_FILL 12
`define MSB_POS__INSTR_FILL `WIDTH_TO_MSB_POS(`WIDTH__INSTR_FILL)

`define WIDTH__INSTR_LDST_IMM_VAL_12 12
`define MSB_POS__INSTR_LDST_IMM_VAL_12 \
	`WIDTH_TO_MSB_POS(`WIDTH__INSTR_LDST_IMM_VAL_12)

`define WIDTH__INSTR_LDST_TYPE 3
`define MSB_POS__INSTR_LDST_TYPE `WIDTH_TO_MSB_POS(`WIDTH__INSTR_LDST_TYPE)


`endif		// src__slash__instr_decoder_defines_header_sv
