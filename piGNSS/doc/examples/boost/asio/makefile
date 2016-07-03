all: example1client.bin example1server.bin example2client.bin example2server.bin example3client.bin example3server.bin

example1client.bin: example1client.cpp
	g++ -o example1client.bin example1client.cpp -lboost_system -lboost_thread -pthread

example1server.bin: example1server.cpp
	g++ -o example1server.bin example1server.cpp -lboost_system -lboost_thread -pthread

example2client.bin: example2client.cpp
	g++ -o example2client.bin example2client.cpp -lboost_system -lboost_thread -pthread

example2server.bin: example2server.cpp
	g++ -o example2server.bin example2server.cpp -lboost_system -lboost_thread -pthread

example3client.bin: example3client.cpp
	g++ -o example3client.bin example3client.cpp -lboost_system -lboost_thread -pthread

example3server.bin: example3server.cpp
	g++ -o example3server.bin example3server.cpp -lboost_system -lboost_thread -pthread

clean:
	rm *.o *~
