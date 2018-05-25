`ifndef src__slash__frost32_cpu_defines_header_sv
`define src__slash__frost32_cpu_defines_header_sv

// src/frost32_cpu_defines.header.sv

`include "src/misc_defines.header.sv"

`define WIDTH__FROST32_CPU_DATA_INOUT 32
`define MSB_POS__FROST32_CPU_DATA_INOUT \
	`WIDTH_TO_MSB_POS(`WIDTH__FROST32_CPU_DATA_INOUT)

`define WIDTH__FROST32_CPU_ADDR 32
`define MSB_POS__FROST32_CPU_ADDR \
	`WIDTH_TO_MSB_POS(`WIDTH__FROST32_CPU_ADDR)

`define WIDTH__FROST32_CPU_DATA_ACCESS_SIZE 2
`define MSB_POS__FROST32_CPU_DATA_ACCESS_SIZE \
	`WIDTH_TO_MSB_POS(`WIDTH__FROST32_CPU_DATA_ACCESS_SIZE)

//`define WIDTH__FROST32_CPU_DECODE_STAGE_STALL_COUNTER 3
//`define WIDTH__FROST32_CPU_DECODE_STAGE_STALL_COUNTER 8
`ifdef OPT_FAST_DIV
`define WIDTH__FROST32_CPU_DECODE_STAGE_STALL_COUNTER 5
`else
`define WIDTH__FROST32_CPU_DECODE_STAGE_STALL_COUNTER 6
`endif		// OPT_FAST_DIV
`define MSB_POS__FROST32_CPU_DECODE_STAGE_STALL_COUNTER \
	`WIDTH_TO_MSB_POS(`WIDTH__FROST32_CPU_DECODE_STAGE_STALL_COUNTER)

`define WIDTH__FROST32_CPU_EXEC_STAGE_COUNTER 3
`define MSB_POS__FROST32_CPU_EXEC_STAGE_COUNTER \
	`WIDTH_TO_MSB_POS(`WIDTH__FROST32_CPU_EXEC_STAGE_COUNTER)

`define WIDTH__FROST32_CPU_STATE 4
`define MSB_POS__FROST32_CPU_STATE \
	`WIDTH_TO_MSB_POS(`WIDTH__FROST32_CPU_STATE)

// Used because Icarus Verilog doesn't support (as of this comment being
// written) packed structs inside other packed structs.
`define MAKE_LIST_OF_MEMBERS__FROST32_CPU_PORTOUT_MEM_ACCESS \
	logic [`MSB_POS__FROST32_CPU_DATA_INOUT:0] data; \
	logic [`MSB_POS__FROST32_CPU_ADDR:0] addr; \
	logic data_inout_access_type; \
	logic [`MSB_POS__FROST32_CPU_DATA_ACCESS_SIZE:0] data_inout_access_size; \
	logic req_mem_access;

`endif		// src__slash__frost32_cpu_defines_header_sv
