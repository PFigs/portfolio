/**
 * @file ublox.cpp
 *
 * @brief Contains the implementations necessary for communicating with an uBlox receiver
 *
 * @author Pedro Silva
 */

#include "ublox.h"

/**
* @brief constructs ublox object
*
* Requires a name (eg, model), location and the header to look for during serial read.
*
* */
uBlox::uBlox(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator, int const &size):Communication(name,location,high_header,low_header,terminator, size){
    #ifdef TRACE
    T(std::cout, "Enters uBlox::uBlox");
    #endif
    retries = 0;
    #ifdef DEBUG_UBX
    std::cout << "Enters uBlox::uBlox(" << getName() << "," << getLocation() << ")" <<std::endl;
    #endif

}

uBlox::uBlox(std::string const &name, std::string const &location, int const &high_header, int const &low_header, int const &terminator):Communication(name,location,high_header,low_header,terminator){
    #ifdef TRACE
    T(std::cout, "Enters uBlox::uBlox");
    #endif
    retries = 0;
    #ifdef DEBUG_UBX
    std::cout << "Enters uBlox::uBlox(" << getName() << "," << getLocation() << ")" <<std::endl;
    #endif

}

/**
 * @brief Closes open descriptor
 *
 * Guarantees that the serial port descriptor is closed on exit
 *
 */
uBlox::~uBlox(){
    #ifdef TRACE
    T(std::cout, "Enters uBlox::~uBlox");
    #endif
    #ifdef DEBUG_UBX
    P(std::cout,  "Enters uBlox::~uBlox");
    #endif
    if(getFd())
        ::close(getFd());
}



/**
 * @brief Opens serial port
 *
 * The serial port is configured to read the uBlox receiver in the
 * ACM0 port
 *
 */
void uBlox::doInit(int &fd){
    #ifdef TRACE
    T(std::cout,  "Enters Ublox::open");
    #endif

    fd = ::open(getLocation().c_str(), O_RDWR | O_NOCTTY); // Open perif
    if(fd < 0) ERROR();

    /* set the other settings (in this case, 9600 8N1) */
    struct termios settings;

    tcflush(fd, TCOFLUSH);
    tcgetattr(fd, &settings);
    cfsetospeed(&settings, baud); /* baud rate */
    // from man - raw mode
    settings.c_iflag    &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | INPCK | ICRNL | IXON);
    settings.c_oflag    &= ~OPOST;
    settings.c_lflag    &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
    settings.c_cflag    &= ~(CSIZE | PARENB);
    settings.c_cflag    &= ~(CRTSCTS);
    settings.c_cflag    |= CS8;
    settings.c_cc[VMIN]  = 0;
    settings.c_cc[VTIME] = 0;

    tcsetattr(fd, TCSADRAIN, &settings); /* apply the settings */

    setStatus(true);
}


/**
 * @brief Configures the receiver
 *
 * The target files are converted to binary format and dumped through
 * the serial port.
 *
 */
void uBlox::doConfiguration(int const &fd, std::string const &filename){
    #ifdef TRACE
    T(std::cout, "Enters Communication::doConfiguration");
    #endif

    // open file and send each line to the device
    std::ifstream file(filename.c_str());
    //assert(file.is_open());

    std::string line;
    Message msg;
    char  hex[3]; hex[2] = '\0';
    unsigned short int value = 0;
    unsigned short int tries = 0;
    while(file.good()){
        std::getline(file,line);
        cleanstring(line);
        std::string::iterator it = line.begin();
        for(unsigned int i = 0;it!=line.end();it+=2,i++){
            hex[0] = *it;
            hex[1] = *(it+1);
            sscanf(hex,"%hx\n", &value);
            doWrite(fd, &value,1);
        }
        do{
            acquire(msg);
            decode(msg);
            parse(msg);
        }while(!msg.ready() && tries++ < 3);
        tries = 0;
    }
    tcflush(fd, TCOFLUSH);
    file.close();
}




int uBlox::doWrite(int const &fd, void const *buffer,unsigned int const &size){
    #ifdef TRACE
    T(std::cout, "Enters Communication::doWrite");
    #endif
    int n = 0;
    if((n = write(fd,buffer,size))<0) ERROR();
    return n;
}



