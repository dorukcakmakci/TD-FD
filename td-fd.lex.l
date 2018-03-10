%{
	#include <stdio.h>
	#include "y.tab.h"
    void yyerror(char *);   
%}
CALL_KW			call
T_VAL			(false|true)
LETTER   		[A-Za-z]
DIGIT      		[0-9]
NUMERIC			[0-9]+
ALPHANUMERIC 		({LETTER}|{DIGIT})
stringTerminator	\*
NEWLINE			\n
STMT_TERMINATOR		\$
NOT			\!
AND			&&
XOR 			\^
OR			\|\|
STRING         		{LETTER}[{LETTER}{DIGIT} ]*
STRINGNL 		{LETTER}[{LETTER}{DIGIT} ]*{NEWLINE}
COMMA 			\,
DOUBLEQUOTE		\"
CONST_CONTENT   	\?([A-Za-z ]*)\?
HASHTAG			\#
SLASH			\/
COMMENT 		{HASHTAG}([^\n]*)(\n)
PRINT_KW		exhale
SCAN_KW			inhale
LIST_KW			list
CONST_TYPE		const
VAR_TYPE		var
RETURN 			return
IF			if
ELSE			else
FOR    			for
WHILE			while
MAIN 			start
%option yylineno
%%
{COMMA}		return COMMA;
{CALL_KW}	return CALL_KW;
{PRINT_KW}	return PRINT_KW;
{SCAN_KW}	return SCAN_KW;
{LIST_KW}	return LIST_KW;
{NOT}		return NOT;
{AND}		return AND;
{XOR}		return XOR;
{OR}		return OR;
{CONST_TYPE} 	return CONST_TYPE ;
{VAR_TYPE}	return VAR_TYPE;
{RETURN}	return RETURN;
{IF}		return IF;
{ELSE}		return ELSE;
{FOR}		return FOR;  	
{WHILE}		return WHILE;
{MAIN}		return MAIN;
{T_VAL}		return T_VAL;
\=\=		return EQUAL_OP;
\=		return ASSIGN_OP;
\(      	return LP;
\)      	return RP;
\{		return LBRACE;
\}      	return RBRACE;
\[		return LSQUARE;
\]		return RSQUARE;
\<\=\>		return IFF;
\=\>		return IMPLIES;
{STMT_TERMINATOR}		return STMT_TERMINATOR;
{NUMERIC}			return NUMERIC;
\_{LETTER}{ALPHANUMERIC}*\_   	return CONST_ID;
{LETTER}{ALPHANUMERIC}*  	return VAR_ID;
{CONST_CONTENT}	 		return CONST_CONTENT;
{STRING}	return STRING; 
{STRINGNL} 	return STRINGNL;
{COMMENT}	; // skip comments
[ \t]*	;
\n {}
%%
int yywrap(void) 
{
  return 1;
}