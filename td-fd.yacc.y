%{
	//#define YYDEBUG 1
	#include "stdio.h"
    void yyerror(char *);
    extern int yylineno;
    #include "y.tab.h"
	int yylex(void);
%}


// Declare the tokens
%token MAIN
%token CALL_KW PRINT_KW SCAN_KW LIST_KW//keyword related
%token NOT AND XOR OR IFF IMPLIES //logical connectives
%token CONST_TYPE VAR_TYPE CONST_ID VAR_ID CONST_CONTENT //constant-variable
%token RETURN //return 
%token IF ELSE //condition staments 
%token FOR WHILE //loop statements 
%token T_VAL //boolean
%token ASSIGN_OP EQUAL_OP //assignment and equality
%token LP RP LBRACE RBRACE LSQUARE RSQUARE STMT_TERMINATOR COMMA NUMERIC//structure related
%token STRINGNL STRING NEWLINE

%start program

%%

//-------------------------------------------------program structure-----------------------------------------------
program: MAIN LBRACE statements RBRACE;

statements: statement STMT_TERMINATOR
		  | statement STMT_TERMINATOR statements;

statement: declaration 
		 | init 
		 | expression 
		 | ifstmt 
		 | loop 
		 | predicateInstantiation
		 | listElementAssignment
		 | inhale
		 | exhale; // TO-DO

//------------------------------------------------list initialization----------------------------------------------

listInit: LIST_KW VAR_ID ASSIGN_OP LBRACE listParameterList RBRACE
		| LIST_KW VAR_ID ASSIGN_OP LBRACE  RBRACE;

listParameter: T_VAL
			 | VAR_ID 
			 | CONST_ID;

listParameterList: listParameter 
			     | listParameter COMMA listParameterList;

listElement: VAR_ID LSQUARE NUMERIC RSQUARE;

listElementAssignment: listElement ASSIGN_OP T_VAL;      
 

//-------------------------------------------------declaration-----------------------------------------------------

//predicate declaration

declaration: VAR_TYPE VAR_ID  //variable declaration
		   | predicate;  //predicate declaration

parameter:  VAR_ID;

parameterList: parameter
	         | parameter COMMA parameterList;

predicateParameterList: LP parameterList RP;

predicateName: VAR_ID ;

predicatePrototype: predicateName predicateParameterList;

predicateBody: LBRACE RETURN T_VAL STMT_TERMINATOR RBRACE
	         | LBRACE RETURN expression STMT_TERMINATOR RBRACE
			 | LBRACE RETURN predicateInstantiation STMT_TERMINATOR RBRACE
			 | LBRACE statements RETURN T_VAL STMT_TERMINATOR RBRACE
			 | LBRACE statements RETURN expression STMT_TERMINATOR RBRACE
			 | LBRACE statements RETURN predicateInstantiation STMT_TERMINATOR RBRACE;


predicate: predicatePrototype predicateBody;


//-------------------------------------------------initialization--------------------------------------------------

init: constInit | varInit | listInit;

constInit: CONST_TYPE  CONST_ID CONST_CONTENT ASSIGN_OP T_VAL
		 | CONST_TYPE  CONST_ID ASSIGN_OP T_VAL
		 | CONST_TYPE  CONST_ID CONST_CONTENT ASSIGN_OP expression
		 | CONST_TYPE CONST_ID ASSIGN_OP expression
  		 | CONST_TYPE  CONST_ID CONST_CONTENT ASSIGN_OP listElement
		 | CONST_TYPE  CONST_ID  ASSIGN_OP listElement
		 | CONST_TYPE  CONST_ID CONST_CONTENT ASSIGN_OP predicateInstantiation
		 | CONST_TYPE CONST_ID ASSIGN_OP predicateInstantiation;

varInit:   varFirstInit | varAssign

varFirstInit: VAR_TYPE VAR_ID ASSIGN_OP T_VAL
			| VAR_TYPE VAR_ID ASSIGN_OP expression
			| VAR_TYPE VAR_ID ASSIGN_OP listElement
			| VAR_TYPE VAR_ID ASSIGN_OP predicateInstantiation

varAssign: VAR_ID ASSIGN_OP T_VAL
		 | VAR_ID ASSIGN_OP expression
		 | VAR_ID ASSIGN_OP listElement
		 | VAR_ID ASSIGN_OP predicateInstantiation;



//--------------------------------------------------expression structure-------------------------------------------

//operator precedence is included 

expression: iffExpression;

iffExpression: iffExpression IFF impliesExpression 
			 | impliesExpression;

impliesExpression: orExpression IMPLIES impliesExpression 
			     | orExpression;

orExpression: orExpression OR xorExpression
			| xorExpression;

xorExpression: xorExpression XOR andExpression 
			 | andExpression;

andExpression : andExpression AND notExpression 
			  | notExpression;

notExpression : NOT paranthesisExpression 
			  | paranthesisExpression;

paranthesisExpression: LP iffExpression RP 
					 | LP id RP
					 | LP predicateInstantiation RP
					 | LP T_VAL RP;

id: VAR_ID
  | CONST_ID;

//--------------------------------------------------decision(selection)-------------------------------------------

ifstmt: noElse 
	  | yesElse;

noElse: IF LP condition RP noElse ELSE noElse
      | LBRACE statements RBRACE ;

yesElse: IF LP condition RP LBRACE statements RBRACE
       | IF LP condition RP noElse ELSE yesElse;

//--------------------------------------------------condition-----------------------------------------------------

condition: VAR_ID EQUAL_OP expression
	 	 | CONST_ID EQUAL_OP expression;

//--------------------------------------------------loop structure (for and while)--------------------------------

loop: for 
	| while;

for: FOR LP varInit STMT_TERMINATOR condition STMT_TERMINATOR RP LBRACE statements RBRACE;

while: WHILE LP condition RP LBRACE statements RBRACE;

//--------------------------------------------------predicate instantiation---------------------------------------

predicateInstantiation: CALL_KW predicateName predicateParameterList;

//--------------------------------------------------I/O-----------------------------------------------------------

inhale: SCAN_KW LP VAR_ID COMMA T_VAL RP
	  | SCAN_KW LP CONST_TYPE COMMA CONST_ID COMMA T_VAL RP
	  | SCAN_KW LP CONST_TYPE COMMA CONST_ID COMMA CONST_CONTENT COMMA  T_VAL RP
	  | SCAN_KW LP listElement COMMA T_VAL RP;


exhale: PRINT_KW LP expression RP
      | PRINT_KW LP STRINGNL RP;
%%

// report errors
void yyerror(char *s) 
{
  fprintf(stderr, "syntax error at line: %d %s\n", yylineno, s);
}

int main(void){
	//#if YYDEBUG
	//	yydebug = 1;
	//#endif
	yyparse();
	if(yynerrs < 1) printf("there are no syntax errors!!\n");
}
