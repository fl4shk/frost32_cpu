`include "src/frost32_cpu_defines.header.sv"
`include "src/register_file_defines.header.sv"
`include "src/instr_decoder_defines.header.sv"

package PkgFrost32Cpu;

typedef enum logic [`MSB_POS__FROST32_CPU_STATE:0]
{
	StInit,
	StMulDiv,
	StCtrlFlow,
	StMemAccess
} StallState;

// Data used by more than one pipeline stage
typedef struct packed
{
	logic [`MSB_POS__INSTRUCTION:0] raw_instruction;

	// Decoded instruction stuff
	logic [`MSB_POS__INSTR_REG_INDEX:0] instr_ra_index, instr_rb_index,
		instr_rc_index;
	logic [`MSB_POS__INSTR_IMM_VALUE:0] instr_imm_val;
	logic [`MSB_POS__INSTR_OP_GROUP:0] instr_group;
	logic [`MSB_POS__INSTR_OPER:0] instr_opcode;
	logic instr_causes_stall;

	// What the PC was for this instruction
	logic [`MSB_POS__REG_FILE_DATA:0] pc_val;

	//logic nop;

} MultiStageData;



typedef struct packed
{
	logic [`MSB_POS__FROST32_CPU_DATA_INOUT:0] data;
	//logic interrupt;
} PortIn_Frost32Cpu;

typedef enum logic
{
	DiatRead,
	DiatWrite
} DataInoutAccessType;

typedef enum logic [`MSB_POS__FROST32_CPU_DATA_ACCESS_SIZE:0]
{
	Dias32,
	Dias16,
	Dias8,
	DiasBad
} DataInoutAccessSize;

typedef struct packed
{
	logic [`MSB_POS__FROST32_CPU_DATA_INOUT:0] data;
	logic [`MSB_POS__FROST32_CPU_ADDR:0] addr;
	logic data_inout_access_type;
	logic [`MSB_POS__FROST32_CPU_DATA_ACCESS_SIZE:0]
		data_inout_access_size;
	logic req_mem_access;
} PortOut_Frost32Cpu;

endpackage : PkgFrost32Cpu