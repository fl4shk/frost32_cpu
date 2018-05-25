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
	* `zero` (always zero), `u0`, `u1`, `u2`, 
	`u3`, `u4`, `u5`, `u6`,
	`u7`, `u8`, `u9`, `u10`,
<br>
	`temp` (assembler temporary (but can be used otherwise)), 
<br>
	`lr` (upon any call instruction, return address stored here), 
<br>
	`fp` (recommended for use as the frame pointer), 
<br>
	`sp` (recommended for use as the stack pointer)
* Special Purpose Registers (32-bit)
	* `pc` (program counter), `ireta` (interrupt return address)
	`idsta` (interrupt destination address)
* Special Purpose Registers (1-bit)
	* `ie` (interrupt enable)
<br><br>
* Opcode Group:  0b0000
	* Encoding:  `0000 aaaa bbbb cccc  0000 0000 0000 oooo`
		* `a`:  rA
		* `b`:  rB
		* `c`:  rC
		* `o`:  opcode
	* Instructions:
		* <b>add</b> rA, rB, rC
			* Opcode:  0x0
		* <b>sub</b> rA, rB, rC
			* Opcode:  0x1
		* <b>sltu</b> rA, rB, rC
			* Opcode:  0x2
		* <b>slts</b> rA, rB, rC
			* Opcode:  0x3
		* <b>sgtu</b> rA, rB, rC
			* Opcode:  0x4
		* <b>sgts</b> rA, rB, rC
			* Opcode:  0x5
		* <b>mul</b> rA, rB, rC
			* Opcode:  0x6
		* <b>and</b> rA, rB, rC
			* Opcode:  0x7
		* <b>orr</b> rA, rB, rC
			* Opcode:  0x8
		* <b>xor</b> rA, rB, rC
			* Opcode:  0x9
		* <b>nor</b> rA, rB, rC
			* Opcode:  0xa
		* <b>lsl</b> rA, rB, rC
			* Opcode:  0xb
		* <b>lsr</b> rA, rB, rC
			* Opcode:  0xc
		* <b>asr</b> rA, rB, rC
			* Opcode:  0xd
		* <b>udiv</b> rA, rB, rC
			* Opcode:  0xe
		* <b>sdiv</b> rA, rB, rC
			* Opcode:  0xf
<br><br>
* Opcode Group:  0b0001
	* Encoding:  `0001 aaaa bbbb oooo  iiii iiii iiii iiii`
		* `a`:  rA
		* `b`:  rB
		* `o`:  opcode
		* `i`:  16-bit immediate
	* Instructions:
		* <b>addi</b> rA, rB, imm16
			* Opcode:  0x0
		* <b>subi</b> rA, rB, imm16
			* Opcode:  0x1
		* <b>sltui</b> rA, rB, imm16
			* Opcode:  0x2
		* <b>sltsi</b> rA, rB, simm16
			* Opcode:  0x3
		* <b>sgtui</b> rA, rB, imm16
			* Opcode:  0x4
		* <b>sgtsi</b> rA, rB, simm16
			* Opcode:  0x5
		* <b>muli</b> rA, rB, imm16
			* Opcode:  0x6
		* <b>andi</b> rA, rB, imm16
			* Opcode:  0x7
		* <b>orri</b> rA, rB, imm16
			* Opcode:  0x8
		* <b>xori</b> rA, rB, imm16
			* Opcode:  0x9
		* <b>nori</b> rA, rB, imm16
			* Opcode:  0xa
		* <b>lsli</b> rA, rB, imm16
			* Opcode:  0xb
		* <b>lsri</b> rA, rB, imm16
			* Opcode:  0xc
		* <b>asri</b> rA, rB, imm16
			* Opcode:  0xd
		* <b>addsi</b> rA, pc, simm16
			* Opcode:  0xe
		* <b>cpyhi</b> rA, imm16
			* Opcode:  0xf
