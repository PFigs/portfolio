all: example1.bin example2.bin

example1.bin: example1.cpp
	g++ -o example1.bin example1.cpp -I/usr/include/postgresql/  -lm -lpq

example2.bin: example2.cpp
	g++ -o example2.bin example2.cpp -I/usr/include/postgresql/ -lm -lpq

clean:
	rm *.o *~

