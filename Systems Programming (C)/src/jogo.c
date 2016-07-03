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
#include "jogo.h"

_Bool debug;

static _Bool mov_timer;
static _Bool bala_timer;
static _Bool saida;
static _Bool last;
static _Bool first;
static _Bool eog;
static _Bool pontuar;

static pthread_mutex_t pedido, jogadores, p1, p2, ng_p1, ng_p2, fim;
static pthread_mutex_t jogadores, jump, mov_inicio, bala_inicio, altera_bala;

static pthread_t jogador_esquerda, jogador_direita;
static pthread_t movimento, bala, sinais;

/**APUE 414*/
static sigset_t mask;

static BulletData *bullets[2];
static profile player[2];
static details game;


/***RELOAD E FEITO POR MIM**/


int main(int argc, char **argv)
{
   mov_timer=FALSE;
   bala_timer=FALSE;
   saida=FALSE;
   last=FALSE;
   first=FALSE;
   pontuar=FALSE;

   guarda_argumentos(argv);

   inicia_mutex();

   inicia_partida();

   efectua_limpeza();

   return 0;
}


void guarda_argumentos(char **argv)
{
   int i;

   fflush(stdout);

   /**Salvaguarda nome do jogo*/
   game.name=(char *)calloc(strlen(argv[JOGO])+1,sizeof(char));
   strcpy(game.name,argv[JOGO]);

   /**Salvaguarda nome do jogador*/
   player[LEFT].name=(char *)calloc(strlen(argv[P1])+1,sizeof(char));
   strcpy(player[LEFT].name,argv[P1]);

   /**Salvaguarda nome do jogador*/
   player[RIGHT].name=(char *)calloc(strlen(argv[P2])+1,sizeof(char));
   strcpy(player[RIGHT].name,argv[P2]);

   /**Salvaguarda descritores para servidor e hof*/
   game.pthof=atoi(argv[FD_HOF]);

   /**Salvaguarda descritores para jogadores*/
   player[LEFT].sfd=atoi(argv[FD_P1]);
   player[RIGHT].sfd=atoi(argv[FD_P2]);

   /**Salvaguarda informação de debug*/
   debug=(_Bool)atoi(argv[DEBUG]);

   if(debug) printf("\n\n\nJ:INICIEI JOGO COM ARGUMENTOS:\nJOGO: %s (%d)\nP1: %s (%d)\nP2: %s (%d)\n\n\n\n", argv[JOGO], strlen(argv[JOGO]), argv[P1], strlen(argv[P1]), argv[P2], strlen(argv[P2]));


   if(debug) printf("\nJ:DEBUG@guarda_argumentos:\nJOGO %s %s (P1) Vs %s (P2)\n\n\n\n\n\n", game.name, player[LEFT].name, player[RIGHT].name);

   game.ptr_p1=argv[PTR_P1];
   game.ptr_p2=argv[PTR_P2];

   game.mintcwait=atoi(argv[MINTCWAIT]);
   game.mintbwait=atoi(argv[MINTBWAIT]);
   game.mintshoot=atoi(argv[MINTSHOOT]);
   game.maxnfired=atoi(argv[MAXNFIRED]);

   player[LEFT].games=0;
   player[RIGHT].games=0;
   player[LEFT].bulletsleft=game.maxnfired;
   player[RIGHT].bulletsleft=game.maxnfired;

   /**Valor por omissao e FALSE mas apenas se garante o bom funcionamento**/
   player[RIGHT].mov_up=FALSE;
   player[RIGHT].mov_down=FALSE;

   player[LEFT].mov_up=FALSE;
   player[LEFT].mov_down=FALSE;

   bullets[0]=(BulletData *)calloc(game.maxnfired,sizeof(BulletData));
   bullets[1]=(BulletData *)calloc(game.maxnfired,sizeof(BulletData));

   for( i = 0; i < game.maxnfired; i++)
   {
      bullets[0][i].empty=TRUE;
      bullets[1][i].empty=TRUE;
   }

   if(debug) printf("J:DEBUG@guarda_argumentos: A comecar %s: %s Vs %s\n", game.name, player[LEFT].name, player[RIGHT].name);
}


void inicia_mutex(void)
{
   pthread_mutex_init(&pedido,NULL);
   pthread_mutex_init(&p1,NULL);
   pthread_mutex_init(&p2,NULL);
   pthread_mutex_init(&jogadores,NULL);
   pthread_mutex_init(&jump,NULL);
   pthread_mutex_init(&mov_inicio,NULL);
   pthread_mutex_init(&bala_inicio,NULL);
   pthread_mutex_init(&fim,NULL);
   pthread_mutex_init(&ng_p1,NULL);
   pthread_mutex_init(&ng_p2,NULL);
   pthread_mutex_init(&altera_bala,NULL);
}


