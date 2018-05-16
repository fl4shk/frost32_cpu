#include "encoding_stuff_class.hpp"
#include "allocation_stuff.hpp"

#define DECODE_ITERATION(some_map, some_args_type) \
	for (auto& iter : some_map()) \
	{ \
		if (iter.second == opcode) \
		{ \
			instr_name = iter.first; \
			args_type = some_args_type; \
			return; \
		} \
	}

EncodingStuff::EncodingStuff()
{
	// Encoding stuff (opcode field, register fields)

	// Registers
	u16 temp = 0;
	__reg_names_map[cstm_strdup("zero")] = temp++;
	__reg_names_map[cstm_strdup("u0")] = temp++;
	__reg_names_map[cstm_strdup("u1")] = temp++;
	__reg_names_map[cstm_strdup("u2")] = temp++;
	__reg_names_map[cstm_strdup("u3")] = temp++;
	__reg_names_map[cstm_strdup("u4")] = temp++;
	__reg_names_map[cstm_strdup("u5")] = temp++;
	__reg_names_map[cstm_strdup("u6")] = temp++;
	__reg_names_map[cstm_strdup("u7")] = temp++;
	__reg_names_map[cstm_strdup("u8")] = temp++;
	__reg_names_map[cstm_strdup("u9")] = temp++;
	__reg_names_map[cstm_strdup("u10")] = temp++;
	__reg_names_map[cstm_strdup("temp")] = temp++;
	__reg_names_map[cstm_strdup("lr")] = temp++;
	__reg_names_map[cstm_strdup("fp")] = temp++;
	__reg_names_map[cstm_strdup("sp")] = temp++;

	// Instruction Opcode Group 0
	temp = 0;
	__iog0_three_regs_map[cstm_strdup("add")] = temp++;
	__iog0_three_regs_map[cstm_strdup("sub")] = temp++;
	__iog0_three_regs_map[cstm_strdup("sltu")] = temp++;
	__iog0_three_regs_map[cstm_strdup("slts")] = temp++;
	__iog0_three_regs_map[cstm_strdup("sgtu")] = temp++;
	__iog0_three_regs_map[cstm_strdup("sgts")] = temp++;
	__iog0_three_regs_map[cstm_strdup("mul")] = temp++;
	__iog0_three_regs_map[cstm_strdup("and")] = temp++;
	__iog0_three_regs_map[cstm_strdup("orr")] = temp++;
	__iog0_three_regs_map[cstm_strdup("xor")] = temp++;
	__iog0_three_regs_map[cstm_strdup("nor")] = temp++;
	__iog0_three_regs_map[cstm_strdup("lsl")] = temp++;
	__iog0_three_regs_map[cstm_strdup("lsr")] = temp++;
	__iog0_three_regs_map[cstm_strdup("asr")] = temp++;

	// Instruction Opcode Group 1
	temp = 0;
	__iog1_two_regs_one_imm_map[cstm_strdup("addi")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("subi")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("sltui")] = temp++;
	__iog1_two_regs_one_simm_map[cstm_strdup("sltsi")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("sgtui")] = temp++;
	__iog1_two_regs_one_simm_map[cstm_strdup("sgtsi")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("muli")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("andi")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("orri")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("xori")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("nori")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("lsli")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("lsri")] = temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("asri")] = temp++;
	__iog1_one_reg_one_pc_one_simm_map[cstm_strdup("addsi")] = temp++;
	__iog1_one_reg_one_imm_map[cstm_strdup("cpyhi")] = temp++;

	// Instruction Opcode Group 2 (branches)
	temp = 0;
	__iog2_branch_map[cstm_strdup("bne")] = temp++;
	__iog2_branch_map[cstm_strdup("beq")] = temp++;
	__iog2_branch_map[cstm_strdup("bltu")] = temp++;
	__iog2_branch_map[cstm_strdup("bgeu")] = temp++;
	__iog2_branch_map[cstm_strdup("bleu")] = temp++;
	__iog2_branch_map[cstm_strdup("bgtu")] = temp++;
	__iog2_branch_map[cstm_strdup("blts")] = temp++;
	__iog2_branch_map[cstm_strdup("bges")] = temp++;
	__iog2_branch_map[cstm_strdup("bles")] = temp++;
	__iog2_branch_map[cstm_strdup("bgts")] = temp++;

	// Instruction Opcode Group 3 (Jumps)
	temp = 0;
	__iog3_jump_map[cstm_strdup("jne")] = temp++;
	__iog3_jump_map[cstm_strdup("jeq")] = temp++;
	__iog3_jump_map[cstm_strdup("jltu")] = temp++;
	__iog3_jump_map[cstm_strdup("jgeu")] = temp++;
	__iog3_jump_map[cstm_strdup("jleu")] = temp++;
	__iog3_jump_map[cstm_strdup("jgtu")] = temp++;
	__iog3_jump_map[cstm_strdup("jlts")] = temp++;
	__iog3_jump_map[cstm_strdup("jges")] = temp++;
	__iog3_jump_map[cstm_strdup("jles")] = temp++;
	__iog3_jump_map[cstm_strdup("jgts")] = temp++;

	// Instruction Opcode Group 3 (Calls)
	temp = 0;
	__iog4_call_map[cstm_strdup("cne")] = temp++;
	__iog4_call_map[cstm_strdup("ceq")] = temp++;
	__iog4_call_map[cstm_strdup("cltu")] = temp++;
	__iog4_call_map[cstm_strdup("cgeu")] = temp++;
	__iog4_call_map[cstm_strdup("cleu")] = temp++;
	__iog4_call_map[cstm_strdup("cgtu")] = temp++;
	__iog4_call_map[cstm_strdup("clts")] = temp++;
	__iog4_call_map[cstm_strdup("cges")] = temp++;
	__iog4_call_map[cstm_strdup("cles")] = temp++;
	__iog4_call_map[cstm_strdup("cgts")] = temp++;

	// Instruction Opcode Group 5 (loads and stores)
	temp = 0;
	__iog5_three_regs_ldst_map[cstm_strdup("ldr")] = temp++;
	__iog5_three_regs_ldst_map[cstm_strdup("ldh")] = temp++;
	__iog5_three_regs_ldst_map[cstm_strdup("ldsh")] = temp++;
	__iog5_three_regs_ldst_map[cstm_strdup("ldb")] = temp++;
	__iog5_three_regs_ldst_map[cstm_strdup("ldsb")] = temp++;
	__iog5_three_regs_ldst_map[cstm_strdup("str")] = temp++;
	__iog5_three_regs_ldst_map[cstm_strdup("sth")] = temp++;
	__iog5_three_regs_ldst_map[cstm_strdup("stb")] = temp++;
	__iog5_two_regs_one_simm_ldst_map[cstm_strdup("ldri")] = temp++;
	__iog5_two_regs_one_simm_ldst_map[cstm_strdup("ldhi")] = temp++;
	__iog5_two_regs_one_simm_ldst_map[cstm_strdup("ldshi")] = temp++;
	__iog5_two_regs_one_simm_ldst_map[cstm_strdup("ldbi")] = temp++;
	__iog5_two_regs_one_simm_ldst_map[cstm_strdup("ldsbi")] = temp++;
	__iog5_two_regs_one_simm_ldst_map[cstm_strdup("stri")] = temp++;
	__iog5_two_regs_one_simm_ldst_map[cstm_strdup("sthi")] = temp++;
	__iog5_two_regs_one_simm_ldst_map[cstm_strdup("stbi")] = temp++;
}


