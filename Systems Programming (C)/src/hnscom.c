/*
 * INSTITUTO SUPERIOR TECNICO
 *  PROGRAMACAO DE SISTEMAS
 *    PROJECTO HIGH NOON
 *
 *  Semestre Inverno 09/10
 *
 * Este ficheiro contem as funcao que
 * permitem a comunicacao do programa
 * servidor
 * Realizado Por:
 *    Eduardo Santos (58008)
 *    Pedro Neves (58011)
 *    Pedro Silva(58035)
 */
#include "tools.h"
#include "hnscom.h"
#include "hns.h"

extern _Bool debug;


/** name: iniciar_comunicacoes
 * Tem como objectivo preparar o programa servidor
 * para escutar mensagens do programa cliente
 * @param porto a escutar
 * @return nada por enquanto
 */

void iniciar_comunicacoes(int porto, int *escuta)
{
   struct sockaddr_in dservidor;

   /**Cria descritor onde fica a escuta*/
   cria_socket(escuta);
   if(debug) printf("DEBUG:\nSocket criada com sucesso...\nEscuta:%d\n",*escuta);

   /**introducao dos detalhes do servidor*/
   dservidor=configura_socket(porto, TRUE);
   if(debug) printf("DEBUG:\nSocket configurada com sucesso...!\n");

   /**Associa escuta ao porto especificado*/
   associa_porto(*escuta, dservidor);
   if(debug) printf("DEBUG:\nColocada escuta no porto: %d ...\n",porto);

   /**Inicia escuta no porto especificado*/
   escuta_porto(*escuta, porto);

   if(debug) printf("DEBUG:\nComunicacoes iniciadas com sucesso!\nServidor esta pronto para aceitar pedidos!\n");
}



/** name: cria_socket
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

}

/* name: configura_socket
 * Devolve estrutura com detalhes preenchidos
 * @param porto e tipo ligacao
 * @return estrutura preenchida
 */
struct sockaddr_in configura_socket(int port, _Bool TCP)
{
   struct sockaddr_in config;

   /**Bool serve para decidir sobre TCP ou UDP*/
   memset((void*)&config,(int)'\0',sizeof(config));
   config.sin_family=AF_INET;
   config.sin_addr.s_addr=htonl(INADDR_ANY);
   config.sin_port=htons(port);

   return config;

}


/** name: associa_porto
 * Wrapper para bind
 * @param descritor em escuta e estrutura com detalhes
 * @return
 */
void associa_porto(int sockfd, struct sockaddr_in details)
{
   if((bind(sockfd, (struct sockaddr*) &details, sizeof(details)))==-1)
   {
      perror("bind");
      exit(EXIT_FAILURE);
   }
}

/** name: escuta_porto
 * Wrapper para listen
 * @param descritor em escuta e porto
 * @return
 */
void escuta_porto(int listenfd, int port)
{

   if(listen(listenfd, port)==-1)
   {
      perror("listen");
      exit(EXIT_FAILURE);
   }
}



/** name: recebe_mensagens
 * Fica encarregue de receber mensagens
 * @param descritor em escuta e porto
 * @return
 */
void recebe_mensagens(int listenfd, int port)
{
   int codigo;
   int connsock;
   unsigned int clilen=0;
   struct sockaddr_in client;
   char **campos=(char **) NULL;
   struct hostent *h;
   char *IP;

   /**Threads vão bloquear aqui*/
   if((connsock=accept(listenfd, (struct sockaddr *)&client, &clilen))==-1)
   {
      perror("accept");
      exit(EXIT_FAILURE);
   }
   /**Threads executam o seu trabalho*/

   campos=decompoe_mensagem(campos, connsock, &codigo);

    /**tratar a info proveniente de campos*/
    h=gethostbyaddr((char*)&client.sin_addr,sizeof(struct in_addr),AF_INET);
    if(h==NULL)
    {
        IP = calloc(strlen((char *)inet_ntoa(client.sin_addr)),sizeof(char)+1);
        strcpy(IP,(char *)inet_ntoa(client.sin_addr));
    }
        else
    {
        IP = calloc(strlen(h->h_name),sizeof(char)+1);
        strcpy(IP,h->h_name);
    }
   
	if(strcmp(campos[0], "NGM\0")==0) codigo=trata_NGM(campos[1], campos[2], connsock, ntohs(client.sin_port), IP);

   /**Escreve Resposta*/
   if(codigo != ok) responde(campos[0], &connsock, codigo);


   /**fazer isso no gere campos, o resto é jogos!**/

}


/**
 * name: decompoe_menagem
 *
 *    identifica o tipo de evento,
 * atraves da leitura do campo identificador
 *
 * @param
 *    vector de strings a preencher e descritor da socket
 *
 * @return
 *    vector de strings com campos da mensagem
 */

char **decompoe_mensagem(char **fields, int fd, int *code)
{
   int aux, left,i;
   char id[4];

   memset((void *)id,(int)'\0',sizeof(id));

   if(debug) printf("DEBUG@decompoe_mensagem: A ler campo identificador!\n");
   for(left=sizeof(char)*4,i=0;;){
      aux=read(fd,id,sizeof(char)*4);
      fflush(stdout);
      left=left-aux;
      if(left<=0) break;
      if(aux<=0)
      {
         if(debug)printf("DEBUG@decompoe_mensagem: Ligacao fechada pelo peer!\n");
         break;
      }
   }

   id[3]='\0';
   if(debug) printf("DEBUG@decompoe_mensagem: Lido \'%s\' como campo identificador!\n",id);

   /**Alocar memoria consoante identificador*/
   fields=gere_campos(id, fields, fd, code);

   return fields;

}



