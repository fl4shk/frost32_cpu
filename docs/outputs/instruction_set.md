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
    * <code>pc</code>
<br><br>
* Instructions
    * Encoding:  ``gggg aaaa bbbb cccc  iiii iiii iiii iiii``
        * ``g``:  Opcode Group
        * ``a``:  rA
        * ``b``:  rB
        * ``c``:  rC <b>or</b> opcode
        * ``i``:  16-bit immediate <b>or</b> opcode
<br><br>
* Opcode Group:  0b0000
    * <b>add</b> rA, rB, rC
        * Opcode (Immediate Field):  0x0000
    * <b>sub</b> rA, rB, rC
        * Opcode (Immediate Field):  0x0001
    * <b>sltu</b> rA, rB, rC
        * Opcode (Immediate Field):  0x0002
    * <b>slts</b> rA, rB, rC
        * Opcode (Immediate Field):  0x0003
    * <b>mul</b> rA, rB, rC
        * Opcode (Immediate Field):  0x0004
    * <b>and</b> rA, rB, rC
        * Opcode (Immediate Field):  0x0005
    * <b>orr</b> rA, rB, rC
        * Opcode (Immediate Field):  0x0006
    * <b>xor</b> rA, rB, rC
        * Opcode (Immediate Field):  0x0007
    * <b>inv</b> rA, rB
        * Opcode (Immediate Field):  0x0008
    * <b>lsl</b> rA, rB, rC
        * Opcode (Immediate Field):  0x0009
    * <b>lsr</b> rA, rB, rC
        * Opcode (Immediate Field):  0x000a
    * <b>asr</b> rA, rB, rC
        * Opcode (Immediate Field):  0x000b
<br><br>
* Opcode Group:  0b0001
    * <b>addi</b> rA, rB, imm16
        * Opcode (rC Field):  0x0
    * <b>subi</b> rA, rB, imm16
        * Opcode (rC Field):  0x1
    * <b>sltui</b> rA, rB, imm16
        * Opcode (rC Field):  0x2
    * <b>sltsi</b> rA, rB, simm16
        * Opcode (rC Field):  0x3
    * <b>muli</b> rA, rB, imm16
        * Opcode (rC Field):  0x4
    * <b>andi</b> rA, rB, imm16
        * Opcode (rC Field):  0x5
    * <b>orri</b> rA, rB, imm16
        * Opcode (rC Field):  0x6
    * <b>xori</b> rA, rB, imm16
        * Opcode (rC Field):  0x7
    * <b>invi</b> rA, imm16
        * Opcode (rC Field):  0x8
    * <b>lsli</b> rA, rB, imm16
        * Opcode (rC Field):  0x9
    * <b>lsri</b> rA, rB, imm16
        * Opcode (rC Field):  0xa
    * <b>asri</b> rA, rB, imm16
        * Opcode (rC Field):  0xb
    * <b>addsi</b> rA, pc, simm16
        * Opcode (rC Field):  0xc
    * <b>cpyhi</b> rA, imm16
        * Opcode (rC Field):  0xd
    * <b>bne</b> rA, simm16
        * Opcode (rC Field):  0xe
    * <b>beq</b> rA, simm16
        * Opcode (rC Field):  0xf
<br><br>
* Opcode Group:  0b0010
    * <b>jne</b> rA, rB
        * Opcode (Immediate Field):  0x0000
    * <b>jeq</b> rA, rB
        * Opcode (Immediate Field):  0x0001
    * <b>callne</b> rA, rB
        * Opcode (Immediate Field):  0x0002
    * <b>calleq</b> rA, rB
        * Opcode (Immediate Field):  0x0003
<br><br>
* Opcode Group:  0b0011
    * <b>ldr</b> rA, rB
        * Opcode (Immediate Field):  0x0000
    * <b>ldh</b> rA, rB
        * Opcode (Immediate Field):  0x0001
    * <b>ldsh</b> rA, rB
        * Opcode (Immediate Field):  0x0002
    * <b>ldb</b> rA, rB
        * Opcode (Immediate Field):  0x0003
    * <b>ldsb</b> rA, rB
        * Opcode (Immediate Field):  0x0004
    * <b>str</b> rA, rB
        * Opcode (Immediate Field):  0x0005
    * <b>sth</b> rA, rB
        * Opcode (Immediate Field):  0x0006
    * <b>stb</b> rA, rB
        * Opcode (Immediate Field):  0x0007
