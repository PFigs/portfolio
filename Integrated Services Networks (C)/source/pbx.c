/*
 * CAUTELA ao mudar os argumentos da funções:
 * - pbx_reg
 * - pbx_unreg
 * Para o fazer é necessário tbm actualizar o ficheiro .h
 * Caso contrário o makefile dá erro.
 */

#include "../headers/tools.h"
#include "../headers/commUDP.h"
#include "../headers/sip.h"
#include "../headers/pbx.h"
#include "../headers/contactbook.h"
#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <strings.h>

/* VAMOS ENVIAR ALGUM INVITE?
char *str_sip_inv(char *sip_message,char *app_name,char *app_ext,char *app_ip,char *app_port,char *sip_ip,char *sip_port)
{
}
*/

/*
 * Retorna !=0 em caso de erro
 */
int pbx_reg(int sockfd,char *app_name, char *pbx,char *app,struct sockaddr_in* pbxaddr)
{
	char buffer[MSG_LENGTH];
	
	/*atribuir valores passados para o programa*/
	args.app_name = app_name;
	args.ext = strtok(pbx,"@");
	args.pbx_ip = strtok(NULL,":\0");
	args.pbx_port = strtok(NULL,":");
	
	/*verificar se foi indicada a porta*/
	if ( !args.pbx_port )
		args.pbx_port = port;
	
	
	/*atribuir endereco ip da aplicacao e respectiva porta*/
	args.app_ip = strtok(app,":\n");
	args.app_port = strtok(NULL,":");
	if ( !args.app_port )
		args.app_port = port;
	
	
	/*inicializar socket para enviar mensagens ao pbx*/
	if(!startUDP(atoi(args.pbx_port), NULL, args.pbx_ip, pbxaddr))
	{
		printf("Error while initializing UDP. Try again!\n");
		exit(EXIT_FAILURE);
	}
	
	
	/*adquirir string para registar*/
	str_sip_reg(buffer,args.app_name,args.ext,args.pbx_ip,args.pbx_port,args.app_ip,args.app_port,"1",1,3600);
	
	
	/*enviar pedido de registo*/
	sendUDP(sockfd,buffer,(struct sockaddr *)pbxaddr);
	
	return 0;
}


int pbx_unreg(int sockfd,struct sockaddr_in* pbxaddr)
{
	char buffer[MSG_LENGTH];
	
	/*adquirir string de 'desregisto'*/
	str_sip_reg(buffer,args.app_name,args.ext,args.pbx_ip,args.pbx_port,args.app_ip,args.app_port,"1",2,0);
	
	/*'desregistar'*/
	sendUDP(sockfd,buffer,(struct sockaddr *)pbxaddr);
	
	return 0;
}

