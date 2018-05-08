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
