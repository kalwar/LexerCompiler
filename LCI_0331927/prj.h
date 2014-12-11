#ifndef _PRJ
#define _PRJ

#define TABSIZE 100 /* size of the tables */


//Structure for numbers, varibles
//if identifier is 0 or constant 1
typedef struct
{
	   // type = 0: name of variable
	  // type = 1: integer
	int type;
	union
	{
		char *symbol; 
		int number; 
	} argument;
	char *strvalue;
} argumentnode;


//Structure needed in while loop
//When using TAC

typedef struct 
{
	char *beginlabel;
	char *endlabel;
} labelnode;

// symbol table 
char *symtable[TABSIZE];
char *repeatlabels[TABSIZE];
char *iflabels[TABSIZE];
char *thenlabels[TABSIZE];
char *strings[TABSIZE];

// Function declarations
void yyerror(char *);
int yylex(void);

char *symlook(char*);
char *newtemp(void);
char *addstr(char*);
char *newlabel(void);
char *getlastlabel(void); 
char *getstrarg(argumentnode);


#endif
