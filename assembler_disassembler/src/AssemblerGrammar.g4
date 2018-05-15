grammar AssemblerGrammar;

// Parser rules
program:
	line*
	;

line:
	scopedLines
	| label TokNewline
	| instruction TokNewline
	| pseudoInstruction TokNewline
	| directive TokNewline
	| TokNewline // Allow blank lines and lines with only a comment
	;

scopedLines:
	TokLBrace TokNewline
	line*
	TokRBrace TokNewline
	;

label: 
	identName TokColon
	;

instruction:
	instrOpGrp0ThreeRegs
	//| instrOpGrp0TwoRegs

	| instrOpGrp1TwoRegsOneImm
	| instrOpGrp1TwoRegsOneSimm
	| instrOpGrp1OneRegOnePcOneSimm
	| instrOpGrp1OneRegOneImm
	| instrOpGrp1Branch

	| instrOpGrp2ThreeRegs
	| instrOpGrp3ThreeRegsLdst
	| instrOpGrp3TwoRegsOneSimmLdst
	;

instrOpGrp0ThreeRegs:
	(TokInstrNameAdd | TokInstrNameSub 
	| TokInstrNameSltu | TokInstrNameSlts
	| TokInstrNameMul | TokInstrNameAnd 
	| TokInstrNameOrr | TokInstrNameXor
	| TokInstrNameNor | TokInstrNameLsl 
	| TokInstrNameLsr | TokInstrNameAsr)
	TokReg TokComma TokReg TokComma TokReg
	;
//instrOpGrp0TwoRegs:
//	TokInstrNameInv
//	TokReg TokComma TokReg
//	;

instrOpGrp1TwoRegsOneImm:
	(TokInstrNameAddi | TokInstrNameSubi
	| TokInstrNameSltui 
	| TokInstrNameMuli | TokInstrNameAndi
	| TokInstrNameOrri | TokInstrNameXori
	| TokInstrNameLsli 
	| TokInstrNameLsri | TokInstrNameAsri)
	TokReg TokComma TokReg TokComma expr
	;

instrOpGrp1TwoRegsOneSimm:
	TokInstrNameSltsi
	TokReg TokComma TokReg TokComma expr
	;

instrOpGrp1OneRegOnePcOneSimm:
	TokInstrNameAddsi
	TokReg TokComma TokPcReg TokComma expr
	;
instrOpGrp1OneRegOneImm:
	//(TokInstrNameInvi | TokInstrNameCpyhi)
	TokInstrNameCpyhi
	TokReg TokComma expr
	;

// Branches must be separate because they're pc-relative
instrOpGrp1Branch:
	(TokInstrNameBne | TokInstrNameBeq)
	TokReg TokComma TokReg TokComma expr
	;

instrOpGrp2ThreeRegs:
	(TokInstrNameJne | TokInstrNameJeq 
	| TokInstrNameCallne | TokInstrNameCalleq)
	TokReg TokComma TokReg TokComma TokReg
	;

instrOpGrp3ThreeRegsLdst:
	(TokInstrNameLdr
	| TokInstrNameLdh | TokInstrNameLdsh
	| TokInstrNameLdb | TokInstrNameLdsb
	| TokInstrNameStr | TokInstrNameSth | TokInstrNameStb)
	TokReg TokComma TokLBracket TokReg TokComma TokReg TokRBracket
	;
instrOpGrp3TwoRegsOneSimmLdst:
	(TokInstrNameLdri
	| TokInstrNameLdhi | TokInstrNameLdshi
	| TokInstrNameLdbi | TokInstrNameLdsbi
	| TokInstrNameStri | TokInstrNameSthi | TokInstrNameStbi)
	TokReg TokComma TokLBracket TokReg TokComma expr TokRBracket
	;

pseudoInstruction:
	pseudoInstrOpInv
	| pseudoInstrOpInvi
	| pseudoInstrOpGrpCpy
	| pseudoInstrOpCpyi
	| pseudoInstrOpCpya
	| pseudoInstrOpBra
	| pseudoInstrOpJmp
	| pseudoInstrOpCall
	| pseudoInstrOpJmpa
	| pseudoInstrOpCalla
	| pseudoInstrOpJmpaCallaConditional
	| pseudoInstrOpIncDec
	| pseudoInstrOpAluOpTwoReg
	| pseudoInstrOpAluOpOneRegOneImm
	| pseudoInstrOpAluOpOneRegOneSimm
	;

