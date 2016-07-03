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

int main(void){

    int fd;
    struct timespec ts;

    fd = open("../log/ubxtim.log",O_RDONLY);


    uint8_t bu;
    do{
        read(fd,&bu,sizeof(uint8_t));
    }while(bu!=':');


    read(fd,&ts,sizeof(struct timespec));
    #ifdef DEBUG
    printf("TIME TAG: %lld.%.9ld\n", (long long)ts.tv_sec, ts.tv_nsec);
    #endif
    long long tt_real_s;
    long tt_real_ns;
    tt_real_s  = (long long) ts.tv_sec;
    tt_real_ns = ts.tv_nsec;

    // Read RAW time
    read(fd,&ts,sizeof(struct timespec));
    #ifdef DEBUG
    printf("TIME TAG: %lld.%.9ld\n", (long long)ts.tv_sec, ts.tv_nsec);
    #endif
    long long tt_real_raw_s;
    long tt_real_raw_ns;
    tt_real_raw_s  = (long long) ts.tv_sec;
    tt_real_raw_ns = ts.tv_nsec;

    // Read RAW time after serial work
    read(fd,&ts,sizeof(struct timespec));
    #ifdef DEBUG
    printf("TIME TAG: %lld.%.9ld\n", (long long)ts.tv_sec, ts.tv_nsec);
    #endif
    long long tt_real_raw_serial_s;
    long tt_real_raw_serial_ns;
    tt_real_raw_serial_s  = (long long) ts.tv_sec;
    tt_real_raw_serial_ns = ts.tv_nsec;

    printf("%lld.%.9ld\t%lld.%.9ld\t%lld.%.9ld\t",tt_real_s,tt_real_ns,tt_real_raw_s,tt_real_raw_ns,tt_real_raw_serial_s,tt_real_raw_serial_ns);

    // ublox
    do{
        read(fd,&bu,sizeof(uint8_t));
    }while(bu!=0xB5);


    // header and class and id
    do{
        read(fd,&bu,sizeof(uint8_t));
    }while(bu!=0x62);

    int i;
    read(fd,&bu,sizeof(uint8_t));
    read(fd,&bu,sizeof(uint8_t));

    // length
    read(fd,&bu,sizeof(uint8_t));
    int len = bu;
    read(fd,&bu,sizeof(uint8_t));
    len |= bu << 8;

    // Payload
    uint8_t buf[len];
    for(i=0;i<len;i++){
        read(fd,&buf[i],sizeof(uint8_t));
    }


    uint32_t iTOW=0;
    int32_t  fTOW=0;
    int16_t  week=0;
    int8_t   leaps=0;
    uint8_t  valid=0;
    uint32_t tAcc=0;

    i=0;

    // iTOW [ms]
    iTOW  = buf[i++];
    iTOW |= buf[i++] << 8;
    iTOW |= buf[i++] << 16;
    iTOW |= buf[i++] << 24;


    // fSOW [ns]
    fTOW  = buf[i++];
    fTOW |= buf[i++] << 8;
    fTOW |= buf[i++] << 16;
    fTOW |= buf[i++] << 24;

    // week [-]
    week  = buf[i++];
    week |= buf[i++]<<8;

    // leaps [-]
    leaps  = buf[i++];

    // valid [-]
    valid  = buf[i++];

    // tAcc [-]
    tAcc  = buf[i++];
    tAcc |= buf[i++] << 8;
    tAcc |= buf[i++] << 16;
    tAcc |= buf[i++] << 24;
/*
    printf("iTOW:%u\n",iTOW);
    printf("fTOW:%u\n",fTOW);
    printf("week:%u\n",week);
    printf("TOW: %f\n",(iTOW * 1e-3) + (fTOW * 1e-9));
*/
printf("%u\t%u\t%d\t%d\t%d\t%u\n",iTOW,fTOW,week,leaps,valid,tAcc);
    //const char *hexstring = "24";
    //int number = (int)strtol(hexstring, NULL, 16);
    //printf("%c\n",(char)number);

}
