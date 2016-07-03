#makefile
.PHONY: clean
.PHONY: clean_bin
.PHONY: clean_t

CC = gcc
CFLAGS =-c -g -ansi -Wall -pedantic -D_GNU_SOURCE
LIBS = -lpthread -lcurses
BIN1 = ./bin/CliHn 
BIN2 = ./bin/ServHN
BIN3 = ./bin/jogo
SRC1 = hnc.c hnccom.c hncui.c tools.c
SRC2 = hns.c hnscom.c tools.c hnsf.c hnst.c hnsui.c hof.c
SRC3 = jogo.c tools.c
VPATH = src
OBJ1 = $(SRC1:.c=.o)
OBJ2 = $(SRC2:.c=.o)
OBJ3 = $(SRC3:.c=.o)

all: $(BIN1) $(BIN2) $(BIN3)
	@mv ./*.o ./bin/

$(BIN1): $(OBJ1)
	$(CC) $(OBJ1) $(LIBS) -o $(BIN1) 

$(BIN2): $(OBJ2)
	$(CC) $(OBJ2) $(LIBS) -o $(BIN2)

$(BIN3): $(OBJ3)
	$(CC) $(OBJ3) $(LIBS) -o $(BIN3)

clean:
	@rm ./bin/*.o

clean_bin:
	@rm $(BIN1)
	@rm $(BIN2)
	@rm $(BIN3)

clean_t:
	@rm *~
	@rm ./src/*~

