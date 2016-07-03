#include "hns.h"
#include "tools.h"
#include "hnscom.h"

extern _Bool debug;
extern _Bool saida;
extern _Bool listar;
extern int fd_hof1[2];
extern int fd_hof2[2];
extern int escuta;
extern int porto;
extern pthread_mutex_t bloqread;
extern pthread_mutex_t bloq_disp;
extern pthread_mutex_t all_full;
extern pthread_mutex_t espera_pontos;
extern pthread_mutex_t espera_top;
extern unsigned short int disponiveis;
fd_set rfds;


/*Recebe a pontução de um jogador*/
void recebe_pontos(char *endr1, char *victorias1, char *endr2, char *victorias2){

   jogador *temp;

   temp=(jogador*)atoi(endr1);

   pthread_mutex_lock(&(temp->bloq_jogador));
   if(listar) printf("Jogador1: %s\nVitorias1 %s\n", temp->nome, victorias1);
   else printf("Jogador1: %s\nVitorias1 %s\nIP1: %s\nPorto1: %d\n", temp->nome, victorias1, temp->ip, temp->porto);
   pthread_mutex_unlock(&(temp->bloq_jogador));

   temp=(jogador*)atoi(endr2);

   pthread_mutex_lock(&(temp->bloq_jogador));
   if(listar) printf("Jogador2: %s\nVitorias2 %s\n", temp->nome, victorias2);
   else printf("Jogador2: %s\nVitorias2 %s\nIP2: %s\nPorto2: %d\n", temp->nome, victorias2, temp->ip, temp->porto);
   pthread_mutex_unlock(&(temp->bloq_jogador));

   pthread_mutex_unlock(&(espera_pontos));

   printf("\n");
   return;
}

/*Função de Tratamento da Informação recebida*/
void *pool_receber(){

      unsigned short int i, j;
      char mensagem[5][NOME];
      int maxfd, counter;

      while(1){

         /*Fica à espera até o read ficar disponivel*/
         pthread_mutex_lock(&bloqread);

         /*Verifica se é para sair*/
         if(saida){
               pthread_mutex_unlock(&bloqread);
               return 0;
            }

         /*Actualiza as threads disponiveis -1*/
         pthread_mutex_lock(&bloq_disp);
         disponiveis = disponiveis -1;

         /*Verifica a ocupação de threads*/
         if( disponiveis <=1 ) pthread_mutex_unlock(&all_full);

         pthread_mutex_unlock(&bloq_disp);

         /*Inicia o Select*/
         FD_ZERO(&rfds);
         FD_SET(fd_hof2[READ], &rfds);
         maxfd=fd_hof2[READ];
         FD_SET(escuta, &rfds);
         maxfd=max(maxfd, escuta);

         counter=select(maxfd+1, &rfds, (fd_set*)NULL, (fd_set*)NULL, (struct timeval*)NULL);

         if(counter<=0) printf("Erro no Select\n");

         for(; counter; counter--){
			
            /*Se for para o PIPE*/
            if(FD_ISSET(fd_hof2[READ], &rfds)){
               i=0;
               j=0;
               while(1){
                  if( read(fd_hof2[READ], &mensagem[j][i], sizeof(char)) <= 0 ){
					 pthread_mutex_unlock(&bloqread);
                     return 0;
					}
                  

                  /*Verifica se não estamos presente do 1º caracter da string*/
                  if(i!=0){

                     /*Verifica se é o fim da mensagem*/
                     if(mensagem[j][(i-1)] == '\n' && mensagem[j][i] == '\n'){

                        mensagem[j][(i-1)]='\0';
                        break;
                     }

                     /*Verifica se terminamos o parametro*/
                     if(mensagem[j][(i-1)] == '\n'){

                        mensagem[j+1][0]=mensagem[j][i];
                        mensagem[j][(i-1)]='\0';
                        j++;
                        i=1;
                        continue;
                     }
                     i++;
                  }else{
                     i++;
                  }
               }

               /*Desbloqueia o read*/
               pthread_mutex_unlock(&bloqread);

               if(debug){
                  printf("HNS: Mensagem do Pipe:");
                  for(i=0; i<=j; i++) printf(" %s",mensagem[i]);
                  printf("\n");
               }

               /*Identificalão da mensagem*/

               switch(mensagem[0][1]){

                  /*END*/
                  case 'N':
                        guarda_end(mensagem[1], mensagem[2]);
                        break;

                  /*SCR*/
                  case 'C':
                        recebe_pontos(mensagem[1], mensagem[2], mensagem[3], mensagem[4]);
                        break;

                  /*DEL*/
                  case 'E':
                        eliminar(mensagem[1]);
                        break;

                  /*TOP*/
                  case 'O':
                        pthread_mutex_unlock(&espera_top);
                        break;

                  /*SHD*/
                  case 'H':
                        pthread_mutex_unlock(&bloqread);
                        break;

                  default:
                        if(debug) printf("HNS: ERRO, mensagem desconhecida\n");
                        break;
               }
               break;
            }

            if(FD_ISSET(escuta, &rfds)){
               pthread_mutex_unlock(&bloqread);
               recebe_mensagens(escuta, porto);
               	if(saida){
                   pthread_mutex_unlock(&bloqread);
                   printf("Thread a sair 3\n");
                   return 0;
               }
               break;
            }

         }

         /*Actualiza as threads disponiveis +1*/
         pthread_mutex_lock(&bloq_disp);
         disponiveis = disponiveis +1;
         pthread_mutex_unlock(&bloq_disp);

      }

   return 0;
}

