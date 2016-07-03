#include "hns.h"
#include "tools.h"
#include "hnscom.h"

/*Variaveis Globais*/
extern _Bool debug;
extern _Bool listar;
extern unsigned short int mincwaite;
extern unsigned short int mintbwaite;
extern unsigned short int maxnfired;
extern unsigned short int mintshoot;
extern arena *instancia[27][7];
extern jogador *jogadores[27][7];
extern pthread_mutex_t bloq_instancia[27][7];
extern pthread_mutex_t bloq_jogadores[27][7];
extern pthread_mutex_t espera_pontos;
extern pthread_mutex_t d_activos;
extern unsigned int desafios_activos;
extern int fd_hof1[2];
extern int fd_hof2[2];
extern int escuta;

/*Imprime Menu*/
void menu_servidor(){

   /*Limpar ecran*/
   system("clear");

   /*Mostra Informaçao de Inicio de Programa*/
   espaco(1);

   printf("\v\t\t\t\t\t\t\t--------------------------------------");
   printf("\n\t\t\t\t\t\t\t- - - - - Servidor High Noon - - - - - \n");
   printf("\t\t\t\t\t\t\t--------------------------------------");

   espaco(1);

   printf("\tComando 'l': Lista os Desafios Activos.\n");

   printf("\tComando 'd': Mostra a Informacao Acerca de um dado Desafio.\n");

   printf("\tComando 'h': Lista os 10 Melhores Jogadores.\n");

   printf("\tComando 'm': Mostra mensagens de Debug.\n");

   printf("\tComando 'n': Desliga mensagens de Debug.\n");

   printf("\tComando 'x': Sair do programa.\n");

   espaco(2);

   return;
}

/*A execuçao de Sinais*/
void tratamento_sinais(int sigNumb) {

   switch(sigNumb){

      case SIGALRM:
         printf("\nPedido SIGALRM\n");
         exit(EXIT_FAILURE);
         break;

   }

   return;
}


/*Tratamento de Sinais*/
void aceitar_sinais(){

   if (signal(SIGALRM, tratamento_sinais)==SIG_ERR)
      printf("Erro na ligacao SIGALRM\n");

   if (signal(SIGTERM, tratamento_sinais)==SIG_ERR)
      printf("Erro na ligacao SIGTERM\n");

   return;
}




/*Insere enter's*/
void espaco(short int x){
   while(x>=0){
      printf("\n");
      x--;
   }
   return;
}

/*Copia s1 para s2 e substitui c2 por c1*/
void copiasubs(char *s1, char *s2, char c2, char c1){
   unsigned short int i;

      for(i=0 ; s1[i]!='\0' ; i++){

         if(s1[i] == c2) s2[i]=c1;
         else s2[i]=s1[i];

      }
      s2[i]='\0';
      return;
}

/*Compara s1 e s2  intrepertado c1 como um espaço em s1, em caso de erro retorna 0*/
unsigned short int compara(char *s1, char *s2, char c1){
   unsigned short int i;

      for(i=0 ; s1[i]!='\0' ; i++){

         if(s1[i] != s2[i]){
            if(s1[i] != c1 || s2[i] != ' ') return 0;
         }
      }
      return 1;
}


/*Copia a string ate x caracter*/
unsigned short int copiac(char *origem, char destino[], char caracter){
   unsigned short int i;
   char temp=27;
      for(i=0 ; temp!=caracter ; i++){
         destino[i]=origem[i];
         temp=origem[i+1];
      }
      destino[i]='\0';
      i++;
      return i;
}


/*Insere a dificuldade na vaiavel Adequada*/
void insere_dificuldade(char linha[], unsigned short int *var){

   unsigned short int i, j=0;
   char temp[VALOR];

   memset(temp, '\0', sizeof(char)*VALOR);

   /*Decide quar o comprimento da Palavra que lhe foi enviada*/
   if(linha[8]=='='){
      i=9;
   }else{
      i=10;
   }

   /*Copia o valor da dificuldade para uma variavel temporaria*/
   while(1){

      if(linha[i]=='\n'){
         temp[j]='\0';
         break;
      }

      temp[j]=linha[i];
      i++;
      j++;
   }

   /*Converte o valor da Dificuldade e Grava-o*/
   *var=atoi(temp);

   if(debug) printf("HNS: Dificuldade = %d\n",*var);

   return;
}


