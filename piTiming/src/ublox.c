#include "main.h"
#include "sensor.h"
#include "ublox.h"

#define SHOW_STRING

extern struct timespec time_tag;
extern struct timespec time_tag_raw;
extern struct timespec time_tag_after_read_ubx;
extern volatile bool keepRunning;


/**
 *  int start_ublox(sensor* gnss)
 *
 * Handles initialisation of ublox
 **/
int start_ublox(sensor* gnss){
    #ifdef DEBUG
    printf("Calling ublox...\n");
    #endif
    return start_sensor(gnss,(void *)&track_ublox_time);
}


/*** Thread ***/

/**
 * void *track_ublox_time
 *
 * Handles ublox serial port requests
 *
 */
void* track_ublox_time(void *arg){

    // receive sensor information
    sensor *device = (sensor *)arg;
    uint8_t header[2];
    uint8_t *message = NULL;
    uint16_t msglen;


    #ifdef DEBUG
    printf("UBX thread: Started ...\n");
    printf("UBX thread: Reading serial port at %d...\n",device->fd);
    #endif

    // Waits for parent to initialise others
    pthread_mutex_lock(&device->init);

    do{

        #ifdef DEBUG
        int sem_val=0;
        sem_getvalue(&device->ready,&sem_val);
        printf("TU: Waiting on main...\n");
        printf("TU: sem_t = %d\n",sem_val);
        #endif
        sem_wait(&device->ready); // wait for it
        lookup_header(device,UBX_H_CF, UBX_H_CF,header);    // Search for message
        message = fetch_payload(device,message,&msglen);
        dump_message(device->fd_log,message,UBX_NAV,UBX_NAV_TIMEGPS,msglen);

        #ifdef DEBUG
        printf("TU: Done...\n");
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





/**
*  void lookup_header(sensor *device, int header_start, int header_confirm, uint8_t* header)
 *
 * Searches for header message and exits when message start has begun
 **/
void lookup_header(sensor *device, int header_start, int header_confirm, uint8_t* header){

    ubx_states_header state = LFHEAD;
    int        offset = 0;
    uint8_t    buf=0;
    bool       new_message = FALSE;
    //fsync(device->fd);
    do{
        // Assumes one byte header
        buf = *header+offset;
        if(read(device->fd,&buf,1)==-1){
            int errsv = errno;
            if(errsv != EAGAIN)
                terminate(errsv);
        }

        switch(state){
            case LFHEAD:
                if(buf==UBX_H_ST){
                    #ifdef DEBUG
                    printf("Got header\n");
                    #endif
                    offset = 1;
                    state  = CFHEAD;
                }
                break;

            case CFHEAD:
                offset = 0; // Regardless of confirmation or not
                if(buf==UBX_H_CF){
                    #ifdef DEBUG
                    printf("Header confirmed\n");
                    #endif
                    new_message = TRUE;
                    break;
                }
            break;
        }
    }while(!new_message);

    #ifdef DEBUG
    printf("Exiting header search\n");
    #endif
}



/**
 * uint8_t* fetch_payload(sensor *device, uint8_t* message,uint16_t* message_len)
 *
 * Retrieves uBlox payload and returns full message with length
 **/
uint8_t* fetch_payload(sensor *device, uint8_t* message,uint16_t* message_len){

    int        msglen,rt,nread,nbytes;
    uint8_t    buffer[4];
    uint16_t   length = 0;


    // retrieves class, ID and length
    do{ // for EAGAIN
        if(read(device->fd,&buffer,4)==-1){
            int errsv = errno;
            if(errsv != EAGAIN)
                terminate(errsv);
        }else{
            break;
        }
    }while(1);

    // Build length (Little Endian)
    length  = buffer[2];
    length |= buffer[3] <<8;

    // Computes FULL message space
    msglen  = (UBX_HEADER_SIZE+UBX_MSG_TAG_SIZE+length+UBX_CHECKSUM_SIZE);
    message = (uint8_t *) malloc(msglen*(sizeof(uint8_t)));

    // Retrieve payload
    nread  = 0;
    nbytes = length+UBX_CHECKSUM_SIZE;
    do{ // for EAGAIN
        rt = read(device->fd,&message[6],nbytes);
        if(rt==-1){
            int errsv = errno;
            if(errsv != EAGAIN)
                terminate(errsv);
        }else{
            nread+=rt;
        }
    }while(nread < nbytes);

    // System time tag from a non specified time (usually boot)
    clock_gettime(CLOCK_MONOTONIC_RAW, &time_tag_after_read_ubx); // disable NTP

    #ifdef DEBUG
    printf("TOTAL MSG SIZE: %d\n",msglen);
    #endif

    // Put tag in message
    message[0] = UBX_H_ST;  // 0xB5
    message[1] = UBX_H_CF;  // 0x62
    message[2] = buffer[0]; // CLASS
    message[3] = buffer[1]; // ID
    message[4] = buffer[2]; // Length (L)
    message[5] = buffer[3]; // Length (H)

    #ifdef DEBUG
    int i;
    printf("MSG LEN: %d\n",msglen);
    for(i=0;i<msglen;i++){
        printf("0x%02X ",message[i]);
    }
    printf("\n");
    #endif
    *message_len = msglen;
    return message;
}



/**
 * void dump_message(int fd, uint8_t* message, uint8_t CLASS, uint8_t ID, uint16_t msglen)
 *
 *  Saves message to a binary file
 */
void dump_message(int fd, uint8_t* message, uint8_t CLASS, uint8_t ID, uint16_t msglen){

    #ifdef DEBUG
    printf("CHECKING message %02X %02X\n",message[2],message[3]);
    #endif

    if(message[2] == CLASS && message[3] == ID){

        #ifdef DEBUG
        printf("saving  %d...\n",msglen);
        #endif

        uint8_t entry_header[2];

        entry_header[0] = '#';
        entry_header[1] = ':';

        safe_write(fd,&entry_header,sizeof(entry_header));
        safe_write(fd,&time_tag,sizeof(struct timespec));
        safe_write(fd,&time_tag_raw,sizeof(struct timespec));
        safe_write(fd,&time_tag_after_read_ubx,sizeof(struct timespec));
        safe_write(fd,message,msglen); // careful sending address

        #ifdef DEBUG
        printf("TIME TAG: %lld.%.9ld\n", (long long)time_tag.tv_sec, time_tag.tv_nsec);
        printf("TIME TAG RAW: %lld.%.9ld\n", (long long)time_tag_raw.tv_sec, time_tag_raw.tv_nsec);
        printf("TIME TAG UBX: %lld.%.9ld\n", (long long)time_tag_after_read_ubx.tv_sec, time_tag_after_read_ubx.tv_nsec);

        printf("\n");
        printf("MESSAGE :>  ");
        int i = 0;
        for(i=0;i<msglen;i++)
            printf("0x%02X ",message[i]);

        #endif

        #ifdef SHOW_STRING
        printf("%lld.%.9ld\t%lld.%.9ld\t%lld.%.9ld\t",(long long)time_tag.tv_sec,time_tag.tv_nsec, \
                                                      (long long) time_tag_raw.tv_sec,time_tag_raw.tv_nsec, \
                                                      (long long) time_tag_after_read_ubx.tv_sec,time_tag_after_read_ubx.tv_nsec);
        #endif

        parse_ubx_nav_timegps(message,6);
    }

}

void safe_write(int fd, void *buff, int len){
    int nr =0;
    do{
        nr=write(fd,buff,len);
        if(nr == -1) terminate(errno);
    }while(nr!=len);

}

/**
 * void parse_ubx_nav_timegps(uint8_t *buf,int payload_start)
 *
 * Parse the payload of the ubx message and retrieves GPS TIME
 * data
 */
void parse_ubx_nav_timegps(uint8_t *buf,int payload_start){

    uint32_t iTOW=0;
    int32_t  fTOW=0;
    int16_t  week=0;
    int8_t   leaps=0;
    uint8_t  valid=0;
    uint32_t tAcc=0;

    int i=payload_start;

    // iTOW [ms]
    iTOW  = buf[i];
    iTOW |= buf[i+1] << 8;
    iTOW |= buf[i+2] << 16;
    iTOW |= buf[i+3] << 24;

    #ifdef DEBUG
    printf("\n");
    printf("iTOW :>  (%u s) ",iTOW);
    printf("0x%02X 0x%02X 0x%02X 0x%02X\n",buf[i],buf[i+1],buf[i+2],buf[i+3]);
    #endif

    // fSOW [ns]
    fTOW  = buf[i+4];
    fTOW |= buf[i+5] << 8;
    fTOW |= buf[i+6] << 16;
    fTOW |= buf[i+7] << 24;

    #ifdef DEBUG
    printf("\n");
    printf("fSOW :>  (%d ns) ",fTOW);
    printf("0x%02X 0x%02X 0x%02X 0x%02X\n",buf[i+4],buf[i+5],buf[i+6],buf[i+7]);
    #endif

    // week [-]
    week  = buf[i+8];
    week |= buf[i+9]<<8;

    #ifdef DEBUG
    printf("\n");
    printf("week :> (%d) ",week);
    printf("0x%02X 0x%02X\n",buf[i+8],buf[i+9]);
    #endif

    // leaps [-]
    leaps |= buf[i+10]; // to avoid warning

    #ifdef DEBUG
    printf("\n");
    printf("leaps :> (%d) ",leaps);
    printf("0x%02X 0x%02X\n",buf[i+10]);
    #endif

    // valid [-]
    valid |= buf[i+11];

    #ifdef DEBUG
    printf("\n");
    printf("valid :> (%X) ",valid);
    printf("0x%02X 0x%02X\n",buf[i+11]);
    #endif

    // tAcc [-]
    tAcc  = buf[i+12];
    tAcc |= buf[i+13] << 8;
    tAcc |= buf[i+14] << 16;
    tAcc |= buf[i+15] << 24;

    #ifdef DEBUG
    printf("iTOW:%u\n",iTOW);
    printf("fTOW:%u\n",fTOW);
    printf("week:%u\n",week);
    printf("tAcc: %d\n",tAcc);
    printf("Valid: %d\n",valid);
    printf("Leaps: %d\n",leaps);
    #endif

    #ifdef SHOW_STRING
    printf("%u\t%u\t%d\t%d\t%d\t%u\n",iTOW,fTOW,week,leaps,valid,tAcc);
    #endif

    #ifdef DEBUG
    int j=0;
    printf("\n");
    printf("Interpreted :>  ");
    for(j=0;j<i+15;j++)
        printf("0x%02X ",buf[j]);
    #endif
}


/*EOF*/
