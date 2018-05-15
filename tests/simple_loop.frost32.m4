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
	cpyi u0, 0x50
	cpy u1, u0

loop:
	inc u1
	
	dec u0
	bne u0, zero, loop

	bra quit
}

quit2:
{
	cpya u4, 0x80ab9000
	;cpyhi u4, 0x9000

	WAIT()

	;bra quit
	jmpa quit
}

.org 0x8000
quit:
{
	WAIT()
}
