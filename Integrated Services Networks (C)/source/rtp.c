#include <stdint.h>
#include "../headers/tools.h"
#include "../headers/rtp.h"
#include "../headers/commUDP.h"

/**
 * Creates an header for the outgoing RTP message
 **/
void buildRTP(RTP_Header_s* psRTPHeader, uint16_t seqNumber, uint32_t timeStamp, uint32_t SSRC, int supression)
{
	if(!supression)
		psRTPHeader->VPXCCMPT = htons(0x8000);
	else
		psRTPHeader->VPXCCMPT = htons(0x8080);
	psRTPHeader->SN = htons(seqNumber);
	psRTPHeader->TS = htonl(timeStamp);
	psRTPHeader->SSRC = htonl(SSRC); 
}


/**
* Sends the RTP message
*/
int sendRTP(int sockfd, void *message, struct sockaddr* pcaddr, int nbytes)
{
	unsigned int len;

	len = sizeof(struct sockaddr_in);
	
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





