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


#define ANY_JUST_ACCEPT_BASIC(arg) \
	arg->accept(this)

#define ANY_ACCEPT_IF_BASIC(arg) \
	if (arg) \
	{ \
		ANY_JUST_ACCEPT_BASIC(arg); \
	}

#define ANY_PUSH_TOK_IF(arg) \
	if (arg) \
	{ \
		push_str(cstm_strdup(arg->toString())); \
	}

Assembler::Assembler(GrammarParser& parser, bool s_show_ws)
	: __show_ws(s_show_ws)
{
	__program_ctx = parser.program();


	// Encoding stuff (opcode field, register fields)

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

template<typename CtxType>
auto Assembler::get_reg_encodings(CtxType *ctx) const
{
	std::vector<u16> ret;

	auto&& regs = ctx->TokReg();

	for (auto reg : regs)
	{
		ret.push_back(__encoding_stuff.reg_names_map.at
			(cstm_strdup(reg->toString())));
	}

	return ret;
}

inline auto Assembler::get_one_reg_encoding(const std::string& reg_name) 
	const
{
	return __encoding_stuff.reg_names_map.at(cstm_strdup(reg_name));
}

void Assembler::gen_no_ws(u16 data)
{
	if (__pass)
	{
		// Output big endian
		printout(std::hex);

		if (__pc.has_changed())
		{
			printout("@", __pc.curr, "\n");
		}

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
		printout(std::hex);

		if (__pc.has_changed())
		{
			printout("@", __pc.curr, "\n");
		}

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
	ANY_ACCEPT_IF_BASIC(ctx->scopedLines())
	else ANY_ACCEPT_IF_BASIC(ctx->label())
	else ANY_ACCEPT_IF_BASIC(ctx->instruction())
	else ANY_ACCEPT_IF_BASIC(ctx->directive())
	else
	{
		// Blank line or a line comment
	}

	return nullptr;
}

// line:
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

antlrcpp::Any Assembler::visitLabel
	(GrammarParser::LabelContext *ctx)
{
	ANY_JUST_ACCEPT_BASIC(ctx->identName());

	auto name = pop_str();

	// What's up with "sym->found_as_label()", you may ask?
	// This disallows duplicate labels in the same scope.
	// Note that this check only needs to be performed in the first pass
	// (pass zero).
	{
	auto sym = sym_tbl().find_in_this_blklev(__curr_scope_node, name);
	if ((sym != nullptr) && !__pass && sym->found_as_label())
	{
		err(ctx, sconcat("Error:  Cannot have two identical identifers!  ",
			"The offending identifier is \"", *name, "\"\n"));
	}
	}
	auto sym = sym_tbl().find_or_insert(__curr_scope_node, name);

	sym->set_found_as_label(true);
	sym->set_addr(pc().curr);

	//printout("visitLabel():  ", pc().curr, "\n");

	return nullptr;
}
antlrcpp::Any Assembler::visitInstruction
	(GrammarParser::InstructionContext *ctx)
{
	ANY_ACCEPT_IF_BASIC(ctx->instrOpGrp0ThreeRegs())
	else ANY_ACCEPT_IF_BASIC(ctx->instrOpGrp0TwoRegs())

	else ANY_ACCEPT_IF_BASIC(ctx->instrOpGrp1TwoRegsOneImm())
	else ANY_ACCEPT_IF_BASIC(ctx->instrOpGrp1TwoRegsOneSimm())
	else ANY_ACCEPT_IF_BASIC(ctx->instrOpGrp1OneRegOnePcOneSimm())
	else ANY_ACCEPT_IF_BASIC(ctx->instrOpGrp1OneRegOneImm())
	else ANY_ACCEPT_IF_BASIC(ctx->instrOpGrp1Branch())

	else ANY_ACCEPT_IF_BASIC(ctx->instrOpGrp2())
	else ANY_ACCEPT_IF_BASIC(ctx->instrOpGrp3())

	else
	{
		err(ctx, "visitInstruction();  Eek!");
	}
	return nullptr;
}
antlrcpp::Any Assembler::visitDirective
	(GrammarParser::DirectiveContext *ctx)
{
	ANY_ACCEPT_IF_BASIC(ctx->dotOrgDirective())
	else ANY_ACCEPT_IF_BASIC(ctx->dotSpaceDirective())
	else ANY_ACCEPT_IF_BASIC(ctx->dotDbDirective())
	else ANY_ACCEPT_IF_BASIC(ctx->dotDb16Directive())
	else ANY_ACCEPT_IF_BASIC(ctx->dotDb8Directive())
	else
	{
		err(ctx, "visitDirective():  Eek!");
	}
	return nullptr;
}

// instruction:
antlrcpp::Any Assembler::visitInstrOpGrp0ThreeRegs
	(GrammarParser::InstrOpGrp0ThreeRegsContext *ctx)
{
	ANY_PUSH_TOK_IF(ctx->TokInstrNameAdd())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSub())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSltu())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSlts())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameMul())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameAnd())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameOrr())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameXor())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLsl ())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLsr())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameAsr())
	else
	{
		err(ctx, "visitInstrOpGrp0ThreeRegs():  Eek!");
	}

	const auto opcode = __encoding_stuff.instr_op_grp_0.three_regs_map.at
		(pop_str());

	auto&& reg_encodings = get_reg_encodings(ctx);

	encode_instr_opcode_group_0(reg_encodings.at(0), reg_encodings.at(1),
		reg_encodings.at(2), opcode);


	return nullptr;
}
antlrcpp::Any Assembler::visitInstrOpGrp0TwoRegs
	(GrammarParser::InstrOpGrp0TwoRegsContext *ctx)
{
	ANY_PUSH_TOK_IF(ctx->TokInstrNameInv())
	else
	{
		err(ctx, "visitInstrOpGrp0TwoRegs():  Eek!");
	}

	const auto opcode = __encoding_stuff.instr_op_grp_0.two_regs_map.at
		(pop_str());

	auto&& reg_encodings = get_reg_encodings(ctx);

	encode_instr_opcode_group_0(reg_encodings.at(0), reg_encodings.at(1),
		0x0, opcode);

	return nullptr;
}
antlrcpp::Any Assembler::visitInstrOpGrp1TwoRegsOneImm
	(GrammarParser::InstrOpGrp1TwoRegsOneImmContext *ctx)
{
	ANY_PUSH_TOK_IF(ctx->TokInstrNameAddi())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSubi())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSltui())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameMuli())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameAndi())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameOrri())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameXori())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLsli())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLsri())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameAsri())
	else
	{
		err(ctx, "visitInstrOpGrp1TwoRegsOneImm():  Eek!");
	}

	const auto opcode = __encoding_stuff.instr_op_grp_1
		.two_regs_one_imm_map.at(pop_str());

	auto&& reg_encodings = get_reg_encodings(ctx);

	ANY_JUST_ACCEPT_BASIC(ctx->expr());
	const auto immediate = pop_num();

	encode_instr_opcode_group_1(reg_encodings.at(0), reg_encodings.at(1),
		opcode, immediate);

	return nullptr;
}
antlrcpp::Any Assembler::visitInstrOpGrp1TwoRegsOneSimm
	(GrammarParser::InstrOpGrp1TwoRegsOneSimmContext *ctx)
{
	ANY_PUSH_TOK_IF(ctx->TokInstrNameSltsi())
	else
	{
		err(ctx, "visitInstrOpGrp1TwoRegsOneSimm():  Eek!");
	}

	const auto opcode = __encoding_stuff.instr_op_grp_1
		.two_regs_one_simm_map.at(pop_str());

	auto&& reg_encodings = get_reg_encodings(ctx);

	ANY_JUST_ACCEPT_BASIC(ctx->expr());
	const auto immediate = pop_num();

	encode_instr_opcode_group_1(reg_encodings.at(0), reg_encodings.at(1),
		opcode, immediate);

	return nullptr;
}
antlrcpp::Any Assembler::visitInstrOpGrp1OneRegOnePcOneSimm
	(GrammarParser::InstrOpGrp1OneRegOnePcOneSimmContext *ctx)
{
	ANY_PUSH_TOK_IF(ctx->TokInstrNameAddsi())
	else
	{
		err(ctx, "visitInstrOpGrp1OneRegOnePcOneSimm():  Eek!");
	}

	const auto opcode = __encoding_stuff.instr_op_grp_1
		.one_reg_one_pc_one_simm_map.at(pop_str());

	//auto&& reg_encodings = get_reg_encodings(ctx);

	ANY_JUST_ACCEPT_BASIC(ctx->expr());
	const auto immediate = pop_num();

	//encode_instr_opcode_group_1(reg_encodings.at(0), 0x0, opcode, 
	//	immediate);
	encode_instr_opcode_group_1(get_one_reg_encoding
		(ctx->TokReg()->toString()), 0x0, opcode,
		immediate);

	return nullptr;
}
antlrcpp::Any Assembler::visitInstrOpGrp1OneRegOneImm
	(GrammarParser::InstrOpGrp1OneRegOneImmContext *ctx)
{
	ANY_PUSH_TOK_IF(ctx->TokInstrNameInvi())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameCpyhi())
	else
	{
		err(ctx, "visitInstrOpGrp1OneRegOneImm():  Eek!");
	}

	const auto opcode = __encoding_stuff.instr_op_grp_1
		.one_reg_one_imm_map.at(pop_str());

	//auto&& reg_encodings = get_reg_encodings(ctx);

	ANY_JUST_ACCEPT_BASIC(ctx->expr());
	const auto immediate = pop_num();

	//encode_instr_opcode_group_1(reg_encodings.at(0), 0x0, opcode,
	//	immediate);
	encode_instr_opcode_group_1(get_one_reg_encoding
		(ctx->TokReg()->toString()), 0x0, opcode,
		immediate);

	return nullptr;
}
// Branches must be separate because they're pc-relative
antlrcpp::Any Assembler::visitInstrOpGrp1Branch
	(GrammarParser::InstrOpGrp1BranchContext *ctx)
{
	//gen_64(pop_num() - pc() - sizeof(s64));
	ANY_PUSH_TOK_IF(ctx->TokInstrNameBne())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameBeq())
	else
	{
		err(ctx, "visitInstrOpGrp1Branch():  Eek!");
	}

	const auto opcode = __encoding_stuff.instr_op_grp_1.branch_map
		.at(pop_str());

	//auto&& reg_encodings = get_reg_encodings(ctx);

	ANY_JUST_ACCEPT_BASIC(ctx->expr());

	// This may need to be adjusted
	const auto immediate = pop_num() - __pc.curr - sizeof(s32);

	//encode_instr_opcode_group_1(reg_encodings.at(0), 0x0, opcode,
	//	immediate);
	encode_instr_opcode_group_1(get_one_reg_encoding
		(ctx->TokReg()->toString()), 0x0, opcode,
		immediate);

	return nullptr;
}
antlrcpp::Any Assembler::visitInstrOpGrp2
	(GrammarParser::InstrOpGrp2Context *ctx)
{
	ANY_PUSH_TOK_IF(ctx->TokInstrNameJne())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameJeq())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameCallne())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameCalleq())
	else
	{
		err(ctx, "visitInstrOpGrp2():  Eek!");
	}

	const auto opcode = __encoding_stuff.instr_op_grp_2.all_names_map
		.at(pop_str());

	auto&& reg_encodings = get_reg_encodings(ctx);

	encode_instr_opcode_group_2(reg_encodings.at(0), reg_encodings.at(1),
		0x0, opcode);

	return nullptr;
}
antlrcpp::Any Assembler::visitInstrOpGrp3
	(GrammarParser::InstrOpGrp3Context *ctx)
{
	ANY_PUSH_TOK_IF(ctx->TokInstrNameLdr())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLdh())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLdsh())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLdb())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLdsb())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameStr())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSth())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameStb())
	else
	{
		err(ctx, "visitInstrOpGrp3():  Eek!");
	}

	const auto opcode = __encoding_stuff.instr_op_grp_3.all_names_map
		.at(pop_str());

	auto&& reg_encodings = get_reg_encodings(ctx);

	encode_instr_opcode_group_3(reg_encodings.at(0), reg_encodings.at(1),
		0x0, opcode);

	return nullptr;
}

