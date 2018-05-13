define(`WAIT', 
`	; Wait for a sufficient amount of time (test value forwarding)'
`	add zero, zero, zero'
`	add zero, zero, zero'
`	add zero, zero, zero'
`	add zero, zero, zero')dnl
dnl
define(`HALT_SIM',
`	; Four "add zero, u0, u1"'s in a row means "end the simulation"'
`	add zero, u0, u1'
`	add zero, u0, u1'
`	add zero, u0, u1'
`	add zero, u0, u1')dnl
dnl
.org 0x0000
main:
{
	; Set stack pointer to (assumed) top of RAM
	; (assume actual memory size is 0x10000 bytes)
	cpyi sp, 0xffff

	cpyi u0, 1
	cpyi u1, 2
	cpyi u3, 0
	cpyi u4, 0
	cpyi u5, 0
	cpyi u6, 0

	cpyi u7, good - .


	; u3 should have 4 in it if we're good
	cpyi u7, 4

	WAIT()


	; Test value forwarding
	add u2, u0, u1
	add u3, u2, u0

	; u3 should now have 4 in it


	WAIT()


	; Compare u3 to 4
	;subi u4, u3, 4
	sub u4, u3, u7

	WAIT()

	bne u4, zero, fail

good:
	cpyi u5, 0x9001
	bra done

fail:
	cpyi u5, 0x9002


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
