`include "src/alu_defines.header.sv"

package PkgAlu;


typedef struct packed
{
	logic [`MSB_POS__ALU_INOUT:0] data;
	logic [4:0] amount;
} PortIn_Shift;

typedef struct packed
{
	logic [`MSB_POS__ALU_INOUT:0] data;
} PortOut_Shift;

//typedef struct packed
//{
//	logic n, v, c;
//} PortOut_CompareFlags;

typedef struct packed
{
	// less than unsigned, less than signed
	logic ltu, lts;
} PortOut_Compare;

typedef enum logic [`MSB_POS__ALU_OPER:0]
{
	Add,
	Sub,
	Sltu,
	Slts,
	AndN,
	And,
	Or,
	Xor,
	Nor,
	Lsl,
	Lsr,
	Asr,
	OrN,
	Nand,
	InvA,
	Xnor
} AluOper;

typedef struct packed
{
	logic [`MSB_POS__ALU_INOUT:0] a, b;
	//AluOper oper;
	logic [`MSB_POS__ALU_OPER:0] oper;
} PortIn_Alu;

typedef struct packed
{
	logic [`MSB_POS__ALU_INOUT:0] data;
} PortOut_Alu;

endpackage : PkgAlu
