flex code.l
yacc -d code.y
gcc lex.yy.c code.tab.c -o tac -lm
./tac input.txt
