#include "obd.h"

OBD::~OBD(){
    #ifdef TRACE
    T(std::cout,"Enters OBD::~OBD");
    #endif
}


OBD::OBD(std::string const &name, std::string const &location, int const &terminator):Communication(name,location,terminator){
    #ifdef TRACE
    T(std::cout,"Enters OBD::OBD");
    #endif
    setStatus(false);
}



void OBD::doInit(int &fd){
    #ifdef TRACE
    T(std::cout,"Enters OBD::doINIT");
    #endif
    if((fd = serialOpen(std::string("/dev/ttyAMA0").c_str(), OBD_BAUDRATE))<0){ERROR();}

    // Ignore data on serial
    serialFlush(fd);

    Message msg(50);

    // Sequence loop
    query(msg, std::string(AT_CMD_RESET).c_str(), 4);
    msg.setEmpty();

    query(msg, std::string(AT_CMD_ECHOF).c_str(), 5);
    msg.setEmpty();

    query(msg, std::string(AT_CMD_LFDOF).c_str(), 5);
    msg.setEmpty();

    query(msg, std::string(AT_CMD_AUTOP).c_str(), 6); // auto obd protocol set
    msg.setEmpty();

}



int OBD::doRead(int const &fd, CommBuffer &cb, Message &msg){

    int value;
    unsigned int nrcv;

    // Reads and removes NULLs as specified by man
    for(nrcv=0;serialDataAvail(fd);nrcv++){
        if((value=serialGetchar(fd))>0){
            if(value!=0)
                cb.push_back(value);
        }else{
            return -1;
        }
        #ifdef DEBUG
        std::cout << value;
        #endif
    }

    #ifdef DEBUG
    std::cout << std::endl;
    #endif
    return nrcv;
}



int OBD::doWrite(int const &fd, void const *buffer, unsigned int const &size){
    #ifdef TRACE
    T(std::cout,"Enters OBD::doWrite");
    #endif
    serialPuts(fd,(char *)buffer);
    return 0;
}


void OBD::doDecoding(int &fsm, CommBuffer &cb, Message &msg, uint8_t *headers){
    #ifdef TRACE
    T(std::cout,"Enters OBD::doWrite");
    #endif
}

void OBD::doParsing(Message &msg){
    #ifdef TRACE
    T(std::cout,"Enters OBD::doWrite");
    #endif
}


int OBD::getVelocity(){
    Message msg(50);
    query(msg,std::string(PID_SPEED).c_str(),5);
    return 0;
}

int OBD::getRPM(){
    Message msg(50);
    query(msg,std::string(PID_RPM).c_str(),5);
    return 0;
}



