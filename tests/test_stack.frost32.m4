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
	// Assume top of available memory is here
	cpya sp, 0xffff			; 0x0

	subi sp, 20				; 0x4
	cpyi u0, 9				; 0x8

	stri u0, [sp, 0]		; 0xc
	inc u0					; 0x10
	stri u0, [sp, 4]		; 0x14
	inc u0
	stri u0, [sp, 8]

	ldri u1, [sp, 0]
	ldri u2, [sp, 4]
	ldri u3, [sp, 8]

	add u4, u2, u3

	cpyi u0, 6
	cpyi u1, 5
	mul u0, u1

	cpya u3, 0x9999aaaa
	;muli u2, u3, 0x9000bbbb
	cpya temp, 0x9000bbbb
	mul u2, u3, temp

	WAIT()


	addi sp, 20
	jmpa quit
}

.org 0x8000
data_0:
	.space 20

data_1:
	.space 20

.org 0xc000
quit:
{
	WAIT()
}
