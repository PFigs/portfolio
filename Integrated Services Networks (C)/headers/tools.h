/**config*/
#define __CLIENT__
/****/

#ifndef __SOCKET__
#define __SOCKET__
#include <sys/types.h> 
#include <sys/socket.h>
#include <arpa/inet.h>
#endif

#ifndef __AUDIO__
#define __AUDIO__
#include <fcntl.h>
#include <sys/stat.h>
#include <netinet/in.h>
#include <netdb.h>
#include <sys/ioctl.h>
#ifdef __CLIENT__
#define AUDIOMODE O_RDWR
#endif
#ifdef __SERVER__
#define AUDIOMODE O_WRONLY
#endif

#define REC_BUFFER_SIZE 256
#define KEYBOARD_BUFFER 512
#define AUDIODEVICE "/dev/audio"

#endif


#ifndef __SIP__
#define __SIP__
#define PARAM_LENGTH 50
#define MSG_LENGTH 1000
#define MAX_FORWARDS 70
#define BRANCH "z9hG4bK"
#define CALL_ID "e2e3areg"
#define PEER_ROWS 9
#define PEER_SIZE 100
#define PEER_NAME 0
#define PEER_EXT 1
#define PEER_IP 2
#define PEER_PORT 3
#define PEER_RTPIP 4
#define PEER_RTPPORT 5
#define PEER_FROMTAG 6
#define PEER_CSEQ 7
#define PEER_CALLID 8
#endif


#ifndef __MAIN__
#define __MAIN__
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <strings.h>
#include <unistd.h>
#include <stdlib.h>
#include <sys/select.h>
#include <sys/time.h>
#include <math.h>
#define PACKET_TIME 20
#define TRUE (1==1)
#define FALSE (!TRUE)
#define  MAX_MESSAGE_BUFFER 1000


typedef short int BOOL;
typedef struct {
	char *app_ip;
	char *app_port;
	char *app_name;
	char *ext;
	char *pbx_ip;
	char *pbx_port;
	unsigned int threshold;
} sArguments;

typedef struct s_ContactBook
{
	unsigned int id;
	int fd;
	char sipname[50];
	char sipext[10];
	char sipcallid[PEER_SIZE];
	char sipip[16];
	char sipport[6];
	char rtpportin[6];
	char siptagfrom[PEER_SIZE];
	struct sockaddr_in addrout;
	struct sockaddr_in addrin;
	struct s_ContactBook *next;
} sContactBook;


extern fd_set readset;
extern sArguments args;
extern char *port;
extern sContactBook* callers;
extern int callid;
extern int maxfd;
extern uint16_t seq;
extern uint32_t tmstamp;
#endif