void *th_sinais(void *args)
{
   char mensagem[MAX_BUFF];
   char pontuacao[SMALL_BUFF];
   int obtido;

   lock(&bala_inicio);
   lock(&mov_inicio);

   if(debug) printf("THREAD SINAIS AO SERVICO!\n");

   for(;;)
   {
      if(debug) printf("THREAD SINAIS A ESCUTAR!\n");
      if(sigwait(&mask, &obtido)!=0)
      {
         printf("ERRO: Erro a escutar sinais!\n");
         exit(EXIT_FAILURE);
      }

      switch(obtido)
      {
         case SIGUSR1:
            if(!mov_timer)
            {
               printf("J:DEBUG@TH_SINAIS: ESCUTADO SIGUSR1\n");
               lock(&jump);
               mov_timer=TRUE;
               printf("J:DEBUG@TH_SINAIS: A soltar th_movimento\n");
               unlock(&mov_inicio);
               unlock(&jump);
            }else
               lock(&mov_inicio);
            break;

         case SIGUSR2:
            if(!bala_timer)
            {
               if(debug)printf("J:DEBUG@th_sinais: Escutado SIGUSR2\n");
               lock(&pedido);
               bala_timer=TRUE;
               unlock(&bala_inicio);
               unlock(&pedido);
            }else
               lock(&bala_inicio);
            break;

         case SIGSTOP:
         case SIGPIPE:
         case SIGINT:
            if(debug)printf("J:DEBUG@th_sinais: Escutado SIGINT\n");
            /**Pontua o P1*/
            memset((void*)mensagem,(int)'\0',sizeof(mensagem));
            memset((void*)pontuacao,(int)'\0',sizeof(pontuacao));

            sprintf(mensagem,"ADD\n");
            strcat(mensagem,game.ptr_p1);
            strcat(mensagem,"\n");

            /**Averiguar Vencedor*/
            obtido=MAX(player[RIGHT].games,player[LEFT].games);

            if(obtido==player[LEFT].games)
               strcat(mensagem,"1\n");
            else
               strcat(mensagem,"0\n");

            sprintf(pontuacao,"%d",player[LEFT].games);
            strcat(mensagem, pontuacao);
            strcat(mensagem,"\n\n");

            if(debug)printf("A registar no hof P1 com:\n%s",mensagem);
            resposta_directa(&game.pthof,mensagem);

            /**Pontua o P2*/
            memset((void*)mensagem,(int)'\0',sizeof(mensagem));
            memset((void*)pontuacao,(int)'\0',sizeof(pontuacao));

            sprintf(mensagem,"ADD\n");
            strcat(mensagem,game.ptr_p2);
            strcat(mensagem,"\n");
            /**Averiguar Vencedor*/
            obtido=MAX(player[RIGHT].games,player[LEFT].games);

            if(obtido==player[RIGHT].games)
               strcat(mensagem,"1\n");
            else
               strcat(mensagem,"0\n");

            sprintf(pontuacao,"%d",player[RIGHT].games);
            strcat(mensagem, pontuacao);
            strcat(mensagem,"\n\n");

            if(debug)printf("A registar no hof P2 com:\n%s",mensagem);
            resposta_directa(&game.pthof,mensagem);

            pthread_exit(0);

            break;

         default:
            if(debug) printf("Ignorado sinal %d\n",obtido);
            pthread_exit(0);
            break;
      }
   }

}



void inicia_partida(void)
{
   _Bool side1;
   _Bool side2;



   /**CRIAR THREAD QUE TRATA DE FIM ABRUPTO e reporta a hof e servidor!*/
   sigemptyset(&mask);
   sigaddset(&mask, SIGUSR1);
   sigaddset(&mask, SIGUSR2);
   sigaddset(&mask, SIGPIPE);
   sigaddset(&mask, SIGINT);

   if(pthread_sigmask(SIG_BLOCK, &mask,NULL)!=0)
   {
      printf("ERRO: Erro a bloquear sinais!\n");
      exit(EXIT_FAILURE);
   }

   if(pthread_create(&sinais, NULL, th_sinais, NULL)!=0)
   {
      printf("ERRO: Thread sinais nao foi lancada com sucesso!\n");
      exit(EXIT_FAILURE);
   }


   side1=LEFT;
   if(pthread_create(&jogador_esquerda, NULL, th_init, (void *)&side1)!=0)
   {
      printf("ERRO: Falha a lancar thread para P1!\n");
      exit(EXIT_FAILURE);
   }

   side2=RIGHT;
   if(pthread_create(&jogador_direita, NULL, th_init, (void *)&side2)!=0)
   {
      printf("ERRO: Falha a lancar thread para P1!\n");
      exit(EXIT_FAILURE);
   }


   /***Thread continua e tratar de fazer sincronizacao*/

   /**Dorme 1 a 2 segundos e prepara mensagem*/

   /** Tem que bloquear tudo e todos        **
    ** Tem que se ter cuidado com mensagens **
    ** que estao para enviar -- (descartar) **/

   /**Coloca posicoes de jogadores*/

   /**Varre balas - Envia apenas as que estao em jogo*/
      /* Uso de um identificador, pe, 1:x:y, 1:x:y *
       * Significando bala de p1 na pos (x,y)      */

   /**Se saida, sai e espera termino das threads*/

   /**thread principal gere sync?*/
   /*pthread_join(jogador_esquerda,NULL);
   pthread_join(jogador_direita,NULL);*/
   pthread_join(sinais,NULL);

}



/**VOu ler de ambos*/
void *th_init(void *arg)
{
   _Bool side = *(_Bool *)arg;

   if(side==LEFT)
      lock(&p1);
   else
      lock(&p2);

   regista_inicio(side, TRUE);

   if(side==first)
   {
      /**Thread responsavel pelos movimentos*/
      pthread_create(&movimento, NULL, th_movimento, NULL);
      if(debug) printf("J:DEBUG@inicia_partida: Thread movimento criada\n");

      pthread_create(&bala, NULL, th_bala, NULL);
      if(debug) printf("J:DEBUG@inicia_partida: Thread movimento criada\n");

   }

   trata_jogador(side);

   pthread_exit(0);
}




/*
 * Regista e informa os jogadores
 * sobre o seu estado inicial
 *
 *
 * name: regista_inicio
 * @param
 *    lado
 * @return
 *    sem retorno
 */

