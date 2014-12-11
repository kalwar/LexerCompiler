#ifndef _PRJ
#define _PRJ

#define TABSIZE 100 /* size of the tables */

/* Data structure for variables and numbers, type contains the 
information, if value is identifier (0) or integer constant (1). */
typedef struct
{
	/* type = 0:represents name of the variable
	   type = 1:represents integer number */
	int type;
	union
	{
		char *symbol; /* Identifiers */
		int number; /* Integer constants */
	} argument;
	char *strvalue;
} argumentnode;

/* Data stucture needed for while loops, which can have loops inside. This
can be implemented easier, when using TAC */
typedef struct 
{
	char *beginlabel;
	char *endlabel;
} labelnode;

char *symtable[TABSIZE];/* symbol table */
char *repeatlabels[TABSIZE];
char *iflabels[TABSIZE];
char *thenlabels[TABSIZE];
char *strings[TABSIZE];

/* Function Prototypes */
void yyerror(char *);
int yylex(void);

char *symlook(char*);
char *newtemp(void);
char *addstr(char*);
char *newlabel(void);
char *getlastlabel(void); 
char *getstrarg(argumentnode);


#endif
