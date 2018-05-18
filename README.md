# Frost32 CPU
My first attempt at a pipelined CPU, being implemented in SystemVerilog.

There's a three-stage pipeline:  
    Instruction Decode -> Execute -> Write Back

## Instructions that take more than one cycle
Relative branches take two cycles, and jumps and calls take three cycles.
`reti` is the exception to this, as it take t

<!--
Multiplications are single-cycle, but only produce 32-bit results.
-->

Multiplications (once fully implemented) will also take more than one than
one cycle, but it isn't clear yet exactly how many cycles they will take.

Conditions are resolved in the instruction decode stage, and the
instruction decode stage **also** handles all memory access.

Loads and stores take three cycles each.


# The Assembler
The assembler is written in C++ and uses ANTLR for the parser generator and
visitor generator.

Also note that the assembler generates Verilog VMEM format data for use
with `readmemh()`.

Another thing of interest is that the assembler **does** let you use
instruction names, register names, etc. as symbols (such as labels).

Directives:  `.org`, `.space`, `.db`, `.db16`, and `.db8`
* `.org`:  change the program counter to an expression
* `.space`:  add the value of an expression to the program counter
* `.db`:  comma-separated list of 32-bit integers (actually expressions)
* `.db16`:  comma-separated list of 16-bit integers (actually expressions)
* `.db8`:  comma-separated list of 8-bit integers (actually expressions)

# The Disassembler
There's also a really basic disassembler (doesn't try to recreate labels,
for example), but it does at least show **most** invalid instructions as
".db".

Since the disassembler is mainly intended for debugging the assembler, it
still actually decodes some technically invalid instructions as legitimate
ones (the `0000 0000 0000` field of instructions of some instruction
opcodes groups is completely ignored in the disassembly
process, except for immediate indexed loads and stores of opcode group 5).

Also note that the input to the disassembler is expected to be Verilog VMEM
format text, which is the same as what the assembler generates.