// directive:
antlrcpp::Any Assembler::visitDotOrgDirective
	(GrammarParser::DotOrgDirectiveContext *ctx)
{
	ANY_JUST_ACCEPT_BASIC(ctx->expr());
	__pc.curr = pop_num();

	return nullptr;
}
antlrcpp::Any Assembler::visitDotSpaceDirective
	(GrammarParser::DotSpaceDirectiveContext *ctx)
{
	ANY_JUST_ACCEPT_BASIC(ctx->expr());
	__pc.curr += pop_num();

	return nullptr;
}
antlrcpp::Any Assembler::visitDotDbDirective
	(GrammarParser::DotDbDirectiveContext *ctx)
{
	auto&& expressions = ctx->expr();

	for (auto expr : expressions)
	{
		expr->accept(this);
		gen_32(pop_num());
	}

	return nullptr;
}
antlrcpp::Any Assembler::visitDotDb16Directive
	(GrammarParser::DotDb16DirectiveContext *ctx)
{
	auto&& expressions = ctx->expr();

	for (auto expr : expressions)
	{
		expr->accept(this);
		gen_16(pop_num());
	}

	return nullptr;
}
antlrcpp::Any Assembler::visitDotDb8Directive
	(GrammarParser::DotDb8DirectiveContext *ctx)
{
	auto&& expressions = ctx->expr();

	for (auto expr : expressions)
	{
		expr->accept(this);
		gen_8(pop_num());
	}

	return nullptr;
}