void regista_inicio(int side, int start)
{

   int codigo;
   char **campos=(char **)NULL;
   char lx[SMALL_BUFF],ly[SMALL_BUFF],
        rx[SMALL_BUFF], ry[SMALL_BUFF],
        gml[SMALL_BUFF], gmr[SMALL_BUFF],
        msg[GIG_BUFF], nbalas[SMALL_BUFF];
   char temp1[SMALL_BUFF], temp2[SMALL_BUFF],
        temp3[SMALL_BUFF];

   if(debug) printf("REGISTA_INICIOS@Sou thread do jogador P%d\nVOU ESPERAR COMUNICACAO DO CLIENTE",side+1);

   /**Recebe mensagem STR com os campos: */
   if(start)
      campos=efectua_leitura(campos, player[side].sfd, &codigo);


   /**O primeiro a obter ligacao cria a mensagem de inicio*/

   if(debug) printf("REGISTA_INICIO@Sou thread do jogador P%d vou OBTER JOGADORES\n",side+1);
   lock(&jogadores);
   if(debug) printf("REGISTA_INICIO@Sou thread do jogador P%d vou OBTIVE JOGADORES\n",side+1);

   memset((void*)lx,(int)'\0',sizeof(lx));
   memset((void*)ly,(int)'\0',sizeof(ly));
   memset((void*)rx,(int)'\0',sizeof(rx));
   memset((void*)ry,(int)'\0',sizeof(ry));
   memset((void*)gml,(int)'\0',sizeof(gml));
   memset((void*)gmr,(int)'\0',sizeof(gmr));
   memset((void*)msg,(int)'\0',sizeof(msg));
   memset((void*)nbalas,(int)'\0',sizeof(nbalas));
   memset((void*)temp1,(int)'\0',sizeof(temp1));
   memset((void*)temp2,(int)'\0',sizeof(temp2));
   memset((void*)temp3,(int)'\0',sizeof(temp3));


   if(!last)
   {
      if(debug) printf("DEFINI OS PONTOS DE INICIO: P%d\n",side+1);
      last=TRUE;
      first=side;

      srand (time(NULL));

      /**Guarda a informacao da posicao inicial para cada jogador.*/

      player[LEFT].x = 0;
      player[LEFT].y = TOPOFFSET + rand() % (NROWS - (TOPOFFSET + COWBOY_HEIGHT -1));

      player[RIGHT].x = NCOLS - COWBOY_WIDTH;
      player[RIGHT].y = TOPOFFSET + rand() % (NROWS - (TOPOFFSET + COWBOY_HEIGHT - 1));

      game.nr_jogos++;
   }


   /**Prepara mensagem de inicio*/
   sprintf(lx,"%d",player[LEFT].x);
   sprintf(ly,"%d",player[LEFT].y);
   sprintf(rx,"%d",player[RIGHT].x);
   sprintf(ry,"%d",player[RIGHT].y);
   sprintf(gml,"%d",player[LEFT].games);
   sprintf(gmr,"%d",player[RIGHT].games);
   sprintf(nbalas,"%d",game.maxnfired);
   sprintf(temp1,"%d",game.mintcwait);
   sprintf(temp2,"%d",game.mintbwait);
   sprintf(temp3,"%d",game.mintshoot);

   /**Cria mensagem de inicio de jogo**/
   strcpy(msg,"STR");
   strcat(msg,"\n");
   strcat(msg,lx);
   strcat(msg,"\n");
   strcat(msg,ly);
   strcat(msg,"\n");
   strcat(msg,rx);
   strcat(msg,"\n");
   strcat(msg,ry);
   strcat(msg,"\n");
   strcat(msg,gml);
   strcat(msg,"\n");
   strcat(msg,gmr);
   strcat(msg,"\n");
   strcat(msg,nbalas);
   strcat(msg,"\n");
   strcat(msg,temp1);
   strcat(msg,"\n");
   strcat(msg,temp2);
   strcat(msg,"\n");
   strcat(msg,temp3);
   strcat(msg,"\n");

   /**Coloco o nome do adversario**/
   if(side==LEFT)
   {
      if(strlen(player[RIGHT].name)>=NAMELEN)
      {
         printf("ERRO: Nome muito extenso\n");
         exit(EXIT_FAILURE);
      }
      if(debug) printf("P%d:NOME DO JOGADOR DA DIREITA: %s\n",side+1,player[RIGHT].name);
      strcat(msg,player[RIGHT].name);
   }
   else
   {
      if(strlen(player[LEFT].name)>=NAMELEN)
      {
         printf("ERRO: Nome muito extenso\n");
         exit(EXIT_FAILURE);
      }
      if(debug) printf("P%d:NOME DO JOGADOR DA ESQUERDA: %s\n",side+1,player[LEFT].name);
      strcat(msg,player[LEFT].name);
   }

   strcat(msg,"\n\n");

   /**Terminei a mensagem*/
   player[side].init = (char*)calloc(strlen(msg)+1, sizeof(char));

   strcpy(player[side].init, msg);


   unlock(&jogadores);

   if(debug) printf("REGISTA_INICIO@Sou thread do jogador P%d vou SAI DE JOGADORES\n",side+1);


   if(side==LEFT)
   {
      if(debug) printf("REGISTA_INICIO@Sou thread do jogador P%d vou LIBERTAR P1\n",side+1);
      /**Removo o lock ao atrasado*/
      unlock(&p1);
      /**Espero pelo lock do segundo*/
      if(debug) printf("REGISTA_INICIO@Sou thread do jogador P%d vou OBTER P2\n",side+1);
      lock(&p2);
   }
   else
   {
      if(debug) printf("REGISTA_INICIO@Sou thread do jogador P%d vou LIBERTAR P2\n",side+1);
      fflush(stdout);
      unlock(&p2);
      if(debug) printf("REGISTA_INICIO@Sou thread do jogador P%d vou OBTER P1\n",side+1);
      /**Vou permanecer com a chave do p1*/
      lock(&p1);
   }

   if(debug) printf("J:DEBUG@REGISTA_INICIO: Vector de inicialização para P%d:\n%s\n", side+1, player[side].init);

   resposta_directa(&player[side].sfd,player[side].init);

}


