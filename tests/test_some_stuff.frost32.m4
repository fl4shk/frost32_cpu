define(`WAIT', 
`	; Wait for a sufficient amount of time (test value forwarding)'
`	add zero, zero, zero'
`	add zero, zero, zero'
`	add zero, zero, zero'
`	add zero, zero, zero')dnl
dnl
.org 0x0000
main:
{
	cpyi u0, 9
	cpyi u1, 8
	cpyi u2, 7
	cpyi u3, 6
	cpyi u4, 5

	add zero, zero, zero
	add zero, zero, zero
	add zero, zero, zero
	add zero, zero, zero
	add zero, zero, zero
	add zero, zero, zero
	add zero, zero, zero
	add zero, zero, zero
	add u5, u1, u2
}
