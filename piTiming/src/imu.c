#include "main.h"
#include "sensor.h"
#include "imu.h"

extern struct timespec time_tag;
extern struct timespec time_tag_raw;
extern struct timespec time_tag_after_read_mcs;
extern volatile bool keepRunning;
/**
* Handles initialisation of mcs
**/

int start_imu(sensor* imu){
    #ifdef DEBUG
    printf("Calling mcst ...\n");
    #endif
    return start_sensor(imu,(void *)&track_ustrain_time);
}


void* track_ustrain_time(void *arg){

    // receive sensor information
    sensor *device = (sensor *)arg;
    uint8_t header[1];
    uint8_t *message = NULL;
    uint16_t msglen;

    #ifdef DEBUG
    printf("UStrain thread: Started ...\n");
    printf("UStrain thread: Reading serial port at %d...\n",device->fd);
    #endif


    // Put this to configuration file...
    uint8_t timer_msg[8];
    uint8_t reset_msg[3];
    uint8_t mode_msg[4];

    memset((void*)&timer_msg,'\0',sizeof(timer_msg));
    memset((void*)&reset_msg,'\0',sizeof(reset_msg));
    memset((void*)&mode_msg,'\0',sizeof(mode_msg));

    timer_msg[0] = 0xD7;
    timer_msg[1] = 0xC1;
    timer_msg[2] = 0x29;

    reset_msg[0] = 0xFE;
    reset_msg[1] = 0x9E;
    reset_msg[2] = 0x3A;

    mode_msg[0] = 0xD4;
    mode_msg[1] = 0xA3;
    mode_msg[2] = 0x47;
    mode_msg[3] = 0x01;

    //send_msg(device->fd,reset_msg,sizeof(reset_msg));
    //send_msg(device->fd,mode_msg,sizeof(mode_msg));

    uint8_t reply[4];
    //read(device->fd,&reply,sizeof(reply));
    int i=0;
    printf("GOT REPLY\n");
    for(i=0;i<4;i++)
        printf("%X ",reply[i]);


    // Waits for parent to initialise others
    pthread_mutex_lock(&device->init);
    do{

        #ifdef DEBUG
        printf("TU: Waiting on main...\n");
        #endif

        sem_wait(&device->ready); // wait for it
        send_msg(device->fd,timer_msg,sizeof(timer_msg));

        if(lookup_imu_header(device,0xD7,header)){    // Search for message

            #ifdef DEBUG
            printf("TU: looking for message...\n");
            #endif

            message = fetch_imu_payload(device,message,&msglen);

            #ifdef DEBUG
            printf("TU: Fetching imu...\n");
            #endif

            dump_imu_message(device->fd_log,message,msglen);

            #ifdef DEBUG
            printf("TU: Done...\n");
            #endif
        }else{
            send_msg(device->fd,timer_msg,sizeof(timer_msg));
        }
        #ifdef DEBUG
        printf("TU: READ header %X...\n",header[0]);
        #endif

    }while(keepRunning);

    #ifdef DEBUG
    printf("TU: Dying...\n");
    #endif

    close(device->fd);
    close(device->fd_log);
    pthread_mutex_unlock(&device->init);

    return NULL;
}


int lookup_imu_header(sensor *device, int header_start, uint8_t* header){

    int count=0;

    #ifdef DEBUG
    printf("looking for.. \n");
    #endif

    do{
        // Assumes one byte header
        if(read(device->fd,&header,sizeof(uint8_t))==-1){
            int errsv = errno;
            if(errsv != EAGAIN)
                terminate(errsv);
        }

        #ifdef DEBUG
        printf("%X ",header[0]);
        #endif

        if(header[0]==header_start) break;

    }while(1);//count++ < 10);


    #ifdef DEBUG
    printf("\nExiting header search\n");
    #endif

    if(count >=5)
        return 0;
    else
        return 1;

}

uint8_t* fetch_imu_payload(sensor *device, uint8_t* message,uint16_t* message_len){

    int        msglen = 0;
    uint8_t    buffer[6];

    // retrieves the message
    do{ // for EAGAIN
        if(read(device->fd,&buffer,6)==-1){
            int errsv = errno;
            if(errsv != EAGAIN)
                terminate(errsv);
        }else{
            break;
        }
    }while(1);

    // Computes FULL message space
    msglen  = 6; // with CHECKSUM
    message = (uint8_t *) malloc(sizeof(uint8_t)*msglen);

    #ifdef DEBUG
    printf("TOTAL MSG SIZE: %d\n",msglen);
    printf("FETCHED New counter value");
    #endif

    message[0] = buffer[0];
    message[1] = buffer[1];
    message[2] = buffer[2];
    message[3] = buffer[3];

    // Should compute the checksum !

    #ifdef DEBUG
    int i;
    for(i=0;i<msglen;i++){
        printf("%X ",buffer[i]);
    }
    printf("\n");
    #endif
    *message_len = msglen;
    return message;
}

void dump_imu_message(int fd, uint8_t* message, uint16_t msglen){

    #ifdef DEBUG
    printf("CHECKING message %02X %02X %02X %02X\n",message[0],message[1],message[2],message[3]);
    #endif

    uint32_t timer_val = 0;   // big endian
    timer_val  = message[0]<<24;
    timer_val |= message[1]<<16;
    timer_val |= message[2]<<8;
    timer_val |= message[3]; //smallest address;

    uint8_t timing_header[2];
    timing_header[0] = '#';
    timing_header[1] = ':';

    uint8_t lf = '\n';
    #ifdef DEBUG
    printf("timer value  %d...\n",timer_val);
    printf("saving  %d...\n",msglen);
    #endif
    if(write(fd,(void *)&timing_header,sizeof(timing_header))==-1) terminate(errno);
    if(write(fd,(void *)&time_tag,sizeof(time_tag))==-1) terminate(errno);
    if(write(fd,(void *)message,msglen)==-1) terminate(errno);
    if(write(fd,(void *)&lf,1)==-1) terminate(errno);
}

/*EOF*/

