#include <stdio.h>
#include <cstdio>

#include <string.h>
#include <stdio.h>
#include <stdint.h>
#include <errno.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <numeric>
#include <assert.h>
#include <unistd.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

#include <boost/circular_buffer.hpp>
#include <iostream>     // std::cout
#include <iterator>     // std::iterator, std::input_iterator_tag

/**
*
*  @example "./doc/examples/boost/circular buffer/example4.cpp"
*/
class CircularBuffer: public boost::circular_buffer<int>{
	public:
		iterator head;
		iterator tail;
	
	
	public:
		CircularBuffer(unsigned int size):boost::circular_buffer<int>(size){
			head = begin();
			tail = end();
		};

	void append(uint8_t *array, unsigned int size){
			insert(head,array,array+size);
			head=begin();
	};


	void search(){
		head = begin();
		tail = end();
		int i=0;
		for(;i < size();i++){
			bool flag;
			flag = head[i] == 181;
			std::cout << "Search: " << head[i] << " : "<< flag << std::endl;
		}
	}


	void cleanup(uint8_t *pattern, int sz){
		bool flag[sz];
		head = begin();
		tail = head+1;
		
		for(int  i = 0, pat = 0;i < size();i++){
		
			flag[pat] = (head[i] == pattern[pat]);
			
			#ifdef DEBUG
			int buffer = 0
			buffer     = pattern[pat] ;
			std::cout << "Pat " << pat << std::endl;
			std::cout << "Searching for " << buffer << " got " << flag[pat] << std::endl;
			#endif
			
			if(flag[pat]){
				if(pat == 0) tail = head + (i==0?1:i);
				pat++;
				
				if(pat == sz){
					#ifdef DEBUG
					std::cout << "Deleting! " << i-sz << std::endl; 
					#endif
					erase(head, tail); // np with head and tail being the same
					break;
				};
			}else{
				do{
					flag[pat] = false;
				}while(pat-- >= 0);
				pat = 0;
			};
		}
		
		// Reassing header and tail iterators
		head = begin();
		tail = end();
	}
	
	
	
		
		//does not include terminator
	


	friend std::ostream& operator<< (std::ostream &out, const CircularBuffer &cCb){
		//boost::circular_buffer<uint8_t>::iterator start = cb.begin();
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
	}
};


int main(void){
	 boost::circular_buffer<int> cb(6);
	boost::circular_buffer<int>::iterator next;
	
	uint8_t array1[10];
	uint8_t array2[10];
	memset((void *) array1,10,sizeof(array1));
	memset((void *) array2,20,sizeof(array2));
	
	cb.push_back(181);
	cb.push_back(10);
	cb.push_back(11);
	cb.push_back(181);
	cb.push_back(96);
	//std::cout << cb << std::endl;
	std::cout << "cb[0]" << cb[0] << std::endl;
	cb.pop_front();
	std::cout << "cb[0]" << cb[0] << std::endl;
	cb.pop_front();
	std::cout << "cb[0]" << cb[0] << std::endl;
	cb.pop_front();
	std::cout << "cb[0]" << cb[0] << std::endl;
	cb.pop_front();
	
//	if(cb.size()>1)
//		std::cout << "can«t pop" << cb.size() << std::endl;
//		cb.pop_front();
//	else{
//		std::cout << "safe to pop?" << cb.size() << std::endl;
//		}
		
	//std::cout << cb << std::endl;

	//cb.append(array1,3);
	
	std::cout << "Can store: " << cb.reserve() << std::endl;
	
	//cb.append(array2,3);
	
//	next=cb.begin();
	//std::cout << "lol: "<< next[0] << std::endl;
	//std::cout << "lol: "<< next[1] << std::endl;
	//std::cout << "lol: "<< next[2] << std::endl;
	
	
	
//	for(CircularBuffer::iterator finished = cb.end(); next != finished; next++)
//	{
//		finished[1]
//	}

//cb.search();
	uint8_t temp[5];
	temp[0] = 181;
	temp[1] = 96;
//	cb.cleanup(temp,2);
	
	
	//test with boost vanilla

	//int n = cb.size();
//	std::cout << n << std::endl;
//	std::cout << cb.capacity() << std::endl;
	//std::cout << cb << std::endl;
	
	cb.clear();
	//std::cout << cb << std::endl;
}
//!@endcode



