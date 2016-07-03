#include <errno.h>
#include <stdio.h>
#include <cstdio>
#include <iostream>
#include <fstream>
#include <assert.h>
#include <boost/any.hpp>
#include <stdint.h>
#include "./../debug/debug.h"
#include "./../communication/communication.h"
#include <wiringPi.h>
#include <wiringSerial.h>

#define OBD_BAUDRATE 38400

// General Commands
#define AT_CMD_REPET        "AT\r"         // Repeat last command
#define AT_CMD_BRDIV        "ATBRD"        // hh\r - Try baud rate divisor
#define AT_CMD_BRTIM        "ATBRT"        // hh\r - Baud rate timeout insert
#define AT_CMD_DEFLT        "ATD\r"        // Set all to defaults
#define AT_CMD_ECHOF        "ATE0\r"       // Set echo off
#define AT_CMD_ECHON        "ATE1\r"       // Set echo on (default)
#define AT_CMD_FGTEV        "ATFE\r"       // Forget events
#define AT_CMD_PRVER        "ATI\r"        // Print version ID
#define AT_CMD_LFDOF        "ATL0\r"       // Linefeed off
#define AT_CMD_LFDON        "ATL1\r"       // Linefeed on
#define AT_CMD_GTLWP        "ATLP\r"       // Go to low power mode
#define AT_CMD_MEMOF        "ATM0\r"       // Memory off
#define AT_CMD_MEMON        "ATM1\r"       // Memory on
#define AT_CMD_READD        "ATRD\r"       // Read stored data
#define AT_CMD_SAVED        "ATSD"         // hh\r - Save data byte
#define AT_CMD_WARMS        "ATWS\r"       // Warm Start (quick software reset)
#define AT_CMD_RESET        "ATZ\r"        // Reset all
#define AT_CMD_DISPD        "AT@1\r"       // Display the device description
#define AT_CMD_DISPI        "AT@2\r"       // Display the device identifier
#define AT_CMD_STOID        "AT@3"         // cccccccccccc\r - Store the @2 identifier

// Programmable Parameter Commands
#define AT_CMD_DISPX        "ATPP"         // xxOFF\r - Disable Prog Parameter xx
#define AT_CMD_DISAL        "ATPPFFOFF\r"  // Disable all Prog Parameter
#define AT_CMD_DISPX        "ATPP"         // xxON\r  - Enable Prog Parameter xx
#define AT_CMD_ENBAL        "ATPPFFON\r"   // Enable all Prog Parameter
#define AT_CMD_ENBPX        "ATPP"         // xxSVyy\r - For PP xx, Set the Value to yy
#define AT_CMD_SETPX        "ATPPS\r"      // Print a PP Summary
#define AT_CMD_SETPX        "ATPPS\r"      // xxSVyy\r - For PP xx, Set the Value to yy

// Voltage Reading Commands
#define AT_CMD_SETVC        "ATCV"         // dddd\r - Calibrate the voltage to dd.dd volts
#define AT_CMD_RSTVC        "ATCV0000\r"   // Restore to factory setting
#define AT_CMD_READV        "ATCV0000\r"   // Read the input voltage

// Other
#define AT_CMD_IGNLV        "ATIGN\r"      // Read the IgnMon input level
#define AT_CMD_AUTOP        "ATSP0\r"      // Search for a compatible protocol to use

#define PID_RPM             "0012\r"
#define PID_SPEED           "0013\r"
#define PID_THROTTLE        "0101\r"
#define PID_ENGINE_LOAD     "0004\r"
#define PID_COOLANT_TEMP    "0005\r"
#define PID_INTAKE_TEMP     "0015\r"
#define PID_MAF_FLOW        "0100\r"
#define PID_ABS_ENGINE_LOAD "0403\r"
#define PID_AMBIENT_TEMP    "0406\r"
#define PID_FUEL_PRESSURE   "0010\r"
#define PID_INTAKE_PRESSURE "0011\r"
#define PID_BAROMETRIC      "0303\r"
#define PID_TIMING_ADVANCE  "0014\r"
#define PID_FUEL_LEVEL      "0215\r"
#define PID_RUNTIME         "0115\r"
#define PID_DISTANCE        "0301\r"


class OBD: public Communication{
    enum FSM{LOOKING=0, PROMPT, QUESTION, PAYLOAD};

    public:
        ~OBD();
        OBD(std::string const &name, std::string const &location, int const &terminator);

    private:
        virtual void doInit(int &fd);
        virtual void doDecoding(int &fsm, CommBuffer &cb, Message &msg, uint8_t *headers);
        virtual void doParsing(Message &msg);
        virtual int  doWrite(int const &fd, void const *buffer,unsigned int const &size);
        virtual int  doRead(int const &fd, CommBuffer &cb, Message &msg);
        int getVelocity();
        int getRPM();
};
