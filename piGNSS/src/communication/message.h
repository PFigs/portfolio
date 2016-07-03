/**
 * @file message.h
 *
 * @brief This file contains the communication interface
 *
 */

 #ifndef MESSAGE_H
#define MESSAGE_H

#include <stdint.h>
#include "../date/date.h"
#include "../common.h"
#include "message.h"
#include <iomanip>


// #define DEBUG_MSG

static const unsigned int msgmaxsize = 1000;

/*!
 *  @class Message
 *
 *  This class handles each message obtained through the comm channel
 */
class Message{
    private:
        bool         dirty;
        unsigned int size;
        unsigned int insertions;
        unsigned int lheader;
        unsigned int lfooter;
        unsigned int lpayload;
        //Date       timestamp; //! Save time information
        uint8_t      *binary;
        uint8_t      mheaderh;
        uint8_t      mheaderl;
        uint8_t      mclass;
        uint8_t      mid;
        uint8_t      mcka;
        uint8_t      mckb;
        uint16_t     mlength;
        uint16_t     mchecksum;

    public:
        Message();
        Message(unsigned int size);
        ~Message();

        bool         add(uint8_t value);

        void         setReady();
        void         setEmpty();


        void         setHeaderH(uint8_t value);
        void         setHeaderL(uint8_t value);
        void         setLengthH(uint8_t value);
        void         setLengthL(uint8_t value);
        void         setClass(uint8_t value);
        void         setId(uint8_t value);
        void         setChecksum(uint8_t cka, uint8_t ckb);
        void         setPayload(uint8_t value);

        bool         ready();
        bool         empty();

        uint8_t      getClass();
        uint8_t      getId();
        uint16_t     getLength();
        uint16_t     getChecksum();
        uint8_t      getCKA();
        uint8_t      getCKB();

        uint8_t*     getPayload();
        uint8_t*     getBinary();
        unsigned int getTOW();
        unsigned int getSize();
        unsigned int getPayloadEntries();

        void         updateChecksum(uint8_t value);

        friend std::ostream& operator<< (std::ostream &out, Message &cmsg);

    private:
        void         clear();
        bool         insert(uint8_t value);
        void         resetChecksum();
        void         setTOW(unsigned int seconds);
        void         setEmpty(bool status);
        void         setSize(unsigned int size);
};

#endif

