#ifndef assembler_class_hpp
#define assembler_class_hpp

#include "misc_includes.hpp"
#include "ANTLRErrorListener.h"
#include "gen_src/GrammarLexer.h"
#include "gen_src/GrammarParser.h"
#include "gen_src/GrammarVisitor.h"

#include "symbol_table_classes.hpp"




class AsmErrorListener : public antlr4::ANTLRErrorListener
{
public:		// functions
	virtual ~AsmErrorListener();

	void syntaxError(antlr4::Recognizer *recognizer, 
		antlr4::Token *offendingSymbol, size_t line, 
		size_t charPositionInLine, const std::string &msg, 
		std::exception_ptr e);
	void reportAmbiguity(antlr4::Parser *recognizer, 
		const antlr4::dfa::DFA &dfa, size_t startIndex, size_t stopIndex, 
		bool exact, const antlrcpp::BitSet &ambigAlts, 
		antlr4::atn::ATNConfigSet *configs);
	
	void reportAttemptingFullContext(antlr4::Parser *recognizer, 
		const antlr4::dfa::DFA &dfa, size_t startIndex, size_t stopIndex,
		const antlrcpp::BitSet &conflictingAlts, 
		antlr4::atn::ATNConfigSet *configs);

	void reportContextSensitivity(antlr4::Parser *recognizer, 
		const antlr4::dfa::DFA &dfa, size_t startIndex, size_t stopIndex,
		size_t prediction, antlr4::atn::ATNConfigSet *configs);
};

class Assembler : public GrammarVisitor
{
private:		// variables
	SymbolTable __sym_tbl;

	//u64 __pc;

	liborangepower::containers::PrevCurrPair<u64> __pc;

	std::stack<s64> __num_stack;
	std::stack<s64> __scope_child_num_stack;
	std::stack<std::string*> __str_stack;

	struct
	{
		std::map<std::string*, u16> reg_names_map;
		struct
		{
			std::map<std::string*, u16> three_regs_map;
			std::map<std::string*, u16> two_regs_map;
		} instr_op_grp_0;
		struct
		{
			std::map<std::string*, u16> two_regs_one_imm_map;
			std::map<std::string*, u16> two_regs_one_simm_map;
			std::map<std::string*, u16> one_reg_one_pc_one_simm_map;
			std::map<std::string*, u16> one_reg_one_imm_map;
			std::map<std::string*, u16> branch_map;
		} instr_op_grp_1;
		struct
		{
			std::map<std::string*, u16> all_names_map;
		} instr_op_grp_2;
		struct
		{
			std::map<std::string*, u16> all_names_map;
		} instr_op_grp_3;

	} __encoding_stuff;

	GrammarParser::ProgramContext* __program_ctx;
	int __pass;

	bool __show_ws;

	ScopedTableNode<Symbol>* __curr_scope_node = nullptr;

public:		// functions
	Assembler(GrammarParser& parser, bool s_show_ws=false);

	int run();

private:		// functions
	inline void err(antlr4::ParserRuleContext* ctx, 
		const std::string& msg)
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
	inline void print_ws_if_allowed(const std::string some_ws)
	{
		if (__pass && __show_ws)
		{
			printout(some_ws);
		}
	}
	// Generate data
	void gen_no_ws(u16 data);
	void gen_8(u8 data);
	void gen_16(u16 data);
	void gen_32(u32 data);

	antlrcpp::Any visitProgram(GrammarParser::ProgramContext *ctx);

private:		// visitor functions
	// program:
	antlrcpp::Any visitLine
		(GrammarParser::LineContext *ctx);

	// line:
	antlrcpp::Any visitScopedLines
		(GrammarParser::ScopedLinesContext *ctx);
	antlrcpp::Any visitLabel
		(GrammarParser::LabelContext *ctx);
	antlrcpp::Any visitInstruction
		(GrammarParser::InstructionContext *ctx);
	antlrcpp::Any visitDirective
		(GrammarParser::DirectiveContext *ctx);

	// instruction:
	antlrcpp::Any visitInstrOpGrp0ThreeRegs
		(GrammarParser::InstrOpGrp0ThreeRegsContext *ctx);
	antlrcpp::Any visitInstrOpGrp0TwoRegs
		(GrammarParser::InstrOpGrp0TwoRegsContext *ctx);
	antlrcpp::Any visitInstrOpGrp1TwoRegsOneImm
		(GrammarParser::InstrOpGrp1TwoRegsOneImmContext *ctx);
	antlrcpp::Any visitInstrOpGrp1TwoRegsOneSimm
		(GrammarParser::InstrOpGrp1TwoRegsOneSimmContext *ctx);
	antlrcpp::Any visitInstrOpGrp1OneRegOnePcOneSimm
		(GrammarParser::InstrOpGrp1OneRegOnePcOneSimmContext *ctx);
	antlrcpp::Any visitInstrOpGrp1OneRegOneImm
		(GrammarParser::InstrOpGrp1OneRegOneImmContext *ctx);
	antlrcpp::Any visitInstrOpGrp1Branch
		(GrammarParser::InstrOpGrp1BranchContext *ctx);
	antlrcpp::Any visitInstrOpGrp2
		(GrammarParser::InstrOpGrp2Context *ctx);
	antlrcpp::Any visitInstrOpGrp3
		(GrammarParser::InstrOpGrp3Context *ctx);

	// directive:
	antlrcpp::Any visitDotOrgDirective
		(GrammarParser::DotOrgDirectiveContext *ctx);
	antlrcpp::Any visitDotSpaceDirective
		(GrammarParser::DotSpaceDirectiveContext *ctx);
	antlrcpp::Any visitDotDbDirective
		(GrammarParser::DotDbDirectiveContext *ctx);
	antlrcpp::Any visitDotDb16Directive
		(GrammarParser::DotDb16DirectiveContext *ctx);
	antlrcpp::Any visitDotDb8Directive
		(GrammarParser::DotDb8DirectiveContext *ctx);

	// Expression parsing
	antlrcpp::Any visitExpr
		(GrammarParser::ExprContext *ctx);

	antlrcpp::Any visitExprLogical
		(GrammarParser::ExprLogicalContext *ctx);
	antlrcpp::Any visitExprCompare
		(GrammarParser::ExprCompareContext *ctx);
	antlrcpp::Any visitExprAddSub
		(GrammarParser::ExprAddSubContext *ctx);
	antlrcpp::Any visitExprJustAdd
		(GrammarParser::ExprJustAddContext *ctx);
	antlrcpp::Any visitExprJustSub
		(GrammarParser::ExprJustSubContext *ctx);
	antlrcpp::Any visitExprMulDivModEtc
		(GrammarParser::ExprMulDivModEtcContext *ctx);

	antlrcpp::Any visitExprUnary
		(GrammarParser::ExprUnaryContext *ctx);
	antlrcpp::Any visitExprBitInvert
		(GrammarParser::ExprBitInvertContext *ctx);
	antlrcpp::Any visitExprNegate
		(GrammarParser::ExprNegateContext *ctx);
	antlrcpp::Any visitExprLogNot
		(GrammarParser::ExprLogNotContext *ctx);

	// Last set of token stuff
	antlrcpp::Any visitIdentName
		(GrammarParser::IdentNameContext *ctx);
	antlrcpp::Any visitInstrName
		(GrammarParser::InstrNameContext *ctx);
	antlrcpp::Any visitNumExpr
		(GrammarParser::NumExprContext *ctx);
	antlrcpp::Any visitCurrPc
		(GrammarParser::CurrPcContext *ctx);

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

};



#endif		// assembler_class_hpp
