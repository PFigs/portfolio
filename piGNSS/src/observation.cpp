/**
 * @file observation.cpp
 *
*/

#include "observation.h"

pthread_mutex_t waitforpoll;
pthread_mutex_t logwrite;
pthread_mutex_t death;
pthread_mutex_t interrupt;
std::string arduino;
uint8_t externRead;

void handleInterrupt(void){
    #ifdef TRACE
    T(std::cout,  "Enters handleInterrupt");
    #endif
    // it it is locked (avoids undefined behaviour)
    std::cout << "INTERRUPT" << std::endl;
    if(pthread_mutex_trylock(&interrupt)!=0){
        pthread_mutex_unlock(&interrupt);
        std::cout << "unlocked mutex" << std::endl;
    }else{
        std::cout << "Kept mutex" << std::endl;
    }

}


void *Observation::pollData(void *context){
    #ifdef TRACE
    std::cout << "Entered Observation::pollData" << std::endl;
    #endif
    int fd;

    pthread_mutex_lock(&waitforpoll);

    fd = ::open(arduino.c_str(), O_RDWR | O_NOCTTY);
    if(fd < 0) ERROR();

    /* set the other settings (in this case, 9600 8N1) */
    struct termios settings;

    tcflush(fd, TCOFLUSH);
    tcgetattr(fd, &settings);
    cfsetospeed(&settings, B9600); /* baud rate */
    // from man - raw mode
    settings.c_iflag    &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | INPCK | ICRNL | IXON);
    settings.c_oflag    &= ~OPOST;
    settings.c_lflag    &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
    settings.c_cflag    &= ~(CSIZE | PARENB);
    settings.c_cflag    &= ~(CRTSCTS);
    settings.c_cflag    |= CS8;
    settings.c_cc[VMIN]  = 1;
    settings.c_cc[VTIME] = 1;

    while(1){
        std::cout<<"pollData: waiting for interrupt"<<std::endl;
        uint8_t buffer[10];
        int     nrcv;
        memset((void *)buffer,'\0',sizeof(buffer));
        // no need to do work if dead right?

        //pthread_mutex_lock(&interrupt);
        pthread_mutex_lock(&logwrite);
        pthread_mutex_unlock(&waitforpoll);
        if(pthread_mutex_trylock(&death) == 0){
            pthread_mutex_unlock(&logwrite);
            std::cout<<"pollData: dying"<<std::endl;
            break;
        }

        P(std::cout,"pollData: doing work");
        nrcv = read(fd, buffer, sizeof(buffer));
        std::cout << "READ A TOTAL OF " << nrcv << " bytes" << std::endl;
        std::cout << "ARDUINO sent: ";
        for(int i =0; i < nrcv ;i++){
            std::cout << int(buffer[i]);
        }
        externRead = buffer[0];
        pthread_mutex_unlock(&logwrite);
        pthread_mutex_lock(&waitforpoll);
        std::cout << std::endl;

    }

    pthread_exit(NULL);
    return NULL;
}


void Ephemerides::init(ieph &value){

    e        = value;
    m0       = value;
    dn       = value;
    i0       = value;
    cuc      = value;
    cus      = value;
    crc      = value;
    cic      = value;
    cis      = value;
    toe      = value;
    idot     = value;
    iode     = value;
    sqra     = value;
    omega    = value;
    omega0   = value;
    omegadot = value;

}


// ********************
// *  Satellite       *
// ********************


Satellite::Satellite(){
    #ifdef TRACE
    T(std::cout, "Entering Satellite::Satellite");
    #endif

    age=0; codeL1=0; codeL2=0; phaseL1=0; phaseL2=0;
};


Satellite::~Satellite(){
    #ifdef TRACE
    T(std::cout, "Entering Satellite::~Satellite");
    #endif

};


/**
 * @brief Returns an updated value for the satellite azimuth
 */
int Satellite::getAzimuth(){return calcAzimuth();};

/**
 * @brief Returns an updated value for the satellite elevation
 */
int Satellite::getElevation(){return calcElevation();};


/**
 * @brief Retrieves the code measurements for the given type (L1 or L2)
 */
