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
	__reg_names_map[cstm_strdup("r0")] = temp++;
	__reg_names_map[cstm_strdup("r1")] = temp++;
	__reg_names_map[cstm_strdup("r2")] = temp++;
	__reg_names_map[cstm_strdup("r3")] = temp++;
	__reg_names_map[cstm_strdup("r4")] = temp++;
	__reg_names_map[cstm_strdup("r5")] = temp++;
	__reg_names_map[cstm_strdup("r6")] = temp++;
	__reg_names_map[cstm_strdup("r7")] = temp++;
	__reg_names_map[cstm_strdup("r8")] = temp++;
	__reg_names_map[cstm_strdup("r9")] = temp++;
	__reg_names_map[cstm_strdup("r10")] = temp++;
	__reg_names_map[cstm_strdup("r11")] = temp++;
	__reg_names_map[cstm_strdup("r12")] = temp++;
	__reg_names_map[cstm_strdup("lr")] = temp++;
	__reg_names_map[cstm_strdup("fp")] = temp++;
	__reg_names_map[cstm_strdup("sp")] = temp++;

	// Instruction Opcode Group 0
	temp = 0;
	__iog0_three_regs_map[cstm_strdup("add")] = temp++;
	__iog0_three_regs_map[cstm_strdup("sub")] = temp++;
	__iog0_three_regs_map[cstm_strdup("sltu")] = temp++;
	__iog0_three_regs_map[cstm_strdup("slts")] = temp++;
	__iog0_three_regs_map[cstm_strdup("mul")] = temp++;
	__iog0_three_regs_map[cstm_strdup("and")] = temp++;
	__iog0_three_regs_map[cstm_strdup("orr")] = temp++;
	__iog0_three_regs_map[cstm_strdup("xor")] = temp++;
	__iog0_two_regs_map[cstm_strdup("inv")] = temp++;
	__iog0_three_regs_map[cstm_strdup("lsl")] = temp++;
	__iog0_three_regs_map[cstm_strdup("lsr")] = temp++;
	__iog0_three_regs_map[cstm_strdup("asr")] = temp++;

	// Instruction Opcode Group 1
	temp = 0;
	__iog1_two_regs_one_imm_map[cstm_strdup("addi")] 
		= temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("subi")]
		= temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("sltui")]
		= temp++;
	__iog1_two_regs_one_simm_map[cstm_strdup("sltsi")]
		= temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("muli")]
		= temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("andi")]
		= temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("orri")]
		= temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("xori")]
		= temp++;
	__iog1_one_reg_one_imm_map[cstm_strdup("invi")]
		= temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("lsli")]
		= temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("lsri")]
		= temp++;
	__iog1_two_regs_one_imm_map[cstm_strdup("asri")]
		= temp++;
	__iog1_one_reg_one_pc_one_simm_map[cstm_strdup("addsi")]
		= temp++;
	__iog1_one_reg_one_imm_map[cstm_strdup("cpyhi")]
		= temp++;
	__iog1_branch_map[cstm_strdup("bne")]
		= temp++;
	__iog1_branch_map[cstm_strdup("beq")] =
		temp++;

	// Instruction Opcode Group 2
	temp = 0;
	__iog2_two_regs_map[cstm_strdup("jne")] = temp++;
	__iog2_two_regs_map[cstm_strdup("jeq")] = temp++;
	__iog2_two_regs_map[cstm_strdup("callne")] = temp++;
	__iog2_two_regs_map[cstm_strdup("calleq")] = temp++;

	// Instruction Opcode Group 3
	temp = 0;
	__iog3_two_regs_ldst_map[cstm_strdup("ldr")] = temp++;
	__iog3_two_regs_ldst_map[cstm_strdup("ldh")] = temp++;
	__iog3_two_regs_ldst_map[cstm_strdup("ldsh")] = temp++;
	__iog3_two_regs_ldst_map[cstm_strdup("ldb")] = temp++;
	__iog3_two_regs_ldst_map[cstm_strdup("ldsb")] = temp++;
	__iog3_two_regs_ldst_map[cstm_strdup("str")] = temp++;
	__iog3_two_regs_ldst_map[cstm_strdup("sth")] = temp++;
	__iog3_two_regs_ldst_map[cstm_strdup("stb")] = temp++;
}


const std::string* EncodingStuff::decode_reg_name(u32 reg_index) const
{
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
	DECODE_ITERATION(iog0_two_regs_map, ArgsType::TwoRegs);

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
	DECODE_ITERATION(iog1_branch_map, 
		ArgsType::Branch);

	instr_name = cstm_strdup("unknown_instruction");
	args_type = ArgsType::Unknown;
}
void EncodingStuff::get_iog2_instr_from_opcode(u32 opcode, 
	std::string*& instr_name, EncodingStuff::ArgsType& args_type) const
{
	DECODE_ITERATION(iog2_two_regs_map, ArgsType::TwoRegs);

	instr_name = cstm_strdup("unknown_instruction");
	args_type = ArgsType::Unknown;
}
void EncodingStuff::get_iog3_instr_from_opcode(u32 opcode, 
	std::string*& instr_name, EncodingStuff::ArgsType& args_type) const
{
	DECODE_ITERATION(iog3_two_regs_ldst_map, ArgsType::TwoRegsLdst);

	instr_name = cstm_strdup("unknown_instruction");
	args_type = ArgsType::Unknown;
}