bool uBlox::doReset(int const &fd){
    #ifdef TRACE
    T(std::cout, "Enters uBlox::doReset");
    #endif

    std::string line = std::string("B56206040400FFFF02000E61");
    Message msg;
    char  hex[3]; hex[2] = '\0';
    unsigned short int value = 0;
    int nwr = 0;
    std::string::iterator it = line.begin();
    for(unsigned int i = 0;it!=line.end();it+=2,i++){
        hex[0] = *it;
        hex[1] = *(it+1);
        sscanf(hex,"%hx\n", &value);
        nwr = doWrite(fd, &value,1);
    }

    return nwr > 0;
}


void uBlox::doDecoding(int &fsm, CommBuffer &cb, Message &msg, uint8_t *headers){

    #ifdef TRACE
    T(std::cout,  "Enters uBlox::doDecoding");
    #endif

    #ifdef DEBUG_UBX
    D(std::cout, cb.reserve());
    #endif

    #ifdef DEBUG_UBX
//    P(std::cout, "PRINTING CIRCULAR BUFFER");
//    D(std::cout, cb.size());
//    int aux =1;
//    for(CommBuffer::iterator it = cb.begin();it!=cb.end();it++){
//        std::cout << std::hex << std::setw(2) << std::setfill('0') << int(*it) << ' ';
//        std::cout << ' ';
//        if(aux%4 == 0) std::cout << "  ";
//        if(aux%16 == 0) std::cout << std::endl;
//        aux++;
//    }
//    //BRK();
//    D(std::cout,cb.size());
//    D(std::cout,msg.ready());
    #endif
    uint8_t *aux;
    // looks for messages in the buffer
    for(CommBuffer::iterator head = cb.begin();head!=cb.end() && !msg.ready();cb.pop_front(),head = cb.begin()){
        uint8_t top = *head;
        switch(fsm){
            case uBlox::LOOKING:
                if(top == headers[0]){
                    fsm = uBlox::CONFIRMING;
                    msg.setHeaderH(top);
                    #ifdef DEBUG_UBX
                    P(std::cout,"HEADER START");
                    H(std::cout,int(top));
                    std::cout << msg << std::endl;
                    //BRK();
                    #endif
                }else{
                    #ifdef DEBUG_UBX
                    P(std::cout,"SYNCING");
                    H(std::cout,int(top));
                    std::cout << msg << std::endl;
                    #endif
                }
                break;

            case uBlox::CONFIRMING:
                if(top == headers[1]){
                    msg.setHeaderL(top);
                    fsm = uBlox::EXT_CLASS;
                    #ifdef DEBUG_UBX
                    P(std::cout,"HEADER CONFIRMED");
                    H(std::cout,int(top));
                    std::cout << msg << std::endl;
                    //BRK();
                    #endif
                }else{
                    msg.setEmpty();
                    fsm = uBlox::LOOKING;
                    #ifdef DEBUG_UBX
                    P(std::cout,"FALSE ALARM");
                    H(std::cout,int(top));
                    #endif
                }
                break;

            //checksum only valid from now on
            case uBlox::EXT_CLASS:
                msg.setClass(top); //okay
                fsm = uBlox::EXT_ID;
                #ifdef DEBUG_UBX
                P(std::cout,"GOT CLASS");
                H(std::cout,int(top));
                H(std::cout,int(msg.getCKA()));
                H(std::cout,int(msg.getCKB()));
                std::cout << msg << std::endl;
                //BRK();
                #endif
                break;

            case uBlox::EXT_ID:
                msg.setId(top); //okay
                fsm = uBlox::EXT_LENGTH_L;
                #ifdef DEBUG_UBX
                P(std::cout,"GOT ID");
                H(std::cout,int(top));
                H(std::cout,int(msg.getCKA()));
                H(std::cout,int(msg.getCKB()));
                std::cout << msg << std::endl;
                //BRK();
                #endif
                break;

            case uBlox::EXT_LENGTH_L:
                msg.setLengthL(top);
                fsm = uBlox::EXT_LENGTH_H;
                #ifdef DEBUG_UBX
                P(std::cout,"GOT LENGTH LOWER ADDR");
                H(std::cout,int(top));
                H(std::cout,int(msg.getCKA()));
                H(std::cout,int(msg.getCKB()));
                std::cout << msg << std::endl;
                //BRK();
                #endif
                break;

            case uBlox::EXT_LENGTH_H:
                msg.setLengthH(top);
                fsm = uBlox::EXT_PAYLOAD;
                #ifdef DEBUG_UBX
                P(std::cout,"GOT LENGTH HIGHER ADDR");
                H(std::cout,top);
                H(std::cout,int(msg.getLength()));
                H(std::cout,int(msg.getCKA()));
                H(std::cout,int(msg.getCKB()));
                std::cout << msg << std::endl;
                //BRK();
                #endif
                break;

            case uBlox::EXT_PAYLOAD:
                //up to the given length
                msg.setPayload(top);
                if(msg.getLength() == msg.getPayloadEntries()){
                    fsm = uBlox::EXT_VALIDATE;
                }
                #ifdef DEBUG_UBX
                P(std::cout,"INSERTING PAYLOAD");
                H(std::cout,msg.getLength());
                H(std::cout,msg.getPayloadEntries());
                H(std::cout,top);
                H(std::cout,int(msg.getCKA()));
                H(std::cout,int(msg.getCKB()));
                //BRK();
                #endif
                break;

            case uBlox::EXT_VALIDATE:
                if(top == msg.getCKA()){
                    fsm = uBlox::EXT_FINISH;
                }else{
                    fsm = uBlox::LOOKING;
                    msg.setEmpty();
                }
                #ifdef DEBUG_UBX
                P(std::cout,"CHECKING CKA");
                H(std::cout,top);
                H(std::cout,int(msg.getCKA()));
                H(std::cout,int(msg.getCKB()));
                //BRK();
                #endif
                break;

            case uBlox::EXT_FINISH:
                if(top == msg.getCKB()){
                    msg.setReady();
                }else{
                    msg.setEmpty();
                }

                fsm = uBlox::LOOKING;
                #ifdef DEBUG_UBX
                P(std::cout,"CHECKING CKB");
                H(std::cout,top);
                H(std::cout,int(msg.getCKA()));
                H(std::cout,int(msg.getCKB()));
                aux = msg.getPayload();
                for(int i=0,k=1; i < msg.getLength();i++,k++)
                {
                    std::cout << std::hex << std::setw(2) << std::setfill('0') << int(aux[i]);
                    std::cout << ' ';

                    if(k%4 == 0) std::cout << "  ";
                    if(k%16 == 0) std::cout << std::endl;
                }
                std::cout << std::endl;
                //BRK();
                std::cout << "Printing message" << std::endl;
                std::cout << msg << std::endl;
                //BRK()
                #endif
                break;

            default:
                #ifdef DEBUG_UBX
                P(std::cout, "Should not be here! Bad Decoder!");
                #endif
                break;
        }
    }
}