int Satellite::getCode(int &type){
    #ifdef TRACE
    T(std::cout, "Enters Satellite::getCode");
    #endif
    int value;

    switch(type){
        case Satellite::L1:
            value = codeL1;
            break;

        case Satellite::L2:
            value = codeL2;
            break;

        default:
            value = -1;
            break;
    }

    return value;
};


/**
 * @brief Retrieves the phase measurements for the given type (L1 or L2)
 */
int Satellite::getPhase(int &type){
    #ifdef TRACE
    T(std::cout, "Enters Satellite::getPhase");
    #endif

    int value;

    switch(type){
        case Satellite::L1:
            value = phaseL1;
            break;

        case Satellite::L2:
            value = phaseL2;
            break;

        default:
            value = -1;
            break;
    };


    return value;
};



int Satellite::calcAzimuth(){return -1;};
int Satellite::calcElevation(){return -1;};


// ********************
// *  Constellation   *
// ********************

Constellation::Constellation(){
    #ifdef TRACE
    T(std::cout, "Enters Constellation::Constellation");
    #endif
    sats = 0;
};

Constellation::Constellation(int &num){
    #ifdef TRACE
    T(std::cout, "Enters Constellation::Constellation");
    #endif
    sats = new Satellite[num];
    nSat    = 0; // seen but with/without data
    nLocked = 0; // seen with data
};
Constellation::~Constellation(){
    #ifdef TRACE
    T(std::cout, "Enters Constellation::~Constellation");
    #endif
    if(sats)
        delete[] sats;
};


bool Constellation::addSat(Satellite &sat){
    #ifdef TRACE
    T(std::cout, "Enters Constellation::addSat");
    #endif
    return false;
};


bool Constellation::rmSat(unsigned int satid){return false;};


// ********************
// *  Observation     *
// ********************

Observation::Observation():msg(){
    #ifdef TRACE
    T(std::cout, "Enters Observation::Observation");
    #endif

    receiver   = std::string("ubx");
    location   = std::string("/dev/ttyACM0");
    arduino    = std::string("/dev/ttyACM0");
    //terminal;
    serverip   = std::string("0.0.0.0");
    serverport = 0;
    localport  = 0;
    nfds       = 1;
    server     = false;
    gps        = false;
    acc        = false;
    gyr        = false;
    mag        = false;
    wfile      = false;
    rfile      = false;
    newdata    = false;
    poll       = false;
    config     = false;

    device     = NULL;
    system     = NULL;
    fdselector = NULL;
    udpclient  = NULL;
    udpserver  = NULL;
    bfile      = NULL;
    log        = NULL;
}


Observation::~Observation(){
    #ifdef TRACE
    T(std::cout, "Enters Observation::~Observation");
    #endif
    if(device) delete device;
    if(system) delete system;
    if(fdselector) delete fdselector;
    if(udpclient) delete udpclient;
    if(udpserver) delete udpserver;
    if(bfile) delete bfile;
    if(log) delete log;
    if(poll){
        pthread_mutex_unlock(&death);
        if(pthread_mutex_trylock(&interrupt)!=0)
            pthread_mutex_unlock(&interrupt);
        pthread_join(tid_poll,NULL);
    }
};


//! \todo message parsing
void Observation::getData(){/*change return to Message*/};
bool Observation::processData(Constellation &system){return false;};
void Observation::share(){};
void Observation::save(){};
bool Observation::createConstellation(){return false;};
bool Observation::createCommunication(){return false;};
bool Observation::updateConstellation(){return false;};
bool Observation::updateStatistic(){return false;};
int Observation::getNumDevices(){return nfds;}

void Observation::init(int argc, char ** argv){
    #ifdef TRACE
    T(std::cout, "Initialising observation");
    #endif

    doInputParse(argc,argv);
    doInitialisation();
}

/**
 * @brief Parses cmdl for parameters
 *
 * This function receives the cmdl arguments and parses its contents, setting
 * up the settings struct.
 *
 */
