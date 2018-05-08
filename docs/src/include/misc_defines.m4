define(`BACKTICK',`changequote(<,>)`dnl'
changequote`'')dnl
define(`MDCODE',changequote(⋀,⋁)``$1``changequote())dnl (Unicode quote characters, eh?.  There's no way I'd ever use these characters in normal text, which is why I'm using them in changequote here)
define(`CONCAT',$1$2)dnl
define(`CONCAT3',CONCAT(CONCAT($1,$2),$3))dnl
define(`CODE',CONCAT3(`<code>',$1,`</code>'))dnl
define(`BOLD',CONCAT3(`<b>',$1,`</b>'))dnl
define(`ITALIC',CONCAT3(`<i>',$1,`</i>'))dnl
define(`UNDERLINE',CONCAT3(`<u>',$1,`</u>'))dnl
define(`OPCODE_GROUP',CONCAT(`Opcode Group:  ',$1))dnl
define(`OP_IMMFIELD',CONCAT(`Opcode (Immediate Field):  ',$1))dnl
define(`OP_RC',CONCAT(`Opcode (rC Field):  ',$1))dnl
define(`NEWLINE',`<br>')dnl
