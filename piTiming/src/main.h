#ifndef MAIN
#define MAIN

#include <sys/types.h>
#include <sys/wait.h>
#include <sys/ipc.h>
#include <sys/sem.h>
#include <sys/time.h>
#include <time.h>
#include <semaphore.h>

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>              /* Obtain O_* constant definitions */

#include <errno.h>
#include <string.h>
#include <signal.h>
#include <stdint.h>

#include <pthread.h>
#include <termios.h>
#include <signal.h>
#include <sys/stat.h>
#include <sys/types.h>


#define WRITE 1
#define READ 0
#define TRUE 1
#define FALSE !(TRUE)
#define ON TRUE
#define OFF FALSE

typedef int bool;
typedef void *(*routine)(void);

// Interrupt routines
void intPiInterrupt(void);
void intHandler(int signo);

void terminate(int errsv);
#endif
/*EOF*/
