#include <string>
#include <fstream>
#include <iostream>
class Potato{
	private:
		int m;
		
	public:
		Potato(){m = 0;};
		int &getM(){return m;}
		void incM(){m++;};
		void pM(){std::cout << "M: " << m << std::endl;}

};

void inc(int &m){
	m++;
}



int main(void){
	
	std::cout << "Strings examples" << std::endl;
	std::string str("random string");
	
	std::cout << str << std::endl;
	std::cout << "first letter: " << str[1] << std::endl;
	
	
	Potato old;
	
	int a = old.getM();
	
	std::cout << "A: " << a << std::endl;
	inc(a);
	std::cout << "A: " << a << std::endl;
	old.pM();
	old.incM();
	std::cout << "A: " << a << std::endl;
	old.pM();
	
}
