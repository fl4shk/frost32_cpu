#include "assembler_class.hpp"
#include "allocation_stuff.hpp"

#include <sstream>

AsmErrorListener::~AsmErrorListener()
{
}

void AsmErrorListener::syntaxError(antlr4::Recognizer *recognizer, 
	antlr4::Token *offendingSymbol, size_t line, 
	size_t charPositionInLine, const std::string &msg, 
	std::exception_ptr e)
{
	printerr("Syntax error on line ", line, 
		", position ", charPositionInLine, 
		":  ", msg, "\n");
	exit(1);
}
void AsmErrorListener::reportAmbiguity(antlr4::Parser *recognizer, 
	const antlr4::dfa::DFA &dfa, size_t startIndex, size_t stopIndex, 
	bool exact, const antlrcpp::BitSet &ambigAlts, 
	antlr4::atn::ATNConfigSet *configs)
{
}

void AsmErrorListener::reportAttemptingFullContext
	(antlr4::Parser *recognizer, const antlr4::dfa::DFA &dfa, 
	size_t startIndex, size_t stopIndex,
	const antlrcpp::BitSet &conflictingAlts, 
	antlr4::atn::ATNConfigSet *configs)
{
}

void AsmErrorListener::reportContextSensitivity
	(antlr4::Parser *recognizer, const antlr4::dfa::DFA &dfa, 
	size_t startIndex, size_t stopIndex, size_t prediction, 
	antlr4::atn::ATNConfigSet *configs)
{
}
Assembler::Assembler(GrammarParser& parser, bool s_show_ws)
	: __show_ws(s_show_ws)
{
	__program_ctx = parser.program();

	// Registers
	u16 temp = 0;
	__encoding_stuff.reg_names_map[cstm_strdup("r0")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r1")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r2")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r3")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r4")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r5")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r6")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r7")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r8")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r9")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r10")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r11")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("r12")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("lr")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("fp")] = temp++;
	__encoding_stuff.reg_names_map[cstm_strdup("sp")] = temp++;

	// Instruction Opcode Group 0
	temp = 0;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("add")] = temp++;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("sub")] = temp++;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("sltu")] = temp++;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("slts")] = temp++;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("mul")] = temp++;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("and")] = temp++;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("orr")] = temp++;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("xor")] = temp++;
	__encoding_stuff.instr_op_grp_0.two_regs_map
		[cstm_strdup("inv")] = temp++;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("lsl")] = temp++;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("lsr")] = temp++;
	__encoding_stuff.instr_op_grp_0.three_regs_map
		[cstm_strdup("asr")] = temp++;

	// Instruction Opcode Group 1
	temp = 0;
	__encoding_stuff.instr_op_grp_1.two_regs_one_imm_map
		[cstm_strdup("addi")] = temp++;
	__encoding_stuff.instr_op_grp_1.two_regs_one_imm_map
		[cstm_strdup("subi")] = temp++;
	__encoding_stuff.instr_op_grp_1.two_regs_one_imm_map
		[cstm_strdup("sltui")] = temp++;
	__encoding_stuff.instr_op_grp_1.two_regs_one_simm_map
		[cstm_strdup("sltsi")] = temp++;
	__encoding_stuff.instr_op_grp_1.two_regs_one_imm_map
		[cstm_strdup("muli")] = temp++;
	__encoding_stuff.instr_op_grp_1.two_regs_one_imm_map
		[cstm_strdup("andi")] = temp++;
	__encoding_stuff.instr_op_grp_1.two_regs_one_imm_map
		[cstm_strdup("orri")] = temp++;
	__encoding_stuff.instr_op_grp_1.two_regs_one_imm_map
		[cstm_strdup("xori")] = temp++;
	__encoding_stuff.instr_op_grp_1.one_reg_one_imm_map
		[cstm_strdup("invi")] = temp++;
	__encoding_stuff.instr_op_grp_1.two_regs_one_imm_map
		[cstm_strdup("lsli")] = temp++;
	__encoding_stuff.instr_op_grp_1.two_regs_one_imm_map
		[cstm_strdup("lsri")] = temp++;
	__encoding_stuff.instr_op_grp_1.two_regs_one_imm_map
		[cstm_strdup("asri")] = temp++;
	__encoding_stuff.instr_op_grp_1.one_reg_one_pc_one_simm_map
		[cstm_strdup("addsi")] = temp++;
	__encoding_stuff.instr_op_grp_1.one_reg_one_imm_map
		[cstm_strdup("cpyhi")] = temp++;
	__encoding_stuff.instr_op_grp_1.branch_map
		[cstm_strdup("bne")] = temp++;
	__encoding_stuff.instr_op_grp_1.branch_map
		[cstm_strdup("beq")] = temp++;

	// Instruction Opcode Group 2
	temp = 0;
	__encoding_stuff.instr_op_grp_2.all_names_map
		[cstm_strdup("jne")] = temp++;
	__encoding_stuff.instr_op_grp_2.all_names_map
		[cstm_strdup("jeq")] = temp++;
	__encoding_stuff.instr_op_grp_2.all_names_map
		[cstm_strdup("callne")] = temp++;
	__encoding_stuff.instr_op_grp_2.all_names_map
		[cstm_strdup("calleq")] = temp++;

	// Instruction Opcode Group 3
	temp = 0;
	__encoding_stuff.instr_op_grp_3.all_names_map
		[cstm_strdup("ldr")] = temp++;
	__encoding_stuff.instr_op_grp_3.all_names_map
		[cstm_strdup("ldh")] = temp++;
	__encoding_stuff.instr_op_grp_3.all_names_map
		[cstm_strdup("ldsh")] = temp++;
	__encoding_stuff.instr_op_grp_3.all_names_map
		[cstm_strdup("ldb")] = temp++;
	__encoding_stuff.instr_op_grp_3.all_names_map
		[cstm_strdup("ldsb")] = temp++;
	__encoding_stuff.instr_op_grp_3.all_names_map
		[cstm_strdup("str")] = temp++;
	__encoding_stuff.instr_op_grp_3.all_names_map
		[cstm_strdup("sth")] = temp++;
	__encoding_stuff.instr_op_grp_3.all_names_map
		[cstm_strdup("stb")] = temp++;
}

