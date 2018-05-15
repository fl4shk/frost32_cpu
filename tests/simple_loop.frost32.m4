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
	cpyi u0, 0x50		; 0x0
	cpy u1, u0			; 0x4

loop:
	inc u1				; 0x8
	
	dec u0				; 0xc
	bne u0, zero, loop	; 0x10

	calla test_call		; 0x14

	bra quit			; 0x18
}

test_call:
{
	cpyi u3, 6			; 0x1c
	jmp lr				; 0x20
	;cpya u4, 0x80ab9000
	;;cpyhi u4, 0x9000

	;WAIT()

	;;bra quit
	;jmpa quit
}

.org 0x8000
quit:
{
	WAIT()
}
