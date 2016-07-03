/**
*	Redes com Integração de Serviços
* 		  Projecto VOIP 2010
*   	IST, Semestre Inverno
*
* Realizado Por:
* Filipe Funenga
* Martim Camacho
* Pedro Silva (58035 - pedro.silva@ist.utl.pt)
*/

/*start the udp server*/
BOOL startUDP(int port, int *sockfd, char* IP, struct sockaddr_in* servaddr);

/*receive a UDP datagram*/
BOOL receiveUDP(int sockfd, void *message, struct sockaddr* pcaddr);

/*send a UDP datagram*/
BOOL sendUDP(int sockfd, void *message, struct sockaddr* pcaddr);
