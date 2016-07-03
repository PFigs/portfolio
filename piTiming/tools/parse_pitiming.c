#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <fcntl.h>              /* Obtain O_* constant definitions */
#include <sys/types.h>
#include <sys/wait.h>
#include <errno.h>
#include <string.h>
#include <time.h>
#include <assert.h>
#include <stdint.h>

#define TRUE 1
#define FALSE !(TRUE)

#define MAX_BUFFER 500 // improve with max expected message from ubx

typedef int bool;

typedef enum {new_entry,new_entry_confirm,start_ubx,start_tim,start_ubx_confirm,ubx_class,ubx_nav_time} state_t;

void parse_ubx_nav_timegps(int fd,int outfile,int length);
void parse_sys_time(int fd,int ffile);
int identify(int fd,int *payload_length);

int main(int argc, char **argv) {

    int ubxfile;
    int ffile;
    int payload_length=0;


    assert(argc >1);

    // open file
    ubxfile = open(argv[1],O_RDONLY);
    if(ubxfile==-1)
    {
        perror(strerror(errno));
        exit(EXIT_FAILURE);
    }

    // open file
    ffile = open(argv[1],O_WRONLY,S_IRWXU);

    // get length of file:
    int      nr    = 0;
    int      count = 0;
    state_t  state = new_entry;

    uint8_t buf;
    bool skip_read = FALSE;
    do{

        // read byte
        if(!skip_read)
            nr = read(ubxfile,&buf,sizeof(uint8_t));

        switch(state){

            case new_entry:
                #ifdef DEBUG
                printf("new_entry %02X\n",buf);
                #endif
                if(buf == '#') // looks for header
                    state = new_entry_confirm;
                break;

            case new_entry_confirm:
                #ifdef DEBUG
                printf("new_entry cnf %02X\n",buf);
                #endif
                if(buf == ':'){ // looks for header
                    state = start_tim;
                    skip_read = TRUE;
                }
                break;

            case start_tim:
                #ifdef DEBUG
                printf("start tim %02X\n",buf);
                #endif
                parse_sys_time(ubxfile,ffile);
                skip_read = FALSE;
                state = start_ubx;
                break;

            case start_ubx:
                #ifdef DEBUG
                printf("start ubx %02X\n",buf);
                #endif
                if(buf == 0xB5){ // looks for header
                    state = start_ubx_confirm;
                }else{
                    state = new_entry;
                }
                break;


            case start_ubx_confirm:
                #ifdef DEBUG
                printf("start ubx cnf %02X\n",buf);
                #endif
                if(buf == 0x62){
                    state = ubx_class;
                    skip_read = TRUE;
                }else{
                    state = new_entry;
                }
                break;

            case ubx_class:
                #ifdef DEBUG
                printf("start ubx class %02X\n",buf);
                #endif
                state = identify(ubxfile,&payload_length);
                break;

            case ubx_nav_time:
                #ifdef DEBUG
                printf("start ubx nav time %02X\n",buf);
                #endif
                parse_ubx_nav_timegps(ubxfile,ffile,payload_length);
                skip_read = FALSE;
                state = new_entry;
                break;
        }

    }while(nr!=EOF && nr >0);

    // clean up
    close(ubxfile);
    return 0;
}


int identify(int fd,int *payload_length){

    uint8_t buf[4];
    int     length = 0;

    read(fd,&buf,sizeof(uint8_t)*sizeof(buf));

    length  = buf[2]; // lE
    length |= buf[3]<<8; // something weird is going on

    *payload_length = length;

    return ubx_nav_time;
}

void parse_sys_time(int fd,int ffile){

    // Read real time
    struct timespec ts;

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

}


void parse_ubx_nav_timegps(int fd,int outfile,int length){

    uint8_t buf[100];

    read(fd,&buf,length*sizeof(uint8_t));


    uint32_t iTOW=0;
    int32_t  fTOW=0;
    int16_t  week=0;
    int8_t   leaps=0;
    uint8_t  valid=0;
    uint32_t tAcc=0;

    int i=0;

    // iTOW [ms]
    iTOW  = buf[i];
    iTOW |= buf[i+1] << 8;
    iTOW |= buf[i+2] << 16;
    iTOW |= buf[i+3] << 24;

    printf("\n");
    printf("iTOW :>  (%u s) ",iTOW);
    printf("0x%02X 0x%02X 0x%02X 0x%02X\n",buf[i],buf[i+1],buf[i+2],buf[i+3]);

    // fSOW [ns]
    fTOW  = buf[i+4];
    fTOW |= buf[i+5] << 8;
    fTOW |= buf[i+6] << 16;
    fTOW |= buf[i+7] << 24;

    printf("\n");
    printf("fSOW :>  (%d ns) ",fTOW);
    printf("0x%02X 0x%02X 0x%02X 0x%02X\n",buf[i+4],buf[i+5],buf[i+6],buf[i+7]);

    // week [-]
    week  = buf[i+8];
    week |= buf[i+9]<<8;

    printf("\n");
    printf("week :> (%d) ",week);
    printf("0x%02X 0x%02X\n",buf[i+8],buf[i+9]);


    // leaps [-]
    leaps  = buf[i+10];

    // valid [-]
    valid  = buf[i+11];

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

    int j=0;
    printf("\n");
    printf("Interpreted :>  ");
    for(j=0;j<i+15;j++)
        printf("0x%02X ",buf[j]);
}


