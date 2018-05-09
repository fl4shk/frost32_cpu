#ifndef src__slash__encoding_stuff_class_hpp
#define src__slash__encoding_stuff_class_hpp

// src/encoding_stuff_class.hpp

#include "misc_includes.hpp"

class EncodingStuff
{
public:		// enums
	enum class ArgsType : u32
	{
		ThreeRegs,
		TwoRegs,

		TwoRegsOneImm,
		TwoRegsOneSimm,
		OneRegOnePcOneSimm,
		OneRegOneImm,
		Branch,

		TwoRegsLdst,

		Unknown,
	};

public:		// typedefs
	typedef std::map<std::string*, u16> MapType;

private:		// variables
	MapType __reg_names_map;

	MapType __iog0_three_regs_map;
	MapType __iog0_two_regs_map;

	MapType __iog1_two_regs_one_imm_map;
	MapType __iog1_two_regs_one_simm_map;
	MapType __iog1_one_reg_one_pc_one_simm_map;
	MapType __iog1_one_reg_one_imm_map;
	MapType __iog1_branch_map;

	MapType __iog2_two_regs_map;
	MapType __iog3_two_regs_ldst_map;

public:		// functions
	EncodingStuff();

	gen_getter_by_con_ref(reg_names_map);

	gen_getter_by_con_ref(iog0_three_regs_map);
	gen_getter_by_con_ref(iog0_two_regs_map);

	gen_getter_by_con_ref(iog1_two_regs_one_imm_map);
	gen_getter_by_con_ref(iog1_two_regs_one_simm_map);
	gen_getter_by_con_ref(iog1_one_reg_one_pc_one_simm_map);
	gen_getter_by_con_ref(iog1_one_reg_one_imm_map);
	gen_getter_by_con_ref(iog1_branch_map);

	gen_getter_by_con_ref(iog2_two_regs_map);
	gen_getter_by_con_ref(iog3_two_regs_ldst_map);

	std::string* decode_reg_name(u32 reg_index) const;
	void get_iog0_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
	void get_iog1_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
	void get_iog2_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
	void get_iog3_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
};


#endif		// src__slash__encoding_stuff_class_hpp
