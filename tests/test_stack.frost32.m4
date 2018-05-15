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
	// Assume top of available memory is
	cpya sp, 0xffffff

	subi sp, 20
	cpyi u0, 9

	stri u0, [sp, 0]
	inc u0
	stri u0, [sp, 4]
	inc u0
	stri u0, [sp, 8]

	ldri u1, [sp, 0]
	ldri u2, [sp, 4]
	ldri u3, [sp, 8]

	add u4, u2, u3

	WAIT()


	addi sp, 20
	jmpa quit
}

.org 0x8000
data_0:
	.space 20

data_1:
	.space 20

.org 0x800000
quit:
{
	WAIT()
}
