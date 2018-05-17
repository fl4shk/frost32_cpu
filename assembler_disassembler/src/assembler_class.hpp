#ifndef src__slash__assembler_class_hpp
#define src__slash__assembler_class_hpp

// src/assembler_class.hpp

#include "misc_includes.hpp"
#include "ANTLRErrorListener.h"
#include "gen_src/AssemblerGrammarLexer.h"
#include "gen_src/AssemblerGrammarParser.h"
#include "gen_src/AssemblerGrammarVisitor.h"

#include "symbol_table_classes.hpp"

#include "encoding_stuff_class.hpp"




class Assembler : public AssemblerGrammarVisitor
{
public:		// typedefs
	typedef antlr4::ParserRuleContext ParserRuleContext;

private:		// variables
	SymbolTable __sym_tbl;

	//u64 __pc;

	liborangepower::containers::PrevCurrPair<u64> __pc;

	std::stack<s64> __num_stack;
	//std::stack<bool> __enable_signed_expr_stack;
	std::stack<s64> __scope_child_num_stack;
	std::stack<std::string*> __str_stack;

	EncodingStuff __encoding_stuff;

	AssemblerGrammarParser::ProgramContext* __program_ctx;
	int __pass;

	bool __show_words;

	ScopedTableNode<Symbol>* __curr_scope_node = nullptr;

public:		// functions
	Assembler(AssemblerGrammarParser& parser, bool s_show_words=false);

	int run();

private:		// functions
	inline void err(ParserRuleContext* ctx, const std::string& msg)
	{
		if (ctx == nullptr)
		{
			printerr("Error:  ", msg, "\n");
		}
		else
		{
			auto tok = ctx->getStart();
			const size_t line = tok->getLine();
			const size_t pos_in_line = tok->getCharPositionInLine();
			//printerr("Error in file \"", *__file_name, "\", on line ",
			//	line, ", position ", pos_in_line, ":  ", msg, "\n");
			printerr("Error on line ", line, ", position ", pos_in_line, 
				":  ", msg, "\n");
		}
		exit(1);
	}
	inline void err(const std::string& msg)
	{
		//printerr("Error in file \"", *__file_name, "\":  ", msg, "\n");
		printerr("Error:  ", msg, "\n");
		exit(1);
	}
	inline void warn(ParserRuleContext* ctx, const std::string& msg)
	{
		if (ctx == nullptr)
		{
			printerr("Error:  ", msg, "\n");
		}
		else
		{
			auto tok = ctx->getStart();
			const size_t line = tok->getLine();
			const size_t pos_in_line = tok->getCharPositionInLine();
			//printerr("Error in file \"", *__file_name, "\", on line ",
			//	line, ", position ", pos_in_line, ":  ", msg, "\n");
			printerr("Warning on line ", line, ", position ", pos_in_line, 
				":  ", msg, "\n");
		}
	}
	inline void warn(const std::string& msg)
	{
		printerr("Warning:  ", msg, "\n");
	}
	//inline void print_words_if_allowed(const std::string some_words)
	//{
	//	if (__pass && __show_words)
	//	{
	//		printout(some_words);
	//	}
	//}

	template<typename CtxType>
	auto get_reg_encodings(CtxType *ctx) const;

	inline auto get_one_reg_encoding(const std::string& reg_name) const;

	inline void encode_instr_opcode_group_0(u32 reg_a_index, 
		u32 reg_b_index, u32 reg_c_index, u32 opcode)
	{
		u64 to_gen = 0;

		// clear_and_set_bits_with_range(to_gen, 0b0000, 31, 28);
		clear_and_set_bits_with_range(to_gen, reg_a_index, 27, 24);
		clear_and_set_bits_with_range(to_gen, reg_b_index, 23, 20);
		clear_and_set_bits_with_range(to_gen, reg_c_index, 19, 16);
		clear_and_set_bits_with_range(to_gen, opcode, 3, 0);

		gen_32(to_gen);
	}

