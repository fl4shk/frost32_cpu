`include "src/instr_decoder_defines.header.sv"

`define DEBUG_INSTR_DECODER

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

	`ifdef DEBUG_INSTR_DECODER
	always @ (*)
	`else
	always_comb
	`endif		// DEBUG_INSTR_DECODER
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

				`ifdef DEBUG_INSTR_DECODER
				case (out.opcode)
					PkgInstrDecoder::Add_ThreeRegs:
					begin
						$display("add r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Sub_ThreeRegs:
					begin
						$display("sub r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Sltu_ThreeRegs:
					begin
						$display("sltu r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Slts_ThreeRegs:
					begin
						$display("slts r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end

					PkgInstrDecoder::Sgtu_ThreeRegs:
					begin
						$display("sgtu r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Sgts_ThreeRegs:
					begin
						$display("sgts r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Mul_ThreeRegs:
					begin
						$display("mul r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::And_ThreeRegs:
					begin
						$display("and r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end

					PkgInstrDecoder::Orr_ThreeRegs:
					begin
						$display("orr r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Xor_ThreeRegs:
					begin
						$display("xor r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Nor_ThreeRegs:
					begin
						$display("nor r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Lsl_ThreeRegs:
					begin
						$display("lsl r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end

					PkgInstrDecoder::Lsr_ThreeRegs:
					begin
						$display("lsr r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Asr_ThreeRegs:
					begin
						$display("asr r%d, r%d, r%d", out.ra_index,
							out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Bad0_Iog0:
					begin
						$display("bad0_iog0");
					end
					PkgInstrDecoder::Bad1_Iog0:
					begin
						$display("bad1_iog0");
					end
				endcase
				`endif		// DEBUG_INSTR_DECODER
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
				`ifdef DEBUG_INSTR_DECODER
				case (out.opcode)
					PkgInstrDecoder::Addi_TwoRegsOneImm:
					begin
						$display("addi r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Subi_TwoRegsOneImm:
					begin
						$display("subi r%d, r%d, r%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Sltui_TwoRegsOneImm:
					begin
						$display("sltui r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Sltsi_TwoRegsOneSimm:
					begin
						$display("sltsi r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end

					PkgInstrDecoder::Sgtui_TwoRegsOneImm:
					begin
						$display("sgtui r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Sgtsi_TwoRegsOneSimm:
					begin
						$display("sgtsi r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Muli_TwoRegsOneImm:
					begin
						$display("muli r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Andi_TwoRegsOneImm:
					begin
						$display("andi r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end

					PkgInstrDecoder::Orri_TwoRegsOneImm:
					begin
						$display("orri r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Xori_TwoRegsOneImm:
					begin
						$display("xori r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Nori_TwoRegsOneImm:
					begin
						$display("nori r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Lsli_TwoRegsOneImm:
					begin
						$display("lsli r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end

					PkgInstrDecoder::Lsri_TwoRegsOneImm:
					begin
						$display("lsri r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Asri_TwoRegsOneImm:
					begin
						$display("asri r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Addsi_OneRegOnePcOneSimm:
					begin
						$display("addsi r%d, pc, 0x%x",
							out.ra_index, out.imm_val);
					end
					PkgInstrDecoder::Cpyhi_OneRegOneImm:
					begin
						$display("cpyhi r%d, 0x%x",
							out.ra_index, out.imm_val);
					end
				endcase
				`endif		// DEBUG_INSTR_DECODER
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

				`ifdef DEBUG_INSTR_DECODER
				case (out.opcode)
					PkgInstrDecoder::Bne_TwoRegsOneSimm:
					begin
						$display("bne r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Beq_TwoRegsOneSimm:
					begin
						$display("beq r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Bltu_TwoRegsOneSimm:
					begin
						$display("blt r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Bgeu_TwoRegsOneSimm:
					begin
						$display("bge r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end

					PkgInstrDecoder::Bleu_TwoRegsOneSimm:
					begin
						$display("ble r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Bgtu_TwoRegsOneSimm:
					begin
						$display("bgt r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Blts_TwoRegsOneSimm:
					begin
						$display("blt r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Bges_TwoRegsOneSimm:
					begin
						$display("bge r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end

					PkgInstrDecoder::Bles_TwoRegsOneSimm:
					begin
						$display("ble r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Bgts_TwoRegsOneSimm:
					begin
						$display("bgt r%d, r%d, 0x%x",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Bad0_Iog2:
					begin
						$display("bad0_iog2");
					end
					PkgInstrDecoder::Bad1_Iog2:
					begin
						$display("bad1_iog2");
					end

					PkgInstrDecoder::Bad2_Iog2:
					begin
						$display("bad2_iog2");
					end
					PkgInstrDecoder::Bad3_Iog2:
					begin
						$display("bad3_iog2");
					end
					PkgInstrDecoder::Bad4_Iog2:
					begin
						$display("bad4_iog2");
					end
					PkgInstrDecoder::Bad5_Iog2:
					begin
						$display("bad5_iog2");
					end
				endcase
				`endif		// DEBUG_INSTR_DECODER
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

				`ifdef DEBUG_INSTR_DECODER
				case (out.opcode)
					PkgInstrDecoder::Jne_TwoRegsOneSimm:
					begin
						$display("jne r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Jeq_TwoRegsOneSimm:
					begin
						$display("jeq r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Jltu_TwoRegsOneSimm:
					begin
						$display("jltu r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Jgeu_TwoRegsOneSimm:
					begin
						$display("jgeu r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end

					PkgInstrDecoder::Jleu_TwoRegsOneSimm:
					begin
						$display("jleu r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Jgtu_TwoRegsOneSimm:
					begin
						$display("jgtu r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Jlts_TwoRegsOneSimm:
					begin
						$display("jlts r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Jges_TwoRegsOneSimm:
					begin
						$display("jges r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end

					PkgInstrDecoder::Jles_TwoRegsOneSimm:
					begin
						$display("jles r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Jgts_TwoRegsOneSimm:
					begin
						$display("jgts r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Bad0_Iog3:
					begin
						$display("bad0_iog3");
					end
					PkgInstrDecoder::Bad1_Iog3:
					begin
						$display("bad1_iog3");
					end

					PkgInstrDecoder::Bad2_Iog3:
					begin
						$display("bad2_iog3");
					end
					PkgInstrDecoder::Bad3_Iog3:
					begin
						$display("bad3_iog3");
					end
					PkgInstrDecoder::Bad4_Iog3:
					begin
						$display("bad4_iog3");
					end
					PkgInstrDecoder::Bad5_Iog3:
					begin
						$display("bad5_iog3");
					end
				endcase
				`endif		// DEBUG_INSTR_DECODER
			end

			// Group 4:  Jumps
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

				`ifdef DEBUG_INSTR_DECODER
				case (out.opcode)
					PkgInstrDecoder::Cne_TwoRegsOneSimm:
					begin
						$display("cne r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Ceq_TwoRegsOneSimm:
					begin
						$display("ceq r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Cltu_TwoRegsOneSimm:
					begin
						$display("cltu r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Cgeu_TwoRegsOneSimm:
					begin
						$display("cgeu r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end

					PkgInstrDecoder::Cleu_TwoRegsOneSimm:
					begin
						$display("cleu r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Cgtu_TwoRegsOneSimm:
					begin
						$display("cgtu r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Clts_TwoRegsOneSimm:
					begin
						$display("clts r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Cges_TwoRegsOneSimm:
					begin
						$display("cges r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end

					PkgInstrDecoder::Cles_TwoRegsOneSimm:
					begin
						$display("cles r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Cgts_TwoRegsOneSimm:
					begin
						$display("cgts r%d, r%d, r%d",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Bad0_Iog4:
					begin
						$display("bad0_iog4");
					end
					PkgInstrDecoder::Bad1_Iog4:
					begin
						$display("bad1_iog4");
					end

					PkgInstrDecoder::Bad2_Iog4:
					begin
						$display("bad2_iog4");
					end
					PkgInstrDecoder::Bad3_Iog4:
					begin
						$display("bad3_iog4");
					end
					PkgInstrDecoder::Bad4_Iog4:
					begin
						$display("bad4_iog4");
					end
					PkgInstrDecoder::Bad5_Iog4:
					begin
						$display("bad5_iog4");
					end
				endcase
				`endif		// DEBUG_INSTR_DECODER
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

				`ifdef DEBUG_INSTR_DECODER
				case (out.opcode)
					PkgInstrDecoder::Ldr_ThreeRegsLdst:
					begin
						$display("ldr r%d, [r%d, r%d]",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Ldh_ThreeRegsLdst:
					begin
						$display("ldh r%d, [r%d, r%d]",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Ldsh_ThreeRegsLdst:
					begin
						$display("ldsh r%d, [r%d, r%d]",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Ldb_ThreeRegsLdst:
					begin
						$display("ldb r%d, [r%d, r%d]",
							out.ra_index, out.rb_index, out.rc_index);
					end

					PkgInstrDecoder::Ldsb_ThreeRegsLdst:
					begin
						$display("ldsb r%d, [r%d, r%d]",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Str_ThreeRegsLdst:
					begin
						$display("str r%d, [r%d, r%d]",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Sth_ThreeRegsLdst:
					begin
						$display("sth r%d, [r%d, r%d]",
							out.ra_index, out.rb_index, out.rc_index);
					end
					PkgInstrDecoder::Stb_ThreeRegsLdst:
					begin
						$display("stb r%d, [r%d, r%d]",
							out.ra_index, out.rb_index, out.rc_index);
					end

					PkgInstrDecoder::Ldri_TwoRegsOneSimm12Ldst:
					begin
						$display("ldri r%d, [r%d, 0x%x]",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Ldhi_TwoRegsOneSimm12Ldst:
					begin
						$display("ldhi r%d, [r%d, 0x%x]",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Ldshi_TwoRegsOneSimm12Ldst:
					begin
						$display("ldshi r%d, [r%d, 0x%x]",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Ldbi_TwoRegsOneSimm12Ldst:
					begin
						$display("ldbi r%d, [r%d, 0x%x]",
							out.ra_index, out.rb_index, out.imm_val);
					end

					PkgInstrDecoder::Ldsbi_TwoRegsOneSimm12Ldst:
					begin
						$display("ldsbi r%d, [r%d, 0x%x]",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Stri_TwoRegsOneSimm12Ldst:
					begin
						$display("stri r%d, [r%d, 0x%x]",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Sthi_TwoRegsOneSimm12Ldst:
					begin
						$display("sthi r%d, [r%d, 0x%x]",
							out.ra_index, out.rb_index, out.imm_val);
					end
					PkgInstrDecoder::Stbi_TwoRegsOneSimm12Ldst:
					begin
						$display("stbi r%d, [r%d, 0x%x]",
							out.ra_index, out.rb_index, out.imm_val);
					end
				endcase
				`endif		// DEBUG_INSTR_DECODER
			end

			default:
			begin
				// Eek!  Invalid instruction group!
				// ...Treat it as a NOP ("add zero, zero, zero")
				out = 0;

				`ifdef DEBUG_INSTR_DECODER
				$display("bad_invalid_group");
				`endif		// DEBUG_INSTR_DECODER
			end
		endcase
	end

endmodule
