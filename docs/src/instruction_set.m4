include(src/include/misc_defines.m4)dnl
define(`CODE',CONCAT3(`<code>',$1,`</code>'))dnl
define(`BOLD',CONCAT3(`<b>',$1,`</b>'))dnl
define(`ITALIC',CONCAT3(`<i>',$1,`</i>'))dnl
define(`UNDERLINE',CONCAT3(`<u>',$1,`</u>'))dnl
define(`OPCODE_GROUP',CONCAT(`Opcode Group:  ',$1))dnl
dnl define(`OP_IMMFIELD',CONCAT(`Opcode (Immediate Field):  ',$1))dnl
dnl define(`OP_RC',CONCAT(`Opcode (rC Field):  ',$1))dnl
define(`OPCODE',CONCAT(`Opcode:  ',$1))dnl
define(`NEWLINE',`<br>')dnl
# Frost32 Instruction Set
<!-- Vim Note:  Use @g to update notes.pdf -->
<!-- Vim Note:  Use @h to update notes.html -->
<!-- Vim Note:  Use @j to update notes.pdf and notes.html -->
<!-- How To Make A Tab:  &emsp; -->
<!--
&epsilon; &Epsilon;   &lambda; &Lambda;   &alpha; &Alpha;
&beta; &Beta;   &pi; &Pi; &#0960;   &sigma; &Sigma;
&omega; &Omega;   &mu; &Mu;  &gamma; &Gamma;
&prod;  &sum;  &int;  &part;  &infin;
&amp;  &ast;  &sdot;
&lt; &le;  &gt; &ge;  &equals; &ne;
-->



* General Purpose Registers (32-bit):
	* MDCODE(zero) (always zero), MDCODE(u0), MDCODE(u1), MDCODE(u2), 
	MDCODE(u3), MDCODE(u4), MDCODE(u5), MDCODE(u6),
	MDCODE(u7), MDCODE(u8), MDCODE(u9), MDCODE(u10),
NEWLINE()
	MDCODE(temp) (assembler temporary (but can be used otherwise)), 
NEWLINE()
	MDCODE(lr) (upon any call instruction, return address stored here), 
NEWLINE()
	MDCODE(fp) (recommended for use as the frame pointer), 
NEWLINE()
	MDCODE(sp) (recommended for use as the stack pointer)
* Special Purpose Registers (32-bit)
	* MDCODE(pc) (program counter), MDCODE(ireta) (interrupt return address)
	MDCODE(idsta) (interrupt destination address)
* Special Purpose Registers (1-bit)
	* MDCODE(ie) (interrupt enable)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0000)
	* Encoding:  MDCODE(0000 aaaa bbbb cccc  0000 0000 0000 oooo)
		* MDCODE(a):  rA
		* MDCODE(b):  rB
		* MDCODE(c):  rC
		* MDCODE(o):  opcode
	* Instructions:
		* BOLD(add) rA, rB, rC
			* OPCODE(0x0)
		* BOLD(sub) rA, rB, rC
			* OPCODE(0x1)
		* BOLD(sltu) rA, rB, rC
			* OPCODE(0x2)
		* BOLD(slts) rA, rB, rC
			* OPCODE(0x3)
		* BOLD(sgtu) rA, rB, rC
			* OPCODE(0x4)
		* BOLD(sgts) rA, rB, rC
			* OPCODE(0x5)
		* BOLD(mul) rA, rB, rC
			* OPCODE(0x6)
		* BOLD(and) rA, rB, rC
			* OPCODE(0x7)
		* BOLD(orr) rA, rB, rC
			* OPCODE(0x8)
		* BOLD(xor) rA, rB, rC
			* OPCODE(0x9)
		* BOLD(nor) rA, rB, rC
			* OPCODE(0xa)
		* BOLD(lsl) rA, rB, rC
			* OPCODE(0xb)
		* BOLD(lsr) rA, rB, rC
			* OPCODE(0xc)
		* BOLD(asr) rA, rB, rC
			* OPCODE(0xd)
		* BOLD(udiv) rA, rB, rC
			* OPCODE(0xe)
		* BOLD(sdiv) rA, rB, rC
			* OPCODE(0xf)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0001)
	* Encoding:  MDCODE(0001 aaaa bbbb oooo  iiii iiii iiii iiii)
		* MDCODE(a):  rA
		* MDCODE(b):  rB
		* MDCODE(o):  opcode
		* MDCODE(i):  16-bit immediate
	* Instructions:
		* BOLD(addi) rA, rB, imm16
			* OPCODE(0x0)
		* BOLD(subi) rA, rB, imm16
			* OPCODE(0x1)
		* BOLD(sltui) rA, rB, imm16
			* OPCODE(0x2)
		* BOLD(sltsi) rA, rB, simm16
			* OPCODE(0x3)
		* BOLD(sgtui) rA, rB, imm16
			* OPCODE(0x4)
		* BOLD(sgtsi) rA, rB, simm16
			* OPCODE(0x5)
		* BOLD(muli) rA, rB, imm16
			* OPCODE(0x6)
		* BOLD(andi) rA, rB, imm16
			* OPCODE(0x7)
		* BOLD(orri) rA, rB, imm16
			* OPCODE(0x8)
		* BOLD(xori) rA, rB, imm16
			* OPCODE(0x9)
		* BOLD(nori) rA, rB, imm16
			* OPCODE(0xa)
		* BOLD(lsli) rA, rB, imm16
			* OPCODE(0xb)
		* BOLD(lsri) rA, rB, imm16
			* OPCODE(0xc)
		* BOLD(asri) rA, rB, imm16
			* OPCODE(0xd)
		* BOLD(addsi) rA, pc, simm16
			* OPCODE(0xe)
		* BOLD(cpyhi) rA, imm16
			* OPCODE(0xf)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0010)
	* Encoding:  MDCODE(0010 aaaa bbbb oooo  iiii iiii iiii iiii)
		* MDCODE(a):  rA
		* MDCODE(b):  rB
		* MDCODE(o):  opcode
		* MDCODE(i):  16-bit immediate
	* Instructions:
		* BOLD(bne) rA, rB, offset16
			* OPCODE(0x0)
		* BOLD(beq) rA, rB, offset16
			* OPCODE(0x1)
		* BOLD(bltu) rA, rB, offset16
			* OPCODE(0x2)
		* BOLD(bgeu) rA, rB, offset16
			* OPCODE(0x3)
		* BOLD(bleu) rA, rB, offset16
			* OPCODE(0x4)
		* BOLD(bgtu) rA, rB, offset16
			* OPCODE(0x5)
		* BOLD(blts) rA, rB, offset16
			* OPCODE(0x6)
		* BOLD(bges) rA, rB, offset16
			* OPCODE(0x7)
		* BOLD(bles) rA, rB, offset16
			* OPCODE(0x8)
		* BOLD(bgts) rA, rB, offset16
			* OPCODE(0x9)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0011)
	* Encoding:  MDCODE(0011 aaaa bbbb cccc  0000 0000 0000 oooo)
		* MDCODE(a):  rA
		* MDCODE(b):  rB
		* MDCODE(c):  rC
		* MDCODE(o):  opcode
	* Instructions:
		* BOLD(jne) rA, rB, rC
			* OPCODE(0x0)
		* BOLD(jeq) rA, rB, rC
			* OPCODE(0x1)
		* BOLD(jltu) rA, rB, rC
			* OPCODE(0x2)
		* BOLD(jgeu) rA, rB, rC
			* OPCODE(0x3)
		* BOLD(jleu) rA, rB, rC
			* OPCODE(0x4)
		* BOLD(jgtu) rA, rB, rC
			* OPCODE(0x5)
		* BOLD(jlts) rA, rB, rC
			* OPCODE(0x6)
		* BOLD(jges) rA, rB, rC
			* OPCODE(0x7)
		* BOLD(jles) rA, rB, rC
			* OPCODE(0x8)
		* BOLD(jgts) rA, rB, rC
			* OPCODE(0x9)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0100)
	* Encoding:  MDCODE(0100 aaaa bbbb cccc  0000 0000 0000 oooo)
		* MDCODE(a):  rA
		* MDCODE(b):  rB
		* MDCODE(c):  rC
		* MDCODE(o):  opcode
	* Instructions:
		* BOLD(cne) rA, rB, rC
			* OPCODE(0x0)
		* BOLD(ceq) rA, rB, rC
			* OPCODE(0x1)
		* BOLD(cltu) rA, rB, rC
			* OPCODE(0x2)
		* BOLD(cgeu) rA, rB, rC
			* OPCODE(0x3)
		* BOLD(cleu) rA, rB, rC
			* OPCODE(0x4)
		* BOLD(cgtu) rA, rB, rC
			* OPCODE(0x5)
		* BOLD(clts) rA, rB, rC
			* OPCODE(0x6)
		* BOLD(cges) rA, rB, rC
			* OPCODE(0x7)
		* BOLD(cles) rA, rB, rC
			* OPCODE(0x8)
		* BOLD(cgts) rA, rB, rC
			* OPCODE(0x9)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0101)
	* Encoding:  MDCODE(0101 aaaa bbbb cccc  iiii iiii iiii oooo)
		* MDCODE(a):  rA
		* MDCODE(b):  rB
		* MDCODE(c):  rC
		* MDCODE(i):  sign-extended 12-bit immediate
		* MDCODE(o):  opcode
