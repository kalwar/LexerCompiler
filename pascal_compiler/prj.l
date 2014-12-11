%{
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
"*)"			{printf(" Unmatching comment marks{\n");
                         yyterminate();}
"{"			BEGIN COMMENT2; 
"}"			{printf(" Unmatching comment marks{\n");
                         yyterminate();}
			 
[ \t]+			;//whitespaces

":="			{return T_ASSIGN;}
"+"			{//printf("%s :%d\n",yytext,linenumber);//calculations
			return *yytext;}
"-"			{//printf("%s :%d\n",yytext,linenumber);//calculations
			return *yytext;}
"*"			{//printf("%s :%d\n",yytext,linenumber);//calculations
			return *yytext;}
"DIV"			{//printf("%s :%d\n",yytext,linenumber);//integer division
			return T_DIV;}

"="			{//printf("%s :%d\n",yytext,linenumber);//
			return *yytext;}
">"			{//printf("%s :%d\n",yytext,linenumber);//
			return *yytext;}
"<"			{//printf("%s :%d\n",yytext,linenumber);//
			return *yytext;}
">="			{//printf("%s :%d\n",yytext,linenumber);//
			return T_GE;}
"<="			{//printf("%s :%d\n",yytext,linenumber);//
			return T_LE;}
"<>"			{//printf("%s :%d\n",yytext,linenumber);//
			return T_NE;}
"("			{//printf("%s :%d\n",yytext,linenumber);//
			return *yytext;}
")"			{//printf("%s :%d\n",yytext,linenumber);//
			return *yytext;}
";"			{//printf("%s :%d\n",yytext,linenumber);//
			return *yytext;}
":"			{//printf("%s :%d\n",yytext,linenumber);//
			return *yytext;}
","			{//printf("%s :%d\n",yytext,linenumber);//
			return *yytext;}
"."			{//printf("%s :%d\n",yytext,linenumber);//
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
<COMMENT2>"{"		{printf(" Comments inside a comment not accepted(*!\n");
			 yyterminate(); }			 
%%
