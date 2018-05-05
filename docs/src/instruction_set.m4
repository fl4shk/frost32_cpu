define(`LQ',`changequote(<,>)`dnl'
changequote`'')dnl
define(`RQ',`changequote(<,>)dnl`
'changequote`'')dnl
define(`CONCAT',$1$2)dnl
define(`CONCAT3',CONCAT(CONCAT($1,$2),$3))dnl
dnl define(`MDCODE',CONCAT3(CONCAT(LQ(),LQ()),$1,CONCAT(RQ(),RQ())))
define(`MDCODE',CONCAT3(CONCAT(``LQ()'',``LQ()''),$1,CONCAT(``RQ()'',``RQ()'')))dnl
define(`CODE',CONCAT3(`<code>',$1,`</code>'))dnl
define(`BOLD',CONCAT3(`<b>',$1,`</b>'))dnl
define(`ITALIC',CONCAT3(`<i>',$1,`</i>'))dnl
define(`UNDERLINE',CONCAT3(`<u>',$1,`</u>'))dnl
define(`EXTOP_IMMFIELD',CONCAT(`Extended Opcode (Immediate Field):  ',$1))dnl
define(`EXTOP_RC',CONCAT(`Extended Opcode (rc):  ',$1))dnl
define(`LESS',`<')dnl
define(`GREATER',`>')dnl
define(`NEWLINE',`<br>')dnl
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
    * MDCODE(r0) (always zero), MDCODE(r1), MDCODE(r2), MDCODE(r3), 
    MDCODE(r4), MDCODE(r5), MDCODE(r6), MDCODE(r7),
    MDCODE(r8), MDCODE(r9), MDCODE(r10), MDCODE(r11),
    MDCODE(r12), MDCODE(lr), MDCODE(fp), MDCODE(sp)
* Special Purpose Registers (32-bit)
    * MDCODE(pc)
<br><br>
* Instructions
    * Encoding:  MDCODE(oooo aaaa bbbb cccc  iiii iiii iiii iiii)
        * MDCODE(o):  Opcode
        * MDCODE(a):  rA
        * MDCODE(b):  rB
        * MDCODE(c):  rC BOLD(or) extended opcode
        * MDCODE(i):  16-bit immediate BOLD(or) extended opcode
<br><br>
* Opcode:  0b0000
    * BOLD(add) rA, rB, rC
        * EXTOP_IMMFIELD(0x0000)
    * BOLD(sub) rA, rB, rC
        * EXTOP_IMMFIELD(0x0001)
    * BOLD(sltu) rA, rB, rC
        * EXTOP_IMMFIELD(0x0002)
    * BOLD(slts) rA, rB, rC
        * EXTOP_IMMFIELD(0x0003)
    * BOLD(mul) rA, rB, rC
        * EXTOP_IMMFIELD(0x0004)
    * BOLD(and) rA, rB, rC
        * EXTOP_IMMFIELD(0x0005)
    * BOLD(orr) rA, rB, rC
        * EXTOP_IMMFIELD(0x0006)
    * BOLD(xor) rA, rB, rC
        * EXTOP_IMMFIELD(0x0007)
    * BOLD(inv) rA, rB
        * EXTOP_IMMFIELD(0x0008)
    * BOLD(lsl) rA, rB, rC
        * EXTOP_IMMFIELD(0x0009)
    * BOLD(lsr) rA, rB, rC
        * EXTOP_IMMFIELD(0x000a)
    * BOLD(asr) rA, rB, rC
        * EXTOP_IMMFIELD(0x000b)
<br><br>
* Opcode:  0b0001
    * BOLD(addi) rA, rB, imm16
        * EXTOP_RC(0x0)
    * BOLD(subi) rA, rB, imm16
        * EXTOP_RC(0x1)
    * BOLD(sltui) rA, rB, imm16
        * EXTOP_RC(0x2)
    * BOLD(sltsi) rA, rB, simm16
        * EXTOP_RC(0x3)
    * BOLD(muli) rA, rB, imm16
        * EXTOP_RC(0x4)
    * BOLD(andi) rA, rB, imm16
        * EXTOP_RC(0x5)
    * BOLD(orri) rA, rB, imm16
        * EXTOP_RC(0x6)
    * BOLD(xori) rA, rB, imm16
        * EXTOP_RC(0x7)
    * BOLD(invi) rA, imm16
        * EXTOP_RC(0x8)
    * BOLD(lsli) rA, rB, imm16
        * EXTOP_RC(0x9)
    * BOLD(lsri) rA, rB, imm16
        * EXTOP_RC(0xa)
    * BOLD(asri) rA, rB, imm16
        * EXTOP_RC(0xb)
    * BOLD(addsi) rA, pc, simm16
        * EXTOP_RC(0xc)
    * BOLD(cpyhi) rA, imm16
        * EXTOP_RC(0xd)
<br><br>
* Opcode:  0b0010
    * BOLD(jne) rA, rB
        * EXTOP_IMMFIELD(0x0000)
    * BOLD(jeq) rA, rB
        * EXTOP_IMMFIELD(0x0001)
    * BOLD(callne) rA, rB
        * EXTOP_IMMFIELD(0x0002)
    * BOLD(calleq) rA, rB
        * EXTOP_IMMFIELD(0x0003)
<br><br>
* Opcode:  0b0011
    * BOLD(bne) rA, simm16
        * EXTOP_RC():  0x0
    * BOLD(beq) rA, simm16
        * EXTOP_RC():  0x1
<br><br>
* Opcode:  0b0111
    * BOLD(ldr) rA, rB
        * EXTOP_IMMFIELD(0x0000)
    * BOLD(ldh) rA, rB
        * EXTOP_IMMFIELD(0x0001)
    * BOLD(ldsh) rA, rB
        * EXTOP_IMMFIELD(0x0002)
    * BOLD(ldb) rA, rB
        * EXTOP_IMMFIELD(0x0003)
    * BOLD(ldsb) rA, rB
        * EXTOP_IMMFIELD(0x0004)
    * BOLD(str) rA, rB
        * EXTOP_IMMFIELD(0x0005)
    * BOLD(sth) rA, rB
        * EXTOP_IMMFIELD(0x0006)
    * BOLD(stb) rA, rB
        * EXTOP_IMMFIELD(0x0007)
<br><br>
    * BOLD(ldria) rA, rB
        * EXTOP_IMMFIELD(0x0010)
        * Effect:  CODE(ldr rA, rB; rB <= rB + 4;)
    * BOLD(ldhia) rA, rB
        * EXTOP_IMMFIELD(0x0011)
        * Effect:  CODE(ldh rA, rB; rB <= rB + 2;)
    * BOLD(ldshia) rA, rB
        * EXTOP_IMMFIELD(0x0012)
        * Effect:  CODE(ldsh rA, rB; rB <= rB + 2;)
    * BOLD(ldbia) rA, rB
        * EXTOP_IMMFIELD(0x0013)
        * Effect:  CODE(ldb rA, rB; rB <= rB + 1;)
    * BOLD(ldsbia) rA, rB
        * EXTOP_IMMFIELD(0x0014)
        * Effect:  CODE(ldsb rA, rB; rB <= rB + 1;)
    * BOLD(stria) rA, rB
        * EXTOP_IMMFIELD(0x0015)
        * Effect:  CODE(str rA, rB; rB <= rB + 1;)
    * BOLD(sthia) rA, rB
        * EXTOP_IMMFIELD(0x0016)
        * Effect:  CODE(sth rA, rB; rB <= rB + 1;)
    * BOLD(stbia) rA, rB
        * EXTOP_IMMFIELD(0x0017)
        * Effect:  CODE(stb rA, rB; rB <= rB + 1;)
<br><br>
    * BOLD(ldrib) rA, rB
        * EXTOP_IMMFIELD(0x0020)
        * Effect:  CODE(rB <= rB + 4; ldr rA, rB;)
    * BOLD(ldhib) rA, rB
        * EXTOP_IMMFIELD(0x0021)
        * Effect:  CODE(rB <= rB + 2; ldh rA, rB;)
    * BOLD(ldshib) rA, rB
        * EXTOP_IMMFIELD(0x0022)
        * Effect:  CODE(rB <= rB + 2; ldsh rA, rB;)
    * BOLD(ldbib) rA, rB
        * EXTOP_IMMFIELD(0x0023)
        * Effect:  CODE(rB <= rB + 1; ldb rA, rB;)
    * BOLD(ldsbib) rA, rB
        * EXTOP_IMMFIELD(0x0024)
        * Effect:  CODE(rB <= rB + 1; ldsb rA, rB;)
    * BOLD(strib) rA, rB
        * EXTOP_IMMFIELD(0x0025)
        * Effect:  CODE(rB <= rB + 1; str rA, rB;)
    * BOLD(sthib) rA, rB
        * EXTOP_IMMFIELD(0x0026)
        * Effect:  CODE(rB <= rB + 1; sth rA, rB;)
    * BOLD(stbib) rA, rB
        * EXTOP_IMMFIELD(0x0027)
        * Effect:  CODE(rB <= rB + 1; stb rA, rB;)
    * BOLD(ldrib) rA, pc
        * EXTOP_IMMFIELD(0x0028)
        * Effect:  CODE(pc <= pc + 1; ldr rA, pc;)
<br><br>
    * BOLD(ldrda) rA, rB
        * EXTOP_IMMFIELD(0x0030)
        * Effect:  CODE(ldr rA, rB; rB <= rB - 4;)
    * BOLD(ldhda) rA, rB
        * EXTOP_IMMFIELD(0x0031)
        * Effect:  CODE(ldh rA, rB; rB <= rB - 2;)
    * BOLD(ldshda) rA, rB
        * EXTOP_IMMFIELD(0x0032)
        * Effect:  CODE(ldsh rA, rB; rB <= rB - 2;)
    * BOLD(ldbda) rA, rB
        * EXTOP_IMMFIELD(0x0033)
        * Effect:  CODE(ldb rA, rB; rB <= rB - 1;)
    * BOLD(ldsbda) rA, rB
        * EXTOP_IMMFIELD(0x0034)
        * Effect:  CODE(ldsb rA, rB; rB <= rB - 1;)
    * BOLD(strda) rA, rB
        * EXTOP_IMMFIELD(0x0035)
        * Effect:  CODE(str rA, rB; rB <= rB - 1;)
    * BOLD(sthda) rA, rB
        * EXTOP_IMMFIELD(0x0036)
        * Effect:  CODE(sth rA, rB; rB <= rB - 1;)
    * BOLD(stbda) rA, rB
        * EXTOP_IMMFIELD(0x0037)
        * Effect:  CODE(stb rA, rB; rB <= rB - 1;)
<br><br>
    * BOLD(ldrdb) rA, rB
        * EXTOP_IMMFIELD(0x0040)
        * Effect:  CODE(rB <= rB - 4; ldr rA, rB;)
    * BOLD(ldhdb) rA, rB
        * EXTOP_IMMFIELD(0x0041)
        * Effect:  CODE(rB <= rB - 2; ldh rA, rB;)
    * BOLD(ldshdb) rA, rB
        * EXTOP_IMMFIELD(0x0042)
        * Effect:  CODE(rB <= rB - 2; ldsh rA, rB;)
    * BOLD(ldbdb) rA, rB
        * EXTOP_IMMFIELD(0x0043)
        * Effect:  CODE(rB <= rB - 1; ldb rA, rB;)
    * BOLD(ldsbdb) rA, rB
        * EXTOP_IMMFIELD(0x0044)
        * Effect:  CODE(rB <= rB - 1; ldsb rA, rB;)
    * BOLD(strdb) rA, rB
        * EXTOP_IMMFIELD(0x0045)
        * Effect:  CODE(rB <= rB - 1; str rA, rB;)
    * BOLD(sthdb) rA, rB
        * EXTOP_IMMFIELD(0x0046)
        * Effect:  CODE(rB <= rB - 1; sth rA, rB;)
    * BOLD(stbdb) rA, rB
        * EXTOP_IMMFIELD(0x0047)
        * Effect:  CODE(rB <= rB - 1; stb rA, rB;)
