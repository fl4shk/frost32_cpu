# Frost32 CPU
My first attempt at a pipelined CPU, being implemented in
[MyHDL](http://myhdl.org/).


# The Assembler
The assembler is written in C++ and uses ANTLR for the parser generator and
visitor generator.

Also note that the assembler generates Verilog VMEM format data for use
with ``readmemh()``.

Another thing of interest is that the assembler does let you use
instruction names, register names, etc. as symbols (such as labels).

Directives:  ``.org``, ``.space``, ``.db``, ``.db16``, and ``.db8``

# The Disassembler
There's also a really basic disassembler (doesn't try to recreate labels,
for example), but it does at least show **most** invalid instructions as
".db".

Since the disassembler is mainly intended for debugging the assembler, it
still actually decodes some technically invalid instructions as legitimate
ones (the ``0000 0000 0000`` field of instructions from instruction opcodes
groups 0, 2, and 3 is completely ignored in the disassembly process).