/*Obter informaçao do Ficheiro*/
void obter_dificuldades(char *file_pontos){

   FILE *ficheiro;
   char linha[STRI];

   /*Abre o ficheiro*/
   ficheiro=fopen(file_pontos,"r");

   /*Verifica se o ficheiro e valido*/
   if(ficheiro==NULL){
      printf("\nFicheiro invalido\n");
      exit(-1);
   }


   while(1){

      /*Copiar dados para uma string e veriifica se esta no fim do ficheiro*/
      if(fgets(linha,STRI,ficheiro)==NULL){
         /*Fecha o ficheiro*/
         fclose(ficheiro);
         break;
      }

      /*Passa à frente se for comentario ou linha em branco*/
      if(linha[0]!='#' && linha[0]!='\n'){

         /*Escolhe qual o tipo de Dificuldade que temos neste momento*/
         if(linha[4]=='w' || linha[4]=='W'){
            insere_dificuldade(linha, &mincwaite);
         }else{
            if(linha[4]=='b' || linha[4]=='B'){
               insere_dificuldade(linha, &mintbwaite);
            }else{
               if(linha[4]=='f' || linha[4]=='F'){
                  insere_dificuldade(linha, &maxnfired);
               }else{
                  if(linha[4]=='s' || linha[4]=='S'){
                     insere_dificuldade(linha, &mintshoot);
                  }
               }
            }
         }
      }
   }
   return;
}


/*Inicia Lista Indexada*/
void inicia_index(){
   int i, j;

   for(i=0; i<27; i++){
      for(j=0; j<7; j++){
         instancia[i][j]=(arena *)NULL;
         jogadores[i][j]=(jogador *)NULL;

         /*Inicializa os mutex das Estroturas*/
         if( (pthread_mutex_init(&(bloq_instancia[i][j]),NULL) == -1) || (pthread_mutex_init(&(bloq_jogadores[i][j]),NULL) == -1)){
            printf("Falha na inicializacao do mutex\n");
            exit(1);
         }
      }
   }
   return;
}

/*Identifica quais as posições dos Nomes na estrotura Indexada*/
void pos_index(char *nome, unsigned short int *posicao){

      unsigned short int i;
      unsigned short int div;

      /*Identificação das letras*/
      for(i=0; i<2; i++){

         if(i==0) div=1;
         else div=4;

         if( (((nome[i])>=65) && ((nome[i])<=90)) ){

            posicao[i]= (nome[i] - 65)/div;

         }else{

            if( (((nome[i])>=97) && ((nome[i])<=122)) ){

               posicao[i]= (nome[i] - 97)/div;

            }else{
               posicao[i]=26/div;
            }
         }
      }

   return;
}

/*Verifica se o nome da Instancia Ja existe, e se sim onde*/
unsigned short int procura_nome_arena(char *nome, arena *estrutura, arena **arena_temp){

   unsigned short int result;
   pthread_mutex_t *bloqueio;

   pthread_mutex_lock(&(estrutura->bloq_arena));

   while(1){

      result=strcmp(estrutura->nome, nome);

      if(result == 0){
         if(debug) printf("HNS: Instancia %s ja existe\n", estrutura->nome);
            if(estrutura->jogador_drt == NULL && estrutura->elimin==0){
               *arena_temp=estrutura;
               return ja_existe;
            }else{
               if(debug) printf("HNS: O Instancia %s ja esta em jogo\n",nome);
               *arena_temp=estrutura;
               return arena_em_jogo;
            }
      }else{
         if(estrutura->arena_next == NULL){
            if(debug) printf("HNS: A Instancia %s ainda nao existe\n",nome);
            *arena_temp=estrutura;
            return nao_existe;
         }else{
            bloqueio=&(estrutura->bloq_arena);
            estrutura=(arena*)estrutura->arena_next;
            pthread_mutex_lock(&(estrutura->bloq_arena));
            pthread_mutex_unlock(bloqueio);
            continue;
         }
      }
   }
}

/*Verifica se o nome do Jogador Ja existe, e se sim onde*/
unsigned short int procura_nome_jogador(char *nome, jogador *estrutura, jogador **jogador_temp){

   unsigned short int result;
   pthread_mutex_t *bloqueio;

   pthread_mutex_lock(&(estrutura->bloq_jogador));

   while(1){

      result=strcmp(estrutura->nome, nome);

      if(result == 0){
         if(debug) printf("HNS: Jogador %s ja existe\n", estrutura->nome);
         *jogador_temp=estrutura;
         return ja_existe;

      }else{
         if(estrutura->jogador_next == NULL){
            if(debug) printf("HNS: O Jogador %s ainda nao existe\n",nome);
            *jogador_temp=estrutura;
            return nao_existe;
         }else{
            bloqueio=&(estrutura->bloq_jogador);
            estrutura=(jogador*)estrutura->jogador_next;
            pthread_mutex_lock(&(estrutura->bloq_jogador));
            pthread_mutex_unlock(bloqueio);
            continue;
         }
      }
   }
}

