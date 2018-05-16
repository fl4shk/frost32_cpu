define(`WAIT', 
`	; Wait for a sufficient amount of time (test value forwarding)'
`	add zero, zero, zero'
`	add zero, zero, zero'
`	add zero, zero, zero'
`	add zero, zero, zero')dnl
dnl
dnl
.org 0x0000
main:
{
	cpyi u0, 5
	cpyi u1, 7
	add u2, u0, u1


	calla test_subroutine

	WAIT()

	jmpa quit
}

test_subroutine:
{
	jmp lr
}

.org 0x8000
quit:
{
	WAIT()
}