	inline void encode_instr_opcode_group_1(u32 reg_a_index,
		u32 reg_b_index, u32 opcode, u32 immediate)
	{
		u64 to_gen = 0;

		clear_and_set_bits_with_range(to_gen, 0b0001, 31, 28);
		clear_and_set_bits_with_range(to_gen, reg_a_index, 27, 24);
		clear_and_set_bits_with_range(to_gen, reg_b_index, 23, 20);
		clear_and_set_bits_with_range(to_gen, opcode, 19, 16);
		clear_and_set_bits_with_range(to_gen, immediate, 15, 0);

		gen_32(to_gen);
	}
	inline void encode_instr_opcode_group_2(u32 reg_a_index,
		u32 reg_b_index, u32 opcode, u32 immediate)
	{
		u64 to_gen = 0;

		clear_and_set_bits_with_range(to_gen, 0b0010, 31, 28);
		clear_and_set_bits_with_range(to_gen, reg_a_index, 27, 24);
		clear_and_set_bits_with_range(to_gen, reg_b_index, 23, 20);
		clear_and_set_bits_with_range(to_gen, opcode, 19, 16);
		clear_and_set_bits_with_range(to_gen, immediate, 15, 0);

		gen_32(to_gen);
	}

	inline void encode_instr_opcode_group_3(u32 reg_a_index, 
		u32 reg_b_index, u32 reg_c_index, u32 opcode)
	{
		u64 to_gen = 0;

		clear_and_set_bits_with_range(to_gen, 0b0011, 31, 28);
		clear_and_set_bits_with_range(to_gen, reg_a_index, 27, 24);
		clear_and_set_bits_with_range(to_gen, reg_b_index, 23, 20);
		clear_and_set_bits_with_range(to_gen, reg_c_index, 19, 16);
		clear_and_set_bits_with_range(to_gen, opcode, 3, 0);

		gen_32(to_gen);
	}
	inline void encode_instr_opcode_group_4(u32 reg_a_index, 
		u32 reg_b_index, u32 reg_c_index, u32 opcode)
	{
		u64 to_gen = 0;

		clear_and_set_bits_with_range(to_gen, 0b0100, 31, 28);
		clear_and_set_bits_with_range(to_gen, reg_a_index, 27, 24);
		clear_and_set_bits_with_range(to_gen, reg_b_index, 23, 20);
		clear_and_set_bits_with_range(to_gen, reg_c_index, 19, 16);
		clear_and_set_bits_with_range(to_gen, opcode, 3, 0);

		gen_32(to_gen);
	}

	inline void encode_instr_opcode_group_5_no_simm(u32 reg_a_index, 
		u32 reg_b_index, u32 reg_c_index, u32 opcode)
	{
		u64 to_gen = 0;

		clear_and_set_bits_with_range(to_gen, 0b0101, 31, 28);
		clear_and_set_bits_with_range(to_gen, reg_a_index, 27, 24);
		clear_and_set_bits_with_range(to_gen, reg_b_index, 23, 20);
		clear_and_set_bits_with_range(to_gen, reg_c_index, 19, 16);
		clear_and_set_bits_with_range(to_gen, opcode, 3, 0);

		gen_32(to_gen);
	}
	inline void encode_instr_opcode_group_5_with_simm(u32 reg_a_index,
		u32 reg_b_index, u32 opcode, u32 immediate)
	{
		u64 to_gen = 0;

		clear_and_set_bits_with_range(to_gen, 0b0101, 31, 28);
		clear_and_set_bits_with_range(to_gen, reg_a_index, 27, 24);
		clear_and_set_bits_with_range(to_gen, reg_b_index, 23, 20);
		clear_and_set_bits_with_range(to_gen, immediate, 15, 4);
		clear_and_set_bits_with_range(to_gen, opcode, 3, 0);

		gen_32(to_gen);
	}
	inline void encode_instr_opcode_group_6(u32 reg_a_index, 
		u32 reg_b_index, u32 reg_c_index, u32 opcode)
	{
		u64 to_gen = 0;

		clear_and_set_bits_with_range(to_gen, 0b0110, 31, 28);
		clear_and_set_bits_with_range(to_gen, reg_a_index, 27, 24);
		clear_and_set_bits_with_range(to_gen, reg_b_index, 23, 20);
		clear_and_set_bits_with_range(to_gen, reg_c_index, 19, 16);
		clear_and_set_bits_with_range(to_gen, opcode, 3, 0);

		gen_32(to_gen);
	}

	// Generate data
	void gen_words(u16 data);
	void gen_8(u8 data);
	void gen_16(u16 data);
	void gen_32(u32 data);


private:		// visitor functions
	antlrcpp::Any visitProgram
		(AssemblerGrammarParser::ProgramContext *ctx);
	// program:
	antlrcpp::Any visitLine
		(AssemblerGrammarParser::LineContext *ctx);

