CC = g++ -std=c++11
all: lex.yy.c
	$(CC) lex.yy.c -ll -o mylex
lex.yy.c: dfa-nfa-simulator.l	
	lex dfa-nfa-simulator.l
remove: 
	rm mylex
	rm lex.yy.c
