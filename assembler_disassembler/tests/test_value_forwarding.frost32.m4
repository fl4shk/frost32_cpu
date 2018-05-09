define(`WAIT', 
`	; Wait for a sufficient amount of time (test value forwarding)'
`	add r0, r0, r0'
`	add r0, r0, r0'
`	add r0, r0, r0'
`	add r0, r0, r0')dnl
dnl
define(`HALT_SIM',
`	; Four "add r0, r1, r2"'s in a row means "end the simulation"'
`	add r0, r1, r2'
`	add r0, r1, r2'
`	add r0, r1, r2'
`	add r0, r1, r2')dnl
dnl
.org 0x0000
main:
{
	; Set stack pointer to (assumed) top of RAM
	; (assume actual memory size is 0x10000 bytes)
	cpyi sp, 0xffff

	cpyi r1, 1
	cpyi r2, 2
	cpyi r4, 0
	cpyi r5, 0
	cpyi r6, 0
	cpyi r7, 0

	cpyi r8, good - .


	; r4 should have 4 in it if we're good
	cpyi r8, 4

	WAIT()


	; Test value forwarding
	add r3, r1, r2
	add r4, r3, r1

	; r4 should now have 4 in it


	WAIT()


	; Compare r4 to 4
	;subi r5, r4, 4
	sub r5, r4, r8

	WAIT()

	bne r5, fail

good:
	cpyi r6, 0x9001
	bra done

fail:
	cpyi r6, 0x9002


done:
	cpya lr, quit

	WAIT()

	jmp lr
}


quit:
{
	HALT_SIM()
	bra quit
}


.org 0x7000

; put variables in memory starting at address 0x8000 
.org 0x8000
data_0:
	.space 0x90

data_1:
	.space 0x100

asdf:
	bra asdf
