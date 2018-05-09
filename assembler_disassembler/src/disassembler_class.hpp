#ifndef src__slash__disassembler_class_hpp
#define src__slash__disassembler_class_hpp

// src/disassembler_class.hpp

#include "misc_includes.hpp"
#include "ANTLRErrorListener.h"
#include "gen_src/DisassemblerGrammarLexer.h"
#include "gen_src/DisassemblerGrammarParser.h"
#include "gen_src/DisassemblerGrammarVisitor.h"

#include "symbol_table_classes.hpp"

#include "encoding_stuff_class.hpp"

class Disassembler : public DisassemblerGrammarVisitor
{
private:		// variables
	EncodingStuff __encoding_stuff;
	DisassemblerGrammarParser::ProgramContext* __program_ctx;

public:		// functions
	Disassembler(DisassemblerGrammarParser& parser);

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

private:		// visitor functions
	antlrcpp::Any visitProgram
		(DisassemblerGrammarParser::ProgramContext *ctx);
	antlrcpp::Any visitLine
		(DisassemblerGrammarParser::LineContext *ctx);


private:		// functions
	u32 convert_hex_string(antlr4::ParserRuleContext* ctx, 
		const std::string& str, u32& num_good_chars) const;

	inline void display_dot_db(u32 data) const
	{
		printout(".db ", std::hex, "0x", data, std::dec);
	}
	inline void display_dot_db16(u32 data) const
	{
		printout(".db16 ", std::hex, "0x", (u16)data, std::dec);
	}
	inline void display_dot_db8(u32 data) const
	{
		printout(".db8 ", std::hex, "0x", (u32)((u8)data), std::dec);
	}

	inline u32 decode_iog(u32 instruction) const
	{
		return get_bits_with_range(instruction, 31, 28);
	}
	inline void decode_instr_opcode_group_0(u32 instruction, 
		u32& reg_a_index, u32& reg_b_index, u32& reg_c_index, u32& opcode)
		const
	{
		reg_a_index = get_bits_with_range(instruction, 27, 24);
		reg_b_index = get_bits_with_range(instruction, 23, 20);
		reg_c_index = get_bits_with_range(instruction, 19, 16);
		opcode = get_bits_with_range(instruction, 3, 0);
	}

	inline void decode_instr_opcode_group_1(u32 instruction, 
		u32& reg_a_index, u32& reg_b_index, u32& opcode, u32& immediate)
		const
	{
		reg_a_index = get_bits_with_range(instruction, 27, 24);
		reg_b_index = get_bits_with_range(instruction, 23, 20);
		opcode = get_bits_with_range(instruction, 19, 16);
		immediate = get_bits_with_range(instruction, 15, 0);
	}

	inline void decode_instr_opcode_group_2(u32 instruction, 
		u32& reg_a_index, u32& reg_b_index, u32& reg_c_index, u32& opcode)
		const
	{
		reg_a_index = get_bits_with_range(instruction, 27, 24);
		reg_b_index = get_bits_with_range(instruction, 23, 20);
		reg_c_index = get_bits_with_range(instruction, 19, 16);
		opcode = get_bits_with_range(instruction, 3, 0);
	}

	inline void decode_instr_opcode_group_3(u32 instruction, 
		u32& reg_a_index, u32& reg_b_index, u32& reg_c_index, u32& opcode)
		const
	{
		reg_a_index = get_bits_with_range(instruction, 27, 24);
		reg_b_index = get_bits_with_range(instruction, 23, 20);
		reg_c_index = get_bits_with_range(instruction, 19, 16);
		opcode = get_bits_with_range(instruction, 3, 0);
	}
};



#endif		// src__slash__disassembler_class_hpp
