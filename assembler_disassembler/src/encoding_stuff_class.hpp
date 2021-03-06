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

		ThreeRegsLdst,
		TwoRegsOneSimmLdst,

		NoArgs,
		OneIretaOneReg,
		OneRegOneIreta,
		OneIdstaOneReg,
		OneRegOneIdsta,

		Unknown,
	};

public:		// typedefs
	typedef std::map<std::string*, u16> MapType;

private:		// variables
	MapType __reg_names_map;

	MapType __iog0_three_regs_map;
	//MapType __iog0_two_regs_map;

	MapType __iog1_two_regs_one_imm_map;
	MapType __iog1_two_regs_one_simm_map;
	MapType __iog1_one_reg_one_pc_one_simm_map;
	MapType __iog1_one_reg_one_imm_map;

	//MapType __iog1_branch_map;

	//MapType __iog2_three_regs_map;
	//MapType __iog3_three_regs_ldst_map;
	//MapType __iog3_two_regs_one_simm_ldst_map;

	MapType __iog2_branch_map;
	MapType __iog3_jump_map;
	MapType __iog4_call_map;

	MapType __iog5_three_regs_ldst_map;
	MapType __iog5_two_regs_one_simm_ldst_map;

	MapType __iog6_no_args_map;
	MapType __iog6_one_ireta_one_reg_map;
	MapType __iog6_one_reg_one_ireta_map;
	MapType __iog6_one_idsta_one_reg_map;
	MapType __iog6_one_reg_one_idsta_map;

public:		// functions
	EncodingStuff();

	gen_getter_by_con_ref(reg_names_map);

	gen_getter_by_con_ref(iog0_three_regs_map);
	//gen_getter_by_con_ref(iog0_two_regs_map);

	gen_getter_by_con_ref(iog1_two_regs_one_imm_map);
	gen_getter_by_con_ref(iog1_two_regs_one_simm_map);
	gen_getter_by_con_ref(iog1_one_reg_one_pc_one_simm_map);
	gen_getter_by_con_ref(iog1_one_reg_one_imm_map);

	gen_getter_by_con_ref(iog2_branch_map);
	gen_getter_by_con_ref(iog3_jump_map);
	gen_getter_by_con_ref(iog4_call_map);

	gen_getter_by_con_ref(iog5_three_regs_ldst_map);
	gen_getter_by_con_ref(iog5_two_regs_one_simm_ldst_map);

	gen_getter_by_con_ref(iog6_no_args_map);
	gen_getter_by_con_ref(iog6_one_ireta_one_reg_map);
	gen_getter_by_con_ref(iog6_one_reg_one_ireta_map);
	gen_getter_by_con_ref(iog6_one_idsta_one_reg_map);
	gen_getter_by_con_ref(iog6_one_reg_one_idsta_map);

	std::string* decode_reg_name(u32 reg_index) const;
	void get_iog0_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
	void get_iog1_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
	void get_iog2_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
	void get_iog3_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
	void get_iog4_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
	void get_iog5_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
	void get_iog6_instr_from_opcode(u32 opcode, std::string*& instr_name,
		ArgsType& args_type) const;
};


#endif		// src__slash__encoding_stuff_class_hpp
