#include "main.h"
#include "sensor.h"
#include "ublox.h"
#include "imu.h"


/**
 * int start_sensor(sensor device, routine thread_worker){
 *
 * Receives a DEVICE structure and the corresponding WORKER
 * function handle
 *
 * Starts a device by launching its working thread
 **/
int start_sensor(sensor* device, routine thread_worker){

    #ifdef DEBUG
    printf("Initialising mutex ...\n");
    #endif
    if (pthread_mutex_init(&device->init, NULL) == -1) terminate(errno);
    if (sem_init(&device->ready, 0,0) == -1) terminate(errno);

    #ifdef DEBUG
    printf("Locking mutex ...\n");
    #endif
    // Locks down children
    pthread_mutex_lock(&device->init);

    // Opens serial port
    init_serial_port(&device->fd,device->port);
    #ifdef DEBUG
    printf("Opened sensor at fd %d ...\n",device->fd);
    #endif

    // Opens log file
    init_log_file(&device->fd_log,device->logname);
    #ifdef DEBUG
    printf("Opened log file at fd %d ...\n",device->fd);
    #endif

    // Creates child threads
    #ifdef DEBUG
    printf("Creating thread...\n");
    #endif
    pthread_create(&device->tid,NULL, (void *) thread_worker, (void *)device);

    return 0;
}



/**
 * void init_serial_port(int *fd, char *location)
 *
 * Generic method to open a serial port in raw mode
 *
 * Terminates execution in failure
 */
void init_serial_port(int *fd, char *location){

    *fd = open(location, O_RDWR | O_NOCTTY | O_NDELAY); // Open perif
    if(*fd < 0){
        #ifdef DEBUG
        printf("Falied to open %s ...\n",location);
        #endif
        terminate(errno);
    }

    #ifdef DEBUG
    printf("Opened sensor at fd %d ...\n",*fd);
    #endif

    /* set the other settings (in this case, 9600 8N1) */
    struct termios settings;

    tcflush(*fd, TCOFLUSH);
    tcgetattr(*fd, &settings);
    cfsetospeed(&settings, 9600); /* baud rate */
    // from man - raw mode
    settings.c_iflag    &= ~(IGNBRK | BRKINT | PARMRK | ISTRIP | INLCR | IGNCR | INPCK | ICRNL | IXON);
    settings.c_oflag    &= ~OPOST;
    settings.c_lflag    &= ~(ECHO | ECHONL | ICANON | ISIG | IEXTEN);
    settings.c_cflag    &= ~(CSIZE | PARENB);
    settings.c_cflag    &= ~(CRTSCTS);
    settings.c_cflag    |= CS8;
    settings.c_cc[VMIN]  = 0;
    settings.c_cc[VTIME] = 0;

    tcsetattr(*fd, TCSADRAIN, &settings); /* apply the settings */
}

/**
 * void init_log_file(int *fd, char *location)
 *
 * Open a file descriptor to the LOCATION provided
 *
 */
void init_log_file(int *fd, char *location){

    *fd = open(location, O_WRONLY | O_CREAT | O_TRUNC, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH); // Open perif
    if(*fd < 0) terminate(errno);

    #ifdef DEBUG
    printf("Opened logfile at fd %d ...\n",*fd);
    #endif

}



/**
 * void send_conf_file(int *fd, char *location)
 *
 * Open a file descriptor to the LOCATION provided
 *
 */
void send_conf_file(int wfd, char *cfgpath){


    uint8_t message[100];
    uint8_t hexstr[3];
    int     nr   = 0;
    int     i    = 0;
    int     j    = 0;
    int     flag = FALSE;
    uint8_t *buf = hexstr;
    int     fd;

    fd = open(cfgpath, O_WRONLY | O_CREAT, S_IROTH); // Open perif
    if(fd < 0) terminate(errno);

    #ifdef DEBUG
    printf("Opened logfile at fd %d ...\n",fd);
    #endif


    // init memory
    memset((void *) hexstr,'\0',sizeof(hexstr));
    memset((void *) message,'\0',sizeof(message));

    do{
        nr = read(fd,&buf[i],sizeof(uint8_t));

        if(buf[i]==' ' || buf[i]=='\n' || buf[i]=='\r'){
            if(buf[i]=='\n' || buf[i]=='\r')
                flag   = TRUE;

            // In case there is CR/LF
            if(i>1){
                buf[i] = '\0';
                i      =  0; // space reset hex buffer
                message[j++] = (uint8_t) strtol((const char *)hexstr, NULL, 16);
            }

            // new message
            if(flag){
                #ifdef DEBUG
                int k=0;
                for(k=0;k<j;k++)
                    printf("0x%02X ",message[k]);
                    printf("\n");
                #endif

                // Send message to device
                message[j] = '\0';
                send_msg(wfd, message, j-1);

                //reset
                j    = 0;
                flag = FALSE;
                memset((void *) message,'\0',sizeof(message));
            }
        }else{
            i++;
        }

    }while(nr>0);



}
#define DEBUG

int send_msg(int wfd, uint8_t* msg, int msglen){
    int nw,i;
    #ifdef DEBUG
        printf("SENT >\n");
    #endif
    do{
        nw = write(wfd,msg,msglen);
        if(nw ==-1) terminate(errno);
        #ifdef DEBUG
            for(i=0;i<nw;i++)
                printf("%X ",msg[i]);
        #endif

    }while(nw!=msglen);

    #ifdef DEBUG
    printf("\n");
    #endif

    return nw;
}
/*EOF*/
