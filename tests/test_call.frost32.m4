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
	cpya sp, 0xffff

	;bra quit

	calla test_subroutine

	;;cpya u0, (test_subroutine & 0xffff)
	;;addi u0, test_subroutine
	;cpyi u0, test_subroutine
	;call u0

	jmpa quit
	;cpyi u1, quit
	;jmp u1
}

test_subroutine:
{
preserve:
	; Preserve lr, u0, u1, u2, u3
	subi sp, 24
	stri lr, [sp, 4]

	stri u0, [sp, 8]
	stri u1, [sp, 12]
	stri u2, [sp, 16]
	stri u3, [sp, 20]


pre_loop:
	cpya u0, data_0
	cpyi u1, 0
	cpyi u3, 70

loop:
	str u3, [u0, u1]
	inc u1

	inc u3

	sltui u2, u1, 20
	bne u2, zero, loop

restore:
	; Restore lr, u4, u5, u6, u7
	ldri lr, [sp, 4]
	ldri u0, [sp, 8]
	ldri u1, [sp, 12]
	ldri u2, [sp, 16]
	ldri u3, [sp, 20]
	addi sp, 24

return:
	jmp lr
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
