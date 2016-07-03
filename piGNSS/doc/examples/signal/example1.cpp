/**
 * @file signal/example1.cpp
 *
 */

#include <stdio.h>
#include <cstdio>
#include <iostream>
#include "signalhandler.h"
#include <unistd.h>

#define DEBUG

using namespace std;
namespace Execution
{
enum States { WAIT = 0, READ, PROCESS, SAVE, SEND};
};


int main(int argc, char **argv){

    cout << "Welcome to piGNNS" << endl;


#ifdef DEBUG
    cout << "Console commands" << endl;
    for(int i=0;i<argc;i++)
        cout << argv[i] << endl;
#endif

    try{
        SignalHandler signalHandler;

        // Register signal handler to handle kill signal
        signalHandler.setupSignalHandlers();

        // Enter state machinev
        cout << "waiting for CTRL-C" << endl;
        Execution::States state = Execution::WAIT;
        while(!signalHandler.gotExitSignal()){
            cout << "..." << endl;
            sleep(5);
            switch(state){
            case Execution::WAIT:
                break;

            case Execution::READ:
                break;

            case Execution::PROCESS:
                break;

            case Execution::SAVE:
                break;

            case Execution::SEND:
                break;

            default:
#ifdef DEBUG
                cout << "Shouldn't be here!" << endl;
#endif
                //run = false;
                break;

            }
        }
    }
    catch (SignalException& e){
        std::cerr << "SignalException: " << e.what() << std::endl;
        //iret = EXIT_FAILURE;
    }


#ifdef DEBUG
    cout << "Cleaning up to leave" << endl;
#endif

    return 0;
}

