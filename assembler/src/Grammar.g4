grammar Grammar;

// Parser rules
program:
	line*
	;

line:
	scopedLines
	| label TokNewline
	| instruction TokNewline
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
	| instrOpGrp0TwoRegs

	| instrOpGrp1TwoRegsOneImm
	| instrOpGrp1TwoRegsOneSimm
	| instrOpGrp1OneRegOnePcOneSimm
	| instrOpGrp1OneRegOneImm
	| instrOpGrp1Branch

	| instrOpGrp2
	| instrOpGrp3
	;

instrOpGrp0ThreeRegs:
	(TokInstrNameAdd | TokInstrNameSub 
	| TokInstrNameSltu | TokInstrNameSlts
	| TokInstrNameMul | TokInstrNameAnd 
	| TokInstrNameOrr | TokInstrNameXor
	| TokInstrNameLsl 
	| TokInstrNameLsr | TokInstrNameAsr)
	TokReg TokComma TokReg TokComma TokReg
	;
instrOpGrp0TwoRegs:
	TokInstrNameInv
	TokReg TokComma TokReg
	;

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
	(TokInstrNameInvi | TokInstrNameCpyhi)
	TokReg TokComma expr
	;

// Branches must be separate because they're pc-relative
instrOpGrp1Branch:
	(TokInstrNameBne | TokInstrNameBeq)
	TokReg TokComma expr
	;

instrOpGrp2:
	(TokInstrNameJne | TokInstrNameJeq 
	| TokInstrNameCallne | TokInstrNameCalleq)
	TokReg TokComma TokReg
	;

instrOpGrp3:
	(TokInstrNameLdr
	| TokInstrNameLdh | TokInstrNameLdsh
	| TokInstrNameLdb | TokInstrNameLdsb
	| TokInstrNameStr | TokInstrNameSth | TokInstrNameStb)
	TokReg TokComma TokReg
	;


directive:
	dotOrgDirective
	| dotSpaceDirective
	| dotDbDirective
	| dotDb16Directive
	| dotDb8Directive
	;


dotOrgDirective:
	TokDotOrg expr
	;

dotSpaceDirective:
	TokDotSpace expr
	;

dotDbDirective:
	TokDotDb expr ((TokComma expr)*)
	;

dotDb16Directive:
	TokDotDb16 expr ((TokComma expr)*)
	;
dotDb8Directive:
	TokDotDb8 expr ((TokComma expr)*)
	;

// Expression parsing
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

identName: TokIdent | instrName | TokReg | TokPcReg ;

instrName:
	(TokInstrNameAdd | TokInstrNameSub
	| TokInstrNameSltu | TokInstrNameSlts
	| TokInstrNameMul | TokInstrNameAnd
	| TokInstrNameOrr | TokInstrNameXor
	| TokInstrNameInv | TokInstrNameLsl
	| TokInstrNameLsr | TokInstrNameAsr

	| TokInstrNameAddi | TokInstrNameSubi
	| TokInstrNameSltui | TokInstrNameSltsi
	| TokInstrNameMuli | TokInstrNameAndi
	| TokInstrNameOrri | TokInstrNameXori
	| TokInstrNameInvi | TokInstrNameLsli
	| TokInstrNameLsri | TokInstrNameAsri

	| TokInstrNameAddsi

	| TokInstrNameCpyhi

	| TokInstrNameBne | TokInstrNameBeq

	| TokInstrNameJne | TokInstrNameJeq
	| TokInstrNameCallne | TokInstrNameCalleq

	| TokInstrNameLdr
	| TokInstrNameLdh | TokInstrNameLdsh
	| TokInstrNameLdb | TokInstrNameLdsb
	| TokInstrNameStr | TokInstrNameSth | TokInstrNameStb)
	;

numExpr: TokDecNum | TokHexNum | TokBinNum;

currPc: TokPeriod ;

// Lexer rules
LexWhitespace: (' ' | '\t') -> skip ;
LexLineComment: '//' (~ '\n')* -> skip ;

TokOpLogical: ('&&' | '||') ;
TokOpCompare: ('==' | '!=' | '<' | '>' | '<=' | '>=') ;
//TokOpAddSub: ('+' | '-') ;
TokPlus: '+' ;
TokMinus: '-' ;
TokOpMulDivMod: ('*' | '/' | '%') ;
TokOpBitwise: ('&' | '|' | '^' | '<<' | '>>' | '>>>') ;
TokBitInvert: '~' ;

TokDecNum: [0-9] ([0-9]*) ;
TokHexNum: '0x' ([0-9A-Za-z]+);
TokBinNum: '0b' ([0-1]+);

TokInstrNameAdd: 'add' ;
TokInstrNameSub: 'sub' ;
TokInstrNameSltu: 'sltu' ;
TokInstrNameSlts: 'slts' ;
TokInstrNameMul: 'mul' ;
TokInstrNameAnd: 'and' ;
TokInstrNameOrr: 'orr' ;
TokInstrNameXor: 'xor' ;
TokInstrNameInv: 'inv' ;
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
TokInstrNameInvi: 'invi' ;
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
	('r0' | 'r1' | 'r2' | 'r3'
	| 'r4' | 'r5' | 'r6' | 'r7'
	| 'r8' | 'r9' | 'r10' | 'r11'
	| 'r12' | 'lr' | 'fp' | 'sp')
	;

TokPcReg: 'pc' ;


TokIdent: [A-Za-z_] (([A-Za-z_] | [0-9])*) ;
TokOther: . ;
