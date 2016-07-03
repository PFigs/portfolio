#include "message.h"


// ####################################################
//                      DESTRUCTOR
// ####################################################


Message::~Message(){
    #ifdef TRACE
    T(std::cout, "Entering Message::~Message");
    #endif
    if(binary) delete []binary;
};


// ####################################################
//                      CONSTRUCTOR
// ####################################################

Message::Message(){
    #ifdef TRACE
    T(std::cout, "Entering Message::Message");
    #endif
    binary     = new uint8_t[msgmaxsize]; /// \todo improve
    size       = msgmaxsize;
    insertions = 0;
    dirty      = false;
    lpayload   = 0;
    lheader    = 0;
    lfooter    = 0;
    mheaderh   = 0;
    mheaderl   = 0;
    mclass     = 255;
    mid        = 255;
    mlength    = 0;
    mcka       = 0;
    mckb       = 0;
    mchecksum  = 0;
    //timestamp ?
};


Message::Message(unsigned int size){
    #ifdef TRACE
    T(std::cout, "Entering Message::Message(size)");
    #endif
    binary     = new uint8_t[size];
    size       = size;
    insertions = 0;
    dirty      = false;
    lpayload   = 0;
    lheader    = 0;
    lfooter    = 0;
    mheaderh   = 0;
    mheaderl   = 0;
    mclass     = 255;
    mid        = 255;
    mlength    = 0;
    mcka       = 0;
    mckb       = 0;
    mchecksum  = 0;
    //timestamp ?
};



// ####################################################
//                      SETTERS
// ####################################################
bool Message::add(uint8_t value){
    #ifdef DEBUG_MSG
    T(std::cout, "Entering Message::add");
    H(std::cout,int(value));
    #endif

    // short circuit is guaranteed but just in case
    if(insert(value))
        updateChecksum(value);

    return true;
}

/**
 * Inserts data on the payload if space is available
 */
bool Message::insert(uint8_t value){
    #ifdef DEBUG_MSG
    T(std::cout, "Entering Message::insert");
    H(std::cout,int(value));
    #endif

    // is there space?
    if(insertions < size){
        binary[insertions] = value; // insert it
        insertions++; // increment occupied or decrement available space
    }else{
        #ifdef DEBUG_MSG
        P(std::cout, "NOT ENOUGH SPACE");
        H(std::cout,int(value));
        #endif
        return false;
    }

    return true;
}



/**
 * Marks message as being ready
 */
void Message::setReady(){
    #ifdef TRACE
    T(std::cout, "Entering Message::setReady");
    #endif
    insert(mcka);
    insert(mckb);
    dirty = true;
}



/**
 * Marks message as being ready
 */
void Message::setEmpty(){
    #ifdef TRACE
    T(std::cout, "Entering Message::setEmpty");
    #endif
    clear();
}


void Message::setHeaderH(uint8_t value){
    #ifdef TRACE
    T(std::cout, "Entering Message::setLength");
    #endif
    insert(value);
    mheaderh = value;
    lheader++;
}

void Message::setHeaderL(uint8_t value){
    #ifdef TRACE
    T(std::cout, "Entering Message::setLength");
    #endif
    insert(value);
    mheaderl = value;
    lheader++;
}



/**
 * Sets the message's class
 */
void Message::setClass(uint8_t value){
    #ifdef TRACE
    T(std::cout, "Entering Message::setClass");
    #endif
    resetChecksum();
    add(value);
    mclass = value;
    lheader++;
};

/**
 * Sets the message's id
 */
void Message::setId(uint8_t value){
    #ifdef TRACE
    T(std::cout, "Entering Message::setId");
    #endif
    add(value);
    mid = value;
    lheader++;
};



/**
 * Stores the message's length (not the maximum size of the payload)
 */
void Message::setLengthL(uint8_t value){
    #ifdef TRACE
    T(std::cout, "Entering Message::setLength");
    #endif
    add(value);
    mlength = value;
    lheader++;
}

/**
 * Stores the message's length (not the maximum size of the payload)
 */
void Message::setLengthH(uint8_t value){
    #ifdef TRACE
    T(std::cout, "Entering Message::setLength");
    #endif
    add(value);
    mlength |= value << 8;
    lheader++;
}



/**
 * Sets the message's payload
 */
