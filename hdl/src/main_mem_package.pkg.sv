`include "src/main_mem_defines.header.sv"
`include "src/frost32_cpu_defines.header.sv"
`include "src/register_file_defines.header.sv"
`include "src/instr_decoder_defines.header.sv"

package PkgMainMem;

typedef struct packed
{
	`MAKE_LIST_OF_MEMBERS__FROST32_CPU_PORTOUT_MEM_ACCESS
} PortIn_MainMem;

typedef struct packed
{
	logic [`MSB_POS__FROST32_CPU_DATA_INOUT:0] data;
	logic wait_for_mem;
} PortOut_MainMem;


endpackage : PkgMainMem
