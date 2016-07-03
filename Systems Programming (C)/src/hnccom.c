/*
 * INSTITUTO SUPERIOR TECNICO
 *  PROGRAMACAO DE SISTEMAS
 *    PROJECTO HIGH NOON
 *
 *  Semestre Inverno 09/10
 *
 * Realizado Por:
 *    Eduardo Santos (58008)
 *    Pedro Neves (58011)
 *    Pedro Silva(58035)
 *
 */
#include "tools.h"
#include "hnccom.h"

extern _Bool debug;

void ligacao(unsigned int porto, int *escrita, char *nome_servidor, struct sockaddr_in *dservidor)
{
   *dservidor=resolve_nome(nome_servidor, porto);

   cria_socket(escrita);

   estabelece_sessao(escrita, *dservidor);
}



/**
 * name: qry_dns
 * @param
 *    struct sockaddr_in qry_dns(char* trackername, int trackerport, int verbose)
 *
 * DESCRICAO:
 * Procura diante o serviço de DNS detalhes sobre o tracker fornecido.
 * Em caso de o tracker estar inacessível, termina programa.
 *
 *
 * @return
 *    struct sockaddr_in - Se tracker estiver acessível
 *
 **/
struct sockaddr_in resolve_nome(char* trackername, int trackerport)
{
   struct sockaddr_in server;
   struct hostent *lookup;
   struct in_addr *server_ip;


   /**Procura detalhes do anfitriao perante o servico de DNS**/
   if((lookup=gethostbyname(trackername))==NULL)
   {
      perror("gethostbyname");
      exit(EXIT_FAILURE);
   }

   if(debug) printf("C:DEBUG@qry_dns: A pesquisar %s\n", trackername);

   /**Para converter o endereco ip, e necessario usar a funcao inet_ntoa(struct in_addr in)**/
   server_ip=(struct in_addr*)lookup->h_addr_list[0];  /*Dai o recurso a uma outra estrutura*/


   if(debug) printf("C:DEBUG@qry_dns: A conectar com: %s:%d\n",inet_ntoa(*server_ip),trackerport);

   memset((void*)&server,(int)'\0',sizeof(server));
   server.sin_family=AF_INET;
   server.sin_addr.s_addr=server_ip->s_addr;
   server.sin_port=htons(trackerport);

   return server;

}



void estabelece_sessao(int *sock, struct sockaddr_in server)
{
   if(alarm(60)!=0){
      if(debug) printf("C:DEBUG@estabelece_sessao: Alarme já se encontrava definido\n");
   }

   if(connect(*sock,(struct sockaddr*)&server,sizeof(server))==-1)
   {
      alarm(0);
      perror("connect");
      close(*sock);
      exit(EXIT_FAILURE);
   }

   alarm(0);
}


/* name: cria_socket
 * Wrapper para socket
 * @param inteiro para conter escuta
 * @return
 */
void cria_socket(int *sock)
{
   if((*sock=socket(AF_INET,SOCK_STREAM,0))==-1)
   {
      perror("socket");
      exit(EXIT_FAILURE);
   }
   if(debug)printf("C:DEBUG@cria_socket: Descritor da socket em %d\n",*sock);

}