<br><br>
* Opcode Group:  0b0010
	* Encoding:  `0010 aaaa bbbb oooo  iiii iiii iiii iiii`
		* `a`:  rA
		* `b`:  rB
		* `o`:  opcode
		* `i`:  16-bit immediate
	* Instructions:
		* <b>bne</b> rA, rB, offset16
			* Opcode:  0x0
		* <b>beq</b> rA, rB, offset16
			* Opcode:  0x1
		* <b>bltu</b> rA, rB, offset16
			* Opcode:  0x2
		* <b>bgeu</b> rA, rB, offset16
			* Opcode:  0x3
		* <b>bleu</b> rA, rB, offset16
			* Opcode:  0x4
		* <b>bgtu</b> rA, rB, offset16
			* Opcode:  0x5
		* <b>blts</b> rA, rB, offset16
			* Opcode:  0x6
		* <b>bges</b> rA, rB, offset16
			* Opcode:  0x7
		* <b>bles</b> rA, rB, offset16
			* Opcode:  0x8
		* <b>bgts</b> rA, rB, offset16
			* Opcode:  0x9
<br><br>
* Opcode Group:  0b0011
	* Encoding:  `0011 aaaa bbbb cccc  0000 0000 0000 oooo`
		* `a`:  rA
		* `b`:  rB
		* `c`:  rC
		* `o`:  opcode
	* Instructions:
		* <b>jne</b> rA, rB, rC
			* Opcode:  0x0
		* <b>jeq</b> rA, rB, rC
			* Opcode:  0x1
		* <b>jltu</b> rA, rB, rC
			* Opcode:  0x2
		* <b>jgeu</b> rA, rB, rC
			* Opcode:  0x3
		* <b>jleu</b> rA, rB, rC
			* Opcode:  0x4
		* <b>jgtu</b> rA, rB, rC
			* Opcode:  0x5
		* <b>jlts</b> rA, rB, rC
			* Opcode:  0x6
		* <b>jges</b> rA, rB, rC
			* Opcode:  0x7
		* <b>jles</b> rA, rB, rC
			* Opcode:  0x8
		* <b>jgts</b> rA, rB, rC
			* Opcode:  0x9
<br><br>
* Opcode Group:  0b0100
	* Encoding:  `0100 aaaa bbbb cccc  0000 0000 0000 oooo`
		* `a`:  rA
		* `b`:  rB
		* `c`:  rC
		* `o`:  opcode
	* Instructions:
		* <b>cne</b> rA, rB, rC
			* Opcode:  0x0
		* <b>ceq</b> rA, rB, rC
			* Opcode:  0x1
		* <b>cltu</b> rA, rB, rC
			* Opcode:  0x2
		* <b>cgeu</b> rA, rB, rC
			* Opcode:  0x3
		* <b>cleu</b> rA, rB, rC
			* Opcode:  0x4
		* <b>cgtu</b> rA, rB, rC
			* Opcode:  0x5
		* <b>clts</b> rA, rB, rC
			* Opcode:  0x6
		* <b>cges</b> rA, rB, rC
			* Opcode:  0x7
		* <b>cles</b> rA, rB, rC
			* Opcode:  0x8
		* <b>cgts</b> rA, rB, rC
			* Opcode:  0x9
<br><br>
* Opcode Group:  0b0101
	* Encoding:  `0101 aaaa bbbb cccc  iiii iiii iiii oooo`
		* `a`:  rA
		* `b`:  rB
		* `c`:  rC
		* `i`:  sign-extended 12-bit immediate
		* `o`:  opcode
	* Instructions:
		* <b>ldr</b> rA, [rB, rC]
			* Opcode:  0b0000
		* <b>ldh</b> rA, [rB, rC]
			* Opcode:  0b0001
		* <b>ldsh</b> rA, [rB, rC]
			* Opcode:  0b0010
		* <b>ldb</b> rA, [rB, rC]
			* Opcode:  0b0011
		* <b>ldsb</b> rA, [rB, rC]
			* Opcode:  0b0100
		* <b>str</b> rA, [rB, rC]
			* Opcode:  0b0101
		* <b>sth</b> rA, [rB, rC]
			* Opcode:  0b0110
		* <b>stb</b> rA, [rB, rC]
			* Opcode:  0b0111
		* <b>ldri</b> rA, [rB, simm12]
			* Opcode:  0b1000
		* <b>ldhi</b> rA, [rB, simm12]
			* Opcode:  0b1001
		* <b>ldshi</b> rA, [rB, simm12]
			* Opcode:  0b1010
		* <b>ldbi</b> rA, [rB, simm12]
			* Opcode:  0b1011
		* <b>ldsbi</b> rA, [rB, simm12]
			* Opcode:  0b1100
		* <b>stri</b> rA, [rB, simm12]
			* Opcode:  0b1101
		* <b>sthi</b> rA, [rB, simm12]
			* Opcode:  0b1110
		* <b>stbi</b> rA, [rB, simm12]
			* Opcode:  0b1111
