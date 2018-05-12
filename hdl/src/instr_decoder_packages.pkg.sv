`include "src/misc_defines.header.sv"
`include "src/instr_decoder_stuff.header.sv"

// Widths, MSB positions
package PkgInstrDecoderWmp;

// Opcode group field
parameter w_group = 4;
parameter mp_group = `WIDTH_TO_MSB_POS(w_group);
parameter field_pos_group_high = 31;
parameter field_pos_group_low = 28;


// Opcode field
parameter w_opcode = `INSTR_DEC__WIDTH_OP;
parameter mp_opcode = `INSTR_DEC__MSB_POS_OP;

// Register index field
parameter w_reg_index = 4;
parameter mp_reg_index = `WIDTH_TO_MSB_POS(w_reg_index);




endpackage : PkgInstrDecoderWmp



package PkgInstrDecoderIog0;

//import PkgInstrDecoderWmp::*;
//parameter mp_group = PkgInstrDecoderWmp::mp_group;

// Each instruction group has a fixed value for the opcode group field
parameter field_val_group = 0;

parameter field_pos_ra_high = 27;
parameter field_pos_ra_low = 24;

parameter field_pos_rb_high = 23;
parameter field_pos_rb_low = 20;

parameter field_pos_rc_high = 19;
parameter field_pos_rc_low = 16;

parameter field_pos_opcode_high = 3;
parameter field_pos_opcode_low = 0;

typedef enum logic [`INSTR_DEC__MSB_POS_OP : 0]
{
	Add,
	Sub,
	Sltu,
	Slts,
	Mul,
	And,
	Orr,
	Xor,
	Inv,
	Lsl,
	Lsr,
	Asr,
	Bad0,
	Bad1,
	Bad2,
	Bad3
} Opcode;

endpackage : PkgInstrDecoderIog0