	// line:
	antlrcpp::Any visitScopedLines
		(AssemblerGrammarParser::ScopedLinesContext *ctx);
	antlrcpp::Any visitLabel
		(AssemblerGrammarParser::LabelContext *ctx);
	antlrcpp::Any visitInstruction
		(AssemblerGrammarParser::InstructionContext *ctx);
	antlrcpp::Any visitPseudoInstruction
		(AssemblerGrammarParser::PseudoInstructionContext *ctx);
	antlrcpp::Any visitDirective
		(AssemblerGrammarParser::DirectiveContext *ctx);

	// instruction:
	antlrcpp::Any visitInstrOpGrp0ThreeRegs
		(AssemblerGrammarParser::InstrOpGrp0ThreeRegsContext *ctx);
	//antlrcpp::Any visitInstrOpGrp0TwoRegs
	//	(AssemblerGrammarParser::InstrOpGrp0TwoRegsContext *ctx);
	antlrcpp::Any visitInstrOpGrp1TwoRegsOneImm
		(AssemblerGrammarParser::InstrOpGrp1TwoRegsOneImmContext *ctx);
	antlrcpp::Any visitInstrOpGrp1TwoRegsOneSimm
		(AssemblerGrammarParser::InstrOpGrp1TwoRegsOneSimmContext *ctx);
	antlrcpp::Any visitInstrOpGrp1OneRegOnePcOneSimm
		(AssemblerGrammarParser::InstrOpGrp1OneRegOnePcOneSimmContext *ctx);
	antlrcpp::Any visitInstrOpGrp1OneRegOneImm
		(AssemblerGrammarParser::InstrOpGrp1OneRegOneImmContext *ctx);
	antlrcpp::Any visitInstrOpGrp2Branch
		(AssemblerGrammarParser::InstrOpGrp2BranchContext *ctx);
	antlrcpp::Any visitInstrOpGrp3Jump
		(AssemblerGrammarParser::InstrOpGrp3JumpContext *ctx);
	antlrcpp::Any visitInstrOpGrp4Call
		(AssemblerGrammarParser::InstrOpGrp4CallContext *ctx);
	antlrcpp::Any visitInstrOpGrp5ThreeRegsLdst
		(AssemblerGrammarParser::InstrOpGrp5ThreeRegsLdstContext *ctx);
	antlrcpp::Any visitInstrOpGrp5TwoRegsOneSimm12Ldst
		(AssemblerGrammarParser::InstrOpGrp5TwoRegsOneSimm12LdstContext
		*ctx);

	antlrcpp::Any visitInstrOpGrp6NoArgs
		(AssemblerGrammarParser::InstrOpGrp6NoArgsContext *ctx);
	antlrcpp::Any visitInstrOpGrp6OneIretaOneReg
		(AssemblerGrammarParser::InstrOpGrp6OneIretaOneRegContext *ctx);
	antlrcpp::Any visitInstrOpGrp6OneRegOneIreta
		(AssemblerGrammarParser::InstrOpGrp6OneRegOneIretaContext *ctx);
	antlrcpp::Any visitInstrOpGrp6OneIdstaOneReg
		(AssemblerGrammarParser::InstrOpGrp6OneIdstaOneRegContext *ctx);
	antlrcpp::Any visitInstrOpGrp6OneRegOneIdsta
		(AssemblerGrammarParser::InstrOpGrp6OneRegOneIdstaContext *ctx);

	// pseudoInstruction:
	antlrcpp::Any visitPseudoInstrOpInv
		(AssemblerGrammarParser::PseudoInstrOpInvContext *ctx);
	antlrcpp::Any visitPseudoInstrOpInvi
		(AssemblerGrammarParser::PseudoInstrOpInviContext *ctx);
	antlrcpp::Any visitPseudoInstrOpGrpCpy
		(AssemblerGrammarParser::PseudoInstrOpGrpCpyContext *ctx);
	antlrcpp::Any visitPseudoInstrOpCpyi
		(AssemblerGrammarParser::PseudoInstrOpCpyiContext *ctx);
	antlrcpp::Any visitPseudoInstrOpCpya
		(AssemblerGrammarParser::PseudoInstrOpCpyaContext *ctx);
	antlrcpp::Any visitPseudoInstrOpBra
		(AssemblerGrammarParser::PseudoInstrOpBraContext *ctx);
	antlrcpp::Any visitPseudoInstrOpJmp
		(AssemblerGrammarParser::PseudoInstrOpJmpContext *ctx);
	antlrcpp::Any visitPseudoInstrOpCall
		(AssemblerGrammarParser::PseudoInstrOpCallContext *ctx);
	antlrcpp::Any visitPseudoInstrOpJmpa
		(AssemblerGrammarParser::PseudoInstrOpJmpaContext *ctx);
	antlrcpp::Any visitPseudoInstrOpCalla
		(AssemblerGrammarParser::PseudoInstrOpCallaContext *ctx);
	antlrcpp::Any visitPseudoInstrOpJmpaCallaConditional
		(AssemblerGrammarParser::PseudoInstrOpJmpaCallaConditionalContext 
		*ctx);
	antlrcpp::Any visitPseudoInstrOpIncDec
		(AssemblerGrammarParser::PseudoInstrOpIncDecContext *ctx);
	antlrcpp::Any visitPseudoInstrOpAluOpTwoReg
		(AssemblerGrammarParser::PseudoInstrOpAluOpTwoRegContext *ctx);
	antlrcpp::Any visitPseudoInstrOpAluOpOneRegOneImm
		(AssemblerGrammarParser::PseudoInstrOpAluOpOneRegOneImmContext
		*ctx);
	antlrcpp::Any visitPseudoInstrOpAluOpOneRegOneSimm
		(AssemblerGrammarParser::PseudoInstrOpAluOpOneRegOneSimmContext
		*ctx);