/*Cria Um estrotura Para uma nova Instancia*/
void cria_arena(arena **arena_temp){

   arena *temp;

   temp=(*arena_temp);

   /*Aloca a Esctrotura*/
   (*arena_temp)->arena_next=malloc(sizeof(arena));

   (*arena_temp)=(arena*)(*arena_temp)->arena_next;
   (*arena_temp)->arena_next=NULL;
   (*arena_temp)->arena_forward=(void*)temp;
   (*arena_temp)->jogador_esq=NULL;
   (*arena_temp)->jogador_drt=NULL;

   /*Inicializa o mutex da noca estrotura*/
   if( pthread_mutex_init(&((*arena_temp)->bloq_arena),NULL) == -1 ){
      printf("HNS: Falha na inicializacao do mutex\n");
      exit(1);
   }
   /*Bloqueia a nova estrotura e liberta a anterior*/
   pthread_mutex_lock(&((*arena_temp)->bloq_arena));
   pthread_mutex_unlock(&(temp->bloq_arena));

   return;
}

/*Cria Um estrotura Para um novo Jogador*/
void cria_jogador(jogador **jogador_temp){

   pthread_mutex_t *bloqueio;
   jogador *temp;

   temp=(*jogador_temp);

   bloqueio=&((*jogador_temp)->bloq_jogador);

   /*Aloca a Esctrotura*/
   (*jogador_temp)->jogador_next=malloc(sizeof(jogador));

   *jogador_temp=(jogador*)(*jogador_temp)->jogador_next;
   (*jogador_temp)->jogador_next=NULL;
   (*jogador_temp)->jogador_forward=(void*)temp;

   /*Inicializa o mutex da noca estrotura*/
   if( pthread_mutex_init(&((*jogador_temp)->bloq_jogador),NULL) == -1 ){
      printf("HNS: Falha na inicializacao do mutex\n");
      exit(1);
   }

   /*Bloqueia a nova estrotura e liberta a anterior*/
   pthread_mutex_lock(&((*jogador_temp)->bloq_jogador));
   pthread_mutex_unlock(bloqueio);

   return;
}

/*Insere os dados Na Instancia*/
void insere_arena(char *inst, arena *arena_temp){

   time_t data;

   strcpy(arena_temp->nome, inst);

   arena_temp->elimin=0;

   /*Data e Hora*/
   data=time(NULL);
   arena_temp->hora_local = localtime(&data);
   if(debug) printf("HNS: Data de inicio: %.2d%.2d%d\nHNS: Hora de inicio: %.2d:%.2d:%.2d\n", arena_temp->hora_local->tm_mday, 1+arena_temp->hora_local->tm_mon, 1900+arena_temp->hora_local->tm_year, arena_temp->hora_local->tm_hour, arena_temp->hora_local->tm_min, arena_temp->hora_local->tm_sec);

   return;
}

/*Guarda o Endereço recebido pelo HOF*/
void guarda_end(char * end_estr, char * end_hof){

   jogador *temp;

   temp=(jogador*)atoi(end_estr);

   strcpy(temp->apont_hof, end_hof);

   pthread_mutex_unlock(&(temp->espera_end));

   return;
}

/*Insere os dados No Jogador*/
void insere_jogador(char *jog, jogador *jogador_temp, int porto, char* IP){

   char enviar[(NOME+ENDR+15+8)];
   unsigned short int tamanho=0;

   strcpy(jogador_temp->nome, jog);

   /*IP ... ... ... ... ... Completar ... ... ... ... ... ...Porto*/
   jogador_temp->porto=porto;
   strcpy(jogador_temp->ip, IP);

   if(debug) printf("HNS: Endereco enviado %i\n", (int)jogador_temp);


   /*Envia a mensagem*/
   strcpy(enviar, "NPC\n\0");
   sprintf(&(enviar[4]), "%i", (int)jogador_temp);
   tamanho=strlen(enviar);
   enviar[tamanho]='\n';

   strcpy(&enviar[(tamanho+1)], jog);
   tamanho=strlen(enviar);
   enviar[tamanho]='\n';

   strcpy(&enviar[(tamanho+1)], jogador_temp->ip);
   tamanho=strlen(enviar);
   enviar[tamanho]='\n';
   enviar[tamanho+1]='\n';

   pthread_mutex_init(&(jogador_temp->espera_end), NULL);
   pthread_mutex_lock(&(jogador_temp->espera_end));
   
   /*Envia endereço*/
   write(fd_hof1[WRITE], enviar, (tamanho+2)*sizeof(char));
   
   /*Espera endereço*/
   pthread_mutex_lock(&(jogador_temp->espera_end));
   if(debug) printf("HNS: Recebi o endereco %s\n", jogador_temp->apont_hof);
   pthread_mutex_unlock(&(jogador_temp->espera_end));
   pthread_mutex_destroy(&(jogador_temp->espera_end));

   return;
}