void Observation::doInputParse(int argc, char ** argv){
    #ifdef TRACE
    T(std::cout, "Enters Observation::parseinputs");
    #endif

    //Send this to an input parser
    std::string parameter;
    for(int i=1;i<argc;i=i+2){
        parameter = argv[i];
        #ifdef DEBUG_OBS
        std::cout << "Evaluating (#" << i <<"): " << parameter << std::endl;
        #endif
        if(COMPARE(parameter,"--help")){ //helps with usage
            #ifdef DEBUG_OBS
            std::cout << "Showing helper" << std::endl;
            #endif

        }else if(COMPARE(parameter,"--serial")){ //changes com port
            #ifdef DEBUG_OBS
            std::cout << "Setting serial port " << location << std::endl;
            #endif
            location = argv[i+1];
            gps = true; // assumes default name
            #ifdef DEBUG_OBS
            std::cout << "Changed serial port to " << location << std::endl;
            #endif

        }else if(COMPARE(parameter,"--receiver")){ //receiver
            #ifdef DEBUG_OBS
            std::cout << "Setting receiver " << receiver << std::endl;
            #endif
            receiver = argv[i+1];
            nfds++;
            gps = true;
            #ifdef DEBUG_OBS
            std::cout << "Changed receiver to " << receiver << std::endl;
            #endif

        }else if(COMPARE(parameter,"--gps")){ //toggle gps
            #ifdef DEBUG_OBS
            std::cout << "Setting gps status " << gps << std::endl;
            #endif
            gps = atoi(argv[i+1]) == 1;
            #ifdef DEBUG_OBS
            std::cout << "Changed gps status to " << gps << std::endl;
            #endif

        }else if(COMPARE(parameter,"--output-file")){ //toggle log
            #ifdef DEBUG_OBS
            std::cout << "Setting output file" << outfile << std::endl;
            #endif
            outfile = argv[i+1];
            wfile   = true;
            #ifdef DEBUG_OBS
            std::cout << "Changed output file to " << outfile << std::endl;
            #endif

        }else if(COMPARE(parameter,"--acc")){ //sets accelerometer
            #ifdef DEBUG_OBS
            std::cout << "Setting accelerometer " << acc << std::endl;
            #endif
            acc = atoi(argv[i+1]) == 1;
            if(acc) nfds++;
            #ifdef DEBUG_OBS
            std::cout << "Changed accelerometer to " << acc << std::endl;
            #endif

        }else if(COMPARE(parameter,"--gyr")){ //sets gyroscope
            #ifdef DEBUG_OBS
            std::cout << "Setting gyroscope " << gyr << std::endl;
            #endif
            gyr = atoi(argv[i+1]) == 1;
            if(gyr) nfds++;
            #ifdef DEBUG_OBS
            std::cout << "Changed gyroscope to " << gyr << std::endl;
            #endif

        }else if(COMPARE(parameter,"--mag")){ //sets magnetometer
            #ifdef DEBUG_OBS
            std::cout << "Setting magnetometer "<< mag << std::endl;
            #endif
            mag = atoi(argv[i+1]) == 1;
            if(mag) nfds++;
            #ifdef DEBUG_OBS
            std::cout << "Changed magnetometer to "<< mag << std::endl;
            #endif

        }else if(COMPARE(parameter,"--remote")){ //sets host location
            #ifdef DEBUG_OBS
            std::cout << "Setting host location "<< mag << std::endl;
            #endif
            serverip = argv[i+1]; // ip
            server   = true;
            nfds++;
            #ifdef DEBUG_OBS
            std::cout << "Changed host location to "<< mag << std::endl;
            #endif

        }else if(COMPARE(parameter,"--remote-port")){ //sets remote port
            #ifdef DEBUG_OBS
            std::cout << "Setting host port "<< mag << std::endl;
            #endif
            serverport = atoi(argv[i+1]);
            #ifdef DEBUG_OBS
            std::cout << "Changed host port to "<< mag << std::endl;
            #endif

        }else if(COMPARE(parameter,"--listening-port")){ //sets listening port
            #ifdef DEBUG_OBS
            std::cout << "Setting listening port "<< mag << std::endl;
            #endif
            localport = atoi(argv[i+1]);
            nfds++;
            #ifdef DEBUG_OBS
            std::cout << "Changed listening port to "<< mag << std::endl;
            #endif

        }else if(COMPARE(parameter,"--input-file")){ //sets input file
            #ifdef DEBUG_OBS
            std::cout << "Setting input file "<< infile << std::endl;
            #endif
            infile = argv[i+1];
            rfile = true;
            nfds++;
            #ifdef DEBUG_OBS
            std::cout << "Changed input file to "<< infile << std::endl;
            #endif

        }else if(COMPARE(parameter,"--obd")){ //sets input file
            #ifdef DEBUG_OBS
            std::cout << "Setting poll thread "<< poll << std::endl;
            #endif
            poll = true;
            #ifdef DEBUG_OBS
            std::cout << "Changed poll thread to "<< poll << std::endl;
            #endif
        }else if(COMPARE(parameter,"--configuration")){ //sets input file
            #ifdef DEBUG_OBS
            std::cout << "Setting poll thread "<< poll << std::endl;
            #endif
            fconfig = std::string(argv[i+1]);
            config = true;
            #ifdef DEBUG_OBS
            std::cout << "Changed poll thread to "<< poll << std::endl;
            #endif
        }
    }
}