	// directive:
	antlrcpp::Any visitDotOrgDirective
		(AssemblerGrammarParser::DotOrgDirectiveContext *ctx);
	antlrcpp::Any visitDotSpaceDirective
		(AssemblerGrammarParser::DotSpaceDirectiveContext *ctx);
	antlrcpp::Any visitDotDbDirective
		(AssemblerGrammarParser::DotDbDirectiveContext *ctx);
	antlrcpp::Any visitDotDb16Directive
		(AssemblerGrammarParser::DotDb16DirectiveContext *ctx);
	antlrcpp::Any visitDotDb8Directive
		(AssemblerGrammarParser::DotDb8DirectiveContext *ctx);

	// Expression parsing
	antlrcpp::Any visitExpr
		(AssemblerGrammarParser::ExprContext *ctx);

	antlrcpp::Any visitExprLogical
		(AssemblerGrammarParser::ExprLogicalContext *ctx);
	antlrcpp::Any visitExprCompare
		(AssemblerGrammarParser::ExprCompareContext *ctx);
	antlrcpp::Any visitExprAddSub
		(AssemblerGrammarParser::ExprAddSubContext *ctx);
	antlrcpp::Any visitExprJustAdd
		(AssemblerGrammarParser::ExprJustAddContext *ctx);
	antlrcpp::Any visitExprJustSub
		(AssemblerGrammarParser::ExprJustSubContext *ctx);
	antlrcpp::Any visitExprMulDivModEtc
		(AssemblerGrammarParser::ExprMulDivModEtcContext *ctx);

	antlrcpp::Any visitExprUnary
		(AssemblerGrammarParser::ExprUnaryContext *ctx);
	antlrcpp::Any visitExprBitInvert
		(AssemblerGrammarParser::ExprBitInvertContext *ctx);
	antlrcpp::Any visitExprNegate
		(AssemblerGrammarParser::ExprNegateContext *ctx);
	antlrcpp::Any visitExprLogNot
		(AssemblerGrammarParser::ExprLogNotContext *ctx);

	// Last set of token stuff
	antlrcpp::Any visitIdentName
		(AssemblerGrammarParser::IdentNameContext *ctx);
	antlrcpp::Any visitInstrName
		(AssemblerGrammarParser::InstrNameContext *ctx);
	antlrcpp::Any visitPseudoInstrName
		(AssemblerGrammarParser::PseudoInstrNameContext *ctx);
	antlrcpp::Any visitNumExpr
		(AssemblerGrammarParser::NumExprContext *ctx);
	antlrcpp::Any visitCurrPc
		(AssemblerGrammarParser::CurrPcContext *ctx);

private:		// functions
	inline void push_num(s64 to_push)
	{
		__num_stack.push(to_push);
	}
	inline auto get_top_num()
	{
		return __num_stack.top();
	}
	inline auto pop_num()
	{
		auto ret = __num_stack.top();
		__num_stack.pop();
		return ret;
	}
	inline void push_scope_child_num(s64 to_push)
	{
		__scope_child_num_stack.push(to_push);
	}
	inline auto get_top_scope_child_num()
	{
		return __scope_child_num_stack.top();
	}
	inline auto pop_scope_child_num()
	{
		auto ret = __scope_child_num_stack.top();
		__scope_child_num_stack.pop();
		return ret;
	}

