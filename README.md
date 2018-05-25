# Frost32 CPU
My first attempt at a pipelined CPU, being implemented in SystemVerilog.

There's a four-stage pipeline:
    Instruction fetch -> Instruction decode -> Execute -> Write Back

The processor reaches nearly 100 MHz in the worst case temperature in my
Cyclone IV FPGA.

## Instructions that take more than one cycle
    * Relative branches take three cycles, and jumps and calls take four
    cycles.  
    * `reti` takes two cycles.
    * `cpy`ing a register
    * Loads and stores take four cycles each.


## Interrupts
Right now there is only one interrupt pin.

The destination to jump to upon an interrupt happening has a special
register:  `idsta`.  The destination to return to upon an interrupt
happening also has a special register:  `ireta`.

When the processor starts, interrupts are disabled.

A second set of registers is being considered to be added for faster
interrupt processing.

Responding to an interrupt takes two cycles due to synchronous reads from
memory, and also the processor will not respond to interrupts when it is in
a stalling instruction.

## Cycle timings
Conditional branches were intended to take very few cycles without the need
for a branch predictor of any sort, and they only take two cycles.

In general, an individual instruction is intended to take a static number
of cycles to facilitate easy clock cycle counting algorithms like the
processors of ye olden days.

This is also a reason for not having a branch predictor, though a static
branch predictor could still potentially permit easy clock cycle counting
algorithms.

For this reason, static branch prediction is still a potential addition,
but dynamic branch prediction is most likely not happening.


## Plans
It's planned for an optional five-stage pipeline to be usable in the
future, with an instruction fetch stage to be added.  This extra stage
would add one cycle of latency to conditional branches, jumps, and calls,
but perhaps not to loads and stores.

It's planned for loads and stores at the very least to be able to take only
three cycles even with the four-stage pipeline, which requires a change to
the stalling logic.  It's planned for loads and stores to also take only three
cycles in the five stage pipeline as well.

The stalling logic currently prevents even just fetching new instructions,
which could be changed for loads and stores in particular.

Integer division is being considered as I've written some modules for that
previously that I could easily include, though it would be preferable to 

Due to the bus architecture, if a cache is added (quite likely), it will
probably be shared instruction and data cache.  It would likely have
asynchronous reads because doing so would permit not needing an instruction
fetch stage in the pipeline.
If a cache is added, special load and store instructions that bypass cache
(access memory directly) will be added so that memory mapped input and
output could still be used.

## Buses
This is essentially a pure von Neumann architecture, with the caveat that
data input and data output happen on two separate buses, but there is only
one data input bus.  There is also only one address bus.


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