dnl 	* Note:  Loads and stores that use cached values
	* Instructions:
		* BOLD(ldr) rA, [rB, rC]
			* OPCODE(0b0000)
		* BOLD(ldh) rA, [rB, rC]
			* OPCODE(0b0001)
		* BOLD(ldsh) rA, [rB, rC]
			* OPCODE(0b0010)
		* BOLD(ldb) rA, [rB, rC]
			* OPCODE(0b0011)
		* BOLD(ldsb) rA, [rB, rC]
			* OPCODE(0b0100)
		* BOLD(str) rA, [rB, rC]
			* OPCODE(0b0101)
		* BOLD(sth) rA, [rB, rC]
			* OPCODE(0b0110)
		* BOLD(stb) rA, [rB, rC]
			* OPCODE(0b0111)
		* BOLD(ldri) rA, [rB, simm12]
			* OPCODE(0b1000)
		* BOLD(ldhi) rA, [rB, simm12]
			* OPCODE(0b1001)
		* BOLD(ldshi) rA, [rB, simm12]
			* OPCODE(0b1010)
		* BOLD(ldbi) rA, [rB, simm12]
			* OPCODE(0b1011)
		* BOLD(ldsbi) rA, [rB, simm12]
			* OPCODE(0b1100)
		* BOLD(stri) rA, [rB, simm12]
			* OPCODE(0b1101)
		* BOLD(sthi) rA, [rB, simm12]
			* OPCODE(0b1110)
		* BOLD(stbi) rA, [rB, simm12]
			* OPCODE(0b1111)
