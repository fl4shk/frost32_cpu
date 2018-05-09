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
	* ``r0`` (always zero), ``r1``, ``r2``, ``r3``, 
	``r4``, ``r5``, ``r6``, ``r7``,
	``r8``, ``r9``, ``r10``, ``r11``,
	``r12``, ``lr``, ``fp``, ``sp``
* Special Purpose Registers (32-bit)
	* ``pc``
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
		* <b>inv</b> rA, rB
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
		* <b>invi</b> rA, imm16
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
		* <b>bne</b> rA, simm16
			* Opcode:  0xe
		* <b>beq</b> rA, simm16
			* Opcode:  0xf
<br><br>
* Opcode Group:  0b0010
	* Encoding:  ``0b0010 aaaa bbbb cccc  0000 0000 0000 oooo``
		* ``a``:  rA
		* ``b``:  rB
		* ``c``:  rC
		* ``o``:  opcode
	* Instructions:
		* <b>jne</b> rA, rB
			* Opcode:  0b0000
		* <b>jeq</b> rA, rB
			* Opcode:  0b0001
		* <b>callne</b> rA, rB
			* Opcode:  0b0010
		* <b>calleq</b> rA, rB
			* Opcode:  0b0011
<br><br>
* Opcode Group:  0b0011
	* Encoding:  ``0b0011 aaaa bbbb cccc  0000 0000 0000 oooo``
		* ``a``:  rA
		* ``b``:  rB
		* ``c``:  rC
		* ``o``:  opcode
	* Instructions:
		* <b>ldr</b> rA, [rB]
			* Opcode:  0b0000
		* <b>ldh</b> rA, [rB]
			* Opcode:  0b0001
		* <b>ldsh</b> rA, [rB]
			* Opcode:  0b0010
		* <b>ldb</b> rA, [rB]
			* Opcode:  0b0011
		* <b>ldsb</b> rA, [rB]
			* Opcode:  0b0100
		* <b>str</b> rA, [rB]
			* Opcode:  0b0101
		* <b>sth</b> rA, [rB]
			* Opcode:  0b0110
		* <b>stb</b> rA, [rB]
			* Opcode:  0b0111
<br><br>
* Pseudo Instructions:
	* <b>cpy</b> rA, rB
		* Encoded as <code>add rA, rB, r0</code>
	* <b>cpy</b> rA, pc
		* Encoded as <code>addsi rA, pc, 0</code>
	* <b>cpyi</b> rA, imm16
		* Encoded as <code>addi rA, r0, imm16</code>
	* <b>cpya</b> rA, imm32
		* Copy absolute (32-bit immediate)
		* Encoded as 
			<br>
			<code>addi rA, r0, (imm32 & 0xffff)</code>
			<br>
			<code>cpyhi rA, (imm32 >> 16)</code>
	* <b>bra</b> simm16
		* Unconditional relative branch
		* Encoded as <code>beq r0, simm16</code>
	* <b>jmp</b> rB
		* Unconditional jump to address in register
		* Encoded as <code>jeq r0, rB</code>
	* <b>call</b> rB
		* Unconditional call to address in register
		* Encoded as <code>calleq r0, rB</code>
