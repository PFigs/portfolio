/**
 * @file boost/threads/example1
 * 
 */


#include <stdio.h>
#include <cstdio>
#include <iostream>
#include <boost/thread.hpp>
#include <unistd.h>
#include <pthread.h>
using namespace std;



void task1() { 
    
    //boost::this_thread::sleep_for( boost::chrono::seconds(1) );
    cout << "t1: woke up" << endl;
    //boost::this_thread::disable_interruption di;
    //cout << "t1: interruption state is " << boost::this_thread::interruption_enabled() << endl;
    
    while(1){
		if(pthread_mutex_trylock(&cte) == 0){
			std::cout<<"t1:GOT IT"<<std::endl;
			break;
		}
		
		cout << "t1: sleeping" << endl;
		boost::this_thread::sleep_for( boost::chrono::seconds(1) );
		cout << "t1: woke up" << endl;
	}
	
	
	cout << "Im dead!" << std::endl;
	
    
}

void task2() { 
    boost::this_thread::sleep_for(boost::chrono::seconds(2));
    cout << "t2: woke up" << endl;
    cout << "t2: interruption state is " << boost::this_thread::interruption_enabled() << endl;
    
    try{
    for(;;){
		boost::this_thread::sleep_for(boost::chrono::seconds(2));};
    }catch(boost::thread_interrupted const& ){
		cout << "t2: got the interruption!" << endl;
	}
    
}

int main (int argc, char ** argv) {
	using namespace boost; 
	thread thread_1 = thread(task1);
	//thread thread_2 = thread(task2);
	
	if (pthread_mutex_init(&cte, NULL) != 0){
        printf("\n mutex init failed\n");
        return 1;
    }
	pthread_mutex_lock(&cte);
	this_thread::sleep_for( boost::chrono::seconds(3));
	pthread_mutex_unlock(&cte);
	
	// do other stuff
	cout << "master: joining t1" << endl;
	thread_1.join();
	
//	sleep(2);
//	cout << "master: interrupting t2" << endl;
//	thread_2.interrupt();

//	sleep(3);
//	cout << "master: joining t2" << endl; 
//	thread_2.join();
	

	return 0;
}

