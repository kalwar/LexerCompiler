%{
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include "prj.h"

int error_num=0;  /* Number of erros */
extern int linenumber;

int strnumber=0; /* number of strings in the table*/
int varnumber=0; /* Variables for generating temporary variables ... */
int labelnumber=0; /* ... and labels */
int repeat=-1;/* shows how many inside repeat loops were created */
int iflb=-1;/* shows how many inside if statements were created */
int thenlb=-1;/* shows how many inside then statements were created */
int addlab=0;/*shows which construction added last label 
0 - nobody, 1 - repeat, 2 - while , 3 - if*/
char* lastlabel;

FILE *out;

%}

%union { argumentnode arg; labelnode lbl; }

%start program

%token T_PROGRAM T_VAR T_BEGIN T_END 
%token T_INTEGER
%token <arg> T_INTEGER_NUM 
%token T_IF T_THEN
%token <lbl> T_WHILE 
%token T_DO T_REPEAT T_UNTIL
%token T_WRITE T_WRITELN
%token <arg> T_STRING
%token <arg> T_VARIABLE
%token T_DIV T_GE T_LE T_NE
%token T_ASSIGN

%type  <arg> expression
%type  <lbl> afterif

%nonassoc IFX
%nonassoc T_ELSE

%left T_GE T_LE T_EQ '=' '>' '<'
%left '+' '-'
%left '*' T_DIV

%%
program : head_block ';' var_block main_block '.'
	| error {		
		error_num++;
		printf("error #%d line %d:Bad program syntax\n",error_num,linenumber);
	} 
	;
 
head_block : T_PROGRAM T_VARIABLE '(' parameter_list ')'
	| T_PROGRAM T_VARIABLE
	; 

parameter_list : variable_list;

variable_list : T_VARIABLE
	| variable_list ',' T_VARIABLE
	;

var_block : T_VAR var_list ';'
	|
	;

var_list: var_list ';' variable_list ':' T_INTEGER
	| variable_list ':' T_INTEGER
	;

main_block : compound_statement
	;


compound_statement : T_BEGIN statement_list T_END
	;
	
optsemicolon: ';'
|
;
	
statement_list : statement_list1
	;

statement_list1 : statement_list1 ';' statement
	| statement	
	| error {
		error_num++;
		printf("error #%d line %d:Bad statement syntax\n",error_num,linenumber);
	}
	;
	


statement :T_VARIABLE T_ASSIGN expression	{
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($3)); 
		fprintf(out, "\tmovl\t%%eax, %s\n", $1.argument.symbol);

		 /*makequad(TAC_ASS, $3, -1, $1);*/}
	| repeat_st 
	| while_st 
	| if_st 
	| write_st 
	| writeln_st
	| compound_statement
	| optsemicolon
	;		 

repeat_st : T_REPEAT {
		addlab=1;
		repeat++;
		repeatlabels[repeat]=newlabel();
		fprintf(out, "%s:\n", repeatlabels[repeat]);
		
		/*$1 = add_label();
		makequad(TAC_LBL, add_label(), -1, -1);*/
	}
	statement_list T_UNTIL comparison
	;

while_st : T_WHILE {
		addlab=2;
		$1.beginlabel=newlabel();
		$1.endlabel=newlabel();
		fprintf(out, "%s:\n", $1.beginlabel);

		/*$1 = add_label();  Start label 
		add_label(); 	 End label 
		makequad(TAC_LBL, $1, -1, -1);*/
	} 
	comparison T_DO statement {
		fprintf(out, "\tjmp\t%s\n", $1.beginlabel);	
		fprintf(out, "%s:\n", $1.endlabel);
	
		/*makequad(TAC_JMP, $1, -1, -1);
		makequad(TAC_LBL, $1+1, -1, -1);*/
	}
	;

if_st: T_IF afterif comparison T_THEN statement afterthen %prec IFX afterthen1
	| T_IF afterif comparison  T_THEN statement afterthen T_ELSE statement afterelse
	; 

afterif:	{
			addlab=3;
			iflb++;
			iflabels[iflb]=newlabel();
			
			/*add_label();*/}