/**
 * name: gere_campos
 *
 * Aloca memoria consoante o evento.
 * Efectua a leitura dos restantes campos da mensagem.
 *
 * @param
 *    campo identificador, vector a preencher, descritor da socket
 *
 * @return
 *    vector de campos preenchido e com espaco para resposta.
 *
 */

char **gere_campos(char *id, char **fields, int fd, int *code)
{
   int aux, left, i, arg;
   char reader[MAX_BUFF];

   memset((void *)reader,(int)'\0',sizeof(reader));

   switch(converte_id(id))
   {
      case NGM:
         fields=(char **) calloc(3+1,sizeof(char **));
         fields[0]=(char *) calloc(strlen("NGM")+1,sizeof(char));
         strcpy(fields[0],"NGM");
         /**Quarto arg e o ID do jogador*/
         *code=NGM;
         break;

      case STR:
         fields=(char **) calloc(2+4+1,sizeof(char **));
         fields[0]=(char *) calloc(strlen("STR")+1,sizeof(char));
         strcpy(fields[0],"STR");
         /**Terceiro arg tem as posicoes iniciais*/
         /**Quarto arg e o nome do adversario*/
         *code=STR;
         break;

      default:
         /**COLOCAR MENSAGEM DE ERRO*/
         exit(EXIT_FAILURE);
      break;
   }

   /*efectua leitura*/
   memset((void *)reader,(int)'\0',sizeof(reader));

   for(left=0,i=0,arg=1;;)
   {
      aux=read(fd,reader+i,1);
      if(reader[0]=='\n') break;
      if(reader[i]=='\n')
      {
         reader[i]='\0';
         fields[arg]=(char *)calloc(strlen(reader),sizeof(char));
         strcpy(fields[arg],reader);
         memset((void *)reader,(int)'\0',sizeof(reader));
         arg++;
         i=0;
         if(debug) printf("DEBUG@gere_campos: Obtido do cliente: %s\n",reader);
      }
      else
      {
         i++;
      }

      if(aux==-1)
      {
         printf("Ligacao fechada pelo utilizador\n");
         exit(EXIT_FAILURE);
         break;
      }

      if(aux==0) break;

   }


   if(debug)
   {
      printf("DEBUG@gere_campos: Parâmetros da mensagem:\n");
      for(i=arg;i>0;i--)
      {
         printf("Campo %d - %s\n",(arg-i),fields[arg-i]);
      }
   }
   return fields;
}

/*
 * name: escreve_resposta
 * @param
 *    vector de string com dados, descritores
 * @return
 *    termina se nao tiver sucesso
 */
char* responde(char *msg, int *sock, int code)
{
   int left, sent;
   char *mensagem;

   switch(code)
   {
      case ok:

         /**1+3 = 1 para '\0' (feito pelo calloc) e 3 para '\n'*/
         mensagem = (char *) calloc(3+strlen(msg)+1+3,sizeof(char));
         /**Copia o identificador*/
         strcpy(mensagem,"NGM\0");
         strcat(mensagem,"\n");
         /**Copia o id do jogador*/
         strcat(mensagem,msg);
         strcat(mensagem,"\n\n");
         if(debug)printf("DEBUG@responde: Preparei resposta:\n%s",mensagem);
         if(debug)printf("DEBUG@responde: A libertar memoria\n");
         break;

	case ja_existe:
		 /**1+3 = 1 para '\0' (feito pelo calloc) e 3 para '\n'*/
		 mensagem = (char *) calloc(3+strlen("Nome de jogador ja existente. Por favor, escolha outro nome.")+1+3,sizeof(char));
         /**Copia o identificador*/
         strcpy(mensagem,"ERR");
         strcat(mensagem,"\n");
         /**Copia o id do jogador*/
         strcat(mensagem, "Nome de jogador ja existente. Por favor, escolha outro nome.");
         strcat(mensagem,"\n\n");
         if(debug)printf("DEBUG@responde: Preparei resposta:\n%s",mensagem);
         if(debug)printf("DEBUG@responde: A libertar memoria\n");
		 break;
		
	case arena_em_jogo:
		 /**1+3 = 1 para '\0' (feito pelo calloc) e 3 para '\n'*/
		 mensagem = (char *) calloc(3+strlen("O Desafio ja se encontra activo")+1+3,sizeof(char));
         /**Copia o identificador*/
         strcpy(mensagem,"ERR");
         strcat(mensagem,"\n");
         /**Copia o id do jogador*/
         strcat(mensagem, "O Desafio ja se encontra activo");
         strcat(mensagem,"\n\n");
         if(debug)printf("DEBUG@responde: Preparei resposta:\n%s",mensagem);
         if(debug)printf("DEBUG@responde: A libertar memoria\n");
		 break;

      default:
         printf("Desconheco mensagem!\n");
         exit(EXIT_FAILURE);
   }

   left=strlen(mensagem);

   while(left>0)
   {
      sent=write(*sock,mensagem,strlen(mensagem));
      left=left-sent;
      if(sent==-1){
         printf("Ligacao pelo utilizador!\n");
         exit(EXIT_FAILURE);
      }
      else if(sent==0) break;
      mensagem=mensagem+sent;
   }
   if(debug)printf("DEBUG@responde: FIX ME!\n");
/*
   free(mensagem);
*/
   return msg;

}