char *escreve_mensagens(char *game, char *player, char *P_ID, char *cmd, char *mensagem, int mode)
{
   switch(mode){
      case NGM:
         /*+1 para o '\0'*/
         mensagem = (char *)calloc(strlen("NGM")+strlen(player)+strlen(game)+4+1,sizeof(char));
         strcat(mensagem,"NGM\n");
         strcat(mensagem,game);
         strcat(mensagem,"\n");
         strcat(mensagem,player);
         strcat(mensagem,"\n\n");
         if(debug) printf("C:DEBUG@escreve_mensagens_cliente: Criada mensagem\n%s!\n",mensagem);
         break;

      case STR:
         mensagem = (char *)calloc(strlen("STR")+strlen(P_ID)+3+1,sizeof(char));
         strcat(mensagem,"STR\n");
         strcat(mensagem,P_ID);
         strcat(mensagem,"\n\n");
         if(debug) printf("C:DEBUG@escreve_mensagens_cliente: Criada mensagem\n%s!\n",mensagem);
         break;

      case NSH:
         mensagem = (char *)calloc(strlen("NSH")+strlen(P_ID)+3+1,sizeof(char));
         strcat(mensagem,"NSH\n");
         strcat(mensagem,P_ID);
         strcat(mensagem,"\n\n");
         if(debug) printf("C:DEBUG@escreve_mensagens_cliente: Criada mensagem\n%s!\n",mensagem);
         break;

      case MOV:
         mensagem = (char *)calloc(strlen("MOV")+strlen(P_ID)+strlen(cmd)+4+1,sizeof(char));
         strcat(mensagem,"MOV\n");
         strcat(mensagem,P_ID);
         strcat(mensagem,"\n");
         strcat(mensagem,cmd);
         strcat(mensagem,"\n\n");
         if(debug) printf("C:DEBUG@escreve_mensagens_cliente: Criada mensagem\n%s!\n",mensagem);
         break;

      case EOG:
         mensagem = (char *)calloc(strlen("EOG")+strlen(P_ID)+strlen(cmd)+3+1,sizeof(char));
         strcat(mensagem,"EOG\n");
         strcat(mensagem,P_ID);
         strcat(mensagem,"\n\n");
         if(debug) printf("C:DEBUG@escreve_mensagens_cliente: Criada mensagem\n%s!\n",mensagem);
         break;

      case CNT:
         mensagem = (char *)calloc(strlen("CNT")+strlen(P_ID)+strlen(cmd)+3+1,sizeof(char));
         strcat(mensagem,"CNT\n");
         strcat(mensagem,P_ID);
         strcat(mensagem,"\n\n");
         if(debug) printf("C:DEBUG@escreve_mensagens_cliente: Criada mensagem\n%s!\n",mensagem);
         break;

      case EXT:
         mensagem = (char *)calloc(strlen("EXT")+strlen(P_ID)+3+1,sizeof(char));
         strcat(mensagem,"EXT\n");
         strcat(mensagem,P_ID);
         strcat(mensagem,"\n\n");
         if(debug) printf("C:DEBUG@escreve_mensagens_cliente: Criada mensagem\n%s!\n",mensagem);
         break;

      default:
         exit(EXIT_FAILURE);
   }
   return mensagem;
}



int envia_mensagem_cliente(int *sock, char *buffer)
{
   int left, aux;
   char reader[MAX_FIELD];

   memset((void *)reader,(int)'\0',sizeof(reader));

   /**Enquanto existirem bytes para escrever**/
   left=strlen(buffer);
   while(left>0)
   {
      aux=write(*sock,buffer,left);

      if(aux==-1)
      {
         printf("Ligacao fechada pelo utilizador!\n");
         exit(EXIT_FAILURE);
      }
      else
         if(aux==0) break;

      /**Subtrai o que foi escrito ao total de bytes**/
      left = left - aux;

      /**Avanca o ponteiro**/
      buffer = buffer + aux;
   }

   return 0;
}

char **espera_resposta(int *fd, char **resposta, int *codigo)
{
   int aux, left,i;
   char id[4];

   memset((void *)id,(int)'\0',sizeof(id));

   if(debug) printf("C:DEBUG@espera_resposta: A ler campo identificador!\n");
   for(left=sizeof(char)*4,i=0;;){
      aux=read(*fd,id,sizeof(char)*4);
      fflush(stdout);
      left=left-aux;
      if(left==0) break;
      if(aux==-1)
      {
         printf("Ligacao fechada pelo peer!\n");
         exit(EXIT_FAILURE);
      }
   }

   id[3]='\0';

   if(debug) printf("C:DEBUG@espera_resposta: Lido \'%s\' como campo identificador!\n",id);

/**Tenho que garantir que id recebido e aquele que esperava**/
   resposta=recebe_campos(id, resposta, fd, codigo);

   return resposta;
}

   /**
 * name: rece_campos
 *
 * Aloca memoria consoante o evento.
 * Efectua a leitura dos restantes campos da mensagem.
 *
 * @param
 *    campo identificador, vector a preencher, descritor da socket, nr de argumentos
 *
 * @return
 *    vector de campos preenchido
 *
 */