void Message::setPayload(uint8_t value){

    add(value);
    lpayload++;
};

/**
 * Sets the message's TOW
 */
void Message::setTOW(unsigned int seconds){
    #ifdef TRACE
    T(std::cout, "Entering Message::setTOW");
    #endif
};


/**
 * Sets the message's size
 */
void Message::setSize(unsigned int size){
    #ifdef TRACE
    T(std::cout, "Entering Message::setSize");
    #endif
    size = size;
};




/**
 * Stores the checksum
 */
void Message::setChecksum(uint8_t cka, uint8_t ckb){
    #ifdef TRACE
    T(std::cout, "Entering Message::setChecksum");
    #endif
    mcka = cka;
    mckb = ckb;
    mchecksum = (cka << 8) || ckb;
    lfooter=2;
};


void Message::resetChecksum(){
    //if not empty, reset checksum
    mcka = 0;
    mckb = 0;
}



// ####################################################
//                      GETTERS
// ####################################################

/**
 * Checks if the message is ready
 */
bool Message::ready(){
    return dirty;
}


/**
 * Checks if the message is empty
 */
bool Message::empty(){
    return insertions == 0;
};



/**
 * Returns the message's payload
 */
uint8_t*     Message::getPayload(){
    #ifdef TRACE
    T(std::cout, "Entering Message::getPayload");
    #endif
    return binary+lheader;
};

uint8_t*     Message::getBinary(){
    #ifdef TRACE
    T(std::cout, "Entering Message::getBinary");
    #endif
    return binary;
};

/**
 * Retrieves the message's TOW
 */
unsigned int Message::getTOW(){
    #ifdef TRACE
    T(std::cout, "Entering Message::getTOW");
    #endif
    return -1;
};


/**
 * Obtains the message's size
 */
unsigned int Message::getSize(){
    #ifdef TRACE
    T(std::cout, "Entering Message::getSize");
    #endif
    return insertions;
};


uint8_t      Message::getClass(){return mclass;};
uint8_t      Message::getId(){return mid;};
uint8_t      Message::getCKA(){return mcka;};
uint8_t      Message::getCKB(){return mckb;};
uint16_t     Message::getLength(){return mlength;};
uint16_t     Message::getChecksum(){return mchecksum;};
unsigned int Message::getPayloadEntries(){return lpayload;}

// ####################################################
//                      MISC
// ####################################################

/**
 * Clears the message's contents
 */
void Message::clear(){
    #ifdef TRACE
    T(std::cout, "Entering Message::clear");
    #endif
    if(!empty()){
        memset((void *)binary,(int)'\0',size);
        insertions = 0;
        lpayload   = 0;
        lheader    = 0;
        lfooter    = 0;
        mheaderh   = 0;
        mheaderl   = 0;
        dirty      = false;
        mclass     = 255;
        mid        = 255;
        mlength    = 0;
        mcka       = 0;
        mckb       = 0;
        mchecksum  = 0;
    }
    #ifdef DEBUG_MSG
    P(std::cout, "Message is now empty");
    #endif
}


void Message::updateChecksum(uint8_t value){

    #ifdef DEBUG_MSG
    T(std::cout,"Enters Message::checksum");
    H(std::cout,value);
    H(std::cout,mcka);
    H(std::cout,mckb);
    #endif

    // updates values
    mcka = mcka + value;
    mckb = mckb + mcka;

    #ifdef DEBUG_MSG
    H(std::cout,mcka);
    H(std::cout,mckb);
    #endif
}


/**
 * Prints the message in the terminal in a formatted pattern
 *  A B C D  E F G H I  J K L M N
 *  ...
 */
std::ostream& operator<< (std::ostream &out, Message &msg){

    uint8_t *ptr = msg.getBinary();
    int      n   = msg.getSize();
    int aux      = 1;

    if(!msg.empty()){
        out << "[" << std::endl;
        for(int i=0; i < n;i++,aux++)
        {
            out << std::hex << std::setw(2) << std::setfill('0') << int(ptr[i]);
            out << ' ';

            if(aux%4 == 0) out << "  ";
            if(aux%16 == 0) out << std::endl;

        }
        out << std::endl << "]" << std::endl;
    }
    else{
        out << "[Message is empty]";
    }

    return out;
};

