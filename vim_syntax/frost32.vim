" Vim syntax file
" Language: Frost32 Assembly
" Maintainer: FL4SHK
" Latest Revision: 8 May 2018

if exists("b:current_syntax")
	finish
endif

let b:current_syntax = "frost32"

syn case match

"syn match frost32_identifier	"[a-zA-Z_][a-zA-Z_0-9]*"


syn match frost32_comment	"//.*"
syn match frost32_comment	";.*"

" Instructions
syn keyword frost32_iog0_instr	add sub sltu slts sgtu sgts mul and orr xor nor lsl lsr asr
syn keyword frost32_iog1_instr	addi subi sltui sltsi sgtui sgtsi muli andi orri xori nori lsli lsri asri addsi cpyhi
syn keyword frost32_iog2_instr	bne beq bltu bgeu bleu bgtu blts bges bles bgts
syn keyword frost32_iog3_instr	jne jeq jltu jgeu jleu jgtu jlts jges jles jgts
syn keyword frost32_iog4_instr	cne ceq cltu cgeu cleu cgtu clts cges cles cgts
syn keyword frost32_iog5_instr	ldr ldh ldsh ldb ldsb str sth stb ldri ldhi ldshi ldbi ldsbi stri sthi stbi
syn keyword frost32_iog6_instr	ei di cpy reti
syn keyword frost32_pseudo_instr	inv invi cpyi cpya bra jmp call jmpa calla jmpane jmpaeq callane callaeq inc dec

syn keyword frost32_reg		zero u0 u1 u2 u3 u4 u5 u6 u7 u8 u9 u10 temp lr fp sp pc ireta idsta

syn match frost32_directive	"\.org" 
syn match frost32_directive	"\.space"
syn match frost32_directive	"\.db"
syn match frost32_directive	"\.db16"
syn match frost32_directive	"\.db8"

"syn match 

syn match frost32_number		"0\+[1-7]\=[\t\n$,; ]\|[1-9]\d*\|0[0-7][0-7]\+\|0[x][0-9a-fA-F]\+\|0[b][0-1]*"

" hi def link frost32_instr Identifier
"hi frost32_identifier ctermfg=darkcyan guifg=darkcyan
"hi frost32_comment ctermfg=darkblue guifg=darkblue
"hi frost32_instr cterm=bold ctermfg=darkgreen gui=bold guifg=darkgreen
"hi frost32_reg cterm=bold ctermfg=black gui=bold guifg=black
"hi frost32_directive ctermfg=darkyellow guifg=darkyellow
"hi frost32_number ctermfg=darkred guifg=darkred
hi def link frost32_identifier		Normal
hi def link frost32_iog0_instr		Identifier
hi def link frost32_iog1_instr		Identifier
hi def link frost32_iog2_instr		Identifier
hi def link frost32_iog3_instr		Identifier
hi def link frost32_iog4_instr		Identifier
hi def link frost32_iog5_instr		Identifier
hi def link frost32_iog6_instr		Identifier
hi def link frost32_pseudo_instr		Identifier
hi def link frost32_comment		Comment
hi def link frost32_directive		Special
hi def link frost32_reg			Structure
hi def link frost32_number		Number