/**
 * @brief Parses message data into the internal structures
 *
 * This function receives a message and extracts its contents to the program's data structures. The
 * data must follow the UBX protocol which is defined by
 *
 * |SYNC|SYNC|CLASS|ID|LENGTH|...PAYLOAD...|CK_A|CK_B|
 *
 * NAV 0x01 Navigation Results: Position, Speed, Time, Acc, Heading, DOP, SVs used
 * RXM 0x02 Receiver Manager Messages: Satellite Status, RTC Status
 * INF 0x04 Information Messages: Printf-Style Messages, with IDs such as Error, Warning, Notice
 * ACK 0x05 Ack/Nack Messages: as replies to CFG Input Messages
 * CFG 0x06 Configuration Input Messages: Set Dynamic Model, Set DOP Mask, Set Baud Rate, etc.
 * MON 0x0A Monitoring Messages: Comunication Status, CPU Load, Stack Usage, Task Status
 * AID 0x0B AssistNow Aiding Messages: Ephemeris, Almanac, other A-GPS data input
 * TIM 0x0D Timing Messages: Timepulse Output, Timemark Results
 * ESF 0x10 External Sensor Fusion Messages: External sensor measurements and status information
 */
void uBlox::doParsing(Message &msg){

    #ifdef TRACE
    T(std::cout,  "Enters uBlox::doParsing");
    #endif

    // Identify the message class fill in constellation data
    switch(msg.getClass()){

        case UBX_NAV:
            #ifdef DEBUG
            P(std::cout,"NAV");
            #endif
            parseNAV(msg);
            break;

        case UBX_RXM:
            #ifdef DEBUG
            P(std::cout,"RXM");
            #endif
            parseRXM(msg);
            break;

        case UBX_INF:
            #ifdef DEBUG
            P(std::cout,"INF");
            #endif
            parseINF(msg);
            break;

        case UBX_ACK:
            #ifdef DEBUG
            P(std::cout, "ACK");
            #endif
            parseACK(msg);
            break;

        case UBX_CFG:
            #ifdef DEBUG
            P(std::cout,"CFG");
            #endif
            parseCFG(msg);
            break;

        case UBX_MON:
            #ifdef DEBUG
            P(std::cout,"MON");
            #endif
            parseMON(msg);
            break;

        case UBX_AID:
            #ifdef DEBUG
            P(std::cout,"AID");
            #endif
            parseAID(msg);
            break;

        case UBX_TIM:
            #ifdef DEBUG
            P(std::cout,"TIM");
            #endif
            parseTIM(msg);
            break;

        case UBX_ESF:
            #ifdef DEBUG
            P(std::cout,"ESF");
            #endif
            parseESF(msg);
            break;

        default:
            #ifdef DEBUG
            P(std::cout,"IGNORING UBX CLASS");
            H(std::cout, msg.getClass());
            #endif
            break;

    }
}


