#Makefile tema LFA
#Autor: Datcu Andrei Daniel 331CC

make:
	flex tema.l && gcc lex.yy.c -o tema && rm lex.yy.c
