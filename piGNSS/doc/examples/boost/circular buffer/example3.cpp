   #include <boost/circular_buffer.hpp>
   #include <numeric>
   #include <assert.h>
   #include <iostream>
using namespace std;

   int main(int /*argc*/, char* /*argv*/[])
   {
      // create a circular buffer of capacity 3
      boost::circular_buffer<int> cb(20);
      boost::circular_buffer<int>::iterator it;

      // Here the reserve and capacity have the same result
      cout << "Available slots? " << cb.reserve() << endl;
      cout << "Container capacity? " << cb.capacity() << endl;

      // insert some other elements
      cb.push_back(121);
      cb.push_back(123);
      cb.push_back(1223);
      cb.push_back(1223);
      cb.push_back(1223);
      cb.push_back(1223);
      cb.push_back(1223);
      cb.push_back(1223);
      cb.push_back(123123);
      cb.push_back(1223);
      cb.push_back(123123);
      cb.push_back(123);
      cb.push_back(123123);
      cb.push_back(12);
      cb.push_back(123123);
      cb.push_back(1233);
      cb.push_back(123);
      cb.push_back(12);
      

      // The capacity is always the same, but reserve returns only 1
      cout << "Available slots? " << cb.reserve() << endl;
      cout << "Container capacity? " << cb.capacity() << endl;

      cb.push_back(1);

      cout << "Available slots? " << cb.reserve() << endl;

      // pop everything (and more?)
//    cb.pop_front(); //would abort code

      
      for(it=cb.begin(); it < cb.end(); it++)
		std::cout << *it;
      

      return 0;
   }
