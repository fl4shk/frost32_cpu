#include "disassembler_class.hpp"

Disassembler::Disassembler(DisassemblerGrammarParser& parser)
{
	__program_ctx = parser.program();
}

int Disassembler::run()
{
	visitProgram(__program_ctx);
	return 0;
}

antlrcpp::Any Disassembler::visitProgram
	(DisassemblerGrammarParser::ProgramContext *ctx)
{
	auto&& lines = ctx->line();

	for (auto line : lines)
	{
		line->accept(this);
	}

	return nullptr;
}
antlrcpp::Any Disassembler::visitLine
	(DisassemblerGrammarParser::LineContext *ctx)
{
	u32 num_good_chars;
	if (ctx->TokOrg())
	{
		const u32 addr = convert_hex_string(ctx, ctx->TokOrg()->toString(),
			num_good_chars);

		// This isn't perfect, as it does plain ".org" instead of ".space"
		// when it can.
		// 
		// It should still work, though
		printout(".org ", std::hex, addr, std::dec, "\n");
	}
	else if (ctx->TokHexNum())
	{
		const u32 instruction = convert_hex_string(ctx, 
			ctx->TokHexNum()->toString(), num_good_chars);

		if (num_good_chars == 2)
		{
			display_dot_db8(instruction);
		}
		else if (num_good_chars == 4)
		{
			display_dot_db16(instruction);
		}
		else if (num_good_chars == 8)
		{
			display_dot_db(instruction);
		}
		else
		{
			err(ctx, "Allowed data sizes:   8-bit, 16-bit, 32-bit");
		}

		printout("\n");
	}
	else if (ctx->TokNewline())
	{
		// Just a blank line (or one with only a comment), so do nothing.
	}
	else
	{
		err(ctx, "visitLine():  Eek!");
	}

	return nullptr;
}
u32 Disassembler::convert_hex_string(antlr4::ParserRuleContext* ctx,
	const std::string& str, u32& num_good_chars) const
{
	std::string temp_str;

	for (size_t i=0; i<str.size(); ++i)
	{
		if ((str.at(i) != '@') && (str.at(i) != ' '))
		{
			temp_str += str.at(i);
		}
	}
	//printout("str, temp_str:  ", strappcom2(str, temp_str), "\n");
	num_good_chars = temp_str.size();

	u32 temp = 0;
	for (size_t i=0; i<temp_str.size(); ++i)
	{
		if ((temp_str.at(i) >= '0') && (temp_str.at(i) <= '9'))
		{
			temp |= (temp_str.at(i) - '0');
		}
		else if ((temp_str.at(i) >= 'a') && (temp_str.at(i) <= 'f'))
		{
			temp |= (temp_str.at(i) - 'a' + 0xa);
		}
		else if ((temp_str.at(i) >= 'A') && (temp_str.at(i) <= 'F'))
		{
			temp |= (temp_str.at(i) - 'A' + 0xa);
		}
		else
		{
			const std::string msg("convert_hex_string():  Eek!");

			auto tok = ctx->getStart();
			const size_t line = tok->getLine();
			const size_t pos_in_line = tok->getCharPositionInLine();
			//printerr("Error in file \"", *__file_name, "\", on line ",
			//	line, ", position ", pos_in_line, ":  ", msg, "\n");
			printerr("Error on line ", line, ", position ", pos_in_line, 
				":  ", msg, "\n");
			exit(1);
		}

		if ((i + 1) < temp_str.size())
		{
			temp <<= 4;
		}
	}
	//printout(std::hex, "0x", temp, std::dec);

	return temp;
}
