%{
    /* Copyright (C) 2008 Santosh Kalwar - All Rights Reserved
     * You may use, distribute and modify this code under the
     * terms of the MIT license, which unfortunately won't be
     * written for another century.
     
     /* Credits and reference from
     *  http://www.it.lut.fi/kurssit/07-08/CT20A6400/projects.html
     *  http://www.it.lut.fi/kurssit/07-08/CT20A6400/project-english.html
     * http://www.stanford.edu/class/cs143/
     * http://www.it.lut.fi/kurssit/07-08/CT20A6400/exercises.html
     * http://www.gnu-pascal.de/gpc/index.html
     */

#include <stdio.h>
#include <errno.h>
#include <stdlib.h> 
#include "prj.h"
#include "prj.tab.h"

int file_num;
int file_num_max;
char **files;
extern int errno;
int linenumber=1;

%}

%x COMMENT1 
%x COMMENT2

%% 
"(*"			BEGIN COMMENT1; 
"*)"			{printf(" Unmatching comment marks{\n"); //Pascal's Comment
                         yyterminate();}
"{"			BEGIN COMMENT2; 
"}"			{printf(" Unmatching comment marks{\n");
                         yyterminate();}
			 
[ \t]+			;//whitespaces is required to separate.

":="			{return T_ASSIGN;}
"+"			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
"-"			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
"*"			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
"DIV"			{//printf("%s :%d\n",yytext,linenumber);//Basic integer division
			return T_DIV;}

"="			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
">"			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
"<"			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
">="			{//printf("%s :%d\n",yytext,linenumber);
			return T_GE;}
"<="			{//printf("%s :%d\n",yytext,linenumber);
			return T_LE;}
"<>"			{//printf("%s :%d\n",yytext,linenumber);
			return T_NE;}
"("			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
")"			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
";"			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
":"			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
","			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
"."			{//printf("%s :%d\n",yytext,linenumber);
			return *yytext;}
			
program			{return T_PROGRAM;}
var			{return T_VAR;}
begin			{return T_BEGIN;}
end			{return T_END;}
integer			{return T_INTEGER;}
if			{return T_IF;}
then			{return T_THEN;}
else			{return T_ELSE;}
while			{return T_WHILE;}
do			{return T_DO;}
repeat			{return T_REPEAT;}
until			{return T_UNTIL;}
write			{return T_WRITE;}
writeln			{return T_WRITELN;}

[a-z]([a-z]|[0-9]|_)*	{//variables
			yylval.arg.type = 0;
			yylval.arg.argument.symbol = symlook(yytext);
			//yylval = symlook(yytext);
			return T_VARIABLE;}
[0-9]+			{//integer
			yylval.arg.type = 1;
			yylval.arg.argument.number = atoi(yytext);
			//yylval = symlook(yytext);
			return T_INTEGER_NUM;}
\'([^\'\n]|\\n|\\\')*\'	{//string
			yylval.arg.type = 2;
			yylval.arg.argument.symbol = addstr(yytext);			
			return T_STRING;}
\n			linenumber++;
.			printf("%s :%d unrecognized\n",yytext,linenumber);

<COMMENT1>"*)"		BEGIN INITIAL;
<COMMENT1>.		;
<COMMENT1>\n		linenumber++;
<COMMENT1>"(*"		{printf(" Comments inside a comment not accepted(*!\n");
			 yyterminate(); }
<COMMENT2>"}"		BEGIN INITIAL;
<COMMENT2>.		;
<COMMENT2>\n		linenumber++;

%%

/*
//Main Program to take arguments in the command prompt.
int main(int argc, char *argv[]) {
        printf("****************************************");
        printf("\nWelcome to Pascal's Lexer Part I" );
        printf("\nDisplay's line number for tokens" );
        printf("\n****************************************\n");
        file_num=1;
	fileno_max = argc;
	files = argv;		
	if ( argc > 1 ) {
		if ( (yyin = fopen(argv[file_num],"r")) == 0 ) {
			perror(argv[file_num]);
			exit(1);
		}
	}
	while( yylex() )
		;
	return 0;
}

int yywrap() {
	fclose(yyin);
	if ( ++file_num < fileno_max ) {
		if ( (yyin = fopen(files[file_num],"r")) == 0 ) {
			perror(files[file_num]);
			exit(1);
		}
		return 0;
	} else {
		return 1;
	}
}
// This is the end of the lexer part of the code.
// Comments and feedback at        santosh (dot) kalwar (at) lut (dot) fi
*/
