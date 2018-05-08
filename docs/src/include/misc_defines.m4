define(`BACKTICK',`changequote(<,>)`dnl'
changequote`'')dnl
define(`MDCODE',`changequote(⋀,⋁)``$1``dnl''''
changequote`'')dnl  This is a bit funky
define(`CONCAT',$1$2)dnl
define(`CONCAT3',CONCAT(CONCAT($1,$2),$3))dnl
