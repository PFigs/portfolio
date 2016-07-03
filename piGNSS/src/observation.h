/**
 * @file observation.h
 *
 */

#ifndef OBSERVATION_H
#define OBSERVATION_H


#include <pthread.h>
#include "communication/message.h"
#include "communication/communication.h"
#include "communication/ublox.h"
#include "common.h"
#include "select.h"
#include "communication/webserver.h"
#include "communication/binfile.h"

#ifdef RPI
#include <wiringPi.h>
#include "obd/obd.h"
#endif

#define COMPARE(P,STR) !P.compare(STR)
#define UBXH 0xB5
#define UBXL 0x62



extern pthread_mutex_t death;

class Ephemerides{
    public:
    typedef double ieph;
    private:
        ieph e;
        ieph m0;
        ieph dn;
        ieph i0;
        ieph cuc;
        ieph cus;
        ieph crc;
        ieph cic;
        ieph cis;
        ieph toe;
        ieph idot;
        ieph iode;
        ieph sqra;
        ieph omega;
        ieph omega0;
        ieph omegadot;

    public:
        Ephemerides(){};
        ~Ephemerides(){};


    private:
        void init(ieph &value);

};



/*!
 * @class Satellite
 *
 * @brief contains all the information regarding a single satellite
 *
*/
class Satellite{
    public:
        enum SIGNALS{L1,L2,L1L2};

    private:
        unsigned int age;
        //Ephemeride ephemerides;
        int codeL1; //consider creating measurements object ;)
        int codeL2;
        int phaseL1;
        int phaseL2;
        Ephemerides eph;

    public:
        Satellite();
        ~Satellite();
        int getAzimuth();
        int getElevation();
        int getCode(int &type);
        int getPhase(int &type);
        //Ephemeride getEphemerides();
        //void setEphemerides(Ephemeride ephmeride);

    private:
        int calcAzimuth();
        int calcElevation();
};



/*!
 * @class Constellation
 *
 * @brief contains the satellites that make up the seen and observed constellation
 *
*/
class Constellation{
    public:
        enum GNSS{GPS,GALILEO,GLONASS,GPSGLO,GPSGAL,GALGLO,GPSGLOGAL};

    private:
        unsigned int nSat;
        unsigned int nLocked;
        Satellite *sats;

    public:
        Constellation();
        Constellation(int &num);
        ~Constellation();
        bool addSat(Satellite &sat);
        bool rmSat(unsigned int satid);
};

/*!
 * @class Observation
 *
 * @brief master class serving as data collector
 *
 * This class is responsible for the object flow between reading, storage and processing.
 *
*/
class Observation{
    private:
        /// \todo IMPROVE: merge bfile with log, udpclient with udpserver (simplify access with array?)
        Communication *device; //! Holders a generic device
        Communication *bfile;  //! Points to binary input file
        BinFile       *log;    //! Points to binary output file
        Constellation *system; //! Keeps the satellites and their information
        Select        *fdselector;
        Client        *udpclient; /// \todo this is also a Communication!
        Server        *udpserver;

        pthread_t       tid_poll;

        std::string   receiver;
        std::string   location;
        std::string   terminal;
        std::string   serverip;
        std::string   infile;
        std::string   outfile;
        std::string   fconfig;

        Message       msg;

        int           serverport;
        int           localport;
        int           nfds;

        bool          poll;
        bool          acc;
        bool          gyr;
        bool          mag;
        bool          gps;
        bool          server;
        bool          rfile;
        bool          wfile;
        bool          newdata;
        bool          config;

    public:
        Observation();
        ~Observation();
        void              init(int argc, char ** argv);
        void              getData();
        bool              processData(Constellation &system);
        void              share();
        void              save();
        void              wait();
        int               getgpsfd();
        int               getNumDevices();
        void              execute(bool &run);
        static void       *pollData(void *context);

    private:
        virtual void doInputParse(int argc, char ** argv);
        virtual void doInitialisation();
        bool createConstellation(); //! Initialises constellation
        bool createCommunication(); //! Opens communication link
        bool updateConstellation();
        bool updateStatistic();
};
#endif