afterthen:	{
			thenlb++;
			thenlabels[thenlb]=newlabel();
			fprintf(out, "\tjmp\t%s\n", thenlabels[thenlb]);
			fprintf(out, "%s:\n", iflabels[iflb]);
			iflb--;
			
			/*makequad(TAC_JMP, add_label(), -1, -1);
			makequad(TAC_LBL, gettoplabel(2), -1, -1);*/}
afterthen1:	{ 
			fprintf(out, "%s:\n", thenlabels[thenlb]);
			thenlb--;
			/*makequad(TAC_LBL, gettoplabel(1), -1, -1);*/}
afterelse:	{ 
			fprintf(out, "%s:\n", thenlabels[thenlb]);
			thenlb--;
			/*makequad(TAC_LBL, gettoplabel(1), -1, -1);*/}

 
write_st:T_WRITE '(' T_INTEGER_NUM ')'	{
		fprintf(out, "\tpushl\t%s\n", getstrarg($3));
		fprintf(out, "\tpushl\t$param1\n");
		fprintf(out, "\tcall\tprintf\n");
		fprintf(out, "\taddl\t$8, %%esp\n");

		/* makequad(TAC_PRI, $3, -1, -1); */}
	|T_WRITE '(' T_VARIABLE ')'	{ 
		fprintf(out, "\tpushl\t%s\n", $3.argument.symbol);
		fprintf(out, "\tpushl\t$param1\n");
		fprintf(out, "\tcall\tprintf\n");
		fprintf(out, "\taddl\t$8, %%esp\n");
	
		/*makequad(TAC_PRI, $3, -1, -1); */}
	|T_WRITE '(' T_STRING ')'	{ 
		fprintf(out, "\tpushl\t%s\n", $3.argument.symbol);
		fprintf(out, "\tpushl\t$param3\n");
		fprintf(out, "\tcall\tprintf\n");
		fprintf(out, "\taddl\t$8, %%esp\n");
	
		/*makequad(TAC_PRI, $3, -1, -1); */}
	;
		
writeln_st:T_WRITELN '(' T_INTEGER_NUM ')'	{
		fprintf(out, "\tpushl\t%s\n", getstrarg($3));
		fprintf(out, "\tpushl\t$param2\n");
		fprintf(out, "\tcall\tprintf\n");
		fprintf(out, "\taddl\t$8, %%esp\n");

		/* makequad(TAC_PRI, $3, -1, -1); */}
	|T_WRITELN '(' T_VARIABLE ')'	{ 
		fprintf(out, "\tpushl\t%s\n", $3.argument.symbol);
		fprintf(out, "\tpushl\t$param2\n");
		fprintf(out, "\tcall\tprintf\n");
		fprintf(out, "\taddl\t$8, %%esp\n");
	
		/*makequad(TAC_PRI, $3, -1, -1); */}
	|T_WRITELN '(' T_STRING ')'	{ 
		fprintf(out, "\tpushl\t%s\n", $3.argument.symbol);
		fprintf(out, "\tpushl\t$param4\n");
		fprintf(out, "\tcall\tprintf\n");
		fprintf(out, "\taddl\t$8, %%esp\n");
	
		/*makequad(TAC_PRI, $3, -1, -1); */}
	;

expression : T_INTEGER_NUM
	| T_VARIABLE
	| expression '+' expression	{ 
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($1));
		fprintf(out, "\taddl\t%s, %%eax\n", getstrarg($3));	
		$$.argument.symbol=newtemp();
		$$.type=0;
		fprintf(out, "\tmovl\t%%eax, %s\n", $$.argument.symbol);
	
		/*$$ = gettemp(); makequad(TAC_ADD, $1, $3, $$); */
	}
	| expression '-' expression { 
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($1));
                fprintf(out, "\tsubl\t%s, %%eax\n", getstrarg($3));
                $$.argument.symbol=newtemp();
		$$.type=0;
                fprintf(out, "\tmovl\t%%eax, %s\n", $$.argument.symbol);
	
		/*$$ = gettemp(); makequad(TAC_SUB, $1, $3, $$);*/ }
	| expression '*' expression	{ 
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($1));
		fprintf(out, "\timull\t%s, %%eax\n", getstrarg($3));	
		$$.argument.symbol=newtemp();
		$$.type=0;
		fprintf(out, "\tmovl\t%%eax, %s\n", $$.argument.symbol);

		/*$$ = gettemp(); makequad(TAC_MUL, $1, $3, $$); */}
	| expression T_DIV expression	{ 
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($1));
		fprintf(out, "\tcdq\n");
	        fprintf(out, "\tmovl\t%s, %%ebx\n", getstrarg($3));
	        fprintf(out, "\tidiv\t%%ebx\n");
		$$.argument.symbol=newtemp();
		$$.type=0;
		fprintf(out, "\tmovl\t%%eax, %s\n", $$.argument.symbol);
	
		/*$$ = gettemp(); makequad(TAC_DIV, $1, $3, $$); */}
	| '('expression ')' 	{ $$ = $2; }
	;

