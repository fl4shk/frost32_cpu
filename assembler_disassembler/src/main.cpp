#include "assembler_class.hpp"
#include "disassembler_class.hpp"
#include "asm_disasm_error_listener_class.hpp"

int main(int argc, char** argv)
{
	auto usage = [&argv]() -> void
	{
		printerr("Usage:  ", argv[0], "{-a,-b,-d}\n");
		exit(1);
	};

	if (argc != 2)
	{
		usage();
	}

	if (std::string(argv[1]) == "-a")
	{
		std::string from_stdin(get_stdin_as_str());

		antlr4::ANTLRInputStream input(from_stdin);
		AssemblerGrammarLexer lexer(&input);
		antlr4::CommonTokenStream tokens(&lexer);
		tokens.fill();

		AssemblerGrammarParser parser(&tokens);
		parser.removeErrorListeners();
		std::unique_ptr<AsmDisasmErrorListener> asm_disasm_error_listener
			(new AsmDisasmErrorListener());
		parser.addErrorListener(asm_disasm_error_listener.get());

		Assembler visitor(parser, false);
		return visitor.run();
	}
	if (std::string(argv[1]) == "-b")
	{
		std::string from_stdin(get_stdin_as_str());

		antlr4::ANTLRInputStream input(from_stdin);
		AssemblerGrammarLexer lexer(&input);
		antlr4::CommonTokenStream tokens(&lexer);
		tokens.fill();

		AssemblerGrammarParser parser(&tokens);
		parser.removeErrorListeners();
		std::unique_ptr<AsmDisasmErrorListener> asm_disasm_error_listener
			(new AsmDisasmErrorListener());
		parser.addErrorListener(asm_disasm_error_listener.get());

		Assembler visitor(parser, true);
		return visitor.run();
	}
	else if (std::string(argv[1]) == "-d")
	{
		std::string from_stdin(get_stdin_as_str());
		antlr4::ANTLRInputStream input(from_stdin);
		DisassemblerGrammarLexer lexer(&input);
		antlr4::CommonTokenStream tokens(&lexer);
		tokens.fill();

		DisassemblerGrammarParser parser(&tokens);
		parser.removeErrorListeners();
		std::unique_ptr<AsmDisasmErrorListener> asm_disasm_error_listener
			(new AsmDisasmErrorListener());
		parser.addErrorListener(asm_disasm_error_listener.get());

		Disassembler visitor(parser);
		//Disassembler visitor(parser);
		return visitor.run();
	}
	else
	{
		usage();
	}
}
