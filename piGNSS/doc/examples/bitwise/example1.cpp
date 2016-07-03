#include <stdio.h>
#include <cstdio>
#include <iostream>
#include <unistd.h>
using namespace std;

string binary( unsigned long n ){
  char     result[ (sizeof( unsigned long ) * 8) + 1 ];
  unsigned index  = sizeof( unsigned long ) * 8;
  result[ index ] = '\0';

  do result[ --index ] = '0' + (n & 1);
  while (n >>= 1);

  return string( result + index );
}


int main(void){
	
	int a = 0x01;
	int b = 0x10;
	int c = 0x0;
	

	c = a << 8 | b;
	std::cout << "res: " << c << std::endl;
	std::cout << "a " << binary(a<<8) << std::endl;
	std::cout << "b " << binary(b) << std::endl;
	std::cout << "c " << binary(c) << std::endl;
	
	c = a << 7 | b;
	std::cout << "res: " << c << std::endl;
	std::cout << "a " << binary(a<<7) << std::endl;
	std::cout << "b " << binary(b) << std::endl;
	std::cout << "c " << binary(c) << std::endl;
	
	c = b << 8 | a;
	std::cout << "res: " << c << std::endl;
	std::cout << "a " << binary(a) << std::endl;
	std::cout << "b " << binary(b<<8) << std::endl;
	std::cout << "c " << binary(c) << std::endl;
	
	c = b << 7 | a;
	std::cout << "res: " << c << std::endl;
	std::cout << "a " << binary(a) << std::endl;
	std::cout << "b " << binary(b<<7) << std::endl;
	std::cout << "c " << binary(c) << std::endl;
	
	return 0;
}
