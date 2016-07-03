/**
* Parser for timing trials
*/
/**Open file*/
#include <stdio.h>      /* printf */
#include <assert.h>     /* assert */
#include <iostream>
#include <fstream>
#include <cstdlib>
#include <string>
#include <iostream>
#include <string.h>
#include <iomanip>

#define HOUR     2
#define MINUTE   2
#define SECOND   2
#define NANO_SEC 9

#define TIME_ENTRY 19

#define MAX_BUFFER 500 // improve with max expected message from ubx

int main (int argc, char **argv) {

    std::ifstream logfile;
    std::ofstream logTime;
    std::ofstream logUBX;

    assert(argc > 1);
    std::cout << "Opening log file: " << argv[1] << "\n";

//    if(strcmp(argv[2],'-t')



    // open file
    logfile.open(argv[1],std::ios::binary);
    if(!logfile)  // operator! is used here
    {
        std::cout << "File opening failed\n" << "\n";
        return EXIT_FAILURE;
    }

    logTime.open("pitime.log");
    if(!logTime)  // operator! is used here
    {
        std::cout << "File opening failed\n" << "\n";
        return EXIT_FAILURE;
    }

    logUBX.open("ubx.aux",std::ios::binary);
    if(!logUBX)  // operator! is used here
    {
        std::cout << "File opening failed\n" << "\n";
        return EXIT_FAILURE;
    }


    // get length of file:
    logfile.seekg (0, logfile.end);
    int length = logfile.tellg();
    logfile.seekg (0, logfile.beg);
    std::cout << "File size: " << length << "\n";

    std::cout << "Working it out.." << "\n";

    int  count = 0;
    char tbuf[TIME_ENTRY+1];
    char mbuf[MAX_BUFFER];

    char*hh = new char[HOUR+1];
    char*mm = new char[MINUTE+1];
    char*ss = new char[SECOND+1];
    char*ns = new char[NANO_SEC+1];


    hh = (char *) memset(hh, '\0', HOUR+1);
    mm = (char *)memset(mm, '\0', MINUTE+1);
    ss = (char *)memset(ss, '\0', SECOND+1);
    ns = (char *)memset(ns, '\0', NANO_SEC+1);

/*
    std::fill(mm, mm+MINUTE+1, "\0");
    std::fill(ss, ss+SECOND+1, "\0");
    std::fill(ns, ns+NANO_SEC+1, "\0");
    std::fill(mbuf, mbuf+MAX_BUFFER, "\0");
*/
    int    bcount = 0;
    double sectime = 0;
    enum     state_t {start,start_confirm,dump};
    state_t  state = start;


    char *buf = mbuf;
    while(count <= length){

        // read byte
        logfile.read(buf,1);
        count ++;

        switch(state){
            case start:
                if(buf[0] == 0x23){ // looks for #
                    state = start_confirm;
                    buf = tbuf;
                }else{
                    bcount ++; // belongs to ubx
                    buf = mbuf+bcount; // sets next read
                };
                break;


            case start_confirm:
                if(buf[0] == 0x3A){ // looks for #
                    state = dump;
                    buf = tbuf;
                }else{
                    state = start;
                    bcount ++; // belongs to ubx
                    buf = mbuf+bcount; // sets next read
                };
                break;

            case dump:
                if(buf[0] == 0x2C){ //','
                    // parse time
                    strncpy(hh,tbuf,HOUR);
                    strncpy(mm,tbuf+3,MINUTE);
                    strncpy(ss,tbuf+6,SECOND);
                    strncpy(ns,tbuf+9,NANO_SEC);


                    // convert to seconds
                    std::cout << "hour " << atoi(hh) <<"\n";
                    std::cout << "minute " << atoi(mm) <<"\n";
                    std::cout << "second " << atoi(ss) <<"\n";
                    std::cout << "nanosec " << atoi(ns) <<"\n";
                    sectime = atoi(hh)*60*60 + atoi(mm)*60 + atoi(ss)+atoi(ns)*1e-9;
                    logTime << std::setprecision(15) << sectime <<"\n";

                    // dumps ubx
                    if (bcount > 0) {// there is something to write
                        std::cout << "writing: ";
                        for(int i=0;i<bcount;i++){
                            logUBX.write(mbuf[i],1);
                            //std::cout << std::hex << std::uppercase << mbuf[i] << std::nouppercase << std::dec << std::endl;
                            printf("%X ", mbuf[i]);
                            mbuf[i] = 0;
                        }
                        std::cout << "\n";
                        bcount = 0;
                    }

                    buf   = mbuf;
                    state = start;

                }else{
                    buf = buf+1; // continues reading
                };
                break;
        }

    }

    if (bcount > 0) {// there is something to write
        std::cout << "writing: ";
        for(int i=0;i<bcount;i++){
            logUBX << mbuf[i];
            //std::cout << std::hex << std::uppercase << mbuf[i] << std::nouppercase << std::dec << std::endl;
            printf("%X ", mbuf[i]);
            mbuf[i] = 0;
        }
        std::cout << "\n";
        bcount = 0;
    }


    // clean up
    logfile.close();
    std::cout << "All done captain.." << "\n";
    return 0;
}





