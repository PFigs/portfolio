/**
 * @file communication.cpp
 *
 * @brief This file contains the communication interface
 *
 */

#include "communication.h"


// ###################################################
//                   DESTRUCTOR
// ###################################################

Communication::~Communication(){
    #ifdef TRACE
    T(std::cout,"Enters Communication::~Communication");
    #endif
    status = false;
    close(fd);
};


// ###################################################
//                   CONSTRUCTOR
// ###################################################

Communication::Communication(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator, int const &size):name(name),location(location),terminator(terminator),cb(size){
    #ifdef TRACE
    T(std::cout,"Enters Communication::Communication (1st)");
    #endif
    state       = 0;
    fsm        = 0;
    status     = false;
    headers[0] = high_header;
    headers[1] = low_header;
}

Communication::Communication(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator):name(name),location(location),terminator(terminator),cb(C_BUFFER){
    #ifdef TRACE
    T(std::cout,"Enters Communication::Communication (2nd)");
    #endif
    state       = 0;
    fsm        = 0;
    status     = false;
    headers[0] = high_header;
    headers[1] = low_header;
}


Communication::Communication(std::string const &name, std::string const &location, int const &header, int const &terminator):name(name),location(location),terminator(terminator),cb(C_BUFFER){
    #ifdef TRACE
    T(std::cout,"Enters Communication::Communication (3rd)");
    #endif
    state       = 0;
    fsm        = 0;
    status     = false;
    headers[0] = header;
    headers[1] = 0;
}

Communication::Communication(std::string const &name, std::string const &location, int const &terminator):name(name),location(location),terminator(terminator),cb(C_BUFFER){
    #ifdef TRACE
    T(std::cout,"Enters Communication::Communication (3rd)");
    #endif
    state       = 0;
    fsm        = 0;
    status     = false;
    headers[0] = terminator;
    headers[1] = 0;
}


// ###################################################
//                   ACCESSORS
// ###################################################

int Communication::init(){
    #ifdef TRACE
    T(std::cout,"Enters Communication::init");
    #endif
    doInit(fd);
    return fd;
}


void Communication::acquire(Message &msg){
    #ifdef TRACE
    T(std::cout,"Enters Communication::acquire");
    #endif
    doRead(fd,cb,msg);
};

void Communication::decode(Message &msg){
    #ifdef TRACE
    T(std::cout,"Enters Communication::decode");
    #endif
    doDecoding(fsm,cb,msg,headers);
}

void Communication::parse(Message &msg){
    #ifdef TRACE
    T(std::cout,"Enters Communication::parse");
    #endif
    if(msg.ready()) doParsing(msg); /// \todo pass along constellation
    else P(std::cout, "Message not ready for parsing");
}


void Communication::configure(std::string const &str){
    #ifdef TRACE
    T(std::cout,"Enters Communication::configure");
    #endif
    doConfiguration(fd,str);
}

void Communication::reset(){
    #ifdef TRACE
    T(std::cout,"Enters Communication::reset");
    #endif
    doReset(fd);
};

void Communication::send(void const *buffer, int const &size){
    #ifdef TRACE
    T(std::cout,"Enters Communication::reset");
    #endif
    doWrite(fd, buffer, size);
};


void Communication::query(Message &msg, void const *buffer, int const &size){
    #ifdef TRACE
    T(std::cout,"Enters Communication::reset");
    #endif
    doWrite(fd, buffer, size);
    doRead(fd,cb,msg);
};

void Communication::process(Message &msg){
    #ifdef TRACE
    T(std::cout,"Enters Communication::process");
    #endif
    if(msg.ready()) doProcessing(msg, state /*Probably system as well*/);
}

// ###################################################
//                   GETTERS
// ###################################################

bool const &Communication::getStatus(){
    #ifdef TRACE
    T(std::cout,"Enters Communication::getSatus");
    #endif
    return status;
};

std::string const &Communication::getName(){
    #ifdef TRACE
    T(std::cout,"Enters Communication::getName");
    #endif
    return name;
}

std::string const &Communication::getLocation(){
    #ifdef TRACE
    T(std::cout, "Enters Communication::getLocation");
    #endif
    return location;
}


int const &Communication::getFd(){
    #ifdef TRACE
    T(std::cout, "Enters Communication::getfd");
    #endif
    return fd;
}



// ###################################################
//                   SETTERS
// ###################################################


void Communication::setLocation(std::string location){
    #ifdef TRACE
    T(std::cout, "Enters Communication::setLocation");
    #endif
    location = location;
};


void Communication::setName(std::string name){
    #ifdef TRACE
    T(std::cout, "Enters Communication::setName");
    #endif
    name = name;
};




void Communication::setStatus(bool status){
    #ifdef TRACE
    T(std::cout, "Enters Communication::setSatus");
    #endif
    status = status;
};




// ###################################################
//                   MISC
// ###################################################

void Communication::doProcessing(Message &msg, int &fsm){
    #ifdef TRACE
    T(std::cout,"Enters Communication::doProcessing");
    #endif
}


int Communication::doRead(int const &fd, CommBuffer &cb, Message &msg){
    #ifdef TRACE
    T(std::cout,"Enters Communication::doRead");
    #endif

    if(sizeof(buffer) < cb.reserve()){

        #ifdef VALIDATION
        assert(sizeof(buffer) < cb.reserve());
        #endif

        memset((void *)buffer,'\0',sizeof(buffer));
        nrcv = 0;

        // read as much as possible to a temporary buffer
        if((nrcv = read(fd, buffer, sizeof(buffer)))==-1){
            ERROR();
        }
        // FD no longer watched
        else if(nrcv == 0 && cb.empty()){
            #ifdef DEBUG_COM
            std::cout << "CLOSING FD: No more info" << std::endl;
            #endif
            status = false;
        }
        // appends new data to the circular buffer (in order to save it)
        else{
            for(int i=0;i<nrcv;i++)
                cb.push_back(buffer[i]);
        }

    }else{
        #ifdef WARNING
        W(std::cout,"Skipping read, due to circular buffer being almost full");
        #endif
    }

    return nrcv;
}


int Communication::doWrite(int const &fd, void const *buffer,unsigned int const &size){
    #ifdef TRACE
    T(std::cout, "Enters Communication::doWrite");
    #endif
    return 0;
}



void Communication::doConfiguration(int const &fd, std::string const &str){
    #ifdef TRACE
    T(std::cout, "Enters Communication::doConfiguration");
    #endif
}



bool Communication::doReset(int const &fd){
    #ifdef TRACE
    T(std::cout, "Enters Communication::doReset");
    #endif
    return false;
}


void Communication::doInit(int &fd){
    #ifdef TRACE
    T(std::cout,  "Enters Communication::open");
    #endif
    if((fd = ::open(location.c_str(), O_RDWR | O_NOCTTY | O_CREAT | O_APPEND, S_IRWXG ))<0) ERROR(); // Open perif
    status = true;
}

void Communication::doCleanup(int &fd){

    #ifdef TRACE
    T(std::cout,  "Enters Communication::close");
    #endif
    if(fd){
        ::close(fd);
        fd = 0;
    }
}

void Communication::flush(){
    cb.clear();
}

bool Communication::empty(){
    return cb.empty();
}