/*Trata a mensagem do tipo MGN*/
unsigned short int lista_desafios(){

   arena *arena_temp;
   jogador *jogador_temp;
   char enviar[(ENDR+ENDR+7)];
   unsigned short int tamanho, i, j;
   pthread_mutex_t *bloqueio;

   pthread_mutex_lock(&d_activos);
   printf("\nNumero total de desafios: %d\n\n", desafios_activos);

   listar=1;
   for(i=0; i<27; i++){
      for(j=0; j<7; j++){

         /*Verifica se ja existe alguma instancia nessa posição*/
         pthread_mutex_lock(&(bloq_instancia[i][j]));

         if((instancia[i][j]) != (arena *)NULL){

            arena_temp=instancia[i][j];
            pthread_mutex_unlock(&(bloq_instancia[i][j]));

            while(1){

               /*Se ja existir e estiver a jogar*/
               if(arena_temp != (arena *)NULL){

                  if(arena_temp->jogador_drt==NULL || arena_temp->elimin==1){
                     bloqueio=&(arena_temp->bloq_arena);
                     arena_temp=(arena*)arena_temp->arena_next;
                     pthread_mutex_unlock(bloqueio);
                     continue;

                  }else{

                     strcpy(enviar, "SCR\n\0");
                     pthread_mutex_unlock(&(arena_temp->bloq_arena));
                     jogador_temp=(jogador*)arena_temp->jogador_esq;
                     pthread_mutex_lock(&(jogador_temp->bloq_jogador));
                     strcpy(&(enviar[4]), jogador_temp->apont_hof);
                     pthread_mutex_unlock(&(jogador_temp->bloq_jogador));
                     tamanho=strlen(enviar);
                     enviar[tamanho]='\n';
                     jogador_temp=(jogador*)arena_temp->jogador_drt;
                     pthread_mutex_lock(&(jogador_temp->bloq_jogador));
                     strcpy(&(enviar[(tamanho+1)]), jogador_temp->apont_hof);
                     pthread_mutex_unlock(&(jogador_temp->bloq_jogador));
                     tamanho=strlen(enviar);
                     enviar[tamanho]='\n';
                     enviar[tamanho+1]='\n';

                     write(fd_hof1[WRITE], enviar, (tamanho+2)*sizeof(char));

                     printf("Desafio: %s\nData de inicio: %.2d%.2d%d\nHora de inicio: %.2d:%.2d:%.2d\n", arena_temp->nome, arena_temp->hora_local->tm_mday, 1+arena_temp->hora_local->tm_mon, 1900+arena_temp->hora_local->tm_year, arena_temp->hora_local->tm_hour, arena_temp->hora_local->tm_min, arena_temp->hora_local->tm_sec);

                     /*Espera endereço*/
                     pthread_mutex_lock(&(espera_pontos));
                     pthread_mutex_lock(&(espera_pontos));
                     pthread_mutex_unlock(&(espera_pontos));

                     bloqueio=&(arena_temp->bloq_arena);
                     arena_temp=(arena*)arena_temp->arena_next;

                     pthread_mutex_unlock(bloqueio);
                  }
               }else{
                  break;
               }
            }
         }else{
            pthread_mutex_unlock(&(bloq_instancia[i][j]));
            continue;
         }
      }
   }
   pthread_mutex_unlock(&d_activos);
   listar=0;
   return ok;
}

