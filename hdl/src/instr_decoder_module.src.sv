`include "src/instr_decoder_defines.header.sv"

module InstrDecoder(input logic [`MSB_POS__INSTRUCTION:0] in,
	output PkgInstrDecoder::PortOut_InstrDecoder out);

	import PkgInstrDecoder::*;
	import PkgAlu::PortOut_Compare;



	logic [`MSB_POS__INSTR_OPER:0] __in_compare_ctrl_flow_b;

	// This works because of symmetry between the control flow instructions
	// Bad instructions don't cause stalls
	assign __in_compare_ctrl_flow_b = PkgInstrDecoder::Bad0_Iog0;
	PkgAlu::PortOut_Compare __out_compare_ctrl_flow;

	Compare #(.DATA_WIDTH(`WIDTH__INSTR_OPER)) __inst_compare_ctrl_flow
		(.a(out.opcode), .b(__in_compare_ctrl_flow_b),
		.out(__out_compare_ctrl_flow));

	PkgInstrDecoder::Iog0Instr __iog0_instr;
	assign __iog0_instr = in;

	PkgInstrDecoder::Iog1Instr __iog1_instr;
	assign __iog1_instr = in;

	PkgInstrDecoder::Iog2Instr __iog2_instr;
	assign __iog2_instr = in;

	PkgInstrDecoder::Iog3Instr __iog3_instr;
	assign __iog3_instr = in;

	PkgInstrDecoder::Iog4Instr __iog4_instr;
	assign __iog4_instr = in;

	PkgInstrDecoder::Iog5Instr __iog5_instr;
	assign __iog5_instr = in;

	PkgInstrDecoder::Iog6Instr __iog6_instr;
	assign __iog6_instr = in;

	always_comb
	begin
		// Just use __iog0_instr.group because the "group" field is in the
		// same location for all instructions.
		case (__iog0_instr.group)
			// Group 0:  Three Registers
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
				out.condition_type = 0;
			end

			// Group 1:  Immediates
			1:
			begin
				out.group = __iog1_instr.group;
				out.ra_index = __iog1_instr.ra_index;
				out.rb_index = __iog1_instr.rb_index;
				out.rc_index = 0;
				out.opcode = __iog1_instr.opcode;
				out.imm_val = __iog1_instr.imm_val;
				out.ldst_type = 0;

				out.causes_stall = 0;
				out.condition_type = 0;
			end

			// Group 2:  Branches
			2:
			begin
				out.group = __iog2_instr.group;
				out.ra_index = __iog2_instr.ra_index;
				out.rb_index = __iog2_instr.rb_index;
				//out.rc_index = __iog2_instr.rc_index;
				out.rc_index = 0;
				out.opcode = __iog2_instr.opcode;
				out.imm_val = __iog2_instr.imm_val;
				out.ldst_type = 0;

				// Bad instructions don't cause stalls
				out.causes_stall = __out_compare_ctrl_flow.ltu;
				out.condition_type = __iog2_instr.opcode;

			end

			// Group 3:  Jumps
			3:
			begin
				out.group = __iog3_instr.group;
				out.ra_index = __iog3_instr.ra_index;
				out.rb_index = __iog3_instr.rb_index;
				out.rc_index = __iog3_instr.rc_index;
				out.opcode = __iog3_instr.opcode;
				out.imm_val = 0;
				out.ldst_type = 0;

				// Bad instructions don't cause stalls
				out.causes_stall = __out_compare_ctrl_flow.ltu;
				out.condition_type = __iog3_instr.opcode;

			end

			// Group 4:  Calls
			4:
			begin
				out.group = __iog4_instr.group;
				out.ra_index = __iog4_instr.ra_index;
				out.rb_index = __iog4_instr.rb_index;
				out.rc_index = __iog4_instr.rc_index;
				out.opcode = __iog4_instr.opcode;
				out.imm_val = 0;
				out.ldst_type = 0;

				// Bad instructions don't cause stalls
				out.causes_stall = __out_compare_ctrl_flow.ltu;
				out.condition_type = __iog4_instr.opcode;

			end

			// Group 5:  Loads and stores
			5:
			begin
				out.group = __iog5_instr.group;
				out.ra_index = __iog5_instr.ra_index;
				out.rb_index = __iog5_instr.rb_index;
				out.rc_index = __iog5_instr.rc_index;
				out.opcode = __iog5_instr.opcode;

				// Sign extend the 12-bit immediate value... to 16-bit
				out.imm_val = {{4{__iog5_instr.imm_val_12
					[`MSB_POS__INSTR_LDST_IMM_VAL_12]}},
					__iog5_instr.imm_val_12};

				// Make use of the opcode ordering
				out.ldst_type = out.opcode[`MSB_POS__INSTR_LDST_TYPE:0];

				// All load/store instructions cause a stall
				out.causes_stall = 1;
				out.condition_type = 0;
			end

			6:
			begin
				out.group = __iog5_instr.group;
				out.ra_index = __iog5_instr.ra_index;
				out.rb_index = __iog5_instr.rb_index;
				out.rc_index = __iog5_instr.rc_index;
				out.opcode = __iog5_instr.opcode;
				out.group = __iog6_instr.group;

				out.imm_val = 0;
				out.ldst_type = 0;

				// Instructions that stall (prevent interrupts)
				out.causes_stall 
					= ((out.opcode == PkgInstrDecoder::Cpy_OneIretaOneReg)
					|| (out.opcode 
					== PkgInstrDecoder::Cpy_OneIdstaOneReg));

				out.condition_type = 0;
			end

			default:
			begin
				// Eek!  Invalid instruction group!
				// ...Treat it as a NOP ("add zero, zero, zero")
				out = 0;

				//`ifdef OPT_DEBUG_INSTR_DECODER
				//$display("bad_invalid_group");
				//`endif		// OPT_DEBUG_INSTR_DECODER
			end
		endcase
	end

endmodule
