#ifndef BINFILE_H
#define BINFILE_H

#include "ublox.h"
#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <sstream>
#include <iomanip>

class BinFile: public uBlox{
    public:
        ~BinFile();
        BinFile(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator, int const &size);
        BinFile(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator);
        void sendData(Message &msg);
    private:
        void doInit(int &fd);
        //void parseData(Message &msg){};
};

#endif