pseudoInstrOpInv:
	TokPseudoInstrNameInv
	TokReg TokComma TokReg
	;
pseudoInstrOpInvi:
	TokPseudoInstrNameInvi
	TokReg TokComma expr
	;

pseudoInstrOpGrpCpy:
	TokPseudoInstrNameCpy
	TokReg TokComma (TokReg | TokPcReg)
	;
pseudoInstrOpCpyi:
	TokPseudoInstrNameCpyi
	TokReg TokComma expr
	;

// Copy absolute (32-bit immediate)
// Allows you to copy a 32-bit immediate into a register.
// This is honestly just a convenience thing, but hey, it was easy to
// implement.
pseudoInstrOpCpya:
	TokPseudoInstrNameCpya
	TokReg TokComma expr
	;
pseudoInstrOpBra:
	TokPseudoInstrNameBra
	expr
	;
pseudoInstrOpJmp:
	TokPseudoInstrNameJmp
	TokReg
	;
pseudoInstrOpCall:
	TokPseudoInstrNameCall
	TokReg
	;
pseudoInstrOpJmpa:
	TokPseudoInstrNameJmpa
	expr
	;
pseudoInstrOpCalla:
	TokPseudoInstrNameCalla
	expr
	;

pseudoInstrOpJmpaCallaConditional:
	(TokPseudoInstrNameJmpane | TokPseudoInstrNameJmpaeq
	| TokPseudoInstrNameCallane | TokPseudoInstrNameCallaeq)
	TokReg TokComma TokReg TokComma expr
	;

pseudoInstrOpIncDec:
	(TokPseudoInstrNameInc | TokPseudoInstrNameDec)
	TokReg
	;
pseudoInstrOpAluOpTwoReg:
	(TokInstrNameAdd | TokInstrNameSub 
	| TokInstrNameSltu | TokInstrNameSlts
	| TokInstrNameMul | TokInstrNameAnd 
	| TokInstrNameOrr | TokInstrNameXor
	| TokInstrNameNor | TokInstrNameLsl 
	| TokInstrNameLsr | TokInstrNameAsr)
	TokReg TokComma TokReg
	;
pseudoInstrOpAluOpOneRegOneImm:
	(TokInstrNameAddi | TokInstrNameSubi
	| TokInstrNameSltui | 
	| TokInstrNameMuli | TokInstrNameAndi
	| TokInstrNameOrri | TokInstrNameXori
	| TokInstrNameNori | TokInstrNameLsli 
	| TokInstrNameLsri | TokInstrNameAsri)
	TokReg TokComma expr
	;
pseudoInstrOpAluOpOneRegOneSimm:
	TokInstrNameSltsi
	TokReg TokComma expr
	;

// Assembler directives 
directive:
	dotOrgDirective
	| dotSpaceDirective
	| dotDbDirective
	| dotDb16Directive
	| dotDb8Directive
	;


// Change the program counter to the value of an expression
dotOrgDirective:
	TokDotOrg expr
	;

// Add the value of an expression to the program counter (allows allocating
// global variables)
dotSpaceDirective:
	TokDotSpace expr
	;

// Raw 32-bit constants
dotDbDirective:
	TokDotDb expr ((TokComma expr)*)
	;

// Raw 16-bit constants
dotDb16Directive:
	TokDotDb16 expr ((TokComma expr)*)
	;

// Raw 8-bit constants
dotDb8Directive:
	TokDotDb8 expr ((TokComma expr)*)
	;

// Expression parsing.  This part of the grammar is borrowed from a
// previous assembler I wrote.
expr:
	exprLogical
	| expr TokOpLogical exprLogical
	;

exprLogical:
	exprCompare
	| exprLogical TokOpCompare exprCompare
	;

exprCompare:
	exprAddSub
	//| exprCompare TokOpAddSub exprAddSub
	| exprJustAdd
	| exprJustSub
	;

exprJustAdd: exprAddSub TokPlus exprCompare ;
exprJustSub: exprAddSub TokMinus exprCompare ;