/**
 * @brief opens and saves file descriptors
 *
 * The devices are initialised and their file descriptors saved inside the select object.
 *
 */
void Observation::doInitialisation(){
    #ifdef TRACE
    T(std::cout, "Enters Observation::initialiseComm");
    #endif

    /// \todo initialise system
    // create select object
    fdselector = new Select(nfds);

    #ifdef RPI
    if (wiringPiSetup () == -1){
        std::cerr << __FILE__ << __LINE__ << strerror(errno) << std::endl;
        exit(EXIT_FAILURE);
    }
    #endif

    // open fd for gps
    if(gps){
        device     = new uBlox(receiver,location, 0xB5, 0x62, '\n');
        fdselector->savefd(device->init(),EXECUTION::R_GPS);
        if(config) device->configure(fconfig);
        device->setStatus(true); // forces device as up (might have been wrongly set during config)
    }

    // if server
    if(server){
        udpclient = new Client(std::string("localhost"),serverport);
        udpserver = new Server(std::string("dontcare"),localport);
        fdselector->savefd(udpclient->init(),EXECUTION::W_SERVER); // does not receive answer
        fdselector->savefd(udpserver->init(),EXECUTION::R_SERVER); // does not reply
    }

    // if there is a file to read
    if(rfile){
        bfile = new BinFile(std::string("binary file"), infile, 0xB5, 0x62, '\n');
        fdselector->savefd(bfile->init(),EXECUTION::R_FILE);
    }

    // if there is a log to update
    if(wfile){
        log = new BinFile(std::string("binary log file"), outfile, 0xB5, 0x62, '\n');
        fdselector->savefd(log->init(),EXECUTION::W_FILE);

        if (pthread_mutex_init(&logwrite, NULL) != 0){
            std::cerr << __FILE__ << __LINE__ << strerror(errno) << std::endl;
            exit(EXIT_FAILURE);
        }
    }

    if(poll){
        // creates mutex and locks thread's death
        if (pthread_mutex_init(&death, NULL) != 0){
            std::cerr << __FILE__ << __LINE__ << strerror(errno) << std::endl;
            exit(EXIT_FAILURE);
        }
        pthread_mutex_lock(&death);

        if (pthread_mutex_init(&waitforpoll, NULL) != 0){
            std::cerr << __FILE__ << __LINE__ << strerror(errno) << std::endl;
            exit(EXIT_FAILURE);
        }

        #ifdef RPI
        if (pthread_mutex_init(&interrupt, NULL) != 0){
            std::cerr << __FILE__ << __LINE__ << strerror(errno) << std::endl;
            exit(EXIT_FAILURE);
        }

        if(pthread_mutex_lock(&interrupt)==0)
            std::cout << "GOT LOCKED!" << std::endl;
        else
            std::cout << "NOT LOCKED!" << std::endl;

        if(wiringPiISR(0,INT_EDGE_RISING,handleInterrupt)==-1){
            std::cerr << __FILE__ << __LINE__ << strerror(errno) << std::endl;
            exit(EXIT_FAILURE);
        }

        #endif
        if(pthread_create(&tid_poll, NULL, Observation::pollData, NULL)){
            std::cerr << __FILE__ << __LINE__ << strerror(errno) << std::endl;
            exit(EXIT_FAILURE);
        }

    }
    // at least the stdin will be read
    fdselector->savefd(STDIN_FILENO,EXECUTION::R_STDIN);

}