// Expression parsing
antlrcpp::Any Assembler::visitExpr
	(GrammarParser::ExprContext *ctx)
{
	if (ctx->expr())
	{
		//ctx->expr()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->expr());
		const auto left = pop_num();

		//ctx->exprLogical()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->exprLogical());
		const auto right = pop_num();

		auto&& op = ctx->TokOpLogical()->toString();

		if (op == "&&")
		{
			push_num(left && right);
		}
		else if (op == "||")
		{
			push_num(left || right);
		}
		else
		{
			//printerr("visitExpr():  Eek!\n");
			//exit(1);
			err(ctx, "visitExpr():  Eek!");
		}
	}
	else
	{
		//ctx->exprLogical()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->exprLogical());
	}
	return nullptr;
}
antlrcpp::Any Assembler::visitExprLogical
	(GrammarParser::ExprLogicalContext *ctx)
{
	if (ctx->exprLogical())
	{
		//ctx->exprLogical()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->exprLogical());
		const auto left = pop_num();

		//ctx->exprCompare()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->exprCompare());
		const auto right = pop_num();

		auto&& op = ctx->TokOpCompare()->toString();

		if (op == "==")
		{
			push_num(left == right);
		}
		else if (op == "!=")
		{
			push_num(left != right);
		}
		else if (op == "<")
		{
			push_num(left < right);
		}
		else if (op == ">")
		{
			push_num(left > right);
		}
		else if (op == "<=")
		{
			push_num(left <= right);
		}
		else if (op == ">=")
		{
			push_num(left >= right);
		}
		else
		{
			//printerr("visitExprLogical():  Eek!\n");
			//exit(1);
			err(ctx, "visitExprLogical():  Eek!");
		}
	}
	else
	{
		//ctx->exprCompare()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->exprCompare());
	}
	return nullptr;
}
antlrcpp::Any Assembler::visitExprCompare
	(GrammarParser::ExprCompareContext *ctx)
{
	ANY_ACCEPT_IF_BASIC(ctx->exprAddSub())
	else ANY_ACCEPT_IF_BASIC(ctx->exprJustAdd())
	else ANY_ACCEPT_IF_BASIC(ctx->exprJustSub())
	else
	{
		//printerr("visitExprCompare():  Eek!\n");
		//exit(1);
		err(ctx, "visitExprCompare():  Eek!");
	}
	return nullptr;
}
antlrcpp::Any Assembler::visitExprJustAdd
	(GrammarParser::ExprJustAddContext *ctx)
{
	//ctx->exprAddSub()->accept(this);
	ANY_JUST_ACCEPT_BASIC(ctx->exprAddSub());
	const auto left = pop_num();

	//ctx->exprCompare()->accept(this);
	ANY_JUST_ACCEPT_BASIC(ctx->exprCompare());
	const auto right = pop_num();

	push_num(left + right);

	return nullptr;
}
antlrcpp::Any Assembler::visitExprJustSub
	(GrammarParser::ExprJustSubContext *ctx)
{
	//ctx->exprAddSub()->accept(this);
	ANY_JUST_ACCEPT_BASIC(ctx->exprAddSub());
	const auto left = pop_num();

	//ctx->exprCompare()->accept(this);
	ANY_JUST_ACCEPT_BASIC(ctx->exprCompare());
	const auto right = pop_num();

	push_num(left - right);

	return nullptr;
}
antlrcpp::Any Assembler::visitExprAddSub
	(GrammarParser::ExprAddSubContext *ctx)
{
	if (ctx->exprAddSub())
	{
		//ctx->exprAddSub()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->exprAddSub());
		const auto left = pop_num();

		//ctx->exprMulDivModEtc()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->exprMulDivModEtc());
		const auto right = pop_num();

		//auto&& op = ctx->TokOpAddSub()->toString();
		std::string op;

		if (ctx->TokOpMulDivMod())
		{
			op = ctx->TokOpMulDivMod()->toString();
		}
		else if (ctx->TokOpBitwise())
		{
			op = ctx->TokOpBitwise()->toString();
		}
		else
		{
			//printerr("visitExprAddSub():  no op thing eek!\n");
			//exit(1);
			err(ctx, "visitExprAddSub():  no op thing eek!");
		}

		if (op == "*")
		{
			push_num(left * right);
		}
		else if (op == "/")
		{
			if (right != 0)
			{
				push_num(left / right);
			}
			else
			{
				if (__pass)
				{
					//printerr("Error:  Cannot divide by zero!\n");
					//exit(1);
					err(ctx, "Error:  Cannot divide by zero!");
				}
				else
				{
					push_num(0);
				}
			}
		}
		else if (op == "%")
		{
			push_num(left % right);
		}
		else if (op == "&")
		{
			push_num(left & right);
		}
		else if (op == "|")
		{
			push_num(left | right);
		}
		else if (op == "^")
		{
			push_num(left ^ right);
		}
		else if (op == "<<")
		{
			push_num(left << right);
		}
		else if (op == ">>")
		{
			// Logical shift right is special
			const u64 left_u = left;
			const u64 right_u = right;
			const u64 to_push = left_u >> right_u;
			push_num(to_push);
		}
		else if (op == ">>>")
		{
			// This relies upon C++ compilers **usually** performing
			// arithmetic right shifting one signed integer by another
			// 
			// Those C++ compilers that don't support this are not
			// supported for building this assembler!
			push_num(left >> right);
		}
		else
		{
			//printerr("visitExprAddSub():  Eek!\n");
			//exit(1);
			err(ctx, "visitExprAddSub():  Eek!");
		}
	}
	else
	{
		//ctx->exprMulDivModEtc()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->exprMulDivModEtc());
	}
	return nullptr;
}
antlrcpp::Any Assembler::visitExprMulDivModEtc
	(GrammarParser::ExprMulDivModEtcContext *ctx)
{
	ANY_ACCEPT_IF_BASIC(ctx->exprUnary())
	else ANY_ACCEPT_IF_BASIC(ctx->numExpr())
	else if (ctx->identName())
	{
		//ctx->identName()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->identName());

		if (!__pass)
		{
			pop_str();
			push_num(0);
		}
		else
		{
			auto sym = sym_tbl().find_or_insert(__curr_scope_node, 
				pop_str());
			push_num(sym->addr());
		}
	}
	else ANY_ACCEPT_IF_BASIC(ctx->currPc())
	else
	{
		//ctx->expr()->accept(this);
		ANY_JUST_ACCEPT_BASIC(ctx->expr());
	}

	return nullptr;
}
antlrcpp::Any Assembler::visitExprUnary
	(GrammarParser::ExprUnaryContext *ctx)
{
	ANY_ACCEPT_IF_BASIC(ctx->exprBitInvert())
	else ANY_ACCEPT_IF_BASIC(ctx->exprNegate())
	else ANY_ACCEPT_IF_BASIC(ctx->exprLogNot())
	else
	{
		printerr("visitExprUnary():  Eek!\n");
		exit(1);
	}
	return nullptr;
}