std::string* EncodingStuff::decode_reg_name(u32 reg_index) const
{
	//printout("EncodingStuff::decode_reg_name():  ", reg_index, "\n");
	for (auto& iter : reg_names_map())
	{
		if (iter.second == reg_index)
		{
			return iter.first;
		}
	}

	printerr("EncodingStuff::decode_reg_name():  Eek!");
	exit(1);
	return nullptr;
}
void EncodingStuff::get_iog0_instr_from_opcode(u32 opcode, 
	std::string*& instr_name, EncodingStuff::ArgsType& args_type) const
{
	DECODE_ITERATION(iog0_three_regs_map, ArgsType::ThreeRegs);
	//DECODE_ITERATION(iog0_two_regs_map, ArgsType::TwoRegs);

	instr_name = cstm_strdup("unknown_instruction");
	args_type = ArgsType::Unknown;
}
void EncodingStuff::get_iog1_instr_from_opcode(u32 opcode, 
	std::string*& instr_name, EncodingStuff::ArgsType& args_type) const
{
	DECODE_ITERATION(iog1_two_regs_one_imm_map, 
		ArgsType::TwoRegsOneImm);
	DECODE_ITERATION(iog1_two_regs_one_simm_map, 
		ArgsType::TwoRegsOneSimm);
	DECODE_ITERATION(iog1_one_reg_one_pc_one_simm_map, 
		ArgsType::OneRegOnePcOneSimm);
	DECODE_ITERATION(iog1_one_reg_one_imm_map, 
		ArgsType::OneRegOneImm);

	instr_name = cstm_strdup("unknown_instruction");
	args_type = ArgsType::Unknown;
}
void EncodingStuff::get_iog2_instr_from_opcode(u32 opcode, 
	std::string*& instr_name, EncodingStuff::ArgsType& args_type) const
{
	DECODE_ITERATION(iog2_branch_map, ArgsType::Branch);

	instr_name = cstm_strdup("unknown_instruction");
	args_type = ArgsType::Unknown;
}
void EncodingStuff::get_iog3_instr_from_opcode(u32 opcode, 
	std::string*& instr_name, EncodingStuff::ArgsType& args_type) const
{
	DECODE_ITERATION(iog3_jump_map, ArgsType::ThreeRegs);

	instr_name = cstm_strdup("unknown_instruction");
	args_type = ArgsType::Unknown;
}
void EncodingStuff::get_iog4_instr_from_opcode(u32 opcode, 
	std::string*& instr_name, ArgsType& args_type) const
{
	DECODE_ITERATION(iog4_call_map, ArgsType::ThreeRegs);

	instr_name = cstm_strdup("unknown_instruction");
	args_type = ArgsType::Unknown;
}
void EncodingStuff::get_iog5_instr_from_opcode(u32 opcode, 
	std::string*& instr_name, ArgsType& args_type) const
{
	DECODE_ITERATION(iog5_three_regs_ldst_map, 
		ArgsType::ThreeRegsLdst);
	DECODE_ITERATION(iog5_two_regs_one_simm_ldst_map,
		ArgsType::TwoRegsOneSimmLdst);

	instr_name = cstm_strdup("unknown_instruction");
	args_type = ArgsType::Unknown;
}
