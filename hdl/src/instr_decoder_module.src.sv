`include "src/instr_decoder_defines.header.sv"

module InstrDecoder(input logic [`MSB_POS__INSTRUCTION:0] in,
	output PkgInstrDecoder::PortOut_InstrDecoder out);

	import PkgInstrDecoder::*;

	PkgInstrDecoder::Iog0Instr __iog0_instr;
	assign __iog0_instr = in;

	PkgInstrDecoder::Iog1Instr __iog1_instr;
	assign __iog1_instr = in;

	PkgInstrDecoder::Iog2Instr __iog2_instr;
	assign __iog2_instr = in;

	PkgInstrDecoder::Iog3Instr __iog3_instr;
	assign __iog3_instr = in;

	always_comb
	begin
		// Just use __iog0_instr.group because the "group" field is in the
		// same location for all instructions.
		case (__iog0_instr.group)
			// Group 0
			0:
			begin
				out.group = __iog0_instr.group;
				out.ra_index = __iog0_instr.ra_index;
				out.rb_index = __iog0_instr.rb_index;
				out.rc_index = __iog0_instr.rc_index;
				out.opcode = __iog0_instr.opcode;
				out.imm_val = 0;
				out.ldst_type = 0;
				out.causes_stall = 0;
			end

			// Group 1
			1:
			begin
				out.group = __iog1_instr.group;
				out.ra_index = __iog1_instr.ra_index;
				out.rb_index = __iog1_instr.rb_index;
				out.rc_index = 0;
				out.opcode = __iog1_instr.opcode;
				out.imm_val = __iog1_instr.imm_val;
				out.ldst_type = 0;

				// The only instructions from group 1 that can cause stalls
				// are the conditional branches
				out.causes_stall 
					= (out.opcode >= PkgInstrDecoder::Bne_TwoRegsOneSimm);
			end

			// Group 2
			2:
			begin
				out.group = __iog2_instr.group;
				out.ra_index = __iog2_instr.ra_index;
				out.rb_index = __iog2_instr.rb_index;
				out.rc_index = __iog2_instr.rc_index;
				out.opcode = __iog2_instr.opcode;
				out.imm_val = 0;
				out.ldst_type = 0;

				// Bad instructions don't dause stalls
				out.causes_stall
					= (out.opcode <= PkgInstrDecoder::Calleq_ThreeRegs);
			end

			// Group 3
			3:
			begin
				out.group = __iog3_instr.group;
				out.ra_index = __iog3_instr.ra_index;
				out.rb_index = __iog3_instr.rb_index;
				out.rc_index = __iog3_instr.rc_index;
				out.opcode = __iog3_instr.opcode;

				// Sign extend the 12-bit immediate value... to 16-bit
				out.imm_val = {{4{__iog3_instr.imm_val_12
					[`MSB_POS__INSTR_LDST_IMM_VAL_12]}},
					__iog3_instr.imm_val_12};

				// Make use of the opcode ordering
				out.ldst_type = out.opcode[`MSB_POS__INSTR_LDST_TYPE:0];

				// All load/store instructions cause a stall
				out.causes_stall = 1;
			end

			default:
			begin
				// Eek!  Invalid instruction!
				out = 0;
			end
		endcase
	end

endmodule
