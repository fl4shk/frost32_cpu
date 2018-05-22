`ifndef src__slash__cache_defines_header_sv
`define src__slash__cache_defines_header_sv

// src/cache_defines.header.sv

`include "src/misc_defines.header.sv"

`define WIDTH__CACHE_DATA_INOUT 32
`define MSB_POS__CACHE_DATA_INOUT \
	`WIDTH_TO_MSB_POS(`WIDTH__CACHE_DATA_INOUT)

`define WIDTH__CACHE_ADDR 32
`define MSB_POS__CACHE_ADDR \
	`WIDTH_TO_MSB_POS(`WIDTH__CACHE_ADDR)


`define WIDTH__CACHE_LINE_DATA 512
`define MSB_POS__CACHE_LINE_DATA \
	`WIDTH_TO_MSB_POS(`WIDTH__CACHE_LINE_DATA)

`endif		// src__slash__cache_defines_header_sv
