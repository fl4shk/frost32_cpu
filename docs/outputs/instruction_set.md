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
	* ``zero`` (always zero), ``u0``, ``u1``, ``u2``, 
	``u3``, ``u4``, ``u5``, ``u6``,
	``u7``, ``u8``, ``u9``, ``u10``,
<br>
	``temp`` (assembler temporary (but can be used otherwise)), 
<br>
	``lr`` (upon any call instruction, return address stored here), 
<br>
	``fp`` (recommended for use as the frame pointer), 
<br>
	``sp`` (recommended for use as the stack pointer)
* Special Purpose Registers (32-bit)
	* ``pc`` (program counter)
<br><br>
* Opcode Group:  0b0000
	* Encoding:  ``0000 aaaa bbbb cccc  0000 0000 0000 oooo``
		* ``a``:  rA
		* ``b``:  rB
		* ``c``:  rC
		* ``o``:  opcode
	* Instructions:
		* <b>add</b> rA, rB, rC
			* Opcode:  0b0000
		* <b>sub</b> rA, rB, rC
			* Opcode:  0b0001
		* <b>sltu</b> rA, rB, rC
			* Opcode:  0b0010
		* <b>slts</b> rA, rB, rC
			* Opcode:  0b0011
		* <b>mul</b> rA, rB, rC
			* Opcode:  0b0100
		* <b>and</b> rA, rB, rC
			* Opcode:  0b0101
		* <b>orr</b> rA, rB, rC
			* Opcode:  0b0110
		* <b>xor</b> rA, rB, rC
			* Opcode:  0b0111
		* <b>nor</b> rA, rB, rC
			* Opcode:  0b1000
		* <b>lsl</b> rA, rB, rC
			* Opcode:  0b1001
		* <b>lsr</b> rA, rB, rC
			* Opcode:  0b1010
		* <b>asr</b> rA, rB, rC
			* Opcode:  0b1011
<br><br>
* Opcode Group:  0b0001
	* Encoding:  ``0001 aaaa bbbb oooo  iiii iiii iiii iiii``
		* ``a``:  rA
		* ``b``:  rB
		* ``o``:  opcode
		* ``i``:  16-bit immediate
	* Instructions:
		* <b>addi</b> rA, rB, imm16
			* Opcode:  0x0
		* <b>subi</b> rA, rB, imm16
			* Opcode:  0x1
		* <b>sltui</b> rA, rB, imm16
			* Opcode:  0x2
		* <b>sltsi</b> rA, rB, simm16
			* Opcode:  0x3
		* <b>muli</b> rA, rB, imm16
			* Opcode:  0x4
		* <b>andi</b> rA, rB, imm16
			* Opcode:  0x5
		* <b>orri</b> rA, rB, imm16
			* Opcode:  0x6
		* <b>xori</b> rA, rB, imm16
			* Opcode:  0x7
		* <b>nori</b> rA, rB, imm16
			* Opcode:  0x8
		* <b>lsli</b> rA, rB, imm16
			* Opcode:  0x9
		* <b>lsri</b> rA, rB, imm16
			* Opcode:  0xa
		* <b>asri</b> rA, rB, imm16
			* Opcode:  0xb
		* <b>addsi</b> rA, pc, simm16
			* Opcode:  0xc
		* <b>cpyhi</b> rA, imm16
			* Opcode:  0xd
		* <b>bne</b> rA, rB, simm16
			* Opcode:  0xe
		* <b>beq</b> rA, rB, simm16
			* Opcode:  0xf
<br><br>
* Opcode Group:  0b0010
	* Encoding:  ``0b0010 aaaa bbbb cccc  0000 0000 0000 oooo``
		* ``a``:  rA
		* ``b``:  rB
		* ``c``:  rC
		* ``o``:  opcode
	* Instructions:
		* <b>jne</b> rA, rB, rC
			* Opcode:  0b0000
		* <b>jeq</b> rA, rB, rC
			* Opcode:  0b0001
		* <b>callne</b> rA, rB, rC
			* Opcode:  0b0010
		* <b>calleq</b> rA, rB, rC
			* Opcode:  0b0011
<br><br>
* Opcode Group:  0b0011
	* Encoding:  ``0b0011 aaaa bbbb cccc  0000 0000 0000 oooo``
		* ``a``:  rA
		* ``b``:  rB
		* ``c``:  rC
		* ``o``:  opcode
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
<br><br>
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
		* Encoded as <code>calleq zero, zero, rC</code>
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
																																							