dnl NEWLINE()NEWLINE()
dnl * OPCODE_GROUP(0b0110)
dnl 	* Encoding:  MDCODE(0102 aaaa bbbb cccc  iiii iiii iiii oooo)
dnl 		* MDCODE(a):  rA
dnl 		* MDCODE(b):  rB
dnl 		* MDCODE(c):  rC
dnl 		* MDCODE(i):  sign-extended 12-bit immediate
dnl 		* MDCODE(o):  opcode
dnl 	* Note:  Loads and stores that touch memory directly
dnl 	* Instructions:
dnl 		* BOLD(ldr_nc) rA, [rB, rC]
dnl 			* OPCODE(0b0000)
dnl 		* BOLD(ldh_nc) rA, [rB, rC]
dnl 			* OPCODE(0b0001)
dnl 		* BOLD(ldsh_nc) rA, [rB, rC]
dnl 			* OPCODE(0b0010)
dnl 		* BOLD(ldb_nc) rA, [rB, rC]
dnl 			* OPCODE(0b0011)
dnl 		* BOLD(ldsb_nc) rA, [rB, rC]
dnl 			* OPCODE(0b0100)
dnl 		* BOLD(str_nc) rA, [rB, rC]
dnl 			* OPCODE(0b0101)
dnl 		* BOLD(sth_nc) rA, [rB, rC]
dnl 			* OPCODE(0b0110)
dnl 		* BOLD(stb_nc) rA, [rB, rC]
dnl 			* OPCODE(0b0111)
dnl 		* BOLD(ldri_nc) rA, [rB, simm12]
dnl 			* OPCODE(0b1000)
dnl 		* BOLD(ldhi_nc) rA, [rB, simm12]
dnl 			* OPCODE(0b1001)
dnl 		* BOLD(ldshi_nc) rA, [rB, simm12]
dnl 			* OPCODE(0b1010)
dnl 		* BOLD(ldbi_nc) rA, [rB, simm12]
dnl 			* OPCODE(0b1011)
dnl 		* BOLD(ldsbi_nc) rA, [rB, simm12]
dnl 			* OPCODE(0b1100)
dnl 		* BOLD(stri_nc) rA, [rB, simm12]
dnl 			* OPCODE(0b1101)
dnl 		* BOLD(sthi_nc) rA, [rB, simm12]
dnl 			* OPCODE(0b1110)
dnl 		* BOLD(stbi_nc) rA, [rB, simm12]
dnl 			* OPCODE(0b1111)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0110)
NEWLINE()NEWLINE()
	* Encoding:  MDCODE(0110 aaaa bbbb cccc  0000 0000 0000 oooo)
		* MDCODE(a):  rA
		* MDCODE(b):  rB
		* MDCODE(c):  rC
		* MDCODE(o);  opcode
	* Instructions:
		* BOLD(ei)
			* Note:  Enable interrupts
			* OPCODE(0x0)
		* BOLD(di)
			* Note:  Disable interrupts
			* OPCODE(0x1)
		* BOLD(cpy) ireta, rA
			* OPCODE(0x2)
		* BOLD(cpy) rA, ireta
			* OPCODE(0x3)
		* BOLD(cpy) idsta, rA
			* OPCODE(0x4)
		* BOLD(cpy) rA, idsta
			* OPCODE(0x5)
		* BOLD(reti)
			* Note:  Enable interrupts and change the program counter to the
			value contained in MDCODE(ireta)
			* OPCODE(0x6)
