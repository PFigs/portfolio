   #include <boost/circular_buffer.hpp>
   #include <numeric>
   #include <assert.h>

   int main(void)
   {
      // create a circular buffer of capacity 3
      boost::circular_buffer<int> cb(3);

      // insert some elements into the circular buffer
      cb.push_back(1);
      cb.push_back(2);

      // assertions
      assert(cb[0] == 1);
      assert(cb[1] == 2);
      assert(!cb.full());
      assert(cb.size() == 2);
      assert(cb.capacity() == 3);

      // insert some other elements
      cb.push_back(3);
      cb.push_back(4);

      // evaluate the sum
      int sum = std::accumulate(cb.begin(), cb.end(), 0);

      // assertions
      assert(cb[0] == 2);
      assert(cb[1] == 3);
      assert(cb[2] == 4);
      assert(*cb.begin() == 2);
      assert(cb.front() == 2);
      assert(cb.back() == 4);
      assert(sum == 9);
      assert(cb.full());
      assert(cb.size() == 3);
      assert(cb.capacity() == 3);

      return 0;
   }



