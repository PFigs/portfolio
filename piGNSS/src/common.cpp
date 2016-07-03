#include "common.h"

Container::Container(boost::any const &value, boost::any const &type, int const &id):value(value),type(type),id(id){
    #ifdef TRACE
    T(std::cout,  "Enters Container::Container");
    #endif
};

/*!
 * @returns boost::any object (device, GPS message)
 */
boost::any Container::getContents(){
    #ifdef TRACE
    T(std::cout,  "Enters Container::getContents");
    #endif
    return value;
}


/*!
 * @returns boost::any object (enum)
 */
boost::any Container::getType(){
    #ifdef TRACE
    T(std::cout,  "Enters Container::getType");
    #endif
    return type;
}


int Container::getid(){
    #ifdef TRACE
    T(std::cout,  "Enters Container::getid");
    #endif
    return id;
}



std::string colourstr(int code, std::string const &str){
    std::string cstr;

    switch(code){

        case BOLD_BLACK:
            cstr = std::string("\x1b[30;1m") + str + std::string("\x1b[0m");
            break;

        case BOLD_RED:
            cstr = std::string("\x1b[31;1m") + str + std::string("\x1b[0m");
            break;

        case BOLD_GREEN:
            cstr = std::string("\x1b[32;1m") + str + std::string("\x1b[0m");
            break;

        case BOLD_YELLOW:
            cstr = std::string("\x1b[33;1m") + str + std::string("\x1b[0m");
            break;

        case BOLD_BLUE:
            cstr = std::string("\x1b[34;1m") + str + std::string("\x1b[0m");
            break;

        case BOLD_MANGENTA:
            cstr = std::string("\x1b[35;1m") + str + std::string("\x1b[0m");
            break;

        case BOLD_CYAN:
            cstr = std::string("\x1b[36;1m") + str + std::string("\x1b[0m");
            break;

        case BOLD_WHITE:
            cstr = std::string("\x1b[37;1m") + str + std::string("\x1b[0m");
            break;

        case BLACK:
            cstr = std::string("\x1b[30m") + str + std::string("\x1b[0m");
            break;

        case RED:
            cstr = std::string("\x1b[31m") + str + std::string("\x1b[0m");
            break;

        case GREEN:
            cstr = std::string("\x1b[32m") + str + std::string("\x1b[0m");
            break;

        case YELLOW:
            cstr = std::string("\x1b[33m") + str + std::string("\x1b[0m");
            break;

        case BLUE:
            cstr = std::string("\x1b[34m") + str + std::string("\x1b[0m");
            break;

        case MANGENTA:
            cstr = std::string("\x1b[35m") + str + std::string("\x1b[0m");
            break;

        case CYAN:
            cstr = std::string("\x1b[36m") + str + std::string("\x1b[0m");
            break;

        case WHITE:
            cstr = std::string("\x1b[37m") + str + std::string("\x1b[0m");
            break;


    }

    return cstr;
}


/***
 * @brief prints wellcome screen
 *
 * Prints data that is stored in wellcome.txt as a
 * wellcome screen to users
 *
 */
void wellcome(std::string filename){
    std::ifstream file(filename.c_str());

    if(file.is_open()){
        std::string line;
        while(file.good()){
            std::getline(file,line);
            std::cout << colourstr(BOLD_GREEN,line) << std::endl;
        }
        file.close();
    }else{
        std::cout << "Wellcome to piGNSS" << std::endl;
    }

    #ifdef RPI
    std::cout << colourstr(BOLD_GREEN,"Executing as RPI") << std::endl << std::endl;
    #else
    std::cout << colourstr(BOLD_GREEN,"Executing as Standard Device") << std::endl << std::endl;
    #endif
}


/***
 * @brief converts files with hex strings to binary
 *
 * This method converts the given file, which contains
 * command strings in hexadecimal and saves them in
 * binary form in a binary file.
 *
 */
void asc2bin(std::string const &filein,std::string const &fileout){
    #ifdef TRACE
    T(std::cout, "Enters BinFile::asc2bin");
    #endif

    // coverts configuration files to binary files
    std::ifstream mfile(filein.c_str());
    std::ofstream bfile(fileout.c_str(), std::ios::out | std::ios::binary);

    assert(mfile.is_open());
    assert(bfile.is_open());

    std::string line;
    while(mfile.good()){
        // remove trash in line
        std::getline(mfile,line);
        line.erase(0, line.find_first_not_of(" \t\r\n\v\f"));
        size_t index = line.find_first_of("#");
        if (index != std::string::npos) line.erase(index, std::string::npos);
        line.erase(remove_if(line.begin(), line.end(), ::isspace), line.end());
        line.append("\n");

        // write binary file
        unsigned short int value = 0;
        char hex[3];
        hex[2] = '\0';
        for(unsigned int i=0;i<line.size();i+=2){
            hex[0] = line[i];
            hex[1] = line[i+1];
            sscanf(hex,"%hx\n", &value);
            bfile.write((char*)&value,1);
        }
    }

    mfile.close();
    bfile.close();
}



unsigned short int *hex2bin(std::string &line,unsigned short int *buffer){

        // convert string to binary
        char    hex[3];
        hex[2] = '\0';

        std::string::iterator it = line.begin();
        for(unsigned int i = 0;it!=line.end()-1;it+=2,i++){
            hex[0] = *it;
            hex[1] = *(it+1);
            std::cout << hex << std::endl;
            sscanf(hex,"%hx\n", (buffer+i));
        }

    return buffer;
}


void cleanstring(std::string &line){
    line.erase(0, line.find_first_not_of(" \t\r\n\v\f"));
    size_t index = line.find_first_of("#");
    if (index != std::string::npos) line.erase(index, std::string::npos);
    line.erase(remove_if(line.begin(), line.end(), ::isspace), line.end());
}

uint8_t hex2uint8(char h, char e){
    if (h >= 'A' && h <= 'F')
        h -= 7;
    else if (h >='a' && h <= 'f')
        h -= 39;
    else if (h < '0' || h > '9')
        return 0;

    if (e >= 'A' && e <= 'F')
        e -= 7;
    else if (e >= 'a' && e <= 'f')
        e -= 39;
    else if (e < '0' || e > '9')
        return 0;

    return h << 4 | (e & 0xf);
}
