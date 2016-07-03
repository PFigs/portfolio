#include "main.h"
#include "sensor.h"
#include "ublox.h"
#include "imu.h"



#ifdef PI
#define  PIN_GPS_TIM 0
#include <wiringPi.h>
#endif

volatile bool   keepRunning = TRUE;
sem_t           heartbeat; // set by rpi

// gets system time tag
struct timespec time_tag;
struct timespec time_tag_raw;
struct timespec time_tag_after_read_ubx;
struct timespec time_tag_after_read_mcs;


void intHandler(int signo){
    if (signo == SIGINT)
        keepRunning = FALSE;
    if (signo == SIGRTMIN+3)
        sem_post(&heartbeat);
}

void intPiInterrupt(void){
    sem_post(&heartbeat);
}


int main (int argc, char *argv[]){
    sensor ublox;
    sensor mcstr;
    int    k =0;
    sigset_t mask;

    printf("Starting piTiming...\n");

    #ifdef PI
    wiringPiSetup();
    piHiPri(99); // Requires sudo
    wiringPiISR(PIN_GPS_TIM, INT_EDGE_RISING, &intPiInterrupt); // pins info on https://projects.drogon.net/raspberry-pi/wiringpi/pins/
    #endif

    #ifndef DEBUG
    printf("PID: %d\n",getpid());
    #endif

    // creates log directory
    mkdir("./log",0777);

    // Blocks all signals (inherited by childs)
    sigemptyset (&mask);
    pthread_sigmask(SIG_SETMASK, &mask, NULL);

    #ifdef DEBUG
    printf("Validating inputs...\n");
    #endif

    if(argc < 3 ){
        printf("Please specify ports.\n");
        exit(EXIT_FAILURE);
    }

    ublox.status  = OFF;
    mcstr.status  = OFF;
    ublox.logname = "./log/ubxtim.log";
    mcstr.logname = "./log/mcstim.log";
    ublox.config  = "./.cfg/ubx.conf";
    mcstr.config  = "./.cfg/mcstr.conf";

    for(k=1;k<argc;k++){
        if(sizeof(argv[k])>=4){
            if(strncmp("-gps",argv[k],4)==0){
                ublox.status = ON;
                ublox.port   = (char *) malloc(sizeof(argv[k+1])*sizeof(char*));
                memcpy((void*)ublox.port,(void*) argv[k+1],sizeof(argv[k+1])*sizeof(char*));
                k++; // I know!

                #ifdef DEBUG
                printf("argv: %s , argc: %d, k: %d  --> port: %s\n",argv[k-1],argc,k,argv[k]);
                #endif
            }
            if(strncmp("-mcs",argv[k],4)==0){
                mcstr.status = ON;
                mcstr.port = (char *) malloc(sizeof(argv[k+1])*sizeof(char*));
                memcpy((void*)mcstr.port,(void*) argv[k+1],sizeof(argv[k+1])*sizeof(char*));
                k++; // I know!

                #ifdef DEBUG
                printf("argv: %s , argc: %d, k: %d  --> port: %s\n",argv[k-1],argc,k,argv[k]);
                #endif
            }
        }

        if(sizeof(argv[k])>=6){
            if(strncmp("-gpslog",argv[k],6)==0){
                ublox.logname= (char *) malloc(sizeof(argv[k+1])*sizeof(char*));
                memcpy((void*)ublox.logname,(void*) argv[k+1],sizeof(argv[k+1])*sizeof(char*));
            }

            if(strncmp("-imulog",argv[k],6)==0){
                mcstr.logname= (char *) malloc(sizeof(argv[k+1])*sizeof(char*));
                memcpy((void*)mcstr.logname,(void*) argv[k+1],sizeof(argv[k+1])*sizeof(char*));
            }
        }
    }

    #ifdef DEBUG
    printf("Initialising semaphore...\n");
    #endif
    // inits semaphore for interrupts by rpi
    if(sem_init(&heartbeat, 1, 0) == -1) terminate(errno);

    #ifdef DEBUG
    printf("Starting SENSORS ...\n");
    if(ublox.status)
        printf("UBLOX port: %s \n",ublox.port);
    printf("UBLOX status: %d \n",ublox.status);
    if(mcstr.status)
        printf("MCSTR port: %s \n",mcstr.port);
    printf("MCSTR status: %d \n",mcstr.status);
    #endif

    // inits processes for uBlox and uStrain
    if(ublox.status){
        start_ublox(&ublox);
    }

    if(mcstr.status){
        start_imu(&mcstr);
    }

    #ifdef DEBUG
    printf("Waiting...\n");
    #endif

    sleep(2); // waits for processes to initialise (handle this better :))

    if(ublox.status) pthread_mutex_unlock(&ublox.init);
    if(mcstr.status)  pthread_mutex_unlock(&mcstr.init);


    sigaddset(&mask, SIGINT);
    signal(SIGINT, (__sighandler_t)intHandler);
    signal(SIGRTMIN+3, (__sighandler_t)intHandler);

    // Enable interrupts

    do{// on every heart beat

        // Waits on heartbeat
        sem_wait(&heartbeat);

        // do not handle sig-int here
        sigprocmask(SIG_BLOCK, &mask, NULL);
        #ifdef DEBUG
        printf("M: Got an heartbeat...\n");
        #endif

        clock_gettime(CLOCK_REALTIME, &time_tag); // disable NTP
        clock_gettime(CLOCK_MONOTONIC_RAW, &time_tag_raw); // to an undifined time

        #ifdef DEBUG
        printf("M: Notifying kids...\n");
        #endif

        // notifies processes to retrieve data
        if(ublox.status){
            sem_post(&ublox.ready);
            #ifdef DEBUG
            printf("M: posted ublox...\n");
            #endif
            };
        if(mcstr.status){
            sem_post(&mcstr.ready);
            #ifdef DEBUG
            printf("M: posted mcstr...\n");
            #endif
        }

        sigprocmask(SIG_UNBLOCK, &mask, NULL);

    }while(keepRunning);

    #ifdef DEBUG
    printf("M: Waiting for kids...\n");
    #endif

    // notifies processes to retrieve data
    if(ublox.status){
        sem_post(&ublox.ready);
        pthread_join(ublox.tid, NULL);
    }

    if(mcstr.status){
        sem_post(&mcstr.ready);
        pthread_join(mcstr.tid, NULL);
    }


    printf("Exiting ...\n");

    return EXIT_SUCCESS;
}




/**
 * void terminate(int errsv)
 *
 * Terminates execution and print
 * error message associated with
 * the given error number.
 *
 * Should be called as,
 *
 * terminate(errno);
 */
void terminate(int errsv){
    printf("%s\n",strerror(errsv));
    exit(EXIT_FAILURE);
}




/*EOF*/