/*Trata a mensagem do tipo MGN*/
unsigned short int mostra_desafio(char *inst){

   unsigned short int posicao_a[2];
   unsigned short int tipo_a;
   arena *arena_temp;
   jogador *jogador_temp;
   char enviar[(ENDR+ENDR+7)];
   unsigned short int tamanho;

   /*Obtem a posição da instancia na estrotura indexada*/
   pos_index(inst, posicao_a);

   if(debug) printf("HNS: Posicao Instancia: %d, %d\n",posicao_a[0], posicao_a[1]);

   /*Verifica se ja existe alguma instancia nessa posição*/
   pthread_mutex_lock(&(bloq_instancia[(posicao_a[0])][(posicao_a[1])]));

   if((instancia[(posicao_a[0])][(posicao_a[1])]) != (arena *)NULL){

      tipo_a=procura_nome_arena(inst, instancia[(posicao_a[0])][(posicao_a[1])], &arena_temp);

      pthread_mutex_unlock(&(bloq_instancia[(posicao_a[0])][(posicao_a[1])]));

      /*Se ja existir e estiver a jogar*/
      if(tipo_a == arena_em_jogo && arena_temp->elimin==0){

         strcpy(enviar, "SCR\n\0");
         jogador_temp=(jogador*)arena_temp->jogador_esq;
         pthread_mutex_lock(&(jogador_temp->bloq_jogador));
         strcpy(&(enviar[4]), jogador_temp->apont_hof);
         pthread_mutex_unlock(&(jogador_temp->bloq_jogador));
         tamanho=strlen(enviar);
         enviar[tamanho]='\n';
         jogador_temp=(jogador*)arena_temp->jogador_drt;
         pthread_mutex_lock(&(jogador_temp->bloq_jogador));
         strcpy(&(enviar[(tamanho+1)]), jogador_temp->apont_hof);
         pthread_mutex_unlock(&(jogador_temp->bloq_jogador));
         tamanho=strlen(enviar);
         enviar[tamanho]='\n';
         enviar[tamanho+1]='\n';

         write(fd_hof1[WRITE], enviar, (tamanho+2)*sizeof(char));

         printf("\nDesafio: %s\nData de inicio: %.2d%.2d%d\nHora de inicio: %.2d:%.2d:%.2d\n", arena_temp->nome, arena_temp->hora_local->tm_mday, 1+arena_temp->hora_local->tm_mon, 1900+arena_temp->hora_local->tm_year, arena_temp->hora_local->tm_hour, arena_temp->hora_local->tm_min, arena_temp->hora_local->tm_sec);

         /*Espera endereço*/
         pthread_mutex_lock(&(espera_pontos));
         pthread_mutex_lock(&(espera_pontos));
         pthread_mutex_unlock(&(espera_pontos));

         pthread_mutex_unlock(&(arena_temp->bloq_arena));

         return tipo_a;
      }

      if(arena_temp->elimin==1){
         pthread_mutex_unlock(&(arena_temp->bloq_arena));
         printf("HNS: O Desafio %s Esta a ser eliminado\n", inst);
         return tipo_a;
      }

      /*Se nao houver essa instancia devolve erro*/
      if(tipo_a == nao_existe){
         pthread_mutex_unlock(&(arena_temp->bloq_arena));
         printf("HNS: O Desafio %s nao existe\n", inst);
         return tipo_a;
      }

      /*Se ja existir mas não estiver em jogo, devolve erro*/
      if(tipo_a == ja_existe){
         pthread_mutex_unlock(&(arena_temp->bloq_arena));
         printf("HNS: O Desafio %s esta a espera do Jogador 2\n", inst);
         return tipo_a;
      }

   }else{
      pthread_mutex_unlock(&(bloq_instancia[(posicao_a[0])][(posicao_a[1])]));
      printf("HNS: O Desafio %s nao existe\n", inst);
      return sem_index;
   }
   return ok;
}

