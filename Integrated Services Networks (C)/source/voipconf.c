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
#include "../headers/tools.h"
#include "../headers/commUDP.h"
#include "../headers/pbx.h"
#include "../headers/contactbook.h"
#include "../headers/rtp.h"
#include "../headers/g711.h"
#include <time.h>
#define FAST_ULAW_CONVERSION

fd_set readset;
sArguments args;
char *port = "5060";
sContactBook* callers=NULL;
int callid=0;
int maxfd;


/*
* Imprime um menu dinamico consoante o numero de chamadas activas
*/
void printmenu(void)
{
	sContactBook * aux  = callers;

	printf("D: Desligar todas as chamadas\n");
	while(aux!=NULL)
	{
		printf("    %d: Desligar a chamada em curso com a extensão %s que foi atendida.\n", aux->id, aux->sipext);
		aux = aux-> next;
	}
	printf("T: Terminar a aplicação, desregistando-se primeiro do proxy SIP.\n");

}

/*
* Converte uma string (sem letras) para um inteiro
*/
int stoi(char *tmp) {
	int a;
	if(tmp == NULL)
		return -1;
	a = atoi(tmp);
	if(a < pow(10,strlen(tmp)-1) && strcasecmp(tmp,"0") != 0)
		return -1;
	return a;
}


