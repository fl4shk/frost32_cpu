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

`define WIDTH__FROST32_CPU_DECODE_STAGE_STALL_COUNTER 3
`define MSB_POS__FROST32_CPU_DECODE_STAGE_STALL_COUNTER \
	`WIDTH_TO_MSB_POS(`WIDTH__FROST32_CPU_DECODE_STAGE_STALL_COUNTER)

`define WIDTH__FROST32_CPU_EXEC_STAGE_COUNTER 3
`define MSB_POS__FROST32_CPU_EXEC_STAGE_COUNTER \
	`WIDTH_TO_MSB_POS(`WIDTH__FROST32_CPU_EXEC_STAGE_COUNTER)

`define WIDTH__FROST32_CPU_STATE 2
`define MSB_POS__FROST32_CPU_STATE \
	`WIDTH_TO_MSB_POS(`WIDTH__FROST32_CPU_STATE)

`endif		// src__slash__frost32_cpu_defines_header_sv