int pbx_handle(char *msg,int sockfd, struct sockaddr_in *pbxaddr)
{
	/*tratar pedido de invite*/
	if(is_sipinvite(msg))
	{
		char peer[PEER_ROWS][PEER_SIZE];
		sContactBook *aux;
		
		#ifdef __DEBUG__
		printf("%s.%d: Received SIP Invite.\n",__FILE__,__LINE__);
		#endif
		
		/*adquirir dados da mensagem de invite*/
		if (data_sipinvite(peer,msg))
		{
			
			#ifdef __DEBUG__
			printf("%s.%d: ERROR reading sipinvite\n",__FILE__,__LINE__);
			#endif
			return -1;
		}
		
		/*adicionar a lista de chamadas activas*/
		aux=insertUniqueContactBook(callid++,0,peer[PEER_NAME],peer[PEER_EXT],peer[PEER_IP],peer[PEER_PORT],peer[PEER_FROMTAG],peer[PEER_CALLID]);
		if(!aux)
		{
			printf("\nRejected call from ext %s\n",peer[PEER_EXT]);
			return -1;
		}
		
		#ifdef __DEBUG__
		printf("%s.%d: Added to ContactBook.\n",__FILE__,__LINE__);
		#endif
		
		/*criar socket para receber desta chamada*/
		#ifdef __DEBUG__
		printf("%s.%d: Create input socket\n",__FILE__,__LINE__);
		#endif
		if(!startUDP(0, &(aux->fd), NULL, &(aux->addrin)))
		{
			printf("Error while initializing UDP. Try again!\n");
			exit(EXIT_FAILURE);
		}
			
		/*socket para enviar para esta chamada*/
		#ifdef __DEBUG__
		printf("%s.%d: Create output socket\n",__FILE__,__LINE__);
		#endif		
		if(!startUDP(atoi(peer[PEER_RTPPORT]), NULL, peer[PEER_RTPIP], &(aux->addrout)))
		{
			printf("Error while initializing UDP. Try again!\n");
			exit(EXIT_FAILURE);
		}
		
		/*actualizar estrutura com a porta de escuta*/
		setrtpportIN(aux);
		
		
		/*adquirir string de confirmacao de chamada*/
		str_sip_ok(msg,args.app_name,args.ext,args.pbx_ip,args.pbx_port,args.app_ip,args.app_port,peer[PEER_NAME],peer[PEER_EXT],peer[PEER_IP],peer[PEER_PORT],"1",aux->siptagfrom,1,1,aux->rtpportin,peer[PEER_CSEQ],peer[PEER_CALLID]);
		
		#ifdef __DEBUG__
		printf("%s\n",msg);
		#endif		
		
		
		/*enviar confirmacao*/
		sendUDP(sockfd,msg,(struct sockaddr *)pbxaddr);
		
		printf("\nAccepted call from ext %s\n",peer[PEER_EXT]);
		
		return 1;
	}
	
	/*tratar mensagem de 'ok'*/
	if(is_sipok(msg))
	{
		#ifdef __DEBUG__
		puts("ok yay");
		#endif		
		return 0;
	}
	
	/*tratar pedido de fim de chamada*/
	if(is_sipbye(msg))
	{
		sContactBook *quitter;
		char ext[10];
		
		char buf[MSG_LENGTH];
		
		
		/*adquirir string de confirmacao de fim de chamada*/
		str_sip_okbyeteste(buf,msg);
		
		
		/*enviar confirmacao*/
		sendUDP(sockfd,buf,(struct sockaddr *)pbxaddr);
		
		
		/*adquirir extensao e chamada*/
		sprintf(ext,"%d",data_sipbye(msg));
		quitter = searchContactExt(callers, ext);
		
		/*se existir apagar da lista de contactos*/
		if(quitter)
		{
			FD_CLR(quitter->fd,&readset);
			close(quitter->fd);
			deleteContactPTR(callers, quitter);
		}
		return 3;
	}
	return 0;
}

void pbx_hangall(int sockfd, struct sockaddr_in* pbxaddr)
{
	int i=0;
	sContactBook *tmp;
	
	/*desligar todas as chamadas*/
	while((tmp = popContactBook(i++))!=NULL)
		pbx_hangup(tmp->id,sockfd,pbxaddr);
}

int pbx_hangup(int id,int sockfd, struct sockaddr_in *pbxaddr)
{
	sContactBook *hang = searchContactID(callers, id);
	char msg[MSG_LENGTH];

	if(!hang)
		return 0;
	
	/*adquirir string de terminacao de chamada*/
	str_sip_bye(msg,args.ext,args.pbx_ip,args.app_ip,args.app_port,hang->sipext,hang->sipip,"1",hang->siptagfrom,hang->sipcallid);
	
	
	/*enviar pedido de terminacao de chamada*/
	sendUDP(sockfd,msg,(struct sockaddr *)pbxaddr);
	
	FD_CLR(hang->fd,&readset);
	close(hang->fd);
	deleteContactPTR(callers, hang);
	
	return 0;
}