/*
 * Recebe e envia respostas a ambos os clientes
 *
 * name: trata_jogador
 * @param
 *    lado
 * @return
 *    sem retorno
 */

void trata_jogador(int side)
{
   int codigo;
   char **campos=(char**)NULL;

   if(debug)
   {
      if(side==LEFT)
         printf("J:DEBUG@TRATA_JOGADOR: A tratar jogador da esquerda P%d\n",side+1);
      else
         printf("J:DEBUG@TRATA_JOGADOR: A tratar jogador da direita P%d\n",side +1);

      printf("Vou escrever para o descritor: %d\n", player[side].sfd);
   }


   /**Espera por comunicacoes*/
   for(;;)
   {
      campos=efectua_leitura(campos, player[side].sfd, &codigo);

      /**Verifica exclusividade da socket do descritor*/

      responde(campos, &player[side].sfd, codigo, side);

   }

}


char **efectua_leitura(char **fields, int fd, int *code)
{
   int aux, left,i;
   char id[4];

   memset((void *)id,(int)'\0',sizeof(id));

   if(debug) printf("J:DEBUG@decompoe_mensagem: A ler campo identificador!\n");
   for(left=sizeof(char)*4,i=0;;){
      aux=read(fd,id,sizeof(char)*4);
      fflush(stdout);
      left=left-aux;
      if(left<=0) break;
      if(aux==-1)
      {
         if(debug)printf("J:DEBUG@decompoe_mensagem: Ligacao fechada pelo peer!\n");
         break;
      }
      else if(aux==0) break;
   }

   id[3]='\0';
   if(debug) printf("J:DEBUG@decompoe_mensagem: Lido \'%s\' como campo identificador!\n",id);

   /**Alocar memoria consoante identificador*/
   fields=gere_campos(id, fields, fd, code);

   return fields;

}





