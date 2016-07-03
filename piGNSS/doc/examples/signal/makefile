# I am a comment, and I want to say that the variable CC will be
# the compiler to use.
CC=g++
# Hey!, I am comment number 2. I want to say that CFLAGS will be the
# options I'll pass to the compiler.
CFLAGS=-c -Wall

all: example.bin

example.bin: example1.o signalhandler.o
	$(CC) example1.o signalhandler.o -o example.bin

example1.o: example1.cpp
	$(CC) $(CFLAGS) example1.cpp

signalhandler.o: signalhandler.cpp
	$(CC) $(CFLAGS) signalhandler.cpp

clean:
	rm -rf *.o *~