int main(int argc, char **argv)
{
	int port, sockfd, maxfd, ready, threshold;
	char buffer[MAX_MESSAGE_BUFFER];
	struct sockaddr_in servaddr;
	struct sockaddr_in sendaddr;
	struct sockaddr_in pbxaddr;
	RTP_Message_s sRTPMessage;
	sContactBook *tmp=NULL;
	int16_t confmessage[SSAMPLE];
	int16_t backmessage[SSAMPLE];
	int16_t auxmessage[SSAMPLE];
    unsigned int confsend;
	uint16_t seq=0;
	uint32_t tmstamp=0;
	time_t local;
	uint32_t ssrc= (uint32_t)time(&local);
	int k=0,waves=0;
	char *aux;
	fd_set auxset;
	BOOL send_voice = FALSE;
	BOOL send_timer = FALSE;
	BOOL callactive = FALSE;
	BOOL supression = FALSE;
	struct timeval timer;
	struct timeval in_time,out_time;
	double elapsedtime=0;
	FILE *fp;

	switch( argc ){
		case 4:
			threshold = 0;
			break;
		case 5:
			threshold = atoi( argv[4] );
			break;
		default:
			printf("usage: ./conf <app_name> <ext>@<sip_ip>[:sip_port] <app_ip>[:app_port] [silence_threshold]\n");
			return -1;
	}

	aux = index(argv[3],(int)':');
	if (aux) {
		port = atoi(aux+1);
	}
	else
		port = 5060;
		
	memset((void*)buffer,(int)'\0',sizeof(buffer));

	if(!(port > 2000))
	{
		printf("Please set an higher port number.\n");
		exit(EXIT_FAILURE);
	}

	if(argc == 5)
		args.threshold = (uint16_t) stoi(argv[4]);
	else
		args.threshold = (unsigned int) 0;

	/*initialize server socket*/
	if(!startUDP(port, &sockfd, NULL, &servaddr))
	{
		printf("Error while initializing UDP. Try again!\n");
		exit(EXIT_FAILURE);
	}
	
	/*initialize pbx*/
	pbx_reg( sockfd, argv[1], argv[2], argv[3],(struct sockaddr_in* )&pbxaddr);
	printf("Ready to receive messages.\n");

	/*Deletes file if it exists*/
	remove( "audio.au" );

	/*Opens file*/
	if (!(fp= fopen ("audio.au", "a"))) 
	{
		printf ("Error in opening file");
		exit (EXIT_FAILURE);
	}

	/*inicializar readset*/
	FD_ZERO(&readset);
	
	/*adicionar descritores */
	FD_SET(0,&readset);
	FD_SET(sockfd,&readset);
	
	maxfd = (0>sockfd)?0:sockfd;
	timer.tv_sec = 0;
	timer.tv_usec = 0;
	out_time.tv_sec = 0;
	out_time.tv_usec = 0;
	in_time.tv_sec = 0;
	in_time.tv_usec = 0;

	puts("T: to exit");
	printf("\nvoip-conference :> ");
	for(;;)
	{
		fflush(stdout);
		/*inicializar set*/
		FD_ZERO(&auxset);
		memcpy(&auxset,&readset,sizeof(readset));
		if (elapsedtime>=PACKET_TIME)
		{
			timer.tv_usec = PACKET_TIME*1000-(elapsedtime*1000-PACKET_TIME*1000);
			gettimeofday(&in_time,NULL);
			send_timer = TRUE;
		}
		else
		{
			timer.tv_usec = PACKET_TIME*1000-elapsedtime*1000;
		}

		ready = select(maxfd + 1, &auxset, NULL, NULL, &timer);

		if(gettimeofday(&out_time,NULL)!=0)
		{
			printf( "%s.%d: %s\n", __FILE__,__LINE__, strerror( errno ));
			return EXIT_FAILURE;
		}
		
		elapsedtime = (double) (((double)out_time.tv_sec - (double) in_time.tv_sec)*1000);
		elapsedtime += (double) (( (double)out_time.tv_usec - (double)in_time.tv_usec) / 1000);
		
		/*Verifica se tem algo para enviar*/		
		if(send_timer)
		{			
		
			if(send_voice)
			{
				/*Constroi a mensagem a enviar*/
				buildRTP(&sRTPMessage.sRTPHeader,seq,tmstamp,ssrc,supression);
				for(k=0;k<SSAMPLE;k++)
					sRTPMessage.payload[k] = st_14linear2ulaw((confmessage[k]>>2)/waves);

				#ifdef __DEBUG__
				printf("%s.%d:Processed sound on with power %d which is above threshold %d\n",__FILE__,__LINE__,confsend,args.threshold);
				printf("VPXCC: %x\nSN: %d\nTS: %d\nSSRC: %d\n",(int) ntohs(sRTPMessage.sRTPHeader.VPXCCMPT),\
																	   (int) ntohs(sRTPMessage.sRTPHeader.SN),\
																	   (int) ntohl(sRTPMessage.sRTPHeader.TS),\
																	   (int) sRTPMessage.sRTPHeader.SSRC);
				#endif
				seq++;
				
				/**Send to everyone*/
				tmp = callers;
				
				while(tmp)
				{
					#ifdef __DEBUG__
					printf("%s.%d:Sending a message to socket %d\n",__FILE__,__LINE__,tmp->fd);
					#endif
					sendRTP(tmp->fd, (void*) &sRTPMessage, (struct sockaddr *) &tmp->addrout, sizeof(sRTPMessage));
					tmp=popContactBookNext(tmp,1);
				}
				supression = FALSE;
			}
			if(callactive)
			{
				supression = TRUE;
				send_voice = FALSE;
			    send_timer = FALSE;
			    callactive = FALSE;
			    memset((void *)confmessage,(int)'\0',sizeof(confmessage));
			    memset((void *)auxmessage,(int)'\0',sizeof(auxmessage));
  			    memset((void *)backmessage,(int)'\0',sizeof(backmessage));
	  			waves=0;
				tmstamp+=SSAMPLE;
   				fwrite(sRTPMessage.payload, 1, SSAMPLE, fp);
			}
		}
		
		
		
		
		/*ha descritores?*/
		if(ready > 0)
		{
			/*pbx activo*/
			if (FD_ISSET(sockfd,&auxset))
			{
				int type;
				ready--;
				/*Receive*/
				receiveUDP(sockfd,buffer,(struct sockaddr*) &sendaddr);
				
				type = pbx_handle(buffer,sockfd,(struct sockaddr_in* )&pbxaddr);
				
				/*successfuly received invite*/
				if(type == 1)
				{
					/*add descriptor to select*/
					sContactBook *tmp = popContactBook(0);;
					maxfd=(maxfd>tmp->fd)?maxfd:tmp->fd;
					FD_SET(tmp->fd,&readset);
				}
				
			}
			
			/*teclado activo*/
			if (FD_ISSET(0,&auxset))
			{
				ready--;
				/*read input*/
				fgets(buffer,MAX_MESSAGE_BUFFER,stdin);
				
				if(!strncmp(buffer,"d ",2))
				{
					char *op,*sid;
					int id;
					
					op = strtok(buffer," ");
					sid = strtok(NULL,"\n");
					
					id = stoi(sid);
					
					if(id != -1)
					{
						puts("hangup");
						pbx_hangup(id,sockfd,(struct sockaddr_in*)&pbxaddr);
						
						if(callers)
							puts("callers not null");
						else
							puts("callers null");
					}
					else
					{
						puts("usage: d [id]");
					}
				}
				
				if(!strncmp(buffer,"d\n",2))
				{
					
					pbx_hangall(sockfd,(struct sockaddr_in*)&pbxaddr);
					destroyBook(callers);
					
					if(callers)
						puts("There are active calls");
					else
						puts("No active calls");
				}

				/*Varios comandos para aumentar e diminuir o limiar*/
				if(!strcmp(buffer,"tp\n"))
					args.threshold+=1000;

				if(!strcmp(buffer,"tpp\n"))
					args.threshold+=10000;

				if(!strcmp(buffer,"tm\n"))
					args.threshold-=1000;

				if(!strcmp(buffer,"tmm\n"))
					args.threshold-=10000;

				if(!strcmp(buffer,"clear\n"))
					system("clear");
					
				if(!strcmp(buffer,"show all contacts\n"))
					showAllContacts(callers);

				if(!strcmp(buffer,"show first contact\n"))
					showContact(callers);
				
				if( (!strcmp(buffer,"?\n")) || (!strcmp(buffer,"help\n")) || (!strcmp(buffer,"h\n")) )
					printmenu();

				if( !strcasecmp(buffer,"T\n") )
				{
					/*Send BYE to callers*/
					while(callers!=NULL)
					{
						FD_CLR(callers->fd,&auxset);
						close(callers->fd);
						callers = callers->next;
					}
					
				    /*Desregistar do PBX*/
					pbx_unreg( sockfd,(struct sockaddr_in* )&pbxaddr);
					break;
				}
				printf("voip-conference :> ");
			}
			
			tmp = NULL;
			while(ready > 0)
			{
				if (tmp == NULL) callactive = TRUE;

				tmp = popContactBookNext(tmp,1);
				memset((void *)&sRTPMessage,(int)'\0',sizeof(sRTPMessage));

				/**Recebe audio RTP no porto indicado a aplicacao*/
				if(tmp!=NULL && FD_ISSET(tmp->fd,&auxset))
				{
					
					ready--;
					receiveUDP(tmp->fd,(void *) &sRTPMessage, (struct sockaddr *) &tmp->addrin);
					memset((void *)backmessage,(int)'\0',sizeof(backmessage));
					memcpy((void*)backmessage,(void*)confmessage,sizeof(confmessage));
					memset((void *)auxmessage,(int)'\0',sizeof(auxmessage));
					
					/**converte o ulaw para linear e soma-o num buffer auxiliar*/
					for ( confsend=0, k = 0; k< SSAMPLE; k++)
					{
						auxmessage[k] = st_ulaw2linear16(sRTPMessage.payload[k]);
						confmessage[k]+=auxmessage[k];
						confsend += auxmessage[k]*auxmessage[k];
					}
					
					/*
					 * Verifica se som recebido do utilizador está acima do limiar.
					 * Incrementa numero de ondas se se verificar. Caso contrário, repoe mensagem anterior
					 */
					confsend=confsend/SSAMPLE;
					if(confsend >= args.threshold)
					{
						send_voice = TRUE;
						waves++;
					}
					else
					{
						#ifdef __DEBUG__
						printf("%s.%d:Sound power: %d is below threshold: %d\n",__FILE__,__LINE__,confsend,args.threshold);
						#endif
						memcpy((void*)confmessage,(void*)backmessage,sizeof(backmessage));
					}
				}
				/*checks if it has obtained everyone\' message*/
			}
		}
	}
	
	puts("");

	close(sockfd);

	fclose(fp);

	return EXIT_SUCCESS;
}



