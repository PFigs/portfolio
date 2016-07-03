#include "../headers/tools.h"


/**
 * Obtains a socket for a UDP server (IP == NULL) or constructs a sockaddr_in to send datagrams
 */
BOOL startUDP(int port, int *sockfd, char* IP, struct sockaddr_in* paddr)
{

	#ifdef __DEBUG__
	printf("%s.%d: Getting a socket.\n",__FILE__,__LINE__);
	#endif
	if(sockfd != NULL)
		if((*sockfd=socket(AF_INET,SOCK_DGRAM,0))==-1)
		{
			printf( "%s.%d: %s\n", __FILE__,__LINE__, strerror( errno ));
			return FALSE;
		}

	#ifdef __DEBUG__
	printf("%s.%d: Registering details.\n",__FILE__,__LINE__);
	#endif
	paddr->sin_family=AF_INET; 
	paddr->sin_port=htons(port);
	if(IP==NULL)
	{
		paddr->sin_addr.s_addr=htonl(INADDR_ANY);
		if(bind(*sockfd,(struct sockaddr *)paddr,sizeof(struct sockaddr_in))==-1)
		{
			printf( "%s.%d: %s\n", __FILE__,__LINE__, strerror( errno ));
			return FALSE;
		}
	}
	else
	{
		paddr->sin_addr.s_addr = inet_addr(IP);
	}
	 

	return TRUE;
}


BOOL receiveUDP(int sockfd, void *message, struct sockaddr* pcaddr)
{
	int nbytes=0;
	unsigned int len;

	len = sizeof(struct sockaddr_in);

	#ifdef __DEBUG__
		printf("%s.%d:Waiting for a UDP datagram\n",__FILE__,__LINE__);
	#endif

	if((nbytes = recvfrom(sockfd, message, MAX_MESSAGE_BUFFER-1, 0, pcaddr, &len))<0)
	{
		printf( "%s.%d: %s\n", __FILE__,__LINE__, strerror( errno ));
		return FALSE;
	}

	#ifdef __DEBUG__
		printf("%s.%d: Received UDP datagram (%d B).\n",__FILE__,__LINE__, nbytes);
	#endif

	return TRUE;
}


BOOL sendUDP(int sockfd, void *message, struct sockaddr* pcaddr)
{
	unsigned int len;
	int nbytes;

	len = sizeof(struct sockaddr_in);
	nbytes = strlen(message);
	
	#ifdef __DEBUG__
		printf("%s.%d:Sending UDP datagram (%d B).\n",__FILE__,__LINE__, nbytes);
	#endif

	if((sendto(sockfd, message, nbytes, 0, pcaddr, len))!=nbytes)
	{
		printf( "%s.%d: %s\n", __FILE__,__LINE__, strerror( errno ));
		return FALSE;
	}

	return TRUE;
}

