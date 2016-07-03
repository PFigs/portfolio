#define SSAMPLE 160

typedef struct {
	uint16_t VPXCCMPT;
	uint16_t SN;
	uint32_t TS;
	uint32_t SSRC;
} RTP_Header_s;

typedef struct {
	RTP_Header_s sRTPHeader;
	uint8_t payload[SSAMPLE]; /**20ms de som = ? kb*/
} RTP_Message_s;

void buildRTP(RTP_Header_s* psRTPHeader, uint16_t seqNumber, uint32_t timeStamp, uint32_t SSRC, int supression);
RTP_Header_s* getRTP(char *buffer, char *msg);
int sendRTP(int sockfd, void *message, struct sockaddr* pcaddr, int nbytes);