char **recebe_campos(char *id, char **fields, int *fd, int *codigo)
{
   int aux, left, i, arg;
   char reader[MAX_BUFF];
   char buff[SMALL_BUFF];
   _Bool erro=FALSE;

   memset((void *)reader,(int)'\0',sizeof(reader));
   memset((void *)buff,(int)'\0',sizeof(buff));

   switch(converte_id(id))
   {
      case NGM:
         fields=(char **) calloc(2,sizeof(char **));
         fields[0]=(char *) calloc(strlen("NGM")+1,sizeof(char));
         strcpy(fields[0],"NGM");
         *codigo=NGM;
         break;

      case STR:
         /**E o nome do outro jogador :)*/
         fields=(char **) calloc(12,sizeof(char **));
         fields[0]=(char *) calloc(strlen("STR")+1,sizeof(char));
         strcpy(fields[0],"STR");
         *codigo=STR;
         break;

      case REL:
         fields=(char **) calloc(1,sizeof(char **));
         fields[0]=(char *) calloc(strlen("REL")+1,sizeof(char));
         strcpy(fields[0],"REL");
         *codigo=REL;
         break;

      case NSH:
         fields=(char **) calloc(3,sizeof(char **));
         fields[0]=(char *) calloc(strlen("NSH")+1,sizeof(char));
         strcpy(fields[0],"NSH");
         *codigo=NSH;
         break;

      case BLT:
         fields=(char **) calloc(1,sizeof(char **));
         fields[0]=(char *) calloc(strlen("BLT")+1,sizeof(char));
         strcpy(fields[0],"BLT");
         *codigo=BLT;
         break;

      case MOV:
         fields=(char **) calloc(3,sizeof(char **));
         fields[0]=(char *) calloc(strlen("MOV")+1,sizeof(char));
         strcpy(fields[0],"MOV");
         *codigo=MOV;
         break;

      case EOG:
         fields=(char **) calloc(3,sizeof(char **));
         fields[0]=(char *) calloc(strlen("EOG")+1,sizeof(char));
         strcpy(fields[0],"EOG");
         *codigo=EOG;
         break;

      case CNT:
         fields=(char **) calloc(2,sizeof(char **));
         fields[0]=(char *) calloc(strlen("CNT")+1,sizeof(char));
         strcpy(fields[0],"CNT");
         *codigo=CNT;
         break;

      case EXT:
         fields=(char **) calloc(2,sizeof(char **));
         fields[0]=(char *) calloc(strlen("EXT")+1,sizeof(char));
         strcpy(fields[0],"EXT");
         *codigo=EXT;
         break;

      case ERR:
         fields=(char **) calloc(2,sizeof(char **));
         fields[0]=(char *) calloc(strlen("ERRO:")+1,sizeof(char));
         strcpy(fields[0],"ERRO:");
         erro=TRUE;
         break;

      default:
         printf("ERRO: Mensagem desconhecida!\n");
         exit(EXIT_FAILURE);
      break;
   }

  /*efectua leitura*/
   memset((void *)reader,(int)'\0',sizeof(reader));

   for(left=0,i=0,arg=1;;)
   {
      aux=read(*fd,reader+i,1);
      if(reader[0]=='\n') break;
      if(reader[i]=='\n')
      {
         reader[i]='\0';
         fields[arg]=(char *)calloc(strlen(reader),sizeof(char));
         strcpy(fields[arg],reader);
         if(debug) printf("DEBUG@gere_campos: Obtido do servidor: %s\n",reader);
         memset((void *)reader,(int)'\0',sizeof(reader));
         arg++;
         i=0;
      }
      else
      {
         i++;
      }
      if(aux<=0)
      {
         if(debug) printf("C:DEBUG@recebe_campos: Ligacao fechada pelo peer\n");
         /**Devo reestabeler ligacao*/
         break;
      }
   }

   if(erro)
   {
      printf("%s %s\n",fields[0], fields[1]);
      exit(EXIT_FAILURE);
   }

   if(debug)
   {
      if(debug) printf("C:DEBUG@recebe_campos: Parâmetros da mensagem:\n");
      for(i=arg;i>0;i--)
      {
         printf("Campo %d - %s\n",(arg-i),fields[arg-i]);
      }
   }
   return fields;
}
