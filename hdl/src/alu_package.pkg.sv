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

typedef struct packed
{
	// less than unsigned, less than signed
	logic ltu, lts;

	// greater than unsigned, greater than signed
	logic gtu, gts;
} PortOut_Compare;

typedef struct packed
{
	logic enable;
	logic [`MSB_POS__MUL32_INOUT:0] x, y;
} PortIn_Multiplier32;

typedef struct packed
{
	logic can_accept_cmd, data_ready;
	logic [`MSB_POS__MUL32_INOUT:0] prod;
} PortOut_Multiplier32;

typedef enum logic [`MSB_POS__ALU_OPER:0]
{
	Add,
	Sub,
	Sltu,
	Slts,

	Sgtu,
	Sgts,
	AndN,
	And,

	Or,
	Xor,
	Nor,
	Lsl,

	Lsr,
	Asr,
	OrN,
	Nand
	//Cpyhi
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
