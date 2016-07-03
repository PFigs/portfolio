all: example1.bin

example1.bin: example1.cpp
	g++ example1.cpp -o example1.bin -pthread -lboost_thread -lboost_system
	make clean

clean:
	rm *~
