`include "src/instr_decoder_defines.header.sv"

package PkgInstrDecoder;


//parameter POS_HIGH__INSTR_GROUP = 31;
//parameter POS_LOW__INSTR_GROUP = 28;
//
//parameter POS_HIGH__RA_INDEX = 27;
//parameter POS_LOW__RA_INDEX = 24;
//
//parameter POS_HIGH__RB_INDEX = 23;
//parameter POS_LOW__RB_INDEX = 20;

typedef enum logic [`MSB_POS__INSTR_LDST_TYPE:0]
{
	Ld32,
	LdU16,
	LdS16,
	LdU8,
	LdS8,
	St32,
	St16,
	St8
} LdstType;


typedef struct packed
{
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index, rc_index;
	logic [`MSB_POS__INSTR_OP_GROUP:0] opcode;
	logic [`MSB_POS__INSTR_IMM_VALUE:0] imm_val;
	logic [`MSB_POS__INSTR_LDST_TYPE:0] ldst_type;
	logic causes_stall;
} PortOut_InstrDecoder;

typedef struct packed
{
	// should be 4'b0000
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index, rc_index;

	// blank (should be filled with zeroes)
	logic [`MSB_POS__INSTR_FILL:0] fill;
	logic [`MSB_POS__INSTR_OPER:0] opcode;
} Iog0Instr;

typedef struct packed
{
	// should be 0b0001
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index;
	logic [`MSB_POS__INSTR_OPER:0] opcode;
	logic [`MSB_POS__INSTR_IMM_VALUE:0] imm_val;
} Iog1Instr;

typedef struct packed
{
	// should be 0b0010
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index, rc_index;

	// blank (should be filled with zeroes)
	logic [`MSB_POS__INSTR_FILL:0] fill;
	logic [`MSB_POS__INSTR_OPER:0] opcode;
} Iog2Instr;

typedef struct packed
{
	// should be 0b0011
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index, rc_index;

	// blank (should be filled with zeroes)
	logic [`MSB_POS__INSTR_FILL:0] fill;
	logic [`MSB_POS__INSTR_OPER:0] opcode;
} Iog3Instr;

typedef enum logic [`MSB_POS__INSTR_OPER:0]
{
	Add_ThreeRegs,
	Sub_ThreeRegs,
	Sltu_ThreeRegs,
	Slts_ThreeRegs,

	Mul_ThreeRegs,
	And_ThreeRegs,
	Orr_ThreeRegs,
	Xor_ThreeRegs,

	Nor_ThreeRegs,
	Lsl_ThreeRegs,
	Lsr_ThreeRegs,
	Asr_ThreeRegs,

	Bad0_Iog0,
	Bad1_Iog0,
	Bad2_Iog0,
	Bad3_Iog0
} Iog0Oper;

typedef enum logic [`MSB_POS__INSTR_OPER:0]
{
	Addi_TwoRegsOneImm,
	Subi_TwoRegsOneImm,
	Sltui_TwoRegsOneImm,
	Sltsi_TwoRegsOneSimm,

	Muli_TwoRegsOneImm,
	Andi_TwoRegsOneImm,
	Orri_TwoRegsOneImm,
	Xori_TwoRegsOneImm,

	Nori_TwoRegsOneImm,
	Lsli_TwoRegsOneImm,
	Lsri_TwoRegsOneImm,
	Asri_TwoRegsOneImm,

	Addsi_OneRegOnePcOneSimm,
	Cpyhi_OneRegOneImm,
	Bne_TwoRegsOneSimm,
	Beq_TwoRegsOneSimm
} Iog1Oper;

typedef enum logic [`MSB_POS__INSTR_OPER:0]
{
	Jne_ThreeRegs,
	Jeq_ThreeRegs,
	Callne_ThreeRegs,
	Calleq_ThreeRegs,

	Bad0_Iog2,
	Bad1_Iog2,
	Bad2_Iog2,
	Bad3_Iog2,

	Bad4_Iog2,
	Bad5_Iog2,
	Bad6_Iog2,
	Bad7_Iog2,

	Bad8_Iog2,
	Bad9_Iog2,
	Bad10_Iog2,
	Bad11_Iog2
} Iog2Oper;

typedef enum logic [`MSB_POS__INSTR_OPER:0]
{
	Ldr_ThreeRegsLdst,
	Ldh_ThreeRegsLdst,
	Ldsh_ThreeRegsLdst,
	Ldb_ThreeRegsLdst,

	Ldsb_ThreeRegsLdst,
	Str_ThreeRegsLdst,
	Sth_ThreeRegsLdst,
	Stb_ThreeRegsLdst,

	Bad0_Iog3,
	Bad1_Iog3,
	Bad2_Iog3,
	Bad3_Iog3,

	Bad4_Iog3,
	Bad5_Iog3,
	Bad6_Iog3,
	Bad7_Iog3

} Iog3Oper;


endpackage : PkgInstrDecoder