* Pseudo Instructions:
	* BOLD(inv) rA, rB
		* Encoded as CODE(`nor rA, rB, zero')
	* BOLD(invi) rA, imm16
		* Encoded as CODE(`nori rA, zero, imm16')
	* BOLD(cpy) rA, rB
		* Encoded as CODE(`add rA, rB, zero')
	* BOLD(cpy) rA, pc
		* Encoded as CODE(`addsi rA, pc, 0')
	* BOLD(cpyi) rA, imm16
		* Encoded as CODE(`addi rA, zero, imm16')
	* BOLD(cpya) rA, imm32
		* Copy absolute (32-bit immediate)
		* Encoded as 
			NEWLINE()
			CODE(`addi rA, zero, (imm32 & 0xffff)')
			NEWLINE()
			CODE(`cpyhi rA, (imm32 >> 16)')
	* BOLD(bra) simm16
		* Unconditional relative branch
		* Encoded as CODE(`beq zero, zero, simm16')
	* BOLD(jmp) rC
		* Unconditional jump to address in register
		* Encoded as CODE(`jeq zero, zero, rC')
	* BOLD(call) rC
		* Unconditional call to address in register
		* Encoded as CODE(`ceq zero, zero, rC')
	* BOLD(jmpa) imm32
		* Jump absolute (to directly encoded address)
		* Encoded as
			NEWLINE()
			CODE(`cpya temp, imm32')
			NEWLINE()
			CODE(`jmp temp')
	* BOLD(calla) imm32
		* Call absolute (to directly encoded address)
		* Encoded as
			NEWLINE()
			CODE(`cpya temp, imm32')
			NEWLINE()
			CODE(`call temp')
	* BOLD(jmpane) rA, rB, imm32
		* Conditional jump absolute (to directly encoded address)
		* Encoded as
			NEWLINE()
			CODE(`cpya temp, imm32')
			NEWLINE()
			CODE(`jne rA, rB temp')
	* BOLD(jmpaeq) rA, rB, imm32
		* Conditional jump absolute (to directly encoded address)
		* Encoded as
			NEWLINE()
			CODE(`cpya temp, imm32')
			NEWLINE()
			CODE(`jeq rA, rB temp')
	* BOLD(callane) rA, rB, imm32
		* Conditional call absolute (to directly encoded address)
		* Encoded as
			NEWLINE()
			CODE(`cpya temp, imm32')
			NEWLINE()
			CODE(`callne rA, rB, temp')
	* BOLD(callaeq) rA, rB, imm32
		* Conditional call absolute (to directly encoded address)
		* Encoded as
			NEWLINE()
			CODE(`cpya temp, imm32')
			NEWLINE()
			CODE(`calleq rA, rB, temp')
	* BOLD(inc) rA
		* Encoded as CODE(`addi rA, rA, 1')
	* BOLD(dec) rA
		* Encoded as CODE(`subi rA, rA, 1')
	* BOLD(alu\_op\_three\_regs) rA, rB
		* Encoded as CODE(`alu\_op\_three\_regs rA, rA, rB')
	* BOLD(alu\_op\_two\_regs\_one\_immediate) rA, imm16
		* Encoded as CODE(`alu\_op\_two\_regs\_one\_immediate rA, rA, imm16')
	dnl * BOLD(bne) rA, rB, imm16
	dnl 	* Relative branch if (rA != rB)
	dnl 	* Encoded as
	dnl 		NEWLINE()
	dnl 		CODE(`sub temp, rA, rB')
	dnl 		NEWLINE()
	dnl 		CODE(`bne temp, imm16 - 4')
	dnl * BOLD(beq) rA, rB, imm16
	dnl 	* Relative branch if (rA == rB)
	dnl 	* Encoded as
	dnl 		NEWLINE()
	dnl 		CODE(`sub temp, rA, rB')
	dnl 		NEWLINE()
	dnl 		CODE(`beq temp, imm16 - 4')
	dnl * BOLD(blts) rA, rB, imm16
	dnl 	* Relative branch if ($signed(rA) < $signed(rB))
	dnl 	* Encoded as
	dnl 		NEWLINE()
	dnl 		CODE(`slts temp, rA, rB')
	dnl 		NEWLINE()
	dnl 		CODE(`bne temp, imm16 - 4')
	dnl * BOLD(bges) rA, rB, imm16
	dnl 	* Relative branch if ($signed(rA) >= $signed(rB))
	dnl 	* Encoded as
	dnl 		NEWLINE()
	dnl 		CODE(`slts temp, rA, rB')
	dnl 		NEWLINE()
	dnl 		CODE(`beq temp, imm16 - 4')
	dnl * BOLD(bles) rA, rB, imm16
	dnl 	* Relative branch if ($signed(rA) <= $signed(rB))
	dnl 	* Encoded as
	dnl 		NEWLINE()
	dnl 		CODE(`slts temp, rA, rB')
	dnl 		NEWLINE()
	dnl 		CODE(`bne temp, imm16 - 4')
	dnl 		NEWLINE()
	dnl 		CODE(`sub temp, rA, rB')
	dnl 		NEWLINE()
	dnl 		CODE(`beq temp, imm16 - 12')
