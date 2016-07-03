/**
 * @file binfile.cpp
 *
 * @author Pedro Silva, pedro.figs.silva@gmail.com
 */
#include "binfile.h"


BinFile::~BinFile(){
    #ifdef TRACE
    T(std::cout, "Enters BinFile::~BinFile");
    #endif

    if(getFd())
        ::close(getFd());

};


BinFile::BinFile(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator, int const &size):uBlox(name,location,high_header,low_header,terminator, size){

    #ifdef TRACE
    T(std::cout, "Enters BinFile::BinFile");
    #endif
    setStatus(true);
}


BinFile::BinFile(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator):uBlox(name,location,high_header,low_header,terminator){

    #ifdef TRACE
    T(std::cout, "Enters BinFile::BinFile");
    #endif
    setStatus(true);
}


// NEED TO WRITE HEADER AS WELL
void BinFile::sendData(Message &msg){
    #ifdef TRACE
    T(std::cout, "Enters BinFile::SendData");
    #endif
    int nwr  = 0;
    int size = msg.getSize();
    int fd = getFd();

    nwr = write(fd,msg.getBinary(),size);
    if(nwr == -1 || size != nwr) ERROR();
}

void BinFile::doInit(int &fd){
    #ifdef TRACE
    T(std::cout,  "Enters Communication::open");
    #endif
    if((fd = ::open(getLocation().c_str(), O_RDWR | O_NOCTTY | O_CREAT | O_APPEND, S_IRUSR | S_IWUSR | S_IROTH ))<0) ERROR(); // Open perif
    setStatus(true);
}