exprAddSub:
	exprMulDivModEtc
	| exprAddSub TokOpMulDivMod exprMulDivModEtc
	| exprAddSub TokOpBitwise exprMulDivModEtc
	;

exprMulDivModEtc:
	exprUnary
	| numExpr
	| identName
	| currPc
	| TokLParen expr TokRParen
	;

exprUnary:
	exprBitInvert
	| exprNegate
	| exprLogNot
	;

exprBitInvert: TokBitInvert expr ;
exprNegate: TokMinus expr ;
exprLogNot: TokExclamPoint expr ;

// Instruction names, pseudo instruction names, register names, and
// TokRegPc are all valid identifiers, but they will **NOT** be caught by
// the TokIdent token in the lexer.  Thus, these things must be special
// cased to allow them to be used as identifiers.
identName: TokIdent | instrName | pseudoInstrName | TokReg | TokPcReg ;

instrName:
	(TokInstrNameAdd | TokInstrNameSub
	| TokInstrNameSltu | TokInstrNameSlts
	| TokInstrNameMul | TokInstrNameAnd
	| TokInstrNameOrr | TokInstrNameXor
	| TokInstrNameNor | TokInstrNameLsl
	| TokInstrNameLsr | TokInstrNameAsr

	| TokInstrNameAddi | TokInstrNameSubi
	| TokInstrNameSltui | TokInstrNameSltsi
	| TokInstrNameMuli | TokInstrNameAndi
	| TokInstrNameOrri | TokInstrNameXori
	| TokInstrNameNori | TokInstrNameLsli
	| TokInstrNameLsri | TokInstrNameAsri

	| TokInstrNameAddsi

	| TokInstrNameCpyhi

	| TokInstrNameBne | TokInstrNameBeq

	| TokInstrNameJne | TokInstrNameJeq
	| TokInstrNameCallne | TokInstrNameCalleq

	| TokInstrNameLdr
	| TokInstrNameLdh | TokInstrNameLdsh
	| TokInstrNameLdb | TokInstrNameLdsb
	| TokInstrNameStr | TokInstrNameSth | TokInstrNameStb

	| TokInstrNameLdri
	| TokInstrNameLdhi | TokInstrNameLdshi
	| TokInstrNameLdbi | TokInstrNameLdsbi
	| TokInstrNameStri | TokInstrNameSthi | TokInstrNameStbi)
	;

pseudoInstrName:
	(TokPseudoInstrNameInv | TokPseudoInstrNameInvi
	| TokPseudoInstrNameCpy 
	| TokPseudoInstrNameCpyi | TokPseudoInstrNameCpya
	| TokPseudoInstrNameBra 
	| TokPseudoInstrNameJmp | TokPseudoInstrNameCall
	| TokPseudoInstrNameJmpa | TokPseudoInstrNameCalla
	| TokPseudoInstrNameJmpane | TokPseudoInstrNameJmpaeq
	| TokPseudoInstrNameCallane | TokPseudoInstrNameCallaeq
	| TokPseudoInstrNameInc | TokPseudoInstrNameDec)
	;

numExpr: TokDecNum | TokHexNum | TokBinNum;

currPc: TokPeriod ;

// Lexer rules
// ALL tokens get a lexer rule of some sort because it forces ANTLR to
// catch more (all?) syntax errors.
// So that means no raw '...' stuff in the parser rules.

LexWhitespace: (' ' | '\t') -> skip ;
LexLineComment: ('//' | ';') (~ '\n')* -> skip ;

TokOpLogical: ('&&' | '||') ;
TokOpCompare: ('==' | '!=' | '<' | '>' | '<=' | '>=') ;
//TokOpAddSub: ('+' | '-') ;
TokPlus: '+' ;
TokMinus: '-' ;
TokOpMulDivMod: ('*' | '/' | '%') ;
TokOpBitwise: ('&' | '|' | '^' | '<<' | '>>' | '>>>') ;
TokBitInvert: '~' ;

TokDecNum: [0-9] ([0-9]*) ;
TokHexNum: '0x' ([0-9A-Fa-f]+) ;
TokBinNum: '0b' ([0-1]+) ;