void uBlox::doProcessing(Message &msg, int &fsm){
    #ifdef TRACE
    T(std::cout,  "Enters uBlox::doProcessing");
    #endif
    bool wait = false;
    do{
        switch(fsm){
            case uBlox::WAITING: /*When waiting for ephs*/
                #ifdef TRACE
                T(std::cout,  "Enters uBlox::WAITING");
                #endif
                //until first message
                if(msg.getClass() == 0x0B && msg.getId() == 0x31){
                    fsm = uBlox::EPHDUMP;
                }else{
                    msg.setEmpty();
                    if(retries==0){
                        fsm = uBlox::POLLEPH;
                        retries = 500;
                    }else{
                        retries--;
                    }
                }
                wait = false;
            break;

            case uBlox::READY:
                #ifdef TRACE
                T(std::cout,  "Enters uBlox::READY");
                #endif
                // Ignores ACK messages
                if(msg.getClass() == 0x05 && msg.getId() == 0x01){
                    msg.setEmpty();
                }
                break;

            case uBlox::CFGTM:
                #ifdef TRACE
                T(std::cout,  "Enters uBlox::CFGTM");
                #endif
                flush();
                sendcommand(std::string("B56206312000000000000000000001000000010000000000008099999919000000006F0000002CCD"));
                sendcommand(std::string("B562063101000038E5"));
                sendcommand(std::string("B56206312000001142000000000001000000010000000000008099999919000000006F0000007F98"));
                fsm = uBlox::READY;
                msg.setEmpty();
                break;


            case uBlox::EPHDUMP: /*Getting RAW*/
                #ifdef TRACE
                T(std::cout,  "Enters uBlox::DUMP");
                #endif
                if(msg.getClass() == 0x02 && msg.getId() == 0x10){
                    fsm = uBlox::CFGTM;
                }
                wait = false;
                break;

            case uBlox::POLLEPH:
                #ifdef TRACE
                T(std::cout,  "Enters uBlox::POLLEPH");
                #endif
                sendcommand(std::string("B5620B3100003CBF"));
                fsm  = uBlox::WAITING;
                wait = true;
                break;

            case uBlox::POLLHUI:
                #ifdef TRACE
                T(std::cout,  "Enters uBlox::POLLHUI");
                #endif
                sendcommand(std::string("B5620B0200000D32"));
                fsm = uBlox::READY;
                wait = false;
                break;

            default:
                #ifdef TRACE
                T(std::cout,  "Enters uBlox::DEFAULT");
                #endif
                fsm = uBlox::WAITING;
                wait = true;
                break;
        }
        // go to filters
    }while(wait);
}