/*Trata a mensagem do tipo MGN*/
unsigned short int trata_NGM(char *inst, char *jog, int connsock, int porto, char* IP){

   unsigned short int posicao_a[2];
   unsigned short int posicao_j[2];
   unsigned short int tipo_a;
   unsigned short int tipo_j;
   arena *arena_temp;
   jogador *jogador_temp;
   jogador *jogador_temp1;

   if(debug) printf("HNS: Novo Pedido de MGN: %s %s\n",inst, jog);



   /*Obtem a posição da instancia na estrotura indexada*/
   pos_index(inst, posicao_a);

   if(debug) printf("HNS: Posicao Instancia: %d, %d\n",posicao_a[0], posicao_a[1]);

   /*Verifica se ja existe alguma instancia nessa posição*/
   pthread_mutex_lock(&(bloq_instancia[(posicao_a[0])][(posicao_a[1])]));

   if((instancia[(posicao_a[0])][(posicao_a[1])]) != (arena *)NULL){

      tipo_a=procura_nome_arena(inst, instancia[(posicao_a[0])][(posicao_a[1])], &arena_temp);

      pthread_mutex_unlock(&(bloq_instancia[(posicao_a[0])][(posicao_a[1])]));

      /*Se houver essa instancia a Jogar Para*/
      if(tipo_a == arena_em_jogo){
         pthread_mutex_unlock(&(arena_temp->bloq_arena));
         return tipo_a;
      }

   }else{
      if(debug) printf("HNS: Nao existe nenhuma instancia na posicao: %d, %d\n",posicao_a[0], posicao_a[1]);
      tipo_a=sem_index;
   }



   /*Obtem a posição do Jogador na estrotura indexada*/
   pos_index(jog, posicao_j);

   if(debug) printf("HNS: Posicao Jogador: %d, %d\n",posicao_j[0], posicao_j[1]);

   /*Verifica se ja existe algum Jogador nessa posição*/
   pthread_mutex_lock(&(bloq_jogadores[(posicao_j[0])][(posicao_j[1])]));

   if((jogadores[(posicao_j[0])][(posicao_j[1])]) != (jogador *)NULL){

      tipo_j=procura_nome_jogador(jog, jogadores[(posicao_j[0])][(posicao_j[1])], &jogador_temp);

      pthread_mutex_unlock(&(bloq_jogadores[(posicao_j[0])][(posicao_j[1])]));

      /*Se houver esse jogador esta a Jogar, Para*/
      if(tipo_j == ja_existe){
         pthread_mutex_unlock(&(jogador_temp->bloq_jogador));
         if(tipo_a!=sem_index) pthread_mutex_unlock(&(arena_temp->bloq_arena));
         else pthread_mutex_unlock(&(bloq_instancia[(posicao_a[0])][(posicao_a[1])]));
         return tipo_j;
      }
   }else{
      if(debug) printf("HNS: Nao existe nenhum Jogador na posicao: %d, %d\n",posicao_j[0], posicao_j[1]);
      tipo_j=sem_index;
   }




   /*Como NADA está em jogo ... */
   /*Se nao houver nenhum Jogador no index cria-o*/
   if(tipo_j == sem_index){

      /*Aloca a Esctrotura*/
      jogador_temp=(jogador*)malloc(sizeof(jogador));
      jogador_temp->jogador_next=NULL;
      jogador_temp->jogador_forward=NULL;

      /*Inicializa o mutex da noca estrotura*/
      if( pthread_mutex_init(&(jogador_temp->bloq_jogador),NULL) == -1 ){
         printf("HNS: Falha na inicializacao do mutex\n");
         exit(1);
      }

      pthread_mutex_lock(&(jogador_temp->bloq_jogador));
      jogadores[(posicao_j[0])][(posicao_j[1])]=jogador_temp;
      pthread_mutex_unlock(&(bloq_jogadores[(posicao_j[0])][(posicao_j[1])]));

      /*Insere os dados Na Instancia*/
      insere_jogador(jog, jogador_temp, porto, IP);
   }

   /*Se nao houver esse Jogador cria-o*/
   if(tipo_j == nao_existe){

      cria_jogador(&jogador_temp);

      /*Insere os dados No Jogador*/
      insere_jogador(jog, jogador_temp, porto, IP);
   }


   /*Se nao houver nenhuma instancia no index cria-a*/
   if(tipo_a == sem_index){

      /*Aloca a Esctrotura*/
      arena_temp=(arena*)malloc(sizeof(arena));
      arena_temp->arena_next=NULL;
      arena_temp->arena_forward=NULL;
      arena_temp->jogador_esq=NULL;
      arena_temp->jogador_drt=NULL;

      /*Inicializa o mutex da noca estrotura*/
      if( pthread_mutex_init(&(arena_temp->bloq_arena),NULL) == -1 ){
         printf("HNS: Falha na inicializacao do mutex\n");
         exit(1);
      }

      pthread_mutex_lock(&(arena_temp->bloq_arena));
      instancia[(posicao_a[0])][(posicao_a[1])]=arena_temp;
      pthread_mutex_unlock(&(bloq_instancia[(posicao_a[0])][(posicao_a[1])]));

      /*Insere os dados Na Instancia*/
      insere_arena(inst, arena_temp);
   }

   /*Se nao houver essa instancia cria-a*/
   if(tipo_a == nao_existe){

      cria_arena(&arena_temp);

      /*Insere os dados Na Instancia*/
      insere_arena(inst, arena_temp);
   }



   /*Se ja houver essa instancia, insere P2*/
   if(tipo_a == ja_existe){

      /*Se a instancia não tiver nenhum jogador associado*/
      if(arena_temp->jogador_esq == NULL){
         if(debug) printf("HNS: A instancia: %s, com o Jogador: %s vai ficar a espera de Adeversario\n",inst, jog);

         arena_temp->jogador_esq=(void*)jogador_temp;
         tipo_a=ok;
         pthread_mutex_unlock(&(jogador_temp->bloq_jogador));
         pthread_mutex_unlock(&(arena_temp->bloq_arena));
         return tipo_a;

      /*Caso contrario, Insere P2*/
      }else{
         if(debug) printf("HNS: A instancia: %s, com o Jogador: %s vai Iniciar o Jogo\n",inst, jog);
         pthread_mutex_lock(&d_activos);
         desafios_activos++;
         arena_temp->jogador_drt=(void*)jogador_temp;
         jogador_temp->connsock=connsock;
         jogador_temp->my_arena=(void*)arena_temp;
         pthread_mutex_unlock(&d_activos);
         responde("P2\0", &(jogador_temp->connsock), ok);
         jogador_temp1=(jogador*)arena_temp->jogador_esq;
         pthread_mutex_lock(&(jogador_temp1->bloq_jogador));
         responde("P1\0", &(jogador_temp1->connsock), ok);

         arena_temp->pid_jogo=fork();

         if(arena_temp->pid_jogo==-1)
         {
            perror("fork");
            exit(EXIT_FAILURE);
         }
			
         if(arena_temp->pid_jogo==0)
         {
            char tp0[10],tp1[10],tp2[10],tp3[10],tp4[10],tp5[10],tp6[10],tp7[10],tp8[10],tp9[10],tp10[10],tp11[10],tp12[10];

            close(escuta);

            memset((void*)tp0,(int)'\0',sizeof(tp0));
            memset((void*)tp1,(int)'\0',sizeof(tp1));
            memset((void*)tp2,(int)'\0',sizeof(tp2));
            memset((void*)tp3,(int)'\0',sizeof(tp3));
            memset((void*)tp4,(int)'\0',sizeof(tp4));
            memset((void*)tp5,(int)'\0',sizeof(tp5));
            memset((void*)tp6,(int)'\0',sizeof(tp6));
            memset((void*)tp7,(int)'\0',sizeof(tp7));
            memset((void*)tp8,(int)'\0',sizeof(tp8));
            memset((void*)tp9,(int)'\0',sizeof(tp9));
            memset((void*)tp10,(int)'\0',sizeof(tp10));
            memset((void*)tp11,(int)'\0',sizeof(tp11));
            memset((void*)tp12,(int)'\0',sizeof(tp12));


            strcpy(tp0,arena_temp->nome);  /**Nome jogo*/

            strcpy(tp1,jogador_temp1->nome);
            sprintf(tp3,"%d",jogador_temp1->connsock); /**fd para p1*/
            strcpy(tp6,jogador_temp1->apont_hof);

            strcpy(tp2,jogador_temp->nome);
            sprintf(tp4,"%d",jogador_temp->connsock); /**fd para p2*/
            strcpy(tp7,jogador_temp->apont_hof);


            sprintf(tp5,"%d",fd_hof1[WRITE]); /**fd para hof*/

            sprintf(tp8,"%d",debug);
            /**FALTAM DIFICULDADES**/

            sprintf(tp9,"%d",mincwaite);
            sprintf(tp10,"%d",mintbwaite);
            sprintf(tp11,"%d",maxnfired);
            sprintf(tp12,"%d",mintshoot);

            if(debug)printf("DEBUG@lanca_jogo: Sou processo FILHO com pid: %ld!\n",(long) getpid());

            if(execl("./bin/jogo", tp0, tp1, tp2, tp3, tp4, tp5, tp6, tp7, tp8, tp9, tp10, tp11, tp12, (char *) 0)==-1)
            {
               perror("execl");
               exit(EXIT_FAILURE);
            }

         }

         close(jogador_temp1->connsock);
         close(jogador_temp->connsock);


         pthread_mutex_unlock(&(jogador_temp->bloq_jogador));
         pthread_mutex_unlock(&(jogador_temp1->bloq_jogador));
         pthread_mutex_unlock(&(arena_temp->bloq_arena));
         
         tipo_a=ok;
         return tipo_a;
      }


   /*Se existia essa instancia*/
   }else{
      if(debug) printf("HNS: A instancia: %s, com o Jogador: %s vai ficar a espera de Adeversario\n",inst, jog);
      arena_temp->jogador_esq=(void*)jogador_temp;
      jogador_temp->connsock=connsock;
      jogador_temp->my_arena=(void*)arena_temp;
      pthread_mutex_unlock(&(jogador_temp->bloq_jogador));
      pthread_mutex_unlock(&(arena_temp->bloq_arena));
      tipo_a=ok;
      return tipo_a;
   }
}