comparison : expression '=' expression	{ 
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($3));
		fprintf(out, "\tcmp \t%s, %%eax\n", getstrarg($1));
		fprintf(out, "\tjne \t%s\n", getlastlabel());
	
		/*$$ = gettoplabel(1); makequad(TAC_JNE, $1, $3, $$);*/}
	| expression '>' expression	{		
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($3));
		fprintf(out, "\tcmp \t%s, %%eax\n", getstrarg($1));
		fprintf(out, "\tjge \t%s\n", getlastlabel());
	
		/*$$ = gettoplabel(1); makequad(TAC_JGE, $1, $3, $$); */}
	| expression '<' expression	{
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($3));
		fprintf(out, "\tcmp \t%s, %%eax\n", getstrarg($1));
		fprintf(out, "\tjle \t%s\n", getlastlabel());
	
		/*$$ = gettoplabel(1); makequad(TAC_JLE, $1, $3, $$); */}
	| expression T_GE expression	{
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($3));
		fprintf(out, "\tcmp \t%s, %%eax\n", getstrarg($1));
		fprintf(out, "\tjg \t%s\n", getlastlabel());
	
		/* $$ = gettoplabel(1); makequad(TAC_JG, $1, $3, $$); */}
	| expression T_LE expression	{ 
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($3));
		fprintf(out, "\tcmp \t%s, %%eax\n", getstrarg($1));
		fprintf(out, "\tjl \t%s\n", getlastlabel());
	
		/*$$ = gettoplabel(1); makequad(TAC_JL, $1, $3, $$); */}
	| expression T_NE expression	{ 
		fprintf(out, "\tmovl\t%s, %%eax\n", getstrarg($3));
		fprintf(out, "\tcmp \t%s, %%eax\n", getstrarg($1));
		fprintf(out, "\tje \t%s\n", getlastlabel());
		
		/*$$ = gettoplabel(1); makequad(TAC_JE, $1, $3, $$); */}
	;

%%
char *symlook(char *s)
{
	int i;
  
	for(i=0; i<TABSIZE; i++) 
	{
		/* is it already here? */
		if(symtable[i] && !strcmp(symtable[i], s))
			return (char*) symtable[i];

		/* is it free */
		if(!symtable[i]) 
		{
			symtable[i] = (char *)strdup(s);
			return (char*) symtable[i];
		}
		/* otherwise continue to next */
	}
	yyerror("Too many symbols");
	exit(1);        /* cannot continue */
}