TokInstrNameAdd: 'add' ;
TokInstrNameSub: 'sub' ;
TokInstrNameSltu: 'sltu' ;
TokInstrNameSlts: 'slts' ;
TokInstrNameMul: 'mul' ;
TokInstrNameAnd: 'and' ;
TokInstrNameOrr: 'orr' ;
TokInstrNameXor: 'xor' ;
TokInstrNameNor: 'nor' ;
TokInstrNameLsl: 'lsl' ;
TokInstrNameLsr: 'lsr' ;
TokInstrNameAsr: 'asr' ;

TokInstrNameAddi: 'addi' ;
TokInstrNameSubi: 'subi' ;
TokInstrNameSltui: 'sltui' ;
TokInstrNameSltsi: 'sltsi' ;
TokInstrNameMuli: 'muli' ;
TokInstrNameAndi: 'andi' ;
TokInstrNameOrri: 'orri' ;
TokInstrNameXori: 'xori' ;
TokInstrNameNori: 'nori' ;
TokInstrNameLsli: 'lsli' ;
TokInstrNameLsri: 'lsri' ;
TokInstrNameAsri: 'asri' ;

TokInstrNameAddsi: 'addsi' ;

TokInstrNameCpyhi: 'cpyhi' ;

TokInstrNameBne: 'bne' ;
TokInstrNameBeq: 'beq' ;

TokInstrNameJne: 'jne' ;
TokInstrNameJeq: 'jeq' ;
TokInstrNameCallne: 'callne' ;
TokInstrNameCalleq: 'calleq' ;

TokInstrNameLdr: 'ldr' ;
TokInstrNameLdh: 'ldh' ;
TokInstrNameLdsh: 'ldsh' ;
TokInstrNameLdb: 'ldb' ;
TokInstrNameLdsb: 'ldsb' ;
TokInstrNameStr: 'str' ;
TokInstrNameSth: 'sth' ;
TokInstrNameStb: 'stb' ;
TokInstrNameLdri: 'ldri' ;
TokInstrNameLdhi: 'ldhi' ;
TokInstrNameLdshi: 'ldshi' ;
TokInstrNameLdbi: 'ldbi' ;
TokInstrNameLdsbi: 'ldsbi' ;
TokInstrNameStri: 'stri' ;
TokInstrNameSthi: 'sthi' ;
TokInstrNameStbi: 'stbi' ;

TokPseudoInstrNameInv: 'inv' ;
TokPseudoInstrNameInvi: 'invi' ;
TokPseudoInstrNameCpy: 'cpy' ;
TokPseudoInstrNameCpyi: 'cpyi' ;
TokPseudoInstrNameCpya: 'cpya' ;
TokPseudoInstrNameBra: 'bra' ;
TokPseudoInstrNameJmp: 'jmp' ;
TokPseudoInstrNameCall: 'call' ;
TokPseudoInstrNameJmpa: 'jmpa' ;
TokPseudoInstrNameCalla: 'calla' ;
TokPseudoInstrNameJmpane: 'jmpane' ;
TokPseudoInstrNameJmpaeq: 'jmpaeq' ;
TokPseudoInstrNameCallane: 'callane' ;
TokPseudoInstrNameCallaeq: 'callaeq' ;
TokPseudoInstrNameInc: 'inc' ;
TokPseudoInstrNameDec: 'dec' ;

// Directives
TokDotOrg: '.org' ;
TokDotSpace: '.space' ;
TokDotDb: '.db' ;
TokDotDb16: '.db16' ;
TokDotDb8: '.db8' ;

// Punctuation, etc.
TokPeriod: '.' ;
TokComma: ',' ;
TokColon: ':' ;
TokExclamPoint: '!' ;
TokLParen: '(' ;
TokRParen: ')' ;
TokLBracket: '[' ;
TokRBracket: ']' ;
TokLBrace: '{' ;
TokRBrace: '}' ;
TokNewline: '\n' ;


TokReg:
	('zero' | 'u0' | 'u1' | 'u2'
	| 'u3' | 'u4' | 'u5' | 'u6'
	| 'u7' | 'u8' | 'u9' | 'u10'
	| 'temp' | 'lr' | 'fp' | 'sp')
	;

TokPcReg: 'pc' ;


TokIdent: [A-Za-z_] (([A-Za-z_] | [0-9])*) ;
TokOther: . ;