/*Elimina Jogador e Desafio*/
void eliminar(char *apontador){

   jogador *jog_temp;
   jogador *jog_next=(jogador*)NULL;
   jogador *jog_forward=(jogador*)NULL;
   arena *arena_temp;
   arena *arena_next=(arena*)NULL;
   arena *arena_forward=(arena*)NULL;
   unsigned short int posicao[2];

   jog_temp=(jogador*)atoi(apontador);
   arena_temp=(arena*)jog_temp->my_arena;

   pthread_mutex_lock(&(jog_temp->bloq_jogador));
   pthread_mutex_lock(&(arena_temp->bloq_arena));

   arena_temp->elimin=1;

   arena_next=(arena*)arena_temp->arena_next;
   arena_forward=(arena*)arena_temp->arena_forward;
   jog_next=(jogador*)jog_temp->jogador_next;
   jog_forward=(jogador*)jog_temp->jogador_forward;

   if(jog_forward != NULL) pthread_mutex_lock(&(jog_forward->bloq_jogador));
   if(jog_next != NULL) pthread_mutex_lock(&(jog_next->bloq_jogador));

	/*Faz o swap*/
   if(jog_forward == NULL){
      pos_index(jog_temp->nome, posicao);
      pthread_mutex_lock(&(bloq_jogadores[(posicao[0])][(posicao[1])]));
      jogadores[(posicao[0])][(posicao[1])]=jog_next;
      pthread_mutex_unlock(&(bloq_jogadores[(posicao[0])][(posicao[1])]));
      if(jog_next != NULL) jog_next->jogador_forward=NULL;

   }else{
      jog_forward->jogador_next=(void*)jog_next;
      if(jog_next != NULL) jog_next->jogador_forward=(void*)jog_forward;
   }

   if(jog_forward != NULL) pthread_mutex_unlock(&(jog_forward->bloq_jogador));
   if(jog_next != NULL) pthread_mutex_unlock(&(jog_next->bloq_jogador));

   /*Verifica qual o jogador da estrutura que esta a ser eliminado*/
   if(jog_temp==(jogador*)arena_temp->jogador_esq) arena_temp->jogador_esq=NULL;
   else if(jog_temp==(jogador*)arena_temp->jogador_drt) arena_temp->jogador_drt=NULL;
      else printf("HNS: ... ... ... ERRO Jogador nao existe na Instancia (ao elminar)\n");

   pthread_mutex_unlock(&(jog_temp->bloq_jogador));
   if(pthread_mutex_destroy(&(jog_temp->bloq_jogador)) != 0) printf("HNS: Erro ao fechar Mutex (Eliminar)1\n");
   if(pthread_mutex_destroy(&(jog_temp->espera_end)) != 0) printf("HNS: Erro ao fechar Mutex (Eliminar)2\n");
   free(jog_temp);


   if(arena_temp->jogador_esq==NULL && arena_temp->jogador_drt==NULL){

      /*Faz o swap*/
      if(arena_forward != NULL) pthread_mutex_lock(&(arena_forward->bloq_arena));
      if(arena_next != NULL) pthread_mutex_lock(&(arena_next->bloq_arena));

      if(arena_forward == NULL){
         pos_index(arena_temp->nome, posicao);
         pthread_mutex_lock(&(bloq_instancia[(posicao[0])][(posicao[1])]));
         instancia[(posicao[0])][(posicao[1])]=arena_next;
         pthread_mutex_unlock(&(bloq_instancia[(posicao[0])][(posicao[1])]));
         if(arena_next != NULL) arena_next->arena_forward=NULL;

      }else{
         arena_forward->arena_next=(void*)arena_next;
         if(arena_next != NULL) arena_next->arena_forward=(void*)arena_forward;
      }

      if(arena_forward != NULL) pthread_mutex_unlock(&(arena_forward->bloq_arena));
      if(arena_next != NULL) pthread_mutex_unlock(&(arena_next->bloq_arena));

      pthread_mutex_unlock(&(arena_temp->bloq_arena));
      if(pthread_mutex_destroy(&(arena_temp->bloq_arena)) != 0) if(debug) printf("HNS: Erro ao fechar Mutex (Eliminar)3\n");
      free(arena_temp);

      if(debug) printf("HNS: Jogador e Desafio elimindao\n");

   }else{
      if(debug) printf("HNS: Jogador elimindao, mas nao o Desafio\n");
      pthread_mutex_lock(&d_activos);
      desafios_activos--;
      pthread_mutex_unlock(&d_activos);
      pthread_mutex_unlock(&(arena_temp->bloq_arena));
   }

   return;
}

