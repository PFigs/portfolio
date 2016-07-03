
#ifndef WEBSERVER_H
#define WEBSERVER_H
#include "communication.h"
#include <sys/types.h>
#include <sys/socket.h>
#include <arpa/inet.h>
#include <netinet/in.h>


static const int maxbuff = 500; /// \todo get previous declaration

/*!
 * @brief implements a UDP server
 *
 * This class provides the necessary interface for a UDP server
 *
 */
class Server: public Communication{
    private:
        int                 fd; // Socket fd
        struct sockaddr_in  servaddr, cliaddr;
        std::string         name;
        int                 port;
        uint8_t             headers[2];
        uint8_t             terminator;
        uint8_t             buffer[250];
        boost::circular_buffer<uint8_t>     cb;

    public:
        ~Server();
        Server(std::string name, int const &port);
        void obtainData(Message &msg);
        //std::string getName(){return name;};
        //std::string getLocation(){return location;};
        int getfd();

    private:
        virtual void doInit(int &fd);
        virtual void doCleanup(int &fd);
        virtual void doDecoding(int &fsm, CommBuffer &cb, Message &msg, uint8_t *headers);
        virtual void doParsing(Message &msg);

};


class Client: public Communication{
    private:
        int         fd;
        struct sockaddr_in  servaddr, cliaddr;
        std::string name;
        int         port;

    public:
        ~Client();
        Client(std::string name, int const &port);
        void sendData(Message &msg);
        void sendData();
        int getfd();

    private:
        virtual void doInit(int &fd);
        virtual void doCleanup(int &fd);
        virtual void doParsing(Message &msg);
        virtual void doDecoding(int &fsm, CommBuffer &cb, Message &msg, uint8_t *headers);
};


#endif

/*
 class uBlox: public Communication{
    private:
        int         fd;
        std::string name;
        std::string location;

    public:
        ~uBlox();
        uBlox(std::string const &name, std::string const &location);
        void obtainData(Message &msg);
        std::string getName(){return name;};
        std::string getLocation(){return location;};
        int getfd();

    private:
        void open();
        void close();
        void parseData();
};
*/


/*
class Communication{
    private:
        int         fd;
        bool        status;
        std::string name;
        std::string location;


    //methods
    public:
        virtual     ~Communication(){}; //! Virtual destructor

        // setters
        bool        getStatus(); //! Returns device's status
        std::string getName(); //! Returns devices's name
        std::string getLocation(); //! Returns devices's location
        int getfd();

        // getters
        void        obtainData(Message &msg); //! Retrieves data from messages

        // Change this?
    private:
        virtual void open()         = 0; //! Opens conversation with device
        virtual void close()        = 0; //! Closes conversation with device
        virtual void parseData()    = 0;
};
*/
