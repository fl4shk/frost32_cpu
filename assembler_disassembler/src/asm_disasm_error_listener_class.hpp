#ifndef src__slash__asm_disasm_error_listener_class_hpp
#define src__slash__asm_disasm_error_listener_class_hpp

// src/asm_disasm_error_listener_class_hpp

#include "misc_includes.hpp"
#include "ANTLRErrorListener.h"


class AsmDisasmErrorListener : public antlr4::ANTLRErrorListener
{
public:		// functions
	virtual ~AsmDisasmErrorListener();

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

#endif		// src__slash__asm_disasm_error_listener_class_hpp
