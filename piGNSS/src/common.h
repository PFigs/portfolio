/*!
 * @file common.h
 *
 */

#ifndef COMMON_H
#define COMMON_H

#include <errno.h>
#include <stdio.h>
#include <stdint.h>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <assert.h>
#include <boost/any.hpp>
#include <stdint.h>
#include "./debug/debug.h"


#define BOLD_BLACK    0
#define BOLD_RED      1
#define BOLD_GREEN    2
#define BOLD_YELLOW   3
#define BOLD_BLUE     4
#define BOLD_MANGENTA 5
#define BOLD_CYAN     6
#define BOLD_WHITE    7
#define BLACK         10
#define RED           11
#define GREEN         12
#define YELLOW        13
#define BLUE          14
#define MANGENTA      15
#define CYAN          16
#define WHITE         17


void wellcome(std::string filename);
void cleanstring(std::string &line);
std::string colourstr(int code, std::string const &str);
void asc2bin(std::string const &filein,std::string const &fileout);
unsigned short int *hex2bin(std::string &line,unsigned short int *buffer);
uint8_t hex2uint8(char h, char e);
/*! This namespace contains the execution states and descriptors position.
 *  The fds value should match the corresponding state,
 *  otherwise the program will misbehave
*/
namespace EXECUTION
{
    enum STATES { R_STDIN = 0, R_GPS, W_GPS, R_SERVER, W_SERVER, R_FILE, W_FILE};
};

namespace CONTENTS
{
    enum DEVICES  {UBLOX=0};
    enum UBX {EPH=0, AID, HUI};
};


/*!
 * @class Container
 *
 * @brief Wrapper for boost::any
 *
 * This class aims to provide a wrapper for the boost::any type, which allows any
 * kind of object to be stored within. It also contains a type, in order to ease
 * object comparison
 *
 */
class Container{
    private:
        boost::any   value;
        boost::any   type;
        int          id;

    public:
        Container(boost::any const &value, boost::any const &type,int const &id); //!< Object and type initialised on creation
        boost::any getContents(); //!< Retrieves the stored object
        boost::any getType(); //!< Retrieves the type of the stored object
        int        getid();
};

#endif
