`include "src/instr_decoder_defines.header.sv"

package PkgInstrDecoder;

parameter WIDTH__REG_INDEX = 4;
parameter MSB_POS__REG_INDEX = `WIDTH_TO_MSB_POS(WIDTH__REG_INDEX);

//parameter POS_HIGH__INSTR_GROUP = 31;
//parameter POS_LOW__INSTR_GROUP = 28;
//
//parameter POS_HIGH__RA_INDEX = 27;
//parameter POS_LOW__RA_INDEX = 24;
//
//parameter POS_HIGH__RB_INDEX = 23;
//parameter POS_LOW__RB_INDEX = 20;

parameter MSB_POS__FILL = 11;

typedef struct packed
{
	logic [`MSB_POS__INSTR_OP_GROUP:0] group;
	logic [MSB_POS__REG_INDEX:0] ra_index, rb_index, rc_index;
	logic [`MSB_POS__INSTR_OP_GROUP:0] opcode;
	logic [`MSB_POS__INSTR_IMM_VALUE:0] imm_val;
} PortOut_InstrDecoder;

typedef struct packed
{
	logic [`MSB_POS__INSTR_OP_GROUP:0] group; // should be 4'b0000
	logic [MSB_POS__REG_INDEX:0] ra_index, rb_index, rc_index;
	logic [MSB_POS__FILL:0] fill;  // blank (should be filled with zeroes)
	logic [`MSB_POS__INSTR_OPER:0] opcode;
} Iog0Instr;

typedef struct packed
{
	logic [`MSB_POS__INSTR_OP_GROUP:0] group; // should be 0b0001
	logic [MSB_POS__REG_INDEX:0] ra_index, rb_index;
	logic [`MSB_POS__INSTR_OPER:0] opcode;
	logic [`MSB_POS__INSTR_IMM_VALUE:0] imm_val;
} Iog1Instr;

typedef struct packed
{
	logic [`MSB_POS__INSTR_OP_GROUP:0] group; // should be 0b0010
	logic [MSB_POS__REG_INDEX:0] ra_index, rb_index, rc_index;
	logic [MSB_POS__FILL:0] fill;  // blank (should be filled with zeroes)
	logic [`MSB_POS__INSTR_OPER:0] opcode;
} Iog2Instr;

typedef struct packed
{
	logic [`MSB_POS__INSTR_OP_GROUP:0] group; // should be 0b0011
	logic [MSB_POS__REG_INDEX:0] ra_index, rb_index, rc_index;
	logic [MSB_POS__FILL:0] fill;  // blank (should be filled with zeroes)
	logic [`MSB_POS__INSTR_OPER:0] opcode;
} Iog3Instr;

endpackage : PkgInstrDecoder
