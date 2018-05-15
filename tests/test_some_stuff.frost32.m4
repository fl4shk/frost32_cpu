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
	dnl WAIT()

	subi u6, u6, 17
	addi u5, u6, 1

	WAIT()

	;bne u6, zero, quit

	;cpyi u7, 6
}

;infin:
;{
;	bra quit
;}

.org 0x8000
quit:
{
	WAIT()
}