antlrcpp::Any Assembler::visitExprBitInvert
	(GrammarParser::ExprBitInvertContext *ctx)
{
	//ctx->expr()->accept(this);
	ANY_JUST_ACCEPT_BASIC(ctx->expr());
	push_num(~pop_num());
	return nullptr;
}
antlrcpp::Any Assembler::visitExprNegate
	(GrammarParser::ExprNegateContext *ctx)
{
	//ctx->expr()->accept(this);
	ANY_JUST_ACCEPT_BASIC(ctx->expr());
	push_num(-pop_num());
	return nullptr;
}
antlrcpp::Any Assembler::visitExprLogNot
	(GrammarParser::ExprLogNotContext *ctx)
{
	//ctx->expr()->accept(this);
	ANY_JUST_ACCEPT_BASIC(ctx->expr());
	push_num(!pop_num());
	return nullptr;
}


// Last set of token stuff
antlrcpp::Any Assembler::visitIdentName
	(GrammarParser::IdentNameContext *ctx)
{
	ANY_PUSH_TOK_IF(ctx->TokIdent())
	else ANY_ACCEPT_IF_BASIC(ctx->instrName())
	else ANY_PUSH_TOK_IF(ctx->TokReg())
	else ANY_PUSH_TOK_IF(ctx->TokPcReg())
	else
	{
		err(ctx, "visitIdentName():  Eek!");
	}

	return nullptr;
}
antlrcpp::Any Assembler::visitInstrName
	(GrammarParser::InstrNameContext *ctx)
{
	ANY_PUSH_TOK_IF(ctx->TokInstrNameAdd())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSub())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSltu())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSlts())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameMul())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameAnd())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameOrr())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameXor())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameInv())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLsl())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLsr())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameAsr())

	else ANY_PUSH_TOK_IF(ctx->TokInstrNameAddi())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSubi())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSltui())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSltsi())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameMuli())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameAndi())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameOrri())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameXori())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameInvi())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLsli())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLsri())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameAsri())

	else ANY_PUSH_TOK_IF(ctx->TokInstrNameAddsi())

	else ANY_PUSH_TOK_IF(ctx->TokInstrNameCpyhi())

	else ANY_PUSH_TOK_IF(ctx->TokInstrNameBne())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameBeq())

	else ANY_PUSH_TOK_IF(ctx->TokInstrNameJne())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameJeq())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameCallne())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameCalleq())

	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLdr())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLdh())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLdsh())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLdb())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameLdsb())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameStr())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameSth())
	else ANY_PUSH_TOK_IF(ctx->TokInstrNameStb())

	else
	{
		err(ctx, "visitInstrName():  Eek!");
	}

	return nullptr;
}
antlrcpp::Any Assembler::visitNumExpr
	(GrammarParser::NumExprContext *ctx)
{
	s64 to_push;

	std::stringstream sstm;
	if (ctx->TokDecNum())
	{
		sstm << ctx->TokDecNum()->toString();
		sstm >> to_push;
	}
	else if (ctx->TokHexNum())
	{
		u64 temp = 0;
		auto&& str = ctx->TokHexNum()->toString();

		for (size_t i=2; i<str.size(); ++i)
		{
			if ((str.at(i) >= '0') && (str.at(i) <= '9'))
			{
				temp |= (str.at(i) - '0');
			}
			else if ((str.at(i) >= 'a') && (str.at(i) <= 'f'))
			{
				temp |= (str.at(i) - 'a' + 0xa);
			}
			else if ((str.at(i) >= 'A') && (str.at(i) <= 'F'))
			{
				temp |= (str.at(i) - 'A' + 0xa);
			}
			else
			{
				err(ctx, "visitNumExpr():  Eek!");
			}

			if ((i + 1) < str.size())
			{
				temp <<= 4;
			}
		}

		to_push = temp;
		//sstm << ctx->TokHexNum()->toString();
		//sstm >> to_push;
	}
	//else if (ctx->TokChar())
	//{
	//	std::string temp;
	//	sstm << ctx->TokChar()->toString();
	//	sstm >> temp;

	//	to_push = temp.at(1);
	//}
	else if (ctx->TokBinNum())
	{
		err(ctx, "Sorry, binary literal numbers are not supported yet.");
	}
	else
	{
		err(ctx, "visitNumExpr():  Eek!");
	}

	push_num(to_push);
	return nullptr;
}
antlrcpp::Any Assembler::visitCurrPc
	(GrammarParser::CurrPcContext *ctx)
{
	push_num(__pc.curr);
	return nullptr;
}
