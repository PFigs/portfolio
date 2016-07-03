#include <string.h>
#include <stdio.h>
#include <string>

#include <boost/circular_buffer.hpp>
#include <iostream>     // std::cout
#include <iterator>     // std::iterator, std::input_iterator_tag
#include <stdint.h>


class CircularBuffer: public boost::circular_buffer<int>{
	private:
		iterator head;
		iterator tail;
	
	public:
		CircularBuffer():boost::circular_buffer<int>(10){};
		CircularBuffer(unsigned int size):boost::circular_buffer<int>(10){head = begin();};
		friend std::ostream& operator<< (std::ostream &out, const CircularBuffer &cCb){	//boost::circular_buffer<uint8_t>::iterator start = cb.begin();
			int n = cCb.size();
			
			if(!cCb.empty()){
				out << "[";
				for(int i=0; i < n-1;i++)
				{
					out << cCb[i];
					out << "|";
				}
				out << cCb[n-1] << "]";
			}
			else{
				out << "[Buffer is empty]";
			}
			
			return out;
		};
};



class Communication{
	private:
		int    		   fd;
		bool   		   status;
		std::string    name;
		std::string    location;
		CircularBuffer cb;
		uint8_t 	   buffer[250]; /// change to generic buffer size
		int			   nrcv;

	//methods
	public:
		Communication(std::string name, std::string location):name(name),location(location),cb(10){};
		virtual 	~Communication(){}; //! Virtual destructor
		
		// setters
		bool 		getStatus(){status = true;return status;}; //! Returns device's status
		std::string getName(){return name;}; //! Returns devices's name
		std::string getLocation(){return location;}; //! Returns devices's location 
		virtual void obtainData(){cb.push_back(1); std::cout << "base class" << std::endl; std::cout << cb << std::endl;};
		int getfd(){return fd;};
		
		
		// Change this?
	private:
		virtual void open() 		= 0; //! Opens conversation with device
		virtual void close()		= 0; //! Closes conversation with device
		virtual void parseData()	= 0;
};


class FileIO : public Communication{
	private:
		int			   fd;
		uint8_t        headers[2];
		uint8_t 	   terminator;
		std::string	   name;
		std::string	   location;
		CircularBuffer cb;
		uint8_t 	   buffer[250];
		int			   nrcv;

	public:
		
		FileIO(std::string name, std::string location):Communication(name,location),cb(10),name("beutifuilll"),location("right there"){fd=1; buffer[0] = 0;cb.push_back(1); cb.push_back(2); cb.push_back(3);};
		void obtainData(){std::cout << "child class" << std::endl;std::cout << cb << std::endl;};
		int getfd(){return fd;};
		std::string getName(){return name;}; //! Returns devices's name

	private:
		void open(){};
		void close(){};
		void parseData(){};
	
};




int main(void){
	
	Communication *device;
	FileIO bfile("random","somewhere");
	
	device = &bfile;
	
	std::cout << "GET DATA" << std::endl;
	device->obtainData();
	bfile.obtainData();
	
	std::cout << "GET NAME" << std::endl;
	std::cout << device->getName() << std::endl;
	std::cout << bfile.getName() << std::endl;
	
	std::cout << "GET LOCATION" << std::endl;
	std::cout << device->getLocation() << std::endl;
	std::cout << bfile.getLocation() << std::endl;
	
	std::cout << "GET STATUS" << std::endl;
	std::cout << device->getStatus() << std::endl;
	std::cout << bfile.getStatus() << std::endl;
	
	return 0;
}