/*Cria e inicializa uma estrotura de 8 threads*/
mult_thread *criagrupo(){

   mult_thread *temp;
   unsigned short int i;

   /*Aloca uma estrotura para 8 threads*/
   temp=(mult_thread*)malloc(sizeof(mult_thread));

   /*Inicializa os seus campos*/
   temp->next=NULL;

   /*Actualiza as threads disponiveis*/
   pthread_mutex_lock(&(bloq_disp));
   disponiveis = (disponiveis) + 8;
   pthread_mutex_unlock(&(bloq_disp));

   /*Inicia a 8 threads*/
   for (i=0; i<8; i++) {
      if (pthread_create(&(temp->grupo_thd[i]), NULL, pool_receber, NULL) != 0) {
         printf("HNS: Erro a criar thread=%d\n", i);
      }
   }

   return temp;
}

/*Terminha o Processo hall of fame*/
void sair_serv(mult_thread *pool_threads, pid_t *pid_hof){
	
   unsigned short int i;
   char msg3[]="SHD\n\n";

   if(debug) printf("HNS: A executar saida\n");
   write(fd_hof1[WRITE], msg3, 5*sizeof(char));
   
   pthread_mutex_unlock(&bloqread);
   
	while(1){
		for(i=0; i<8; i++) pthread_join(pool_threads->grupo_thd[i], NULL);

		if(pool_threads->next != NULL){
			free(pool_threads);
			pool_threads=(mult_thread*)pool_threads->next;
			continue;
		}else{
			free(pool_threads);
			break;
		}
	}
	if(debug) printf("HNS: As Threads ja terminaram\n");

   wait(pid_hof);

   /*Fecha os descritores dos Pipes*/
   close(fd_hof2[READ]);
   close(fd_hof1[WRITE]);
   close(escuta);

   if(debug) printf("HNS: O processo HOF terminou\n");

   return;
}

/*A thread principal trata da gestão do numero de threads activas*/
void muti_thread(pid_t *pid_hof){

      mult_thread *mt_thrds;
      mult_thread *mt_temp;


      if(debug) printf("HNS: A iniciar Multi Thread\n");


      /*Inicializa os mutexes para bloquear a vareavel disponiveis e o apontador para a estrutura hall_of*/
      if(pthread_mutex_init(&bloq_disp, NULL) == -1 || pthread_mutex_init(&bloqread, NULL) == -1 || pthread_mutex_init(&all_full, NULL) == -1){
         printf("HNS: Falha na inicializacao do mutex\n");
         exit(1);
      }

      pthread_mutex_lock(&all_full);

      /*Cria o 1º grupo de 8 threads*/
      mt_thrds=criagrupo();
      mt_temp=mt_thrds;

      /*preenche();*/
      pthread_mutex_unlock(&espera_top);

      /*Inicia a analise à disponibilidade das threads*/
      while(1){

         /*Fica retido até estarem praticamente todas as threads ocupadas*/
         pthread_mutex_lock(&all_full);

         if(saida == 1){
            sair_serv(mt_thrds, pid_hof);
            break;
         }

         if(debug) printf("HNS: As threads estao todas ocupadas, criado novo grupo com mais 8 threads\n");

		mt_temp->next=(void*)criagrupo();			
		mt_temp=(mult_thread*)mt_temp->next;

         /*Verifica se ainda é preciso mais threads*/
         pthread_mutex_lock(&bloq_disp);

         if( disponiveis <=1 ){
            pthread_mutex_unlock(&bloq_disp);
            pthread_mutex_unlock(&all_full);
            continue;
         }

         pthread_mutex_unlock(&bloq_disp);

      }
      return;
}
