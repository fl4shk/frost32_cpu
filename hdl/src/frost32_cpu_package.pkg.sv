`include "src/frost32_cpu_defines.header.sv"
`include "src/register_file_defines.header.sv"
`include "src/instr_decoder_defines.header.sv"

package PkgFrost32Cpu;

typedef enum logic [`MSB_POS__FROST32_CPU_STATE:0]
{
	StInit,
	StRespondToInterrupt,
	StReti,
	StOther,
	//StMul,
	StDiv,
	StCtrlFlowBranch,
	StCtrlFlowJumpCall,
	StCpyRaToInterruptsRelatedAddr,
	StMemAccess
} StallState;

// Data used by more than one pipeline stage
typedef struct packed
{
	// For debugging
	logic [`MSB_POS__INSTRUCTION:0] raw_instruction;

	// Decoded instruction stuff
	logic [`MSB_POS__INSTR_REG_INDEX:0] instr_ra_index, instr_rb_index,
		instr_rc_index;
	logic [`MSB_POS__INSTR_IMM_VALUE:0] instr_imm_val;
	logic [`MSB_POS__INSTR_OP_GROUP:0] instr_group;
	logic [`MSB_POS__INSTR_OPER:0] instr_opcode;
	logic [`MSB_POS__INSTR_LDST_TYPE:0] instr_ldst_type;
	logic instr_causes_stall;
	logic [`MSB_POS__INSTR_CONDITION_TYPE:0] instr_condition_type;


	// What the PC was for this instruction
	logic [`MSB_POS__REG_FILE_DATA:0] pc_val;

	logic nop;



} MultiStageData;



typedef struct packed
{
	logic [`MSB_POS__FROST32_CPU_DATA_INOUT:0] data;

	logic wait_for_mem;
	logic interrupt;
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
	//logic [`MSB_POS__FROST32_CPU_DATA_INOUT:0] data;
	//logic [`MSB_POS__FROST32_CPU_ADDR:0] addr;
	//logic data_inout_access_type;
	//logic [`MSB_POS__FROST32_CPU_DATA_ACCESS_SIZE:0]
	//	data_inout_access_size;
	//logic req_mem_access;
	`MAKE_LIST_OF_MEMBERS__FROST32_CPU_PORTOUT_MEM_ACCESS

	`ifdef OPT_DEBUG_REGISTER_FILE
	logic [`MSB_POS__REG_FILE_DATA:0] debug_reg_zero, debug_reg_u0,
		debug_reg_u1, debug_reg_u2, debug_reg_u3, debug_reg_u4,
		debug_reg_u5, debug_reg_u6, debug_reg_u7, debug_reg_u8,
		debug_reg_u9, debug_reg_u10, debug_reg_temp, debug_reg_lr,
		debug_reg_fp, debug_reg_sp;
	`endif		// OPT_DEBUG_REGISTER_FILE
} PortOut_Frost32Cpu;

endpackage : PkgFrost32Cpu
