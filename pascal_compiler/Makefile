CC = gcc
LIBS = -lfl 	# Linux
LEX = flex -I

BISON = bison -d 
CFLAGS = -DYYDEBUG=1 -g

DEP1=prj.tab.c prj.yy.c
EXE1=prj

.SUFFIXES:                    # Delete the default suffixes
.SUFFIXES: .y .tab.c .l .yy.c # Define our suffix list

.y.tab.c:
	$(BISON) $<

.l.yy.c:
	$(LEX) -i -o$@ $<
	
all: $(EXE1) prj.h

$(EXE1): $(DEP1) prj.h
	$(CC) -w -o $(EXE1) $(DEP1) $(LIBS) $(CFLAGS)

clean: 
	rm -f *.tab.h core $(DEP1) *.o $(EXE1)
