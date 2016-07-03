/*!
 * @file pignss.cpp
 *
 * Main file which contains the worflow of the piGNSS program
 *
 * @author Pedro Silva, pedro.figs.silva@gmail.com
 */

#include "pignss.h"

/**
 * @brief Program's workflow
 *
 * It might be necessary to add the running user to the dialout group through
 *  sudo gpasswd --add \<user\> dialout
 * -- Do not forget to relogin
 *
 */
int main(int argc, char **argv){

    //Parse cmdline inputs
    wellcome(std::string("./doc/wellcome.txt"));

    // Creates and initialises object
    Observation obs;
    obs.init(argc,argv);

    //Set up descriptors to be watched
    for(bool run=true;run;){
        obs.wait();
        obs.execute(run);
    }

    return 0;
}
