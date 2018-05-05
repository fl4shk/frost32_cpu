# Small RISC Thing Instruction Set
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
    * `r0' (always zero), `r1', `r2', `r3', 
    `r4', `r5', `r6', `r7',
    `r8', `r9', `r10', `r11',
    `r12', `lr', `fp', `sp'
* Special Purpose Registers (32-bit)
    * `pc'
<br><br>
* Instructions
    * Encoding:  `oooo aaaa bbbb cccc  iiii iiii iiii iiii'
        * `o':  Opcode
        * `a':  rA
        * `b':  rB
        * `c':  rC <b>or</b> extended opcode
        * `i':  16-bit immediate <b>or</b> extended opcode
<br><br>
* Opcode:  0b0000
    * <b>add</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x0000
    * <b>sub</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x0001
    * <b>sltu</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x0002
    * <b>slts</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x0003
    * <b>mul</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x0004
    * <b>and</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x0005
    * <b>orr</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x0006
    * <b>xor</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x0007
    * <b>inv</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0008
    * <b>lsl</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x0009
    * <b>lsr</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x000a
    * <b>asr</b> rA, rB, rC
        * Extended Opcode (Immediate Field):  0x000b
<br><br>
* Opcode:  0b0001
    * <b>addi</b> rA, rB, imm16
        * Extended Opcode (rc):  0x0
    * <b>subi</b> rA, rB, imm16
        * Extended Opcode (rc):  0x1
    * <b>sltui</b> rA, rB, imm16
        * Extended Opcode (rc):  0x2
    * <b>sltsi</b> rA, rB, simm16
        * Extended Opcode (rc):  0x3
    * <b>muli</b> rA, rB, imm16
        * Extended Opcode (rc):  0x4
    * <b>andi</b> rA, rB, imm16
        * Extended Opcode (rc):  0x5
    * <b>orri</b> rA, rB, imm16
        * Extended Opcode (rc):  0x6
    * <b>xori</b> rA, rB, imm16
        * Extended Opcode (rc):  0x7
    * <b>invi</b> rA, imm16
        * Extended Opcode (rc):  0x8
    * <b>lsli</b> rA, rB, imm16
        * Extended Opcode (rc):  0x9
    * <b>lsri</b> rA, rB, imm16
        * Extended Opcode (rc):  0xa
    * <b>asri</b> rA, rB, imm16
        * Extended Opcode (rc):  0xb
    * <b>addsi</b> rA, pc, simm16
        * Extended Opcode (rc):  0xc
    * <b>cpyhi</b> rA, imm16
        * Extended Opcode (rc):  0xd
<br><br>
* Opcode:  0b0010
    * <b>jne</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0000
    * <b>jeq</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0001
    * <b>callne</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0002
    * <b>calleq</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0003
<br><br>
* Opcode:  0b0011
    * <b>bne</b> rA, simm16
        * Extended Opcode (rc):  :  0x0
    * <b>beq</b> rA, simm16
        * Extended Opcode (rc):  :  0x1
<br><br>
* Opcode:  0b0111
    * <b>ldr</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0000
    * <b>ldh</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0001
    * <b>ldsh</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0002
    * <b>ldb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0003
    * <b>ldsb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0004
    * <b>str</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0005
    * <b>sth</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0006
    * <b>stb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0007
<br><br>
    * <b>ldria</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0010
        * Effect:  <code>ldr rA</code>
    * <b>ldhia</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0011
        * Effect:  <code>ldh rA</code>
    * <b>ldshia</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0012
        * Effect:  <code>ldsh rA</code>
    * <b>ldbia</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0013
        * Effect:  <code>ldb rA</code>
    * <b>ldsbia</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0014
        * Effect:  <code>ldsb rA</code>
    * <b>stria</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0015
        * Effect:  <code>str rA</code>
    * <b>sthia</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0016
        * Effect:  <code>sth rA</code>
    * <b>stbia</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0017
        * Effect:  <code>stb rA</code>
<br><br>
    * <b>ldrib</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0020
        * Effect:  <code>rB <= rB + 4; ldr rA</code>
    * <b>ldhib</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0021
        * Effect:  <code>rB <= rB + 2; ldh rA</code>
    * <b>ldshib</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0022
        * Effect:  <code>rB <= rB + 2; ldsh rA</code>
    * <b>ldbib</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0023
        * Effect:  <code>rB <= rB + 1; ldb rA</code>
    * <b>ldsbib</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0024
        * Effect:  <code>rB <= rB + 1; ldsb rA</code>
    * <b>strib</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0025
        * Effect:  <code>rB <= rB + 1; str rA</code>
    * <b>sthib</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0026
        * Effect:  <code>rB <= rB + 1; sth rA</code>
    * <b>stbib</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0027
        * Effect:  <code>rB <= rB + 1; stb rA</code>
    * <b>ldrib</b> rA, pc
        * Extended Opcode (Immediate Field):  0x0028
        * Effect:  <code>pc <= pc + 1; ldr rA</code>
<br><br>
    * <b>ldrda</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0030
        * Effect:  <code>ldr rA</code>
    * <b>ldhda</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0031
        * Effect:  <code>ldh rA</code>
    * <b>ldshda</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0032
        * Effect:  <code>ldsh rA</code>
    * <b>ldbda</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0033
        * Effect:  <code>ldb rA</code>
    * <b>ldsbda</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0034
        * Effect:  <code>ldsb rA</code>
    * <b>strda</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0035
        * Effect:  <code>str rA</code>
    * <b>sthda</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0036
        * Effect:  <code>sth rA</code>
    * <b>stbda</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0037
        * Effect:  <code>stb rA</code>
<br><br>
    * <b>ldrdb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0040
        * Effect:  <code>rB <= rB - 4; ldr rA</code>
    * <b>ldhdb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0041
        * Effect:  <code>rB <= rB - 2; ldh rA</code>
    * <b>ldshdb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0042
        * Effect:  <code>rB <= rB - 2; ldsh rA</code>
    * <b>ldbdb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0043
        * Effect:  <code>rB <= rB - 1; ldb rA</code>
    * <b>ldsbdb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0044
        * Effect:  <code>rB <= rB - 1; ldsb rA</code>
    * <b>strdb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0045
        * Effect:  <code>rB <= rB - 1; str rA</code>
    * <b>sthdb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0046
        * Effect:  <code>rB <= rB - 1; sth rA</code>
    * <b>stbdb</b> rA, rB
        * Extended Opcode (Immediate Field):  0x0047
        * Effect:  <code>rB <= rB - 1; stb rA</code>