int main(int argc, char *argv[])
{
	int i;
	char *asm_file;
	char *exe_file;
	yydebug=0;
	if ( argc > 1 ) 
	{
		if( freopen(argv[1],"r",stdin) == 0 ) 
		{
			perror(argv[1]);
			exit(1);
		}
	}
	
	asm_file = strdup(argv[1]);
        asm_file[strlen(asm_file)-1] = 's';
        out = fopen( asm_file, "w" );
        if(out == NULL)
                exit(1);
	
	//printf("%s\n",argv[1]);
	
	fprintf(out, "\t.text\n");
	fprintf(out, "\t.global main\n");
	fprintf(out, "main:\n");
	fprintf(out, "\tpushl\t%%ebp\n");
	fprintf(out, "\tmovl\t%%esp, %%ebp\n");
	fprintf(out, "\tpushl\t%%ebx\n");
	fprintf(out, "\tpushl\t%%esi\n");
	fprintf(out, "\tpushl\t%%edi\n");
	
	yyparse();
	
	fprintf(out, "\tpopl\t%%edi\n");
	fprintf(out, "\tpopl\t%%esi\n");
	fprintf(out, "\tpopl\t%%ebx\n");
	fprintf(out, "\tmovl\t%%ebp, %%esp\n");
	fprintf(out, "\tpopl\t%%ebp\n");
	fprintf(out, "\tret\t$0\n");
	fprintf(out, "\n\t.data\n");
	fprintf(out, "param1:\t.asciz \"%s\"\n","%d");
	fprintf(out, "param2:\t.asciz \"%s\\n\"\n","%d");
	fprintf(out, "param3:\t.asciz \"%s\"\n","%s");
	fprintf(out, "param4:\t.asciz \"%s\\n\"\n","%s");
	for (i=0; i<TABSIZE;i++)
	{
		if(symtable[i])
		fprintf(out, "%s:\t.int 0\n", symtable[i]);
	}
	for (i=0; i<TABSIZE;i++)
	{
		if(strings[i])
		{
			char tempvar[10];
			if ((snprintf(tempvar, 10, "tmpstr%d", i)) == -1)
			{
				perror("The name of an temporary variable was"
					" truncated in fuction newtemp");
				exit(-1);
			}
			fprintf(out, "%s:\t.asciz  %s\n", tempvar, strings[i]);
		}
	}
	
	fclose (out);
	
	exe_file = strdup(argv[1]);
	exe_file[strlen(exe_file)-2]='\0';
	if (execlp ("gcc", "gcc", "-o", exe_file, asm_file, (char *)0) == -1) {
	    printf("Error with execve\n");
	    exit(1);
	}	
	
	if(error_num != 0)
	{
		printf("Program has some erros!\n");
		return 0;
	}

	return 0;
}

void yyerror(char *s)
{
	fprintf(stderr, "%s\n", s);
}

/*yywrap()
{
	return(1);
}*/

char *newtemp(void)
{
	char tempvar[6];
	if ((snprintf(tempvar, 6, "_T%d", varnumber++)) == -1)
	{
		perror("The name of an temporary variable was truncated in fuction newtemp");
		exit(-1);
	}
	/* Temporary variables have to be inserted into the symbol table */
	return symlook(tempvar);
}

char *addstr(char *s)
{
	char tempvar[10];
	if ((snprintf(tempvar, 10, "$tmpstr%d", strnumber++)) == -1)
	{
		perror("The name of an temporary variable was truncated in fuction newtemp");
		exit(-1);
	}
	//strncpy(strings[strnumber-1], s+1, strlen(s)-2);
	strings[strnumber-1] = (char*)strdup(s);
	strings[strnumber-1][0]='"';
	strings[strnumber-1][strlen(s)-1]='"';
	return tempvar;
}

char *newlabel(void)
{
	char templabel[6];
	if ((snprintf(templabel, 6, "_L%d", labelnumber++)) == -1)
	{
		perror("The name of an labels was truncated in fuction newlabel");
		exit(-1);
	}
	/*labeltable[lablenumber-1] = (char *)strdup(templabel);
	return (char *)labeltable[lablenumber-1];*/
	lastlabel = (char *)strdup(templabel);
	return (char *)lastlabel;
}

char *getlastlabel(void)
{
	if(addlab>1)
	{
		return lastlabel;
	} else
	{
		repeat--;
		return repeatlabels[repeat+1];				
	}
}

/*char* gettoplabel(void)
{
	return (char *)labeltable[lablenumber-1];
}*/

char *getstrarg(argumentnode arg)
{
	char *string;
	if(arg.type)
	{//it is a number
		string = (char *)calloc(12, sizeof(char));
		/* $, an integer and '\0' should fit in 12 characters, but testing anyway */
		if ((snprintf(string, 12, "$%d", arg.argument.number)) == -1)
		{
			perror("The value of an integer was truncated in fuction getstrarg");
			exit(-1);
		}
		return string;
	}
	else
		return arg.argument.symbol;
}
