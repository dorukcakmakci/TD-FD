LEX = lex
YACC = yacc -d

CC = gcc

all: parser clean

parser: y.tab.o lex.yy.o
	$(CC) -o parser y.tab.o lex.yy.o 
	./parser < td-fd.test.txt

lex.yy.o: lex.yy.c y.tab.h
lex.yy.o y.tab.o: y.tab.c

y.tab.c y.tab.h: td-fd.yacc.y
	$(YACC) -v td-fd.yacc.y

lex.yy.c: td-fd.lex.l
	$(LEX) td-fd.lex.l

clean:
	-rm -f *.o lex.yy.c *.tab.* parser *.output
