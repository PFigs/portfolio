#include <stdio.h>
#include <cstdio>
#include <iostream>
#include <string>

using namespace std;

// "Non pure" Abstract class
class Shape{
	private:
	string _name;
	int _id;
	
	public:
		
		string getName() const { return _name;}
		string setName(string name){_name = name; return _name;}
		
		int  setID(int id){_id = id; return _id;}
		int  getID() const{ return _id;}
		
		virtual void gettosomething() const = 0;
		
		virtual void gettostuff() const = 0;
	
	private:
		virtual void doSomething() const{cout << "Not doing anything" << endl;};
		void doStuff() const{cout << "this is stuff" << endl;} // Does not make sense unless smth public uses it!
};

//Inherited class
class Fruit: public Shape{
	private:
	string name;
	int id;
	Shape *holder;
	
	public:
		// No need to use virtual here!
		void gettosomething() const{
			cout << "I simply want to do something" << endl;
			doSomething();
		};
	
		void gettostuff() const{
			// Cant get to stuff as it is private in the upper class
			doSomething();
		}
	
		void setholder(Shape &pSmth){holder = &pSmth;};
	
	private:
		void doSomething() const{
			cout << "Yup, I am doing something!" << endl;
		};
	
};


// Main loop
int main(void){
	
	cout << "Starting up" << endl;
	
	Fruit orange;
	
	cout << orange.setID(2) << endl;
	cout << orange.setID(3) << endl;
	orange.setName("Orange");
	cout << "My name is: " << orange.getName() << endl;
	cout << "My ID is: "   << orange.getID() << endl;
	
	orange.gettosomething();
	
	Fruit *aux = &orange; //Use this pointer to see with gdb which type of fp the class contains
	
	// orange.gettostuff(); // Simply unreachable as it is private. If the scope is protected, then it would work
	
	return 0;
}
