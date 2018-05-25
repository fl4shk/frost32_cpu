
	if (__stage_instr_decode_data.stall_counter != 1)
	begin
	$display();
	$display();
	$display("Program counter:  %h", __locals.pc);
	case (__out_instr_decoder.group)
		0:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Add_ThreeRegs:
				begin
					$display("add r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Sub_ThreeRegs:
				begin
					$display("sub r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Sltu_ThreeRegs:
				begin
					$display("sltu r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Slts_ThreeRegs:
				begin
					$display("slts r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Sgtu_ThreeRegs:
				begin
					$display("sgtu r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Sgts_ThreeRegs:
				begin
					$display("sgts r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Mul_ThreeRegs:
				begin
					$display("mul r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::And_ThreeRegs:
				begin
					$display("and r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Orr_ThreeRegs:
				begin
					$display("orr r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Xor_ThreeRegs:
				begin
					$display("xor r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Nor_ThreeRegs:
				begin
					$display("nor r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Lsl_ThreeRegs:
				begin
					$display("lsl r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Lsr_ThreeRegs:
				begin
					$display("lsr r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Asr_ThreeRegs:
				begin
					$display("asr r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				//PkgInstrDecoder::Bad0_Iog0:
				//begin
				//	$display("bad0_iog0");
				//end
				//PkgInstrDecoder::Bad1_Iog0:
				//begin
				//	$display("bad1_iog0");
				//end
				PkgInstrDecoder::Udiv_ThreeRegs:
				begin
					$display("udiv r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Sdiv_ThreeRegs:
				begin
					$display("sdiv r%d, r%d, r%d", 
						__out_instr_decoder.ra_index,
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
			endcase
		end

		1:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Addi_TwoRegsOneImm:
				begin
					$display("addi r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Subi_TwoRegsOneImm:
				begin
					$display("subi r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Sltui_TwoRegsOneImm:
				begin
					$display("sltui r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Sltsi_TwoRegsOneSimm:
				begin
					$display("sltsi r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Sgtui_TwoRegsOneImm:
				begin
					$display("sgtui r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Sgtsi_TwoRegsOneSimm:
				begin
					$display("sgtsi r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Muli_TwoRegsOneImm:
				begin
					$display("muli r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Andi_TwoRegsOneImm:
				begin
					$display("andi r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Orri_TwoRegsOneImm:
				begin
					$display("orri r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Xori_TwoRegsOneImm:
				begin
					$display("xori r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Nori_TwoRegsOneImm:
				begin
					$display("nori r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Lsli_TwoRegsOneImm:
				begin
					$display("lsli r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Lsri_TwoRegsOneImm:
				begin
					$display("lsri r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Asri_TwoRegsOneImm:
				begin
					$display("asri r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Addsi_OneRegOnePcOneSimm:
				begin
					$display("addsi r%d, pc, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Cpyhi_OneRegOneImm:
				begin
					$display("cpyhi r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.imm_val);
				end
			endcase
		end

		2:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Bne_TwoRegsOneSimm:
				begin
					$display("bne r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Beq_TwoRegsOneSimm:
				begin
					$display("beq r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bltu_TwoRegsOneSimm:
				begin
					$display("bltu r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bgeu_TwoRegsOneSimm:
				begin
					$display("bgeu r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Bleu_TwoRegsOneSimm:
				begin
					$display("bleu r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bgtu_TwoRegsOneSimm:
				begin
					$display("bgtu r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Blts_TwoRegsOneSimm:
				begin
					$display("blts r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bges_TwoRegsOneSimm:
				begin
					$display("bges r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Bles_TwoRegsOneSimm:
				begin
					$display("bles r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Bgts_TwoRegsOneSimm:
				begin
					$display("bgts r%d, r%d, 0x%x",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
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
		end

		3:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Jne_TwoRegsOneSimm:
				begin
					$display("jne r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jeq_TwoRegsOneSimm:
				begin
					$display("jeq r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jltu_TwoRegsOneSimm:
				begin
					$display("jltu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jgeu_TwoRegsOneSimm:
				begin
					$display("jgeu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Jleu_TwoRegsOneSimm:
				begin
					$display("jleu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jgtu_TwoRegsOneSimm:
				begin
					$display("jgtu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jlts_TwoRegsOneSimm:
				begin
					$display("jlts r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jges_TwoRegsOneSimm:
				begin
					$display("jges r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Jles_TwoRegsOneSimm:
				begin
					$display("jles r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Jgts_TwoRegsOneSimm:
				begin
					$display("jgts r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
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
		end

		4:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Cne_TwoRegsOneSimm:
				begin
					$display("cne r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Ceq_TwoRegsOneSimm:
				begin
					$display("ceq r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Cltu_TwoRegsOneSimm:
				begin
					$display("cltu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Cgeu_TwoRegsOneSimm:
				begin
					$display("cgeu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Cleu_TwoRegsOneSimm:
				begin
					$display("cleu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Cgtu_TwoRegsOneSimm:
				begin
					$display("cgtu r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Clts_TwoRegsOneSimm:
				begin
					$display("clts r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Cges_TwoRegsOneSimm:
				begin
					$display("cges r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Cles_TwoRegsOneSimm:
				begin
					$display("cles r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Cgts_TwoRegsOneSimm:
				begin
					$display("cgts r%d, r%d, r%d",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
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
		end

		5:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Ldr_ThreeRegsLdst:
				begin
					$display("ldr r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Ldh_ThreeRegsLdst:
				begin
					$display("ldh r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Ldsh_ThreeRegsLdst:
				begin
					$display("ldsh r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Ldb_ThreeRegsLdst:
				begin
					$display("ldb r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Ldsb_ThreeRegsLdst:
				begin
					$display("ldsb r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Str_ThreeRegsLdst:
				begin
					$display("str r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Sth_ThreeRegsLdst:
				begin
					$display("sth r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end
				PkgInstrDecoder::Stb_ThreeRegsLdst:
				begin
					$display("stb r%d, [r%d, r%d]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.rc_index);
				end

				PkgInstrDecoder::Ldri_TwoRegsOneSimm12Ldst:
				begin
					$display("ldri r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Ldhi_TwoRegsOneSimm12Ldst:
				begin
					$display("ldhi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Ldshi_TwoRegsOneSimm12Ldst:
				begin
					$display("ldshi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Ldbi_TwoRegsOneSimm12Ldst:
				begin
					$display("ldbi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end

				PkgInstrDecoder::Ldsbi_TwoRegsOneSimm12Ldst:
				begin
					$display("ldsbi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Stri_TwoRegsOneSimm12Ldst:
				begin
					$display("stri r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Sthi_TwoRegsOneSimm12Ldst:
				begin
					$display("sthi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
				PkgInstrDecoder::Stbi_TwoRegsOneSimm12Ldst:
				begin
					$display("stbi r%d, [r%d, 0x%x]",
						__out_instr_decoder.ra_index, 
						__out_instr_decoder.rb_index, 
						__out_instr_decoder.imm_val);
				end
			endcase
		end

		6:
		begin
			case (__out_instr_decoder.opcode)
				PkgInstrDecoder::Ei_NoArgs:
				begin
					$display("ei");
				end
				PkgInstrDecoder::Di_NoArgs:
				begin
					$display("di");
				end
				PkgInstrDecoder::Cpy_OneIretaOneReg:
				begin
					$display("cpy ireta, r%d",
						__out_instr_decoder.ra_index);
				end
				PkgInstrDecoder::Cpy_OneRegOneIreta:
				begin
					$display("cpy r%d, ireta",
						__out_instr_decoder.ra_index);
				end

				PkgInstrDecoder::Cpy_OneIdstaOneReg:
				begin
					$display("cpy idsta, r%d",
						__out_instr_decoder.ra_index);
				end
				PkgInstrDecoder::Cpy_OneRegOneIdsta:
				begin
					$display("cpy r%d, idsta",
						__out_instr_decoder.ra_index);
				end
				PkgInstrDecoder::Reti_NoArgs:
				begin
					$display("reti");
				end
				PkgInstrDecoder::Bad0_Iog6:
				begin
					$display("bad0_iog6");
				end

				PkgInstrDecoder::Bad1_Iog6:
				begin
					$display("bad1_iog6");
				end
				PkgInstrDecoder::Bad2_Iog6:
				begin
					$display("bad2_iog6");
				end
				PkgInstrDecoder::Bad3_Iog6:
				begin
					$display("bad3_iog6");
				end
				PkgInstrDecoder::Bad4_Iog6:
				begin
					$display("bad4_iog6");
				end

				PkgInstrDecoder::Bad5_Iog6:
				begin
					$display("bad5_iog6");
				end
				PkgInstrDecoder::Bad6_Iog6:
				begin
					$display("bad6_iog6");
				end
				PkgInstrDecoder::Bad7_Iog6:
				begin
					$display("bad7_iog6");
				end
				PkgInstrDecoder::Bad8_Iog6:
				begin
					$display("bad8_iog6");
				end
			endcase
		end

		default:
		begin
			$display("unknown");
		end
	endcase
	end

	else
	begin
		$display();
		$display();
		$display("__stage_instr_decode_data.stall_counter == 1");
	end
