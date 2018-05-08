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
	(TokInstrNameAdd | TokInstrNameSub 
	| TokInstrNameSltu | TokInstrNameSlts
	| TokInstrNameMul | TokInstrNameAnd 
	| TokInstrNameOrr | TokInstrNameXor
	| TokInstrNameInv | TokInstrNameLsl 
	| TokInstrNameLsr | TokInstrNameAsr)
	TokReg ',' TokReg ',' TokReg
	;

instrOpGrp1TwoRegsOneImm:
	(TokInstrNameAddi | TokInstrNameSubi 
	| TokInstrNameSltui | TokInstrNameSltsi
	| TokInstrNameMuli | TokInstrNameAndi 
	| TokInstrNameOrri | TokInstrNameXori
	| TokInstrNameInvi | TokInstrNameLsli 
	| TokInstrNameLsri | TokInstrNameAsri)
	TokReg ',' TokReg ',' expr
	;

instrOpGrp1OneRegOnePcOneImm:
	TokInstrNameAddsi
	TokReg ',' TokPcReg ',' expr
	;

instrOpGrp1OneRegOneImm:
	TokInstrNameCpyhi 
	TokReg ',' expr
	;

// Branches must be separate because they're pc-relative
instrOpGrp1Branch:
	(TokInstrNameBne | TokInstrNameBeq)
	TokReg ',' expr
	;

instrOpGrp2:
	(TokInstrNameJne | TokInstrNameJeq 
	| TokInstrNameCallne | TokInstrNameCalleq)
	TokReg ',' TokReg
	;

instrOpGrp3:
	(TokInstrNameLdr
	| TokInstrNameLdh | TokInstrNameLdsh
	| TokInstrNameLdb | TokInstrNameLdsb
	| TokInstrNameStr | TokInstrNameSth | TokInstrNameStb)
	TokReg ',' TokReg
	;


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
	//'.db' expr ((',' expr)*)
	'.db' expr
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


TokReg:
	('r0' | 'r1' | 'r2' | 'r3'
	| 'r4' | 'r5' | 'r6' | 'r7'
	| 'r8' | 'r9' | 'r10' | 'r11'
	| 'r12' | 'lr' | 'fp' | 'sp')
	;

TokPcReg: 'pc' ;


TokIdent: [A-Za-z_] (([A-Za-z_] | [0-9])*) ;
TokOther: . ;