/**
 * name: gere_campos
 *
 * Aloca memoria consoante o evento.
 * Prepara a leitura de um evento
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
      case STR:
         fields=(char **) calloc(2,sizeof(char **));
         fields[0]=(char *) calloc(strlen("STR")+1,sizeof(char));
         strcpy(fields[0],"STR");
         *code=STR;
         break;

      case NSH:
         fields=(char **) calloc(2+1,sizeof(char **));
         fields[0]=(char *) calloc(strlen("NSH")+1,sizeof(char));
         strcpy(fields[0],"NSH");
         fields[2]=(char *) calloc(strlen("6")+1,sizeof(char));
         /**Terceiro arg e o numero de balas*/
         *code=NSH;
         break;

      case MOV:
         fields=(char **) calloc(3,sizeof(char **));
         fields[0]=(char *) calloc(strlen("MOV")+1,sizeof(char));
         strcpy(fields[0],"MOV");
         /**E so fazer FWD*/
         *code=MOV;
         break;

      case EOG:
         fields=(char **) calloc(2,sizeof(char **));
         fields[0]=(char *) calloc(strlen("EOG")+1,sizeof(char));
         strcpy(fields[0],"EOG");
         /**Terceiro arg e a pontuacao final*/
         *code=EOG;
         break;

      case CNT:
         fields=(char **) calloc(2+1,sizeof(char **));
         fields[0]=(char *) calloc(strlen("CNT")+1,sizeof(char));
         strcpy(fields[0],"CNT");
         /**Terceiro arg e o ID de NGM*/
         *code=CNT;
         break;

      case EXT:
         fields=(char **) calloc(2+2,sizeof(char **));
         fields[0]=(char *) calloc(strlen("NGM")+1,sizeof(char));
         strcpy(fields[0],"EXT");
         /**Terceiro arg e a pontuacao final*/
         *code=EXT;
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
      }
      else
      {
         i++;
      }

      if(aux==-1)
      {
         printf("Ligacao fechada pelo utilizador\n");
         exit(EXIT_FAILURE);
      }

      if(aux==0) break;
   }

   /**NO CASO DE MOVIMENTO TER ATENCAO FLAG CIMA E BAIXO**/


   if(debug)
   {
      printf("J:DEBUG@gere_campos: Parâmetros da mensagem:\n");
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
int responde(char **msg, int *sock, int code, int side)
{
   int i;
   char *mensagem;
   char won[SMALL_BUFF],lost[SMALL_BUFF];

   switch(code)
   {

      case STR:

         if(debug) printf("A libertar memoria do jogador\n");
         free(player[side].init);
         if(debug) printf("A iniciar novo jogo\n");

         last=FALSE;
         first=FALSE;
         eog=FALSE;

         if(debug) printf("Pontuacao actual:\nP1: %d\nP2: %d",player[LEFT].games, player[RIGHT].games);

         player[side].bulletsleft=game.maxnfired;
         player[side].mov_up=FALSE;
         player[side].mov_down=FALSE;
         player[side].morto=FALSE;

         for( i = 0; i < game.maxnfired; i++)
         {
            bullets[side][i].empty=TRUE;
         }

         if(side==LEFT)
         {
            /**Devolvo a chave ao adversario*/
            if(debug) printf("Sou thread do jogador P%d vou LIBERTAR P2\n",side+1);
            lock(&ng_p2);
            unlock(&p2);
            /**Espero pela minha*/
            if(debug) printf("Sou thread do jogador P%d vou OBTER P1\n",side+1);
            lock(&p1);
            unlock(&ng_p2);
            lock(&ng_p1);
            unlock(&ng_p1);
            if(debug) printf("Sou thread do jogador P%d ja detenho a minha chave!\n",side+1);
         }
         else
         {
            lock(&ng_p1);
            if(debug) printf("Sou thread do jogador P%d vou LIBERTAR P1\n",side+1);
            unlock(&p1);
            if(debug) printf("Sou thread do jogador P%d vou OBTER P2\n",side+1);
            lock(&p2);
            if(debug) printf("Sou thread do jogador P%d ja detenho a minha chave!\n",side+1);
            unlock(&ng_p1);
            lock(&ng_p2);
            unlock(&ng_p2);
         }

         regista_inicio(side, FALSE);

      break;

      case MOV:
         lock(&jump);
         if(!mov_timer)
         {
            if(debug) printf("DEBUG@Responde: SOLTEM A THREAD MOVIMENTO!\n");
            pthread_kill(sinais,SIGUSR1);
         }

         /**Significa que vou alterar a minha posicao*/
         lock(&pedido);
         if(strcmp(msg[2],"UP")==0)
         {
               if(side==LEFT)
                  regista_movimento(side, &player[LEFT].mov_up, &player[LEFT].mov_down, UP_SELF);
               else
                  regista_movimento(side, &player[RIGHT].mov_up, &player[RIGHT].mov_down, UP_SELF);
         }
         else if(strcmp(msg[2],"DW")==0)
         {
               if(side==LEFT)
                  regista_movimento(side, &player[LEFT].mov_down, &player[LEFT].mov_up, DOWN_SELF);
               else
                  regista_movimento(side, &player[RIGHT].mov_down, &player[RIGHT].mov_up, DOWN_SELF);
         }
         else
         {
            printf("ERRO: Mensagem de movimento mal formada!\n");
            if(debug) printf("J:DEBUG@responde: Valor do campo '%s'\n",msg[2]);
            unlock(&jump);
            unlock(&pedido);
            exit(EXIT_FAILURE);
         }

         if(debug)
         {
            printf("J:DEBUG@responde: A processar pedido de movimento de %s e sou P%d\n",msg[1],side+1);
            printf("Movimentos:\n   | U | D |\n");
            printf("L: | %d | %d |\n", player[LEFT].mov_up, player[LEFT].mov_down);
            printf("R: | %d | %d |\n", player[RIGHT].mov_up, player[RIGHT].mov_down);
            printf("J:DEBUG@responde: Recebi pedido de %s e sou P%d\n",msg[1],side+1);
         }


         if(debug)printf("J:DEBUG@responde: A libertar memoria\n");

         for(i=2;i>=0;i--)
         {
            free(msg[i]);
         }

         unlock(&jump);
         unlock(&pedido);

         return MOV;

      break;

      case NSH:

         if(debug)printf("J:DEBUG@responde: (NSH) a tratar novo tiro\n");

         if (!player[LEFT].bulletsleft && !player[RIGHT].bulletsleft)
         {
            if(debug) printf("RELOAD!\n");
            player[LEFT].bulletsleft = game.maxnfired;
            player[RIGHT].bulletsleft = game.maxnfired;
         }

         lock(&jump);
         /**Verifica qual a bala a disparar**/
         for ( i = 0; i < game.maxnfired; i++ )
         {
            if ( bullets[side][i].empty )
            {
               break;
            }
         }


         if ( i < game.maxnfired )
         {
            bullets[side][i].empty = FALSE;
            bullets[side][i].y = player[side].y + 2;

            if ( side == LEFT )
            {
               bullets[side][i].x = player[side].x+4;
            }
            else
            {
               bullets[side][i].x = player[side].x-1;
               /**move bala*/
            }

         } else
         {
            unlock(&jump);
            return NSH;
         }


         memset((void *)won,(int)'\0',sizeof(won));
         sprintf(won,"%d",player[side].y);

         unlock(&jump);

         if(debug)printf("J:DEBUG@responde: Jogador P%d tem %d balas disponiveis\n",side+1,player[side].bulletsleft);

         player[side].bulletsleft--;

         mensagem = (char *) calloc(strlen(msg[0])+strlen(msg[1])+3+1,sizeof(char));
         strcpy(mensagem,msg[0]);
         strcat(mensagem,"\n");
         strcat(mensagem,msg[1]);
         strcat(mensagem,"\n");

         /**Garante que nao ha mexidelas na altura*/
         if(debug)printf("J:DEBUG@responde: (NSH) A obter jump\n");

         strcat(mensagem,won);
         strcat(mensagem,"\n\n");

         /***RESPOSTA DIRECTA**/
         lock(&pedido);
         if(side==LEFT){
            resposta_directa(&player[RIGHT].sfd, mensagem);
            resposta_directa(&player[LEFT].sfd, mensagem);
         }
         else
         {
            resposta_directa(&player[LEFT].sfd, mensagem);
            resposta_directa(&player[RIGHT].sfd, mensagem);
         }
         unlock(&pedido);
         if(debug)printf("J:DEBUG@responde: (NSH) Enviado para P%d:\n%s",(side+1)%2,mensagem);

         /**COLOCAR NUMERO DE BALAS*/
         if(!bala_timer)
         {
            if(debug) printf("J:DEBUG@responde: (NSH) temporizador de balas activado\n");
            pthread_kill(sinais,SIGUSR2);
         }

         for(i=2;i>=0;i--)
         {
            free(msg[i]);
         }

         free(mensagem);

         return NSH;

      break;

      case EXT:
         saida=TRUE;

         memset((void *)won,(int)'\0',sizeof(won));
         memset((void *)lost,(int)'\0',sizeof(lost));

         sprintf(won,"%d",MAX(player[LEFT].games, player[RIGHT].games));
         sprintf(lost,"%d",MIN(player[LEFT].games, player[RIGHT].games));


         if(debug)printf("J:DEBUG@responde: a tratar saida\n");
         mensagem = (char *) calloc(strlen(msg[0])+strlen(msg[1])+strlen(won)+strlen(lost)+5+1,sizeof(char));
         strcpy(mensagem,msg[0]);
         strcat(mensagem,"\n");

         if(player[LEFT].games==MAX(player[LEFT].games, player[RIGHT].games))
            strcat(mensagem,"P1");
         else
            strcat(mensagem,"P2");

         strcat(mensagem,"\n");
         strcat(mensagem,won);
         strcat(mensagem,"\n");
         strcat(mensagem,lost);
         strcat(mensagem,"\n\n");
         lock(&pedido);
         resposta_directa(&player[RIGHT].sfd, mensagem);
         resposta_directa(&player[LEFT].sfd, mensagem);
         unlock(&pedido);
         free(mensagem);

         lock(&fim);
         if(!pontuar)
         {
            pontuar=TRUE;
            pthread_kill(sinais,SIGPIPE);
         }
         unlock(&fim);

         pthread_exit(0);
         return EXT;

      break;


      default:

         printf("Desconheco mensagem!\n");

         exit(EXIT_FAILURE);

      break;
   }
   return 0;

}


int resposta_directa(int *sock, char *buffer)
{
   int left, aux;
   char reader[MAX_FIELD];

   memset((void *)reader,(int)'\0',sizeof(reader));

   /**Enquanto existirem bytes para escrever**/
   left=strlen(buffer);
   while(left>0){
      aux=write(*sock,buffer,left);
      left = left-aux;

      if(aux==-1){
         printf("Perdida ligacao com cliente!\n");
         exit(EXIT_SUCCESS);
      }else
         if(aux==0) break;

      /**Avanca o ponteiro**/
      buffer=buffer+aux;
   }

   /**FIX ME*/

   return 0;
}


/*
 * Thread responsável pelos movimentos dos jogadores.
 * Dorme o tempo especificado e informa os utilizadores.
 *
 * name: th_movimento
 * @param
 *    sem parametros
 * @return
 *    retorna sucesso
 */

void *th_movimento(void *arg)
{
   struct timespec dorme;

   char p1_msg[MAX_FIELD];
   char p2_msg[MAX_FIELD];
   int comprimento;
   int side;

   if(debug) printf("THREAD MOVIMENTO APRESENTA-SE AO SERVIÇO!\n");

   side=rand()%2;

   dorme.tv_sec=0;
   dorme.tv_nsec=game.mintcwait*1000000;

   /**Prepara mensagens*/
   memset((void*)p1_msg,(int)'\0',sizeof(p1_msg));
   memset((void*)p2_msg,(int)'\0',sizeof(p2_msg));

   strcpy(p1_msg,"MOV\nP1\n");
   strcpy(p2_msg,"MOV\nP2\n");

   comprimento=strlen(p1_msg);

   if(debug) printf("DEBUG@TH_MOVIMENTO: A bloquear em mov_inicio\n");

   while(!mov_timer)
   {
      lock(&mov_inicio);
   }

   unlock(&mov_inicio);

   lock(&jump);
   lock(&pedido);

   if(debug) printf("DEBUG@TH_MOVIMENTO: A Enviar movimento...\n");

   /**Resposta directa a ambos*/
   responde_movimento(p1_msg,p2_msg,comprimento,side);

   unlock(&jump);
   unlock(&pedido);


   pthread_kill(sinais,SIGUSR1);
   /**Dorme tempo especificado*/
   for(side=rand()%2; ;side=(side+1)%2)
   {
      /**Dorme*/
      if(debug) printf("DEBUG@TH_MOVIMENTO: A dormir...\n");
      nanosleep(&dorme, NULL);

      /**Se for fim de jogo*/
      if(eog)
      {
         lock(&mov_inicio);
      }

      /**No caso de uma saida*/
      if(saida) break;
      /**Garante que nao ha alteracoes de posicoes*/
      lock(&jump);
      lock(&pedido);

      if(debug) printf("DEBUG@TH_MOVIMENTO: A Enviar movimento...\n");
      /**A resposta e sempre feita para o adversario, contudo o tratamento do jogador e alternado*/

      responde_movimento(p1_msg, p2_msg, comprimento, side);

      unlock(&jump);
      unlock(&pedido);

   }

   pthread_exit(0);

}




/*
 *Tem como objectivo actualizar as flags de controlo dos jogadores
 *
 * name: regista_movimento
 * @param
 *    lado do jogador, apontadores para flags de controlo e  identificador do movimento
 * @return
 */

void regista_movimento(int side, _Bool *mov_pro, _Bool *mov_contra, int id)
{
   switch(id)
   {
      case UP_SELF:
         /**Se o próprio estiver a mover-se para cima, ignora*/
         if ( player[side].y > TOPOFFSET && !*mov_pro)
         {
            /**Ja se encontra a mover para baixo*/
            if(!*mov_contra)
               *mov_pro=TRUE;
            else
               *mov_contra=FALSE;
         }
      break;


      case DOWN_SELF:

         /**Se já estiver a mover-se para baixo, ignora*/
         if ( player[side].y < (NROWS - COWBOY_HEIGHT) && !*mov_pro)
         {
            /**Ja se encontra a mover para cima*/
            if(!*mov_contra)
               *mov_pro=TRUE;
            else
               *mov_contra=FALSE;
         }

      break;

   }
}


/*
 * Verifica se e necessario enviar notificacao de movimento ao jogador
 *
 * name: responde_movimento
 * @param
 *    mensagens genericas e posicoes dos jogadores
 * @return
 *
 */

int responde_movimento(char *p1_msg, char *p2_msg, int geral, int side)
{
   int lp1, lp2, count;

   char p1_pos[SMALL_BUFF];
   char p2_pos[SMALL_BUFF];

   for(count=0; count<=1; count++,side=(side+1)%2)
   {
      memset((void*)p1_pos,(int)'\0',sizeof(p1_pos));
      memset((void*)p2_pos,(int)'\0',sizeof(p2_pos));

      if(debug)printf("J:DEBUG@RESPONDE_MOVIMENTO: A tratar P%d em %d lugar\n",side+1,count);

      if(player[side].mov_up || player[side].mov_down)
      {
         if(player[side].mov_up)
         {

            if (player[side].y > TOPOFFSET )
            {
               player[side].y--;

               if(side==LEFT)
               {
                  /**ENVIA MENSAGEM COM IDENTIFICADOR DE P1**/
                  sprintf(p1_pos,"%d",player[LEFT].y);
                  strcat(p1_msg, p1_pos);
                  strcat(p1_msg, "\n\n");

                  if(debug)printf("RENOVA POSICAO: A enviar:\n%s",p1_msg);
                  resposta_directa(&player[RIGHT].sfd,p1_msg);
                  resposta_directa(&player[LEFT].sfd,p1_msg);

                  lp1=strlen(p1_msg);

                  memset((void*)&p1_msg[geral],(int)'\0',sizeof(lp1-geral));
               }
               else
               {
                  /**ENVIA MENSAGEM COM IDENTIFICADOR DE P2**/
                  sprintf(p2_pos,"%d",player[RIGHT].y);

                  strcat(p2_msg, p2_pos);
                  strcat(p2_msg, "\n\n");

                  resposta_directa(&player[LEFT].sfd,p2_msg);
                  resposta_directa(&player[RIGHT].sfd,p2_msg);

                  if(debug)printf("RENOVA POSICAO: A enviar:\n%s",p2_msg);
                  lp2=strlen(p2_msg);

                  if(debug)printf("TAMANHO %d\nA APAGAR EM %d\nNr:%d\n",lp2,geral-1,lp2-geral);

                  memset((void*)&p2_msg[geral],(int)'\0',sizeof(lp2-geral));
               }

            }
            else
            {
               player[side].mov_up=FALSE;
               continue;
            }

         }else
         {
            if(player[side].y < (NROWS - COWBOY_HEIGHT) )
            {
               player[side].y++;

               if(side==LEFT)
               {
                  /**ENVIA MENSAGEM COM IDENTIFICADOR DE P1**/
                  sprintf(p1_pos,"%d",player[LEFT].y);
                  strcat(p1_msg, p1_pos);
                  strcat(p1_msg, "\n\n");

                  if(debug)printf("RENOVA POSICAO: A enviar:\n%s",p1_msg);
                  resposta_directa(&player[RIGHT].sfd,p1_msg);
                  resposta_directa(&player[LEFT].sfd,p1_msg);

                  lp1=strlen(p1_msg);

                  memset((void*)&p1_msg[geral],(int)'\0',sizeof(lp1-geral));
               }
               else
               {
                  /**ENVIA MENSAGEM COM IDENTIFICADOR DE P2**/
                  sprintf(p2_pos,"%d",player[RIGHT].y);

                  strcat(p2_msg, p2_pos);
                  strcat(p2_msg, "\n\n");

                  resposta_directa(&player[LEFT].sfd,p2_msg);
                  resposta_directa(&player[RIGHT].sfd,p2_msg);

                  if(debug)printf("RENOVA POSICAO: A enviar:\n%s",p2_msg);
                  lp2=strlen(p2_msg);

                  if(debug)printf("TAMANHO %d\nA APAGAR EM %d\nNr:%d\n",lp2,geral-1,lp2-geral);

                  memset((void*)&p2_msg[geral],(int)'\0',sizeof(lp2-geral));
               }
            }
            else
            {
               player[side].mov_down=FALSE;
               continue;
            }
         }
      }
   }

   return FALSE;
}



void *th_bala(void *arg)
{
   struct timespec dorme;
   char mensagem[10];
   int side, voo;
   char caixao[MAX_FIELD];
   char reload[MAX_FIELD];
   char count[SMALL_BUFF];

   dorme.tv_sec=0;
   dorme.tv_nsec=game.mintbwait*1000000;
   if(debug)printf("MINTBWAIT: %d",game.mintbwait);

   memset((void*)mensagem,(int)'\0',sizeof(mensagem));
   memset((void*)caixao,(int)'\0',sizeof(caixao));
   memset((void*)count,(int)'\0',sizeof(count));
   memset((void*)reload,(int)'\0',sizeof(reload));

   strcpy(mensagem,"BLT\n\n");
   strcpy(reload,"REL\n\n");

   if(debug) printf("THREAD BALA APRESENTA-SE AO SERVIÇO!\n");

   while(!bala_timer)
   {
      lock(&bala_inicio);
   }

   unlock(&bala_inicio);

   /**Notifica sinais para obter lock*/
   pthread_kill(sinais,SIGUSR2);

   /**Dorme tempo especificado*/
   for(side=rand()%2, voo=1 ; ; side=(side+1)%2)
   {
      nanosleep(&dorme, NULL);

      lock(&jump);
      lock(&pedido);

      if(saida) break;
      if(debug)printf("BALAS EM VOO: %d\n",voo);

      if(!check_dead(LEFT) && !check_dead(RIGHT))
      {

         if(voo)
         {
            if(debug) printf("P%d:BALAS EM VOO: %d\n",side+1,voo);
            resposta_directa(&player[side].sfd,mensagem);
            resposta_directa(&player[side].sfd,mensagem);
         }



         if(!player[LEFT].bulletsleft && !player[RIGHT].bulletsleft)
         {
            resposta_directa(&player[side].sfd,reload);
            resposta_directa(&player[side].sfd,reload);
         }

         unlock(&jump);
         unlock(&pedido);

      }
      else
      {
         unlock(&jump);
         eog=TRUE;
         bala_timer=FALSE;
         mov_timer=FALSE;
         /**Situacao de empate, soma a ambos*/
         if(player[LEFT].morto && player[RIGHT].morto)
         {
            player[LEFT].games++;
            player[RIGHT].games++;
            strcat(caixao,"EOG\nP0\n\n");
            resposta_directa(&player[LEFT].sfd,caixao);
            resposta_directa(&player[RIGHT].sfd,caixao);

            memset((void*)caixao,(int)'\0',sizeof(caixao));
            memset((void*)count,(int)'\0',sizeof(count));

            /**ENVIAR MENSAGEM AO HOF*/

         }
         else if(player[RIGHT].morto)
         {
            player[RIGHT].games++;
            sprintf(count,"%d",player[RIGHT].games);

            strcat(caixao,"EOG\nP2\n");
            strcat(caixao,count);
            strcat(caixao,"\n\n");

            resposta_directa(&player[LEFT].sfd,caixao);
            resposta_directa(&player[RIGHT].sfd,caixao);

            memset((void*)caixao,(int)'\0',sizeof(caixao));
            memset((void*)count,(int)'\0',sizeof(count));
            /**ENVIAR MENSAGEM AO HOF*/

         }
         else if(player[LEFT].morto)
         {
            player[LEFT].games++;
            sprintf(count,"%d",player[LEFT].games);

            strcat(caixao,"EOG\nP1\n");
            strcat(caixao,count);
            strcat(caixao,"\n\n");

            resposta_directa(&player[RIGHT].sfd,caixao);
            resposta_directa(&player[LEFT].sfd,caixao);

            memset((void*)caixao,(int)'\0',sizeof(caixao));
            memset((void*)count,(int)'\0',sizeof(count));
            /**ENVIAR MENSAGEM AO HOF*/

         }
         unlock(&pedido);
         /**Vou esperar até me chamarem de novo**/
         lock(&bala_inicio);
      }

      voo=move_balas();
   }
   pthread_exit(0);

}




int check_dead(int side)
{
  int other = (side + 1) % 2;
  int i;
  int dead = 0;

   for ( i = 0; i < game.maxnfired; i++ )
   {
      if ( bullets[other][i].empty ) continue;

      if ( side == LEFT )
      {
         if ( bullets[other][i].y == player[side].y )
         {
            if ( (bullets[other][i].x == player[side].x) ||
            (bullets[other][i].x == player[side].x + 1) ||
            (bullets[other][i].x == player[side].x + 2))
            {
               player[other].morto=TRUE;
               dead = 1;
            }
         }
         else if ( (bullets[other][i].y == player[side].y+1) ||
         (bullets[other][i].y == player[side].y+3) )
         {
            if ( (bullets[other][i].x == player[side].x+1) )
            {
               player[other].morto=TRUE;
               dead = 1;
            }
         }
         else if ( bullets[other][i].y == player[side].y+2 )
         {
            if ( (bullets[other][i].x == player[side].x) ||
            (bullets[other][i].x == player[side].x + 1) ||
            (bullets[other][i].x == player[side].x + 2) ||
            (bullets[other][i].x == player[side].x + 3))
            {
               player[other].morto=TRUE;
               dead = 1;
            }
         }
         else if ( bullets[other][i].y == player[side].y+4 )
         {
            if ( (bullets[other][i].x == player[side].x) ||
            (bullets[other][i].x == player[side].x + 2))
            {
               player[other].morto=TRUE;
               dead = 1;
            }
         }
      }

      if ( side == RIGHT )
      {
         if ( bullets[other][i].y == player[side].y )
         {
            if ( (bullets[other][i].x == player[side].x+1) ||
            (bullets[other][i].x == player[side].x + 2) ||
            (bullets[other][i].x == player[side].x + 3))
            {
               player[other].morto=TRUE;
               dead = 1;
            }
         }
         else if ( (bullets[other][i].y == player[side].y+1) ||
         (bullets[other][i].y == player[side].y+3) )
         {
            if ( (bullets[other][i].x == player[side].x+2) )
            {
               player[other].morto=TRUE;
               dead = 1;
            }
         }
         else if ( bullets[other][i].y == player[side].y+2 )
         {
            if ( (bullets[other][i].x == player[side].x) ||
            (bullets[other][i].x == player[side].x + 1) ||
            (bullets[other][i].x == player[side].x + 2) ||
            (bullets[other][i].x == player[side].x + 3))
            {
               player[other].morto=TRUE;
               dead = 1;
            }
         }
         else if ( bullets[other][i].y == player[side].y+4 )
         {
            if ( (bullets[other][i].x == player[side].x + 1) ||
            (bullets[other][i].x == player[side].x + 3))
            {
               player[other].morto=TRUE;
               dead = 1;
            }
         }
      }

   }

  return dead;
}



int move_balas()
{
  int i, side, ar=0;

   for ( i = 0; i < game.maxnfired; i++ )
   {
      for ( side = LEFT; side <= RIGHT; side++ )
      {
         if ( !bullets[side][i].empty )
         {
            if ( side == LEFT )
            {
               bullets[side][i].x++;
               if ( bullets[side][i].x >= NCOLS )
               {
                  bullets[side][i].empty = 1;
               }
               else
               {
                  ar++;
               }
            }
            else
            {
               bullets[side][i].x--;
               if ( bullets[side][i].x < 0 )
               {
                  bullets[side][i].empty = 1;
               }
               else
               {
                  ar++;
               }
            }
         }
      }
   }

  return ar;
}



void efectua_limpeza()
{
   pthread_mutex_destroy(&p1);
   pthread_mutex_destroy(&p2);
   pthread_mutex_destroy(&jogadores);
   pthread_mutex_destroy(&jump);
   pthread_mutex_destroy(&mov_inicio);
   pthread_mutex_destroy(&bala_inicio);
   pthread_mutex_destroy(&fim);
   pthread_mutex_destroy(&ng_p1);
   pthread_mutex_destroy(&ng_p2);
   pthread_mutex_destroy(&altera_bala);

}
