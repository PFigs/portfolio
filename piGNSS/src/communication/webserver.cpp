#include "webserver.h"


/*!
 * @brief initialises server's UDP socket
 *
 * @param[in] serverip server's own ip (either localhost or external/local ip)
 * @param[in] serverport server's port to bind
 */
Server::Server(std::string serverip, int const &serverport):name(serverip),port(serverport),cb(maxbuff){
    headers[0] = 181;
    headers[1] = 96;
    terminator = '\n';
    memset((void *)&servaddr, (int) '\0', sizeof(servaddr));
    memset((void *)&buffer, (int) '\0', sizeof(buffer));
}
Server::~Server(){}

/*!
 * @brief creates sokect descriptor
 *
 */
void Server::doInit(int &fd){

    int protocol = AF_INET;
    int port     = 22;

    if((fd = socket(AF_INET,SOCK_DGRAM,0))==-1){
        std::cerr << strerror(errno) << std::endl;
        exit(EXIT_FAILURE);
    }

    servaddr.sin_family = protocol;
    servaddr.sin_addr.s_addr   = htonl(INADDR_ANY);
    servaddr.sin_port   = htons(port);

    if(bind(fd, (struct sockaddr *) &servaddr, sizeof(servaddr)) ==-1){
        std::cerr << strerror(errno) << std::endl;
        exit(EXIT_FAILURE);
    }
}


void Server::doDecoding(int &fsm, CommBuffer &cb, Message &msg, uint8_t *headers){
    #ifdef DEBUG
    P(std::cout,  "Enters Server::obtainData");
    #endif
    socklen_t peer_addr_len;
    int nrcv;
    // read as much as possible to a temporary buffer

    if((nrcv = recvfrom(fd,buffer,sizeof(buffer),0, (struct sockaddr *) &cliaddr,&peer_addr_len))==-1){
        ERROR();
    }else{
        //copies datagram
        for(int i=0; i< nrcv; i++){
            cb.push_back(buffer[i]);
        }
    }


    #ifdef DEBUG
    D(std::cout, buffer);
    D(std::cout, nrcv);
    #endif
}


void Server::doCleanup(int &fd){}

void Server::doParsing(Message &msg){
}

int Server::getfd(){
    return fd;
}



/*!
 * @brief initialises client's UDP socket
 *
 * @param[in] serverip server's ip where to send message
 * @param[in] serverport server's port where it is listening for a message
 */
Client::Client(std::string serverip, int const &serverport):name(serverip),port(serverport){

    memset((void *)&servaddr, (int) '\0', sizeof(servaddr));

}
Client::~Client(){}

/*!
 * @brief creates sokect descriptor
 */
void Client::doInit(int &fd){

    char const * ip       = name.c_str();
    uint16_t port         = 22;
    int protocol          = AF_INET;

    servaddr.sin_family = protocol;
    servaddr.sin_port   = htons(port);
    if(inet_pton(protocol,ip,&servaddr.sin_addr)==-1){
        std::cerr << strerror(errno) << std::endl;
        exit(EXIT_FAILURE);
    }

    if((fd = socket(protocol,SOCK_DGRAM,0))==-1){
        std::cerr << strerror(errno) << std::endl;
        exit(EXIT_FAILURE);
    }

}


void Client::doDecoding(int &fsm, CommBuffer &cb, Message &msg, uint8_t *headers){
    char mesg[100];
    socklen_t peer_addr_len;

    recvfrom(fd,mesg,100,0, (struct sockaddr *) &cliaddr,&peer_addr_len);

    std::cout << mesg << std::endl;
}

void Client::sendData(Message &msg){
    char mesg[20] = "webserver-> ola";
    //socklen_t peer_addr_len;

    sendto(fd, mesg, strlen(mesg), 0, (const struct sockaddr *)&servaddr, sizeof(servaddr));

    std::cout << mesg << std::endl;
}

void Client::sendData(){
    char mesg[20] = "webserver-> ola";
    //socklen_t peer_addr_len;

    sendto(fd, mesg, strlen(mesg), 0, (const struct sockaddr *)&servaddr, sizeof(servaddr));

    std::cout << mesg << std::endl;
}


void Client::doCleanup(int &fd){}
void Client::doParsing(Message &msg){}

int Client::getfd(){return fd;}
