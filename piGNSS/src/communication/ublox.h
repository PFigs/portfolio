/**
 * @file ublox.h
 *
 * @brief This file contains ublox particulars
 *
 */

#ifndef UBLOX_H
#define UBLOX_H

#include "communication.h"
#include "../debug/debug.h"
#include "../common.h"
#include <iostream>
#include <fstream>
#include <termios.h>

static const speed_t baud = B9600; /* baud rate */

typedef unsigned short int  U1;
typedef short int           I1;
typedef short int           I2;
typedef int                 I4;
typedef double              R8;
typedef float               R4;

#ifndef UBLOX_SYMBOLS
#define UBLOX_SYMBOLS
#define UBX_HEADER      0xB562
#define UBX_NAV           0x01
#define UBX_RXM           0x02
#define UBX_INF           0x04
#define UBX_ACK           0x05
#define UBX_CFG           0x06
#define UBX_MON           0x0A
#define UBX_AID           0x0B
#define UBX_TIM           0x0D
#define UBX_ESF           0x10

// AID
#define UBX_ACK_ACK       0x01
#define UBX_ACK_NAK       0x00

#define UBX_AID_ALM       0x30
#define UBX_AID_ALPSRV    0x32
#define UBX_AID_ALP       0x50
#define UBX_AID_AOP       0x33
#define UBX_AID_DATA      0x10
#define UBX_AID_EPH       0x31
#define UBX_AID_HUI       0x02
#define UBX_AID_INI       0x01
#define UBX_AID_REQ       0x00

// CFG
#define UBX_CFG_ANT       0x13
#define UBX_CFG_CFG       0x09
#define UBX_CFG_DAT       0x06
#define UBX_CFG_EKF       0x12
#define UBX_CFG_ESFGWT    0x29
#define UBX_CFG_FXN       0x0E
#define UBX_CFG_INF       0x02
#define UBX_CFG_ITFM      0x39
#define UBX_CFG_MSG       0x01
#define UBX_CFG_NAV5      0x24
#define UBX_CFG_NAVX5     0x23
#define UBX_CFG_NMEA      0x17
#define UBX_CFG_NVS       0x22
#define UBX_CFG_PM2       0x3B
#define UBX_CFG_PM        0x32
#define UBX_CFG_PRT       0x00
#define UBX_CFG_RATE      0x08
#define UBX_CFG_RINV      0x34
#define UBX_CFG_RST       0x04
#define UBX_CFG_RXM       0x11
#define UBX_CFG_SBAS      0x16
#define UBX_CFG_TMODE2    0x3D
#define UBX_CFG_TMODE     0x1D
#define UBX_CFG_TP5       0x31
#define UBX_CFG_TP        0x07
#define UBX_CFG_USB       0x1B

// ESF
#define UBX_ESF_MEAS      0x02
#define UBX_ESF_STATUS    0x10

// INF
#define UBX_INF_DEBUG     0x04
#define UBX_INF_ERROR     0x00
#define UBX_INF_NOTICE    0x02
#define UBX_INF_TEST      0x03
#define UBX_INF_WARNING   0x01

// MON
#define UBX_MON_HW2       0x0B
#define UBX_MON_HW        0x09
#define UBX_MON_IO        0x02
#define UBX_MON_MSGPP     0x06
#define UBX_MON_RXBUF     0x07
#define UBX_MON_RXR       0x21
#define UBX_MON_TXBUF     0x08
#define UBX_MON_VER       0x04

// NAV
#define UBX_NAV_AOPSTATUS 0x60
#define UBX_NAV_CLOCK     0x22
#define UBX_NAV_DGPS      0x31
#define UBX_NAV_DOP       0x04
#define UBX_NAV_EKFSTATUS 0x40
#define UBX_NAV_POSECEF   0x01
#define UBX_NAV_POSLLH    0x02
#define UBX_NAV_SBAS      0x32
#define UBX_NAV_SOL       0x06
#define UBX_NAV_STATUS    0x03
#define UBX_NAV_SVINFO    0x30
#define UBX_NAV_TIMEGPS   0x20
#define UBX_NAV_TIMEUTC   0x21
#define UBX_NAV_VELECEF   0x11
#define UBX_NAV_VELNED    0x12

// RXM
#define UBX_RXM_ALM       0x30
#define UBX_RXM_EPH       0x31
#define UBX_RXM_PMREQ     0x41
#define UBX_RXM_RAW       0x10
#define UBX_RXM_SFRB      0x11
#define UBX_RXM_SVSI      0x20

// TIM
#define UBX_TIM_SVIN      0x04
#define UBX_TIM_TM2       0x03
#define UBX_TIM_TP        0x01
#define UBX_TIM_VRFY      0x06

#endif


//! Helper function to print out received messages
bool printMessageIdentifier( std::ostream& out, uint8_t mclass, uint8_t mid);

/*!
  @class uBlox

  @brief This class handles comminucattion with uBlox receivers

  The objective of this class is to allow communication with the uBlox receivers,
  parsing the proprietary protocol (ubx).

 */
class uBlox: public Communication{
    enum CLASS{NAV=1, RXM, INF, ACK, CFG, MON, AID, TIM, ESF};
    enum PROTOCOL{HH=0,LH,CLASS,ID,LLENGTH,HLENGTH};
    enum FSM{LOOKING=0, CONFIRMING, EXT_CLASS, EXT_ID, EXT_LENGTH_L,EXT_LENGTH_H,EXT_PAYLOAD,EXT_VALIDATE,EXT_FINISH};
    enum DATA{WAITING=0, READY, WAITFOR, POLLEPH, POLLHUI, NWAIT, CFGTM, EPHDUMP};

    private:
        int retries;

    public:
        ~uBlox();
        uBlox(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator, int const &size);
        uBlox(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator);

    private:
        virtual void doInit(int &fd);
        virtual void doDecoding(int &fsm, CommBuffer &cb, Message &msg, uint8_t *headers);
        virtual void doParsing(Message &msg);
        virtual bool doReset(int const &fd);
        virtual int  doWrite(int const &fd, void const *buffer,unsigned int const &size);
        virtual void doConfiguration(int const &fd, std::string const &filename);
        virtual void doProcessing(Message &msg, int &fsm);

        void sendcommand(std::string const &line);

        // parsers
        bool parseACK(Message &msg);
        void parseNAV(Message &msg);
        void parseRXM(Message &msg);
        void parseINF(Message &msg);
        void parseCFG(Message &msg);
        void parseMON(Message &msg);
        void parseAID(Message &msg);
        void parseTIM(Message &msg);
        void parseESF(Message &msg);
};


//Provide enums?
class UBX{

};

class Raw: public UBX{
    private:
    I4 tow;
    I2 week;
    R8 cpMes;
    R8 prMes;
    R4 doMes;
    U1 svNb;
    I1 mesQI;
    I1 cno;
    U1 lli;

    public:
        Raw(uint8_t* payload);
        I4 getTow();
        R8 getWeek();
        U1 getSatnb();
        R8 getCp();
        R8 getPr();
        R4 getDo();
        I1 getQi();
        I1 getCno();
        U1 getLli();

    private:
        void setTow();
        void setWeek();
        void setSatnb();
        void setCp();
        void setPr();
        void setDo();
        void setQi();
        void setCno();
        void setLli();
};

#endif
