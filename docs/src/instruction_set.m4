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
	* MDCODE(r0) (always zero), MDCODE(r1), MDCODE(r2), MDCODE(r3), 
	MDCODE(r4), MDCODE(r5), MDCODE(r6), MDCODE(r7),
	MDCODE(r8), MDCODE(r9), MDCODE(r10), MDCODE(r11),
	MDCODE(r12), MDCODE(lr), MDCODE(fp), MDCODE(sp)
* Special Purpose Registers (32-bit)
	* CODE(pc)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0000)
	* Encoding:  MDCODE(0000 aaaa bbbb cccc  0000 0000 0000 oooo)
		* MDCODE(a):  rA
		* MDCODE(b):  rB
		* MDCODE(c):  rC
		* MDCODE(o):  opcode
	* Instructions:
		* BOLD(add) rA, rB, rC
			* OPCODE(0b0000)
		* BOLD(sub) rA, rB, rC
			* OPCODE(0b0001)
		* BOLD(sltu) rA, rB, rC
			* OPCODE(0b0010)
		* BOLD(slts) rA, rB, rC
			* OPCODE(0b0011)
		* BOLD(mul) rA, rB, rC
			* OPCODE(0b0100)
		* BOLD(and) rA, rB, rC
			* OPCODE(0b0101)
		* BOLD(orr) rA, rB, rC
			* OPCODE(0b0110)
		* BOLD(xor) rA, rB, rC
			* OPCODE(0b0111)
		* BOLD(inv) rA, rB
			* OPCODE(0b1000)
		* BOLD(lsl) rA, rB, rC
			* OPCODE(0b1001)
		* BOLD(lsr) rA, rB, rC
			* OPCODE(0b1010)
		* BOLD(asr) rA, rB, rC
			* OPCODE(0b1011)
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
		* BOLD(muli) rA, rB, imm16
			* OPCODE(0x4)
		* BOLD(andi) rA, rB, imm16
			* OPCODE(0x5)
		* BOLD(orri) rA, rB, imm16
			* OPCODE(0x6)
		* BOLD(xori) rA, rB, imm16
			* OPCODE(0x7)
		* BOLD(invi) rA, imm16
			* OPCODE(0x8)
		* BOLD(lsli) rA, rB, imm16
			* OPCODE(0x9)
		* BOLD(lsri) rA, rB, imm16
			* OPCODE(0xa)
		* BOLD(asri) rA, rB, imm16
			* OPCODE(0xb)
		* BOLD(addsi) rA, pc, simm16
			* OPCODE(0xc)
		* BOLD(cpyhi) rA, imm16
			* OPCODE(0xd)
		* BOLD(bne) rA, simm16
			* OPCODE(0xe)
		* BOLD(beq) rA, simm16
			* OPCODE(0xf)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0010)
	* Encoding:  MDCODE(0b0010 aaaa bbbb cccc  0000 0000 0000 oooo)
		* MDCODE(a):  rA
		* MDCODE(b):  rB
		* MDCODE(c):  rC
		* MDCODE(o):  opcode
	* Instructions:
		* BOLD(jne) rA, rB
			* OPCODE(0b0000)
		* BOLD(jeq) rA, rB
			* OPCODE(0b0001)
		* BOLD(callne) rA, rB
			* OPCODE(0b0010)
		* BOLD(calleq) rA, rB
			* OPCODE(0b0011)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0011)
	* Encoding:  MDCODE(0b0011 aaaa bbbb cccc  0000 0000 0000 oooo)
		* MDCODE(a):  rA
		* MDCODE(b):  rB
		* MDCODE(c):  rC
		* MDCODE(o):  opcode
	* Instructions:
		* BOLD(ldr) rA, rB
			* OPCODE(0b0000)
		* BOLD(ldh) rA, rB
			* OPCODE(0b0001)
		* BOLD(ldsh) rA, rB
			* OPCODE(0b0010)
		* BOLD(ldb) rA, rB
			* OPCODE(0b0011)
		* BOLD(ldsb) rA, rB
			* OPCODE(0b0100)
		* BOLD(str) rA, rB
			* OPCODE(0b0101)
		* BOLD(sth) rA, rB
			* OPCODE(0b0110)
		* BOLD(stb) rA, rB
			* OPCODE(0b0111)
