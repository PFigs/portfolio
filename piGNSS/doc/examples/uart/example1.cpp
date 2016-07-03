#include <wiringSerial.h>


#include <stdio.h>
#include <string.h>
#include <errno.h>
#include <iostream>
#include <unistd.h>
#include <sstream>

#include <wiringPi.h>
#include <wiringSerial.h>

#define OBD_BAUDRATE 38400
#define DFT_BAUDRATE 115200

int main (){
    int fd ;
    int count ;
    unsigned int nextTime ;

    if ((fd = serialOpen("/dev/ttyAMA0", 115200)) < 0){
        fprintf (stderr, "Unable to open serial device: %s\n", strerror (errno)) ;
        return 1 ;
    }

    if (wiringPiSetup () == -1){
        fprintf (stdout, "Unable to start wiringPi: %s\n", strerror (errno)) ;
        return 1 ;
    }

    bool run = true;
    for (int i=0;run; ){

        //busy waits for new data
        while(!serialDataAvail(fd)){
            sleep(1/3);
        };

        //reads
        while(serialDataAvail(fd)){
            std::string s;
            std::stringstream out;
            i = serialGetchar(fd);
            out << i;
            s = out.str();
            std::cout << s << std::endl;
        }

        std::cout << std::endl;
        std::cout << "RPI :> ";
        std::string terminal;
        std::getline(std::cin, terminal);
        std::cout << terminal << std::endl;

        if(terminal[0]=='q') run = false;

        serialPuts(fd,terminal.c_str());
        terminal.clear();
    }

    return 0 ;
}