/**
 * @brief waits on select
 *
 * This method is to be called in a loop, in other to continuously wait for new information in
 * the file descriptors passed on to the select object
 *
 */
void Observation::wait(){
    #ifdef TRACE
    T(std::cout, "Enters Observation::wait");
    #endif
    //wait on available fd
    fdselector->wipesets();
    fdselector->setfdread(EXECUTION::R_STDIN);
    if(gps)    fdselector->setfdread(EXECUTION::R_GPS);
    if(rfile)  fdselector->setfdread(EXECUTION::R_FILE);   //fdselector->setfdwrite(EXECUTION::W_FILE); // dont care for now
    if(server) fdselector->setfdread(EXECUTION::R_SERVER); //fdselector->setfdwrite(EXECUTION::W_SERVER); // dont care for now
    fdselector->waitonselect();
}

/**
 * @brief tests descriptors for new information
 *
 * Each descriptor is tested and if it flagged, then the checkfd function returns the state to jump to.
 *
 */
void Observation::execute(bool &run){
    #ifdef TRACE
    T(std::cout, "Enters Observation::execute");
    #endif
    /// \todo change to a vector of devices

    // act on changes with the following priority
    for(int i=0;i<fdselector->getactive();i++){
        D(std::cout,fdselector->getactive());
        switch(fdselector->checkfd(i) /*check first to last saved*/){
            case EXECUTION::R_GPS:
                #ifdef DEBUG_OBS
                P(std::cout, "reading GNSS");
                #endif
                device->acquire(msg);
                break;

            case EXECUTION::W_SERVER:
                #ifdef DEBUG_OBS
                P(std::cout, "sending remote message");
                #endif
                // dont care for now
                break;

            case EXECUTION::R_SERVER:
                #ifdef DEBUG_OBS
                P(std::cout, "received remote message");
                #endif
                //reads maximum ublox message! (datagram)
                //udpserver->callgetdata(msg);
                break;

            case EXECUTION::R_STDIN: /// \todo create object for terminal reading
                #ifdef DEBUG_OBS
                P(std::cout, "reading terminal information");
                #endif

                //define this as device ;)
                std::getline(std::cin, terminal);
                std::cout << "got: "<< terminal << std::endl;

                if(terminal[0]=='q') run = false;
                if(terminal[0]=='r') device->reset();

                terminal.clear();
                break;

            case EXECUTION::R_FILE:
                #ifdef DEBUG_OBS
                P(std::cout, "reading from local file")
                #endif

                // reads and waits for read descriptor until eof
                bfile->acquire(msg);
                bfile->decode(msg);
                //bfile->parseData(msg);

                if(!bfile->getStatus()){
                    rfile = false;
                    msg.setEmpty();
                }
                break;

            default:
                #ifdef DEBUG_OBS
                P(std::cout, "Nothing to be done, checking next fd");
                #endif
                break;

        }

        if(device){
            while(!device->empty()){
                device->decode(msg);
                device->parse(msg);
                device->process(msg);

                // Store and send information
                if(msg.ready()){
                    #ifdef TRACE
                    T(std::cout,  "Storing data");
                    #endif

                    //speed is always saved before raw
                    if(log && poll && msg.getClass() == 0x02 && msg.getId() == 0x10){
                        Message speed(10);
                        speed.setHeaderH(0xB5);
                        speed.setHeaderL(0x62);
                        speed.setClass(0x03);
                        speed.setId(0x00);
                        speed.setLengthL(0x01);
                        speed.setLengthH(0x00);
                        pthread_mutex_lock(&waitforpoll);
                        pthread_mutex_lock(&logwrite);
                        speed.setPayload(externRead);
                        speed.setReady();
                        log->sendData(speed);
                        pthread_mutex_unlock(&waitforpoll);
                        pthread_mutex_unlock(&logwrite);
                    }

                    if(log) log->sendData(msg);
                    msg.setEmpty();
                }
            }
        }
    }
}


