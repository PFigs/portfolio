
#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <sstream>
#include <iomanip>
#include <stdio.h>
#include <stdlib.h>     /* strtol */

using namespace std;


int main(){
    string line;
    ifstream mfile("disable.bin");
    //ofstream bfile("disable.bin", ios::out | ios::binary);


        while(mfile.good()){

            // remove trash in line
            getline (mfile,line);
//            line.erase(0, line.find_first_not_of(" \t\r\n\v\f"));
//            size_t index = line.find_first_of("#");
//            if (index != string::npos) line.erase(index, string::npos);
//            line.erase(remove_if(line.begin(), line.end(), ::isspace), line.end());
//            line.append("\n");

//            // write binary file
//            unsigned short int value = 0;
//            char hex[3];
//            hex[2] = '\0';
//            for(int i=0;i<line.size();i+=2){
//                hex[0] = line[i];
//                hex[1] = line[i+1];
//                cout << hex << endl;
//                sscanf(hex,"%hx\n", &value);
//                bfile.write((char*)&value,1);
//            }

            std::string::iterator it = line.begin();

            for(it=line.begin();it!=line.end();it++){

                std::cout << int(*it) << std::endl;
            }

        mfile.close();
    }

    return 0;
}