<br><br>
* Opcode Group:  0b0110
<br><br>
	* Encoding:  `0110 aaaa bbbb cccc  0000 0000 0000 oooo`
		* `a`:  rA
		* `b`:  rB
		* `c`:  rC
		* `o`;  opcode
	* Instructions:
		* <b>ei</b>
			* Note:  Enable interrupts
			* Opcode:  0x0
		* <b>di</b>
			* Note:  Disable interrupts
			* Opcode:  0x1
		* <b>cpy</b> ireta, rA
			* Opcode:  0x2
		* <b>cpy</b> rA, ireta
			* Opcode:  0x3
		* <b>cpy</b> idsta, rA
			* Opcode:  0x4
		* <b>cpy</b> rA, idsta
			* Opcode:  0x5
		* <b>reti</b>
			* Note:  Enable interrupts and change the program counter to the
			value contained in `ireta`
			* Opcode:  0x6
* Pseudo Instructions:
	* <b>inv</b> rA, rB
		* Encoded as <code>nor rA, rB, zero</code>
	* <b>invi</b> rA, imm16
		* Encoded as <code>nori rA, zero, imm16</code>
	* <b>cpy</b> rA, rB
		* Encoded as <code>add rA, rB, zero</code>
	* <b>cpy</b> rA, pc
		* Encoded as <code>addsi rA, pc, 0</code>
	* <b>cpyi</b> rA, imm16
		* Encoded as <code>addi rA, zero, imm16</code>
	* <b>cpya</b> rA, imm32
		* Copy absolute (32-bit immediate)
		* Encoded as 
			<br>
			<code>addi rA, zero, (imm32 & 0xffff)</code>
			<br>
			<code>cpyhi rA, (imm32 >> 16)</code>
	* <b>bra</b> simm16
		* Unconditional relative branch
		* Encoded as <code>beq zero, zero, simm16</code>
	* <b>jmp</b> rC
		* Unconditional jump to address in register
		* Encoded as <code>jeq zero, zero, rC</code>
	* <b>call</b> rC
		* Unconditional call to address in register
		* Encoded as <code>ceq zero, zero, rC</code>
	* <b>jmpa</b> imm32
		* Jump absolute (to directly encoded address)
		* Encoded as
			<br>
			<code>cpya temp, imm32</code>
			<br>
			<code>jmp temp</code>
	* <b>calla</b> imm32
		* Call absolute (to directly encoded address)
		* Encoded as
			<br>
			<code>cpya temp, imm32</code>
			<br>
			<code>call temp</code>
	* <b>jmpane</b> rA, rB, imm32
		* Conditional jump absolute (to directly encoded address)
		* Encoded as
			<br>
			<code>cpya temp, imm32</code>
			<br>
			<code>jne rA, rB temp</code>
	* <b>jmpaeq</b> rA, rB, imm32
		* Conditional jump absolute (to directly encoded address)
		* Encoded as
			<br>
			<code>cpya temp, imm32</code>
			<br>
			<code>jeq rA, rB temp</code>
	* <b>callane</b> rA, rB, imm32
		* Conditional call absolute (to directly encoded address)
		* Encoded as
			<br>
			<code>cpya temp, imm32</code>
			<br>
			<code>callne rA, rB, temp</code>
	* <b>callaeq</b> rA, rB, imm32
		* Conditional call absolute (to directly encoded address)
		* Encoded as
			<br>
			<code>cpya temp, imm32</code>
			<br>
			<code>calleq rA, rB, temp</code>
	* <b>inc</b> rA
		* Encoded as <code>addi rA, rA, 1</code>
	* <b>dec</b> rA
		* Encoded as <code>subi rA, rA, 1</code>
	* <b>alu\_op\_three\_regs</b> rA, rB
		* Encoded as <code>alu\_op\_three\_regs rA, rA, rB</code>
	* <b>alu\_op\_two\_regs\_one\_immediate</b> rA, imm16
		* Encoded as <code>alu\_op\_two\_regs\_one\_immediate rA, rA, imm16</code>
																																							