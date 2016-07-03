#makefile
.PHONY: clean
.PHONY: cleant
.PHONY: clean_bin

CC = gcc
CFLAGS =-c -g -ansi -pedantic -Wall

BIN = risc
SRC = main.c load.c unidades_cc.c alu.c functions.c
OBJ = $(SRC:.c=.o)


$(BIN): $(OBJ) $(INC)
	$(CC) $(OBJ) $(LIBS) -o $(BIN) 

clean:
	rm *.o 
cleant:
	rm *~

clean_bin:
	rm $(BIN)