void uBlox::sendcommand(std::string const &line){
    char  hex[3]; hex[2] = '\0';
    unsigned short int value = 0;
    int nwr = 0;
    uint8_t buffer[line.size()/2];
    std::string::const_iterator it = line.begin();

    for(unsigned int i = 0;it!=line.end();it+=2,i++){
        buffer[i] = hex2uint8(*it, *(it+1));
        std::cout << int(buffer[i]) << ' ';
    }
    std::cout << std::endl;
    nwr = doWrite(getFd(), buffer,sizeof(buffer));
}


void uBlox::parseNAV(Message &msg){
    #ifdef TRACE
    T(std::cout,  "Enters uBlox::parseNAV");
    #endif
};

void uBlox::parseRXM(Message &msg){
    #ifdef TRACE
    T(std::cout,  "Enters uBlox::parseRXM");
    #endif
};

void uBlox::parseINF(Message &msg){
    #ifdef TRACE
    T(std::cout,  "Enters uBlox::parseINF");
    #endif
};

bool uBlox::parseACK(Message &msg){
    #ifdef TRACE
    T(std::cout,  "Enters uBlox::parseACK");
    #endif

    uint8_t *payload = msg.getPayload();
    bool ACK = false;

    switch(msg.getId()){
        case UBX_ACK_NAK:
            #ifdef DEBUG_UBX
            P(std::cout,"UBX_ACK_NAK");
            #endif
            ACK = false;
            break;

        case UBX_ACK_ACK:
            #ifdef DEBUG_UBX
            P(std::cout,"UBX_ACK_ACK");
            #endif
            ACK = true;
            break;

        default:
            #ifdef DEBUG_UBX
            P(std::cout,"Unknown ACK message");
            #endif
            break;
    }

    // ACK class ID
    uint8_t mclass = payload[0];
    uint8_t mid    = payload[1];

    if(printMessageIdentifier(std::cout << (ACK?colourstr(BOLD_GREEN,"ACK "):colourstr(BOLD_RED,"NAK ")),mclass,mid) && ACK);
        return true;
    return false;
};


void uBlox::parseCFG(Message &msg){
    #ifdef TRACE
    T(std::cout,  "Enters uBlox::parseCFG");
    #endif

    #ifdef DEBUG
    D(std::cout, colourstr(BOLD_GREEN,"CFG"));
    #endif
};

void uBlox::parseMON(Message &msg){
    #ifdef TRACE
    T(std::cout,  "Enters uBlox::parseMON");
    #endif

    #ifdef DEBUG
    D(std::cout, colourstr(BOLD_GREEN,"MON"));
    #endif
};

void uBlox::parseAID(Message &msg){
    #ifdef TRACE
    T(std::cout,  "Enters uBlox::parseAID");
    #endif

    #ifdef DEBUG
    D(std::cout, colourstr(BOLD_GREEN,"AID"));
    #endif
};

void uBlox::parseTIM(Message &msg){
    #ifdef TRACE
    T(std::cout,  "Enters uBlox::parseTIM");
    #endif

    #ifdef DEBUG
    D(std::cout, colourstr(BOLD_GREEN,"TIM"));
    #endif
};

void uBlox::parseESF(Message &msg){
    #ifdef TRACE
    T(std::cout,  "Enters uBlox::parseESF");
    #endif

    #ifdef DEBUG
    D(std::cout, colourstr(BOLD_GREEN,"ESF"));
    #endif
};


