# Frost32 CPU
My first attempt at a pipelined CPU, being implemented in SystemVerilog.

There's either a three-stage or a four-stage pipeline:  
* Three-stage pipeline:
    Instruction Decode -> Execute -> Write Back
* Four-stage pipeline:
    Instruction Decode -> Register Read -> Execute -> Write Back

The four-stage pipeline is intended for use at higher clock rates, and the
three-stage pipeline is intended for use at lower clock rates and less FPGA
usage.

With the three-stage pipeline, for simplicity, multiplications are single
cycle because many FPGAs contain embedded multipliers.

Also, in that case, then for a little extra speed, the 32-bit by 32-bit ->
32-bit multiplications are constructed out of three 16-bit multiplications
and some additions.


The four-stage pipeline does not yet have multiplications implemented, but
once they are, they will have to take more than one cycle (probably will be
implemented using 8-bit multipliers, again because many FPGAs contain
built-in multipliers)

The four-stage pipeline allows somewhat higher clock rates than the
three-stage pipeline.

The original design was just the three stage pipeline.

## Instructions that take more than one cycle
* When there's a three-stage pipeline:
    * Relative branches take two cycles, and jumps and calls take three
    cycles.  (Note:  `reti` takes only one cycle).
    * Conditions are resolved in the instruction decode stage, and the
    instruction decode stage **also** handles all memory access.
    * Loads and stores take three cycles each.

* When there's a four-stage pipeline:
    * Relative branches still take two cycles, but jumps and calls take
    four cycles.  (Note:  `reti` still takes only one cycle).
    * Loads and stores take four cycles, but this may be changed to three
    cycles later (there will need to be changes to the stalling logic to
    allow for this).
    * Multiplications (once implemented) will take more than one cycle, but
    it is not yet known exactly how many cycles they will take.

## Interrupts
Right now there is only one interrupt pin.

The destination to jump to upon an interrupt happening has a special
register.

When the processor starts, interrupts are disabled.

A second set of registers is being considered to be added for faster
interrupt processing.

Interrupts do not get serviced unless the processor is not stalling, which
is perhaps a downside, but as of right now it won't 


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
