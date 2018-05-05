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
    * ``r0`` (always zero), ``r1``, ``r2``, ``r3``, 
    ``r4``, ``r5``, ``r6``, ``r7``,
    ``r8``, ``r9``, ``r10``, ``r11``,
    ``r12``, ``lr``, ``fp``, ``sp``
* Special Purpose Registers (32-bit)
    * ``pc``
<br>
<br>
* Instructions
    * Encoding:  ``oooo aaaa bbbb cccc  iiii iiii iiii iiii``
        * ``o``:  Opcode
        * ``a``:  rA
        * ``b``:  rB
        * ``c``:  rC
        * ``i``:  16-bit immediate
* <b>add</b> rA, rB, rC
    * Opcode:  0b0000
* <b>sub</b> rA, rB, rC
    * Opcode:  0b0001
* <b>sltu</b> rA, rB, rC
    * Opcode:  0b0010
* <b>mul</b> rA, rB, rC
    * Opcode:  0b0011
* <b>and</b> rA, rB, rC
    * Opcode:  0b0100
* <b>nor</b> rA, rB, rC
    * Opcode:  0b0101
* <b>inv</b> rA, rB
    * Opcode:  0b0110
* <b>lsl</b> rA, rB, rC
    * Opcode:  0b0111
* <b>lsr</b> rA, rB, rC
    * Opcode:  0b1000
* <b>addsi</b> rA, rB, simm16
    * Opcode:  0b1001
* <b>addsi</b> rA, pc, simm16
    * Opcode:  0b1010
* <b>cpyhi</b> rA, imm16
    * Opcode:  0b1011
* <b>bne</b> rA, rB
    * Opcode:  0b1100
* <b>beq</b> rA, rB
    * Opcode:  0b1101
* <b>ldr</b> rA, rB
    * Opcode:  0b1110
* <b>str</b> rA, rB
    * Opcode:  0b1111
