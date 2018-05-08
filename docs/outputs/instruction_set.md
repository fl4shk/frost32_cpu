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
    * CODE(pc)
NEWLINE()NEWLINE()
* Instructions
    * Encoding:  ``gggg aaaa bbbb cccc  iiii iiii iiii iiii``
        * ``g``:  Opcode Group
        * ``a``:  rA
        * ``b``:  rB
        * ``c``:  rC BOLD(or) opcode
        * ``i``:  16-bit immediate BOLD(or) opcode
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0000)
    * BOLD(add) rA, rB, rC
        * OP_IMMFIELD(0x0000)
    * BOLD(sub) rA, rB, rC
        * OP_IMMFIELD(0x0001)
    * BOLD(sltu) rA, rB, rC
        * OP_IMMFIELD(0x0002)
    * BOLD(slts) rA, rB, rC
        * OP_IMMFIELD(0x0003)
    * BOLD(mul) rA, rB, rC
        * OP_IMMFIELD(0x0004)
    * BOLD(and) rA, rB, rC
        * OP_IMMFIELD(0x0005)
    * BOLD(orr) rA, rB, rC
        * OP_IMMFIELD(0x0006)
    * BOLD(xor) rA, rB, rC
        * OP_IMMFIELD(0x0007)
    * BOLD(inv) rA, rB
        * OP_IMMFIELD(0x0008)
    * BOLD(lsl) rA, rB, rC
        * OP_IMMFIELD(0x0009)
    * BOLD(lsr) rA, rB, rC
        * OP_IMMFIELD(0x000a)
    * BOLD(asr) rA, rB, rC
        * OP_IMMFIELD(0x000b)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0001)
    * BOLD(addi) rA, rB, imm16
        * OP_RC(0x0)
    * BOLD(subi) rA, rB, imm16
        * OP_RC(0x1)
    * BOLD(sltui) rA, rB, imm16
        * OP_RC(0x2)
    * BOLD(sltsi) rA, rB, simm16
        * OP_RC(0x3)
    * BOLD(muli) rA, rB, imm16
        * OP_RC(0x4)
    * BOLD(andi) rA, rB, imm16
        * OP_RC(0x5)
    * BOLD(orri) rA, rB, imm16
        * OP_RC(0x6)
    * BOLD(xori) rA, rB, imm16
        * OP_RC(0x7)
    * BOLD(invi) rA, imm16
        * OP_RC(0x8)
    * BOLD(lsli) rA, rB, imm16
        * OP_RC(0x9)
    * BOLD(lsri) rA, rB, imm16
        * OP_RC(0xa)
    * BOLD(asri) rA, rB, imm16
        * OP_RC(0xb)
    * BOLD(addsi) rA, pc, simm16
        * OP_RC(0xc)
    * BOLD(cpyhi) rA, imm16
        * OP_RC(0xd)
    * BOLD(bne) rA, simm16
        * OP_RC(0xe)
    * BOLD(beq) rA, simm16
        * OP_RC(0xf)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0010)
    * BOLD(jne) rA, rB
        * OP_IMMFIELD(0x0000)
    * BOLD(jeq) rA, rB
        * OP_IMMFIELD(0x0001)
    * BOLD(callne) rA, rB
        * OP_IMMFIELD(0x0002)
    * BOLD(calleq) rA, rB
        * OP_IMMFIELD(0x0003)
NEWLINE()NEWLINE()
* OPCODE_GROUP(0b0011)
    * BOLD(ldr) rA, rB
        * OP_IMMFIELD(0x0000)
    * BOLD(ldh) rA, rB
        * OP_IMMFIELD(0x0001)
    * BOLD(ldsh) rA, rB
        * OP_IMMFIELD(0x0002)
    * BOLD(ldb) rA, rB
        * OP_IMMFIELD(0x0003)
    * BOLD(ldsb) rA, rB
        * OP_IMMFIELD(0x0004)
    * BOLD(str) rA, rB
        * OP_IMMFIELD(0x0005)
    * BOLD(sth) rA, rB
        * OP_IMMFIELD(0x0006)
    * BOLD(stb) rA, rB
        * OP_IMMFIELD(0x0007)
