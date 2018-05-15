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

	;;subi u6, u6, 17
	;;addi u5, u6, 1

	cpyi u0, 0x50
	cpy u1, u0

loop:
	;addi u1, u1, 1
	addi u1, 1
	;inc u1
	
	;subi u0, u0, 1
	;dec u0
	subi u0, 1
	bne u0, zero, loop
}

quit2:
{
	;cpya u4, 0x9000
	;cpyi u4, 0x9000
	;cpyhi u4, 0x0000
	;cpya u4, 0x9000
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
