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

typedef enum logic [`MSB_POS__INSTR_CONDITION_TYPE:0]
{
	CtNe,
	CtEq,
	CtLtu,
	CtGeu,

	CtLeu,
	CtGtu,
	CtLts,
	CtGes,

	//CtLes,
	//CtGts,
	//CtBad0,
	//CtBad1,

	//CtBad2,
	//CtBad3,
	//CtBad4,
	//CtBad5
} CondType;


typedef struct packed
{
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index, rc_index;
	logic [`MSB_POS__INSTR_OP_GROUP:0] opcode;
	logic [`MSB_POS__INSTR_IMM_VALUE:0] imm_val;
	logic [`MSB_POS__INSTR_LDST_TYPE:0] ldst_type;
	logic causes_stall;
	logic [`MSB_POS__INSTR_CONDITION_TYPE:0] condition_type;
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

// Group 2:  Branches
typedef struct packed
{
	// should be 0b0010
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index;
	logic [`MSB_POS__INSTR_OPER:0] opcode;
	logic [`MSB_POS__INSTR_IMM_VALUE:0] imm_val;
} Iog2Instr;

// Group 3:  Jumps
typedef struct packed
{
	// should be 4'b0011
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index, rc_index;

	// blank (should be filled with zeroes)
	logic [`MSB_POS__INSTR_FILL:0] fill;
	logic [`MSB_POS__INSTR_OPER:0] opcode;
} Iog3Instr;

// Group 4:  Calls
typedef struct packed
{
	// should be 4'b0100
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index, rc_index;

	// blank (should be filled with zeroes)
	logic [`MSB_POS__INSTR_FILL:0] fill;
	logic [`MSB_POS__INSTR_OPER:0] opcode;
} Iog4Instr;


// Group 5:  Loads and stores
typedef struct packed
{
	// should be 0b0101
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index, rc_index;

	//// blank (should be filled with zeroes)
	//logic [`MSB_POS__INSTR_FILL:0] fill;
	logic [`MSB_POS__INSTR_LDST_IMM_VAL_12:0] imm_val_12;
	logic [`MSB_POS__INSTR_OPER:0] opcode;
} Iog5Instr;


// Group 6:  Interrupts stuff
typedef struct packed
{
	// should be 4'b0110
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [`MSB_POS__INSTR_REG_INDEX:0] ra_index, rb_index, rc_index;

	// blank (should be filled with zeroes)
	logic [`MSB_POS__INSTR_FILL:0] fill;
	logic [`MSB_POS__INSTR_OPER:0] opcode;
} Iog6Instr;

typedef enum logic [`MSB_POS__INSTR_OPER:0]
{
	Add_ThreeRegs,
	Sub_ThreeRegs,
	Sltu_ThreeRegs,
	Slts_ThreeRegs,

	Sgtu_ThreeRegs,
	Sgts_ThreeRegs,
	Mul_ThreeRegs,
	And_ThreeRegs,

	Orr_ThreeRegs,
	Xor_ThreeRegs,
	Nor_ThreeRegs,
	Lsl_ThreeRegs,

	Lsr_ThreeRegs,
	Asr_ThreeRegs,
	Bad0_Iog0,
	Bad1_Iog0
} Iog0Oper;

typedef enum logic [`MSB_POS__INSTR_OPER:0]
{
	Addi_TwoRegsOneImm,
	Subi_TwoRegsOneImm,
	Sltui_TwoRegsOneImm,
	Sltsi_TwoRegsOneSimm,

	Sgtui_TwoRegsOneImm,
	Sgtsi_TwoRegsOneSimm,
	Muli_TwoRegsOneImm,
	Andi_TwoRegsOneImm,

	Orri_TwoRegsOneImm,
	Xori_TwoRegsOneImm,
	Nori_TwoRegsOneImm,
	Lsli_TwoRegsOneImm,

	Lsri_TwoRegsOneImm,
	Asri_TwoRegsOneImm,
	Addsi_OneRegOnePcOneSimm,
	Cpyhi_OneRegOneImm
} Iog1Oper;

typedef enum logic [`MSB_POS__INSTR_OPER:0]
{
	Bne_TwoRegsOneSimm,
	Beq_TwoRegsOneSimm,
	Bltu_TwoRegsOneSimm,
	Bgeu_TwoRegsOneSimm,

	Bleu_TwoRegsOneSimm,
	Bgtu_TwoRegsOneSimm,
	Blts_TwoRegsOneSimm,
	Bges_TwoRegsOneSimm,

	Bles_TwoRegsOneSimm,
	Bgts_TwoRegsOneSimm,
	Bad0_Iog2,
	Bad1_Iog2,

	Bad2_Iog2,
	Bad3_Iog2,
	Bad4_Iog2,
	Bad5_Iog2
} Iog2Oper;

typedef enum logic [`MSB_POS__INSTR_OPER:0]
{
	Jne_TwoRegsOneSimm,
	Jeq_TwoRegsOneSimm,
	Jltu_TwoRegsOneSimm,
	Jgeu_TwoRegsOneSimm,

	Jleu_TwoRegsOneSimm,
	Jgtu_TwoRegsOneSimm,
	Jlts_TwoRegsOneSimm,
	Jges_TwoRegsOneSimm,

	Jles_TwoRegsOneSimm,
	Jgts_TwoRegsOneSimm,
	Bad0_Iog3,
	Bad1_Iog3,

	Bad2_Iog3,
	Bad3_Iog3,
	Bad4_Iog3,
	Bad5_Iog3
} Iog3Oper;

typedef enum logic [`MSB_POS__INSTR_OPER:0]
{
	Cne_TwoRegsOneSimm,
	Ceq_TwoRegsOneSimm,
	Cltu_TwoRegsOneSimm,
	Cgeu_TwoRegsOneSimm,

	Cleu_TwoRegsOneSimm,
	Cgtu_TwoRegsOneSimm,
	Clts_TwoRegsOneSimm,
	Cges_TwoRegsOneSimm,

	Cles_TwoRegsOneSimm,
	Cgts_TwoRegsOneSimm,
	Bad0_Iog4,
	Bad1_Iog4,

	Bad2_Iog4,
	Bad3_Iog4,
	Bad4_Iog4,
	Bad5_Iog4
} Iog4Oper;

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

	Ldri_TwoRegsOneSimm12Ldst,
	Ldhi_TwoRegsOneSimm12Ldst,
	Ldshi_TwoRegsOneSimm12Ldst,
	Ldbi_TwoRegsOneSimm12Ldst,

	Ldsbi_TwoRegsOneSimm12Ldst,
	Stri_TwoRegsOneSimm12Ldst,
	Sthi_TwoRegsOneSimm12Ldst,
	Stbi_TwoRegsOneSimm12Ldst
} Iog5Oper;

typedef enum logic [`MSB_POS__INSTR_OPER:0]
{
	Ei_NoArgs,
	Di_NoArgs,
	Cpy_OneIretaOneReg,
	Cpy_OneRegOneIreta,

	Cpy_OneIdstaOneReg,
	Cpy_OneRegOneIdsta,
	Reti_NoArgs,
	Bad0_Iog6,

	Bad1_Iog6,
	Bad2_Iog6,
	Bad3_Iog6,
	Bad4_Iog6,

	Bad5_Iog6,
	Bad6_Iog6,
	Bad7_Iog6,
	Bad8_Iog6
} Iog6Oper;


endpackage : PkgInstrDecoder
