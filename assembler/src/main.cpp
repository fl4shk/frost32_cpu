#include "assembler_class.hpp"

int main(int argc, char** argv)
{
	std::string from_stdin(get_stdin_as_str());

	antlr4::ANTLRInputStream input(from_stdin);
	GrammarLexer lexer(&input);
	antlr4::CommonTokenStream tokens(&lexer);
	tokens.fill();

	GrammarParser parser(&tokens);
	parser.removeErrorListeners();
	std::unique_ptr<AsmErrorListener> asm_error_listener
		(new AsmErrorListener());
	parser.addErrorListener(asm_error_listener.get());

	Assembler visitor(parser, true);
	//Assembler visitor(parser);
	return visitor.run();
}
