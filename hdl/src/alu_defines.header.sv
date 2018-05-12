`ifndef src__slash__alu_defines_header_sv
`define src__slash__alu_defines_header_sv

// src/alu_defines.header.sv

`include "src/misc_defines.header.sv"


`define WIDTH__ALU_INOUT 32
`define MSB_POS__ALU_INOUT `WIDTH_TO_MSB_POS(`WIDTH__ALU_INOUT)

`define WIDTH__ALU_OPER 4
`define MSB_POS__ALU_OPER `WIDTH_TO_MSB_POS(`WIDTH__ALU_OPER)


`endif		// src__slash__alu_defines_header_sv