	inline void push_str(std::string* to_push)
	{
		__str_stack.push(to_push);
	}
	inline auto get_top_str()
	{
		return __str_stack.top();
	}
	inline auto pop_str()
	{
		auto ret = __str_stack.top();
		__str_stack.pop();
		return ret;
	}

	gen_getter_and_setter_by_val(pc);
	gen_getter_by_ref(sym_tbl);

	void __encode_alu_op_three_regs(ParserRuleContext* ctx,
		const std::string& instr_name, u32 reg_a_index, u32 reg_b_index, 
		u32 reg_c_index);
	void __encode_alu_op_two_regs_one_imm(ParserRuleContext* ctx,
		const std::string& instr_name, u32 reg_a_index, u32 reg_b_index, 
		s64 immediate);
	void __encode_inv(ParserRuleContext* ctx, u32 reg_a_index, u32 
		reg_b_index);
	void __encode_invi(ParserRuleContext* ctx, u32 reg_a_index, 
		s64 immediate);
	void __encode_cpy_ra_rb(ParserRuleContext* ctx, u32 reg_a_index, 
		u32 reg_b_index);
	void __encode_cpy_ra_pc(ParserRuleContext* ctx, u32 reg_a_index);
	void __encode_cpyi(ParserRuleContext* ctx, u32 reg_a_index, 
		s64 immediate);
	void __encode_cpya(ParserRuleContext* ctx, u32 reg_a_index, 
		s64 immediate);


	void __encode_relative_branch(ParserRuleContext* ctx,
		const std::string& instr_name, 
		u32 reg_a_index, u32 reg_b_index, s64 raw_immediate);
	void __encode_jump(ParserRuleContext* ctx,
		const std::string& instr_name, u32 reg_a_index, 
		u32 reg_b_index, u32 reg_c_index);
	void __encode_call(ParserRuleContext* ctx,
		const std::string& instr_name, u32 reg_a_index, 
		u32 reg_b_index, u32 reg_c_index);
	void __encode_ldst_three_regs(ParserRuleContext* ctx,
		const std::string& instr_name,
		u32 reg_a_index, u32 reg_b_index, u32 reg_c_index);
	void __encode_ldst_two_regs_one_simm(ParserRuleContext* ctx,
		const std::string& instr_name,
		u32 reg_a_index, u32 reg_b_index, s64 immediate);

	u32 __get_reg_temp_index() const;

	inline void __warn_if_imm16_out_of_range(ParserRuleContext* ctx, 
		s64 immediate)
	{
		if (__pass)
		{
			const u16 imm16 = static_cast<u16>(immediate);
			const u64 imm64 = static_cast<u64>(immediate);

			//if (immediate != static_cast<s64>(imm64))
			if (imm64 != imm16)
			{
				warn(ctx, sconcat("immediate value 0x", std::hex,
					immediate, std::dec, 
					" out of range for for 16-bit unsigned "
					"immediate."));
			}
		}
	}

	inline void __warn_if_simm16_out_of_range(ParserRuleContext* ctx, 
		s64 immediate, bool is_for_branch=false)
	{
		if (__pass)
		{
			s16 simm16 = static_cast<s16>(immediate);
			//s16 simm16;
			//const s64 simm64 = static_cast<s64>(simm16);

			if (immediate != simm16)
			{
				if (!is_for_branch)
				{
					warn(ctx, sconcat("immediate value 0x", std::hex, 
						immediate, std::dec, 
						" out of range for for 16-bit signed ",
						"immediate."));
				}
				else // if (is_for_branch)
				{
					warn(ctx, sconcat("branch offset 0x", std::hex,
						immediate, std::dec, " out of range ",
						"because it doesn't fit in a 16-bit signed ",
						"immediate."));
				}
			}
		}
	}

	inline void __warn_if_simm12_out_of_range(ParserRuleContext* ctx, 
		s64 immediate)
	{
		if (__pass)
		{
			struct
			{
				u8 fill : 4;
				s16 simm12 : 12;
			} temp;

			//const s16 simm16 = static_cast<s16>(immediate);
			temp.simm12 = static_cast<s16>(immediate);

			//const s64 simm64 = static_cast<s64>(temp.simm12);

			if (immediate != temp.simm12)
			{
				warn(ctx, sconcat("immediate value 0x", std::hex, immediate,
					std::dec, " out of range for for 12-bit signed ",
					"immediate."));
			}
		}
	}

};



#endif		// src__slash__assembler_class_hpp
