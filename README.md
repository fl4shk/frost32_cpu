# Frost32 CPU
My first attempt at a pipelined CPU, being implemented in SystemVerilog.

There's a four-stage pipeline:
    Instruction fetch -> Instruction decode -> Execute -> Write Back

The processor reaches about 96 MHz in the worst case temperature (85
degrees C) in my Cyclone IV FPGA, but can potentially run more quickly than
that if the FPGA isn't at a high temperature (in practice it seems to work
at 100 MHz).


## Stuff that takes more than one cycle
  * Relative branches take three cycles, and jumps and calls take four
  cycles.  All relative branches, jumps, and calls are conditional.
  * `reti` takes two cycles.
  * `cpy`ing a register into `ireta` or `idsta` takes three cycles
  * Loads and stores take four cycles each (this is something I wish to
  possibly change since loads and stores don't change the program
  counter.   Hence, I can at least *fetch* the instruction following the
  load or store, at the risk of making self modifying code take slightly
  more effort to figure out whether or not it will work).
  * Multiplication:  32-bit by 32-bit -> 32-bit results, 5 cycles.  (Need
  to add in 32-bit by 32-bit -> 64-bit results multiply)
  * Division:  32-bit by 32-bit -> 32-bit results
    * Note that there is both unsigned and signed division, computed by the
    same division module.  There is not an integer remainder instruction,
    but a multiplication can be performed to get the remainder.
    * Of note is that division by zero will simply return zero.  Software
    will need to check if division by zero is going to occur. 
    * Number of cycles:
      * When 32-bit division is *very* fast (four bits computed per cycle,
      at the expense of lowered clock rate and increased logic usage):
      13 cycles
      * When 32-bit division is fast (two bits computed per cycle, the
      default):  21
      cycles
      * When 32-bit division is slow (one bit computed per cycle):  37 
      cycles


## Interrupts
Responding to an interrupt takes two cycles due to synchronous reads from
memory, and also the processor will not respond to interrupts when it is
in the middle of performing an instruction that stalls.  This may become an
option later; it would be feasible to just force the processor to flush the
pipeline when an interrupt happens.

Right now there is only one interrupt pin.

The destination to jump to upon an interrupt happening has a special
register:  `idsta`.
The destination to return to upon an interrupt happening also has a special
register:  `ireta`.
These registers may be copied to/from registers in the register file such
that nested interrupts may be performed, or if interrupts aren't needed,
`idsta` and `ireta` can be used for extra storage space.

When the processor starts, interrupts are disabled, and can be enabled with
the `ei` instruction.  Interrupts can be disabled with the `di`
instruction.  
Also, upon responding to an interrupt, interrupts become
disabled.
`reti`, the return from interrupt instruction, enables
interrupts again.

A second set of registers is being considered to be added for faster
interrupt processing.t


## Cycle timings
Conditional branches were intended to take very few cycles without the need
for a branch predictor of any sort, and they only take three cycles.

In general, an individual instruction is intended to take a static number
of cycles to facilitate easy clock cycle counting algorithms like the
processors of ye olden days.

This is also a reason for not having a branch predictor, though a static
branch predictor could still potentially permit easy clock cycle counting
algorithms.

For this reason, static branch prediction is still a potential addition,
but dynamic branch prediction is most likely not happening.


## Plans
Split instruction cache and data cache are of interest to be added.  These
caches would be direct-mapped, and the data cache would likely be
write-through.

Also, to facilitate self-modifying code, writes to memory would actually
affect the instruction cache if the write affects an data that is in
instruction cache.

Additionally, support of 64-bit by 64-bit -> 64-bit divides is a possible
addition as well.


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