void dar_pontos(char *nome){

   jogador *temp;
   unsigned short int tipo;
   unsigned short int posicao[2];
	
   if(debug) printf("HNS: ADD pontos: %s\n", nome);
	
   pos_index(nome, posicao);

   /*Verifica se ja existe algum Jogador nessa posição*/
   pthread_mutex_lock(&(bloq_jogadores[(posicao[0])][(posicao[1])]));

   if((jogadores[(posicao[0])][(posicao[1])]) != (jogador *)NULL){

      tipo=procura_nome_jogador(nome, jogadores[(posicao[0])][(posicao[1])], &temp);

      pthread_mutex_unlock(&(bloq_jogadores[(posicao[0])][(posicao[1])]));

      /*Se houver esse jogador esta a Jogar, Para*/
      if(tipo == ja_existe){
         write(fd_hof1[WRITE], "ADD\n", 4*sizeof(char));
         write(fd_hof1[WRITE], temp->apont_hof, ENDR*sizeof(char));
         write(fd_hof1[WRITE], "\n2\n10\n\n", 7*sizeof(char));
         pthread_mutex_unlock(&(temp->bloq_jogador));
         return;
      }

      if(tipo == nao_existe){
         printf("HNS: Esse Jogador não existe\n");
         pthread_mutex_unlock(&(temp->bloq_jogador));
         return;
      }

   }else{
      if(debug) printf("HNS: Nao existe nenhum Jogador na posicao: %d, %d\n",posicao[0], posicao[1]);
      pthread_mutex_unlock(&(bloq_jogadores[(posicao[0])][(posicao[1])]));
      return;
   }

   return;
}