int Assembler::run()
{
	push_scope_child_num(0);
	// Two passes
	for (__pass=0; __pass<2; ++__pass)
	{
		//__pc = 0;
		//__pc.prev = __pc.curr = 0;
		__pc.curr = 0;
		__pc.back_up();

		__curr_scope_node = sym_tbl().tree().children.front();

		visitProgram(__program_ctx);

	};

	return 0;
}

void Assembler::gen_no_ws(u16 data)
{
	if (__pass)
	{
		if (__pc.has_changed())
		{
			printout(std::hex);
			printout("@");
			printout(__pc.curr);
			printout(std::dec);
		}

		// Output big endian
		printout(std::hex);
		//printout(get_bits_with_range(data, 15, 8), "");
		//printout(get_bits_with_range(data, 7, 0), "\n");
		const u32 a = get_bits_with_range(data, 15, 8);
		const u32 b = get_bits_with_range(data, 7, 0);

		if (a < 0x10)
		{
			printout(0);
		}
		printout(a);

		if (b < 0x10)
		{
			printout(0);
		}
		printout(b);

		printout(std::dec);
	}
	//__pc += sizeof(data);
	__pc.curr += sizeof(data);
	__pc.back_up();
}
void Assembler::gen_8(u8 data)
{
	if (__pass)
	{
		if (__pc.has_changed())
		{
			printout(std::hex);
			printout("@");
			printout(__pc.curr);
			printout(std::dec);
		}

		printout(std::hex);

		const u32 a = data;

		if (a < 0x10)
		{
			printout(0);
		}
		printout(a);
		printout(std::dec);
	}
	//__pc += sizeof(data);
	__pc.curr += sizeof(data);
	__pc.back_up();

	print_ws_if_allowed("\n");
}
void Assembler::gen_16(u16 data)
{
	gen_no_ws(data);

	print_ws_if_allowed("\n");
}
void Assembler::gen_32(u32 data)
{
	gen_no_ws(get_bits_with_range(data, 31, 16));
	print_ws_if_allowed(" ");
	gen_no_ws(get_bits_with_range(data, 15, 0));

	print_ws_if_allowed("\n");
}

antlrcpp::Any Assembler::visitProgram
	(GrammarParser::ProgramContext *ctx)
{
	auto&& lines = ctx->line();

	for (auto line : lines)
	{
		line->accept(this);
	}

	return nullptr;
}

antlrcpp::Any Assembler::visitLine
	(GrammarParser::LineContext *ctx)
{

	return nullptr;
}
antlrcpp::Any Assembler::visitScopedLines
	(GrammarParser::ScopedLinesContext *ctx)
{
	if (!__pass)
	{
		sym_tbl().mkscope(__curr_scope_node);
	}
	else // if (__pass)
	{
		__curr_scope_node = __curr_scope_node->children.at
			(get_top_scope_child_num());
		push_scope_child_num(0);
	}
	auto&& lines = ctx->line();

	for (auto line : lines)
	{
		line->accept(this);
	}

	if (!__pass)
	{
		sym_tbl().rmscope(__curr_scope_node);
	}
	else // if (__pass)
	{
		pop_scope_child_num();

		if (__scope_child_num_stack.size() >= 1)
		{
			auto temp = pop_scope_child_num();
			++temp;
			push_scope_child_num(temp);
		}
		__curr_scope_node = __curr_scope_node->parent;
	}

	return nullptr;
}

