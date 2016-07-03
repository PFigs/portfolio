/*! @file debug.h
 *  @brief This file contains macro definitions useful for debugging purposes.
 */

#ifndef DEBUG_H
#define DEBUG_H

#include "../common.h"

#define DEBUG
#define WARNING
#define TRACE

#define VALIDATION
//#define DEBUG_OBS
//#define DEBUG_UBX
//#define DEBUG_MSG
//#define DEBUG_COM
//#define DEBUG_BFL

//#define RPI


#define TSTR colourstr(BLUE,"/: ")
#define DSTR colourstr(YELLOW,"?: ")
#define WSTR colourstr(RED,"!: ")
#define ERRO colourstr(BOLD_RED,"#: ")


/*!
 * @def BRK()
 * @brief Simple macro to wait for a carriage return
 *
*/
#define BRK()   std::cin.get();

/*!
 * @def D(STREAM,ARG)
 * @brief Evaluates the ARG and prints it to STREAM\n
 * @param[out] STREAM Where to print the information\n
 * @param[in]  ARG Value to evaluate and print\n
 *
*/
#define D(STREAM, ARG) (STREAM) << DSTR << #ARG "=[" << (ARG) << ']' << std::endl;


/*!
 * @def H(STREAM,ARG)
 * @brief Evaluates the ARG and prints it to STREAM\n
 * @param[out] STREAM Where to print the information\n
 * @param[in]  ARG Value to evaluate and print\n
 *
*/
#define H(STREAM, ARG) (STREAM) << DSTR << #ARG "=[" << std::hex << int(ARG) << ']' << std::endl;



/*!
 * @def TRC(STREAM,ARG)
 * @brief Prints and executes the code
 * @param[out] STREAM Where to print the information\n
 * @param[in]  ARG Value to trace\n
 *
*/
#define TRC(STREAM, ARG) (STREAM) << TSTR << __FILE__ << '(' << __LINE__ << "): "<< #ARG << std::endl; (ARG)
#define T(STREAM, ARG) (STREAM) << TSTR << __FILE__ << '(' << __LINE__ << "): "<< #ARG << std::endl;

/*!
 * @def P(STREAM,ARG)
 * @brief Simple macro to print information
 * @param[out] STREAM Where to print the information\n
 * @param[in]  ARG Argument to be stringised\n
 *
*/
#define P(STREAM, ARG) (STREAM) << DSTR << __FILE__ << '(' << __LINE__ << "): " << #ARG << std::endl;


/*!
 * @def P(STREAM,ARG)
 * @brief Simple macro to print information
 * @param[out] STREAM Where to print the information\n
 * @param[in]  ARG Argument to be stringised\n
 *
*/
#define W(STREAM, ARG) (STREAM) << WSTR << __FILE__ << '(' << __LINE__ << "): " << colourstr(BOLD_RED,#ARG) << std::endl;


/*!
 * @def E(STREAM,ARG)
 * @brief Evaluates the ARG and prints it to STREAM\n
 * @param[out] STREAM Where to print the information\n
 * @param[in]  ARG Value to evaluate and print\n
 *
*/
#define ERROR() {std::cerr << ERRO << __FILE__ << '(' << __LINE__ << "): " << strerror(errno) << std::endl; exit(EXIT_FAILURE);}

#endif