bool printMessageIdentifier(std::ostream& out, uint8_t mclass, uint8_t mid){

    bool flag  = true;
    out << "MESSAGE";

    switch(mclass){
        case UBX_NAV:
            out << "::NAV";
            switch(mid){
                case UBX_NAV_AOPSTATUS:
                    out << "::AOPSTATUS" << std::endl;
                break;

                case UBX_NAV_CLOCK:
                    out << "::CLOCK" << std::endl;
                break;

                case UBX_NAV_DGPS:
                out << "::DGPS" << std::endl;
                break;

                case UBX_NAV_DOP:
                out << "::DOP" << std::endl;
                break;

                case UBX_NAV_EKFSTATUS:
                out << "::EKFSTATUS" << std::endl;
                break;

                case UBX_NAV_POSECEF:
                out << "::POSECEF" << std::endl;
                break;

                case UBX_NAV_POSLLH:
                out << "::POSLLH" << std::endl;
                break;

                case UBX_NAV_SBAS:
                out << "::SBAS" << std::endl;
                break;

                case UBX_NAV_SOL:
                out << "::SOL" << std::endl;
                break;

                case UBX_NAV_STATUS:
                out << "::STATUS" << std::endl;
                break;

                case UBX_NAV_SVINFO:
                out << "::SVINFO" << std::endl;
                break;

                case UBX_NAV_TIMEGPS:
                out << "::TIMEGPS" << std::endl;
                break;

                case UBX_NAV_TIMEUTC:
                out << "::TIMEUTC" << std::endl;
                break;

                case UBX_NAV_VELECEF:
                out << "::VELECEF" << std::endl;
                break;

                case UBX_NAV_VELNED:
                out << "::VELNED" << std::endl;
                    break;

                default:
                    out << "::UNKNOWN(" << int(mid) << ")" << std::endl;
                    flag = false;
                    break;
            }
            break;

        case UBX_RXM:
            out << "::CLOCK";
            switch(mid){
                case UBX_RXM_ALM:
                    out << "::ALM" << std::endl;
                    break;

                case UBX_RXM_EPH:
                    out << "::EPH" << std::endl;
                    break;

                case UBX_RXM_PMREQ:
                    out << "::PMREQ" << std::endl;
                    break;

                case UBX_RXM_RAW:
                    out << "::RAW" << std::endl;
                    break;

                case UBX_RXM_SFRB:
                    out << "::SFRB" << std::endl;
                    break;

                case UBX_RXM_SVSI:
                    out << "::SVSI" << std::endl;
                    break;

                default:
                    out << "::UNKNOWN(" << int(mid) << ")" << std::endl;
                    flag = false;
                    break;
            }
            break;

        case UBX_INF:
            out << "::INF";
            switch(mid){
                case UBX_INF_DEBUG:
                out << "::DEBUG" << std::endl;
                break;

                case UBX_INF_ERROR:
                out << "::DEBUG" << std::endl;
                break;

                case UBX_INF_NOTICE:
                out << "::NOTICE" << std::endl;
                break;

                case UBX_INF_TEST:
                out << "::TEST" << std::endl;
                break;

                case UBX_INF_WARNING:
                out << "::WARNING" << std::endl;
                break;

                default:
                    out << "::UNKNOWN(" << int(mid) << ")" << std::endl;
                    flag = false;
                    break;
            }
            break;

        case UBX_ACK:
            out << "::ACK";
            switch(mid){
                case UBX_ACK_ACK:
                    out << "::ACK" << std::endl;
                    break;

                case UBX_ACK_NAK:
                    out << "::NACK" << std::endl;
                    break;

                default:
                    out << "::UNKNOWN(" << int(mid) << ")" << std::endl;
                    flag = false;
                    break;
            }
            break;

        case UBX_CFG:
            out << "::CFG";
            switch(mid){
                case UBX_CFG_ANT:
                out << "::ANT" << std::endl;
                break;

                case UBX_CFG_CFG:
                out << "::CFG" << std::endl;
                break;

                case UBX_CFG_DAT:
                out << "::DAT" << std::endl;
                break;

                case UBX_CFG_EKF:
                out << "::EKF" << std::endl;
                break;

                case UBX_CFG_ESFGWT:
                out << "::ESFGWT" << std::endl;
                break;

                case UBX_CFG_FXN:
                out << "::FXN" << std::endl;
                break;

                case UBX_CFG_INF:
                out << "::INF" << std::endl;
                break;

                case UBX_CFG_ITFM:
                out << "::ITFM" << std::endl;
                break;

                case UBX_CFG_MSG:
                out << "::MSG" << std::endl;
                break;

                case UBX_CFG_NAV5:
                out << "::NAV5" << std::endl;
                break;

                case UBX_CFG_NAVX5:
                out << "::NAVX5" << std::endl;
                break;

                case UBX_CFG_NMEA:
                out << "::NMEA" << std::endl;
                break;

                case UBX_CFG_NVS:
                out << "::NVS" << std::endl;
                break;

                case UBX_CFG_PM2:
                out << "::PM2" << std::endl;
                break;

                case UBX_CFG_PM:
                out << "::PM" << std::endl;
                break;

                case UBX_CFG_PRT:
                out << "::PRT" << std::endl;
                break;

                case UBX_CFG_RATE:
                out << "::RATE" << std::endl;
                break;

                case UBX_CFG_RINV:
                out << "::RINV" << std::endl;
                break;

                case UBX_CFG_RST:
                out << "::RST" << std::endl;
                break;

                case UBX_CFG_RXM:
                out << "::RXM" << std::endl;
                break;

                case UBX_CFG_SBAS:
                out << "::SBAS" << std::endl;
                break;

                case UBX_CFG_TMODE2:
                out << "::TMODE2" << std::endl;
                break;

                case UBX_CFG_TMODE:
                out << "::TMODE" << std::endl;
                break;

                case UBX_CFG_TP5:
                out << "::TP5" << std::endl;
                break;

                case UBX_CFG_TP:
                out << "::TP" << std::endl;
                break;

                case UBX_CFG_USB:
                out << "::USB" << std::endl;
                break;

                default:
                    out << "::UNKNOWN(" << int(mid) << ")" << std::endl;
                    flag = false;
                    break;
            }
            break;

        case UBX_MON:
            out << "::MON";
            switch(mid){
                case UBX_MON_HW2:
                out << "::HW2" << std::endl;
                break;

                case UBX_MON_HW:
                out << "::HW" << std::endl;
                break;

                case UBX_MON_IO:
                out << "::IO" << std::endl;
                break;

                case UBX_MON_MSGPP:
                out << "::MSGPP" << std::endl;
                break;

                case UBX_MON_RXBUF:
                out << "::RXBUF" << std::endl;
                break;

                case UBX_MON_RXR:
                out << "::RXR" << std::endl;
                break;

                case UBX_MON_TXBUF:
                out << "::TXBUF" << std::endl;
                break;

                case UBX_MON_VER:
                out << "::VER" << std::endl;
                break;

                default:
                    out << "::UNKNOWN(" << int(mid) << ")" << std::endl;
                    flag = false;
                    break;
            }
            break;

        case UBX_AID:
        out << "::AID";
            switch(mid){
                case UBX_AID_ALM:
                out << "::ALM" << std::endl;
                break;

                case UBX_AID_ALPSRV:
                out << "::ALPSRV" << std::endl;
                break;

                case UBX_AID_ALP:
                out << "::ALP" << std::endl;
                break;

                case UBX_AID_AOP:
                out << "::AOP" << std::endl;
                break;

                case UBX_AID_DATA:
                out << "::DATA" << std::endl;
                break;

                case UBX_AID_EPH:
                out << "::EPH" << std::endl;
                break;

                case UBX_AID_HUI:
                out << "::HUI" << std::endl;
                break;

                case UBX_AID_INI:
                out << "::INI" << std::endl;
                break;

                case UBX_AID_REQ:
                out << "::REQ" << std::endl;
                break;

                default:
                    out << "::UNKNOWN(" << int(mid) << ")" << std::endl;
                    flag = false;
                    break;
            }
            break;

        case UBX_TIM:
            out << "::TIM";
            switch(mid){
                case UBX_TIM_SVIN:
                out << "::SVIN" << std::endl;
                    break;

                case UBX_TIM_TM2:
                out << "::TM2" << std::endl;
                    break;

                case UBX_TIM_TP:
                out << "::TP" << std::endl;
                    break;

                case UBX_TIM_VRFY:
                out << "::VRFY" << std::endl;
                    break;

                default:
                    out << "::UNKNOWN(" << int(mid) << ")" << std::endl;
                    flag = false;
                    break;
            }
            break;

        case UBX_ESF:
            out << "::ESF";
            switch(mid){
                case UBX_ESF_MEAS:
                out << "::MEAS" << std::endl;
                break;

                case UBX_ESF_STATUS:
                out << "::STATUS" << std::endl;
                break;

                default:
                    out << "::UNKNOWN(" << int(mid) << ")" << std::endl;
                    flag = false;
                    break;
            }
            break;

        default:
            out << "::UNKNOWN(" << int(mclass) << "," << int(mid) << ")" << std::endl;
            flag = false;
            break;
    }

    return flag;
}


