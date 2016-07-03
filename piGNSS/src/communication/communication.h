/**
 * @file communication.h
 *
 * @brief This file contains the communication interface
 *
 */

#ifndef COMMUNICATION_H
#define COMMUNICATION_H
#include <cstdio>
#include <string.h>
#include <stdio.h>
#include <string>
#include <errno.h>
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <numeric>
#include <iostream>
#include <iterator>
#include <stdint.h>
#include <boost/circular_buffer.hpp>
#include "message.h"
#include "../date/date.h"
#include "../debug/debug.h"


static const int R_BUFFER = 300;
static const int C_BUFFER = 10000;
typedef boost::circular_buffer<uint8_t> CommBuffer;

/*!
  @class Communication

  @brief Abstract class to handle communication methods

  This class aims to provide an interface in order to facilitate
  the communication through different protocols

 */
class Communication{
    public:
        unsigned int   lHeader;
        unsigned int   lFooter;
        unsigned int   lPayload;

    private:
        int            fd;  //! file descriptor
        int            fsm; //! current state
        int            state; //! state machine for data
        bool           status; //! device's status
        std::string    name; //! device's name
        std::string    location; //! device's location
        uint8_t        buffer[R_BUFFER]; //! incoming buffer
        uint8_t        headers[2]; //! message headers
        uint8_t        terminator; //! message terminator
        int            nrcv; //! bytes received
        CommBuffer     cb; //! parsing buffer

    //methods
    public:
        Communication(){}; /// \todo remove this (fix webserver)
        Communication(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator, int const &size);
        Communication(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator);
        Communication(std::string const &name, std::string const &location, int const &header, int const &terminator);
        Communication(std::string const &name, std::string const &location, int const &terminator);
        virtual     ~Communication() = 0; //! Virtual destructor

        // accessors
        int  init();
        void acquire(Message &msg); //! Accessor for read
        void decode(Message &msg);  //! Accessor for decoder
        void parse(Message &msg);  //! Accessor for parser
        void configure(std::string const &str); //! Accessor for configuration
        void reset(); //! Accessor for reset
        void send(void const *buffer, int const &size);
        void query(Message &msg, void const *buffer, int const &size);
        void process(Message &msg);

        // getters
        bool        const &getStatus(); //! Returns device's status
        std::string const &getName(); //! Returns devices's name
        std::string const &getLocation(); //! Returns devices's location
        int         const &getFd(); //! Returns device's file descriptor (Read Only)

        // setters
        void setLocation(std::string location); //! Sets the device's location
        void setName(std::string name); //! Sets the device's name
        void setStatus(bool status); //! Sets the status of the device

        bool empty();
        void flush(); //! clear buffer

    private:
        virtual void doInit(int &fd); //! Opens conversation with device
        virtual void doCleanup(int &fd); //! Closes conversation with device

        virtual int doRead(int const &fd, CommBuffer &cb, Message &msg); //! Reads data from device
        virtual int doWrite(int const &fd, void const *buffer, unsigned int const &size); //! Writes data to the device

        virtual void doDecoding(int &fsm, CommBuffer &cb, Message &msg, uint8_t *headers) = 0; //! Data decoding (receiver specific)
        virtual void doParsing(Message &msg)  = 0; //! Data parser (receiver specific)
        virtual void doProcessing(Message &msg, int &fsm);

        virtual void doConfiguration(int const &fd, std::string const &str); //! Configures device
        virtual bool doReset(int const &fd); //! Sets device to default settings
};

#endif
