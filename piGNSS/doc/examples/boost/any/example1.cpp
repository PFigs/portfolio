#include <iostream>
#include <boost/any.hpp>

class Fruit{
	private:
	std::string name;
	boost::any pickle;
	
	public:
		Fruit(std::string name):name(name){ };
		~Fruit(){std::cout << "dead is " << name << std::endl;};
		std::string getName(){return name;};
		void fillpickle(boost::any const &smth){pickle = smth;};
		boost::any getpickle(){return pickle;};
};



int main(){
	boost::any holdsAnything; 
	
	holdsAnything = 3;
	std::cout << typeid(holdsAnything).name() << std::endl;
	std::cout << boost::any_cast<int>(holdsAnything) << std::endl;
	
	if(holdsAnything.type() == typeid(int))
		std::cout << "yep, the same" << std::endl;
	
	std::string name = "sour";
	Fruit peach(name);
	Fruit pickle("pickle");
	
	holdsAnything = peach;
	std::cout << typeid(holdsAnything).name() << std::endl;
	std::cout << boost::any_cast<Fruit>(holdsAnything).getName() << std::endl;
	
	//Save as pickle
	peach.fillpickle(pickle);
	if( peach.getpickle().type() == typeid(Fruit))
		std::cout << "I'm a pickle!" << std::endl;

}

