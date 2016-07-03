#ifndef SENSOR
#define SENSOR

#include "main.h"
#include <pthread.h>
#include <pthread.h>
#include <termios.h>

typedef struct {
    int   status;
    char  **type;
    char *port;
    char *logname;
    char *config;
    int   fd;
    int   fd_log;
    int   id;        /** sensor ID**/
    pthread_mutex_t init;
    pthread_t tid;
    sem_t ready;
    routine worker;
}sensor;

void init_serial_port(int *fd, char *location);
int start_sensor(sensor* device, routine thread_worker);
void send_conf_file(int wfd, char *cfgpath);
int send_msg(int wfd, uint8_t* msg, int msglen);
#endif
