grammar Grammar;

// Parser rules
program:
	line*
	;

line:
	scopedLines
	| label '\n'
	| instruction '\n'
	| directive '\n'
	| '\n' // Allow blank lines and lines with only a comment
	;

scopedLines:
	'{' '\n'
	line*
	'}' '\n'
	;

label: 
	identName ':' 
	;

instruction:
	instrOpGrp0ThreeRegs
	| instrOpGrp1TwoRegsOneImm
	| instrOpGrp1OneRegOnePcOneImm
	| instrOpGrp1OneRegOneImm
	| instrOpGrp1Branch
	| instrOpGrp2
	| instrOpGrp3
	;

instrOpGrp0ThreeRegs:
	(instrNameAdd | instrNameSub | instrNameSltu | instrNameSlts
	| instrNameMul | instrNameAnd | instrNameOrr | instrNameXor
	| instrNameInv | instrNameLsl | instrNameLsr | instrNameAsr)
	TokReg ',' TokReg ',' TokReg
	;

instrOpGrp1TwoRegsOneImm:
	(instrNameAddi | instrNameSubi | instrNameSltui | instrNameSltsi
	| instrNameMuli | instrNameAndi | instrNameOrri | instrNameXori
	| instrNameInvi | instrNameLsli | instrNameLsri | instrNameAsri)
	TokReg ',' TokReg ',' expr
	;

instrOpGrp1OneRegOnePcOneImm:
	instrNameAddsi
	TokReg ',' TokPcReg ',' expr
	;

instrOpGrp1OneRegOneImm:
	instrNameCpyhi 
	TokReg ',' expr
	;

// Branches must be separate because they're pc-relative
instrOpGrp1Branch:
	(instrNameBne | instrNameBeq)
	TokReg ',' expr
	;

instrOpGrp2:
	(instrNameJne | instrNameJeq | instrNameCallne | instrNameCalleq)
	TokReg ',' TokReg
	;

instrOpGrp3:
	(instrNameLdr
	| instrNameLdh | instrNameLdsh
	| instrNameLdb | instrNameLdsb
	| instrNameStr | instrNameSth | instrNameStb)
	TokReg ',' TokReg
	;

instrNameAdd: 'add' ; instrNameSub: 'sub' ;
instrNameSltu: 'sltu' ; instrNameSlts: 'slts' ;
instrNameMul: 'mul' ; instrNameAnd: 'and' ;
instrNameOrr: 'orr' ; instrNameXor: 'xor' ;
instrNameInv: 'inv' ; instrNameLsl: 'lsl' ;
instrNameLsr: 'lsr' ; instrNameAsr: 'asr' ;

instrNameAddi: 'addi' ; instrNameSubi: 'subi' ;
instrNameSltui: 'sltui' ; instrNameSltsi: 'sltsi' ;
instrNameMuli: 'muli' ; instrNameAndi: 'andi' ;
instrNameOrri: 'orri' ; instrNameXori: 'xori' ;
instrNameInvi: 'invi' ; instrNameLsli: 'lsli' ;
instrNameLsri: 'lsri' ; instrNameAsri: 'asri' ;

instrNameAddsi: 'addsi' ;

instrNameCpyhi: 'cpyhi' ;

instrNameBne: 'bne' ; instrNameBeq: 'beq' ;

instrNameJne: 'jne' ; instrNameJeq: 'jeq' ;
instrNameCallne: 'callne' ; instrNameCalleq: 'calleq' ;

instrNameLdr: 'ldr' ;
instrNameLdh: 'ldh' ; instrNameLdsh: 'ldsh' ;
instrNameLdb: 'ldb' ; instrNameLdsb: 'ldsb' ;
instrNameStr: 'str' ;
instrNameSth: 'sth' ;
instrNameStb: 'stb' ;

directive:
	// dotOrgDirective
	// | dotSpaceDirective
	/*|*/ dotDbDirective
	// | dotDbU16Directive
	// | dotDbS16Directive
	// | dotDbU8Directive
	// | dotDbS8Directive
	;


//dotOrgDirective:
//	'.org' expr
//	;
//
//dotSpaceDirective:
//	'.space' expr
//	;

dotDbDirective:
	'.db' expr ((',' expr)*)
	;

//dotDbU16Directive:
//	'.db_u16' expr ((',' expr)*)
//	;
//dotDbS16Directive:
//	'.db_s16' expr ((',' expr)*)
//	;
//
//dotDbU8Directive:
//	'.db_u8' expr ((',' expr)*)
//	;
//dotDbS8Directive:
//	'.db_s8' expr ((',' expr)*)
//	;

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

exprJustAdd: exprAddSub '+' exprCompare ;
exprJustSub: exprAddSub '-' exprCompare ;

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
	| '(' expr ')'
	;

exprUnary:
	exprBitInvert
	| exprNegate
	| exprLogNot
	;

exprBitInvert: '~' expr ;
exprNegate: '-' expr ;
exprLogNot: '!' expr ;

identName: TokIdent | TokInstrName | TokReg | TokSpecReg;

numExpr: TokDecNum | TokHexNum | TokBinNum;

currPc: '.' ;

// Lexer rules
LexWhitespace: (' ' | '\t') -> skip ;
LexLineComment: '//' (~ '\n')* -> skip ;

TokOpLogical: ('&&' | '||') ;
TokOpCompare: ('==' | '!=' | '<' | '>' | '<=' | '>=') ;
//TokOpAddSub: ('+' | '-') ;
TokOpMulDivMod: ('*' | '/' | '%') ;
TokOpBitwise: ('&' | '|' | '^' | '<<' | '>>' | '>>>') ;

TokDecNum: [0-9] ([0-9]*) ;
TokHexNum: '0x' ([0-9A-Za-z]+);
TokBinNum: '0b' ([0-1]+);

TokInstrName:
	('add' | 'sub' | 'sltu' | 'stls'
	| 'mul' | 'and' | 'orr' | 'xor'
	| 'inv' | 'lsl' | 'lsr' | 'asr'
	| 'addi' | 'subi' | 'sltui' | 'stlsi'
	| 'muli' | 'andi' | 'orri' | 'xori'
	| 'invi' | 'lsli' | 'lsri' | 'asri'
	| 'addsi'
	| 'cpyhi' | 'bne' | 'beq'
	| 'jne' | 'jeq' | 'callne' | 'calleq'
	| 'ldr' | 'ldh' | 'ldsh' | 'ldb' | 'ldsb'
	| 'str' | 'sth' | 'stb')
	;

TokReg:
	('r0' | 'r1' | 'r2' | 'r3'
	| 'r4' | 'r5' | 'r6' | 'r7'
	| 'r8' | 'r9' | 'r10' | 'r11'
	| 'r12' | 'lr' | 'fp' | 'sp')
	;

TokPcReg: 'pc' ;


TokIdent: [A-Za-z_] (([A-Za-z_] | [0-9])*) ;
TokOther: . ;
