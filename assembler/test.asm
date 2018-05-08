.org 0x9000000a
aaa:
	.db16 -8

.org 0x9000
.db 0xabcd
.db aaa

some_global_var:
.space 0x20


some_extra_data:
.db 0xcafe,0xface9001
.db some_extra_data

.org 9000
r0:
.db r0
