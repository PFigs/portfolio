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
#include "hns.h"
#include "tools.h"
#include "hnscom.h"

/*Variaveis Globais*/
_Bool debug=0;
_Bool saida=0;
_Bool listar=0;
unsigned short int mincwaite=500;
unsigned short int mintbwaite=100;
unsigned short int maxnfired=6;
unsigned short int mintshoot=100;
arena *instancia[27][7];
jogador *jogadores[27][7];
pthread_mutex_t bloq_instancia[27][7];
pthread_mutex_t bloq_jogadores[27][7];
pthread_mutex_t bloqread;
pthread_mutex_t bloq_disp;
unsigned short int disponiveis=0;
pthread_mutex_t d_activos;
unsigned int desafios_activos=0;
pthread_mutex_t all_full;
pthread_mutex_t espera_pontos;
pthread_mutex_t espera_top;
int fd_hof1[2];
int fd_hof2[2];
int escuta;
int porto;

void *preenche() {


   /*for(tamanho_nomes=0; tamanho_nomes <= 10; tamanho_nomes++){
      write(fd_hof1[WRITE], msg, 29*sizeof(char));
      write(fd_hof1[WRITE], msg2, 24*sizeof(char));
   }*/


   /*Trata a mensagem do tipo MGN*/
   trata_NGM("ColmeiasCity", "PedroNeves", 0, 0, "127.000.000.001\0");
   trata_NGM("Never", "Joca", 0, 0, "127.000.000.001\0");

   trata_NGM("ColmeiasCity", "Silva", 0, 0, "127.000.000.001\0");
   trata_NGM("Never", "Porco", 0, 0, "127.000.000.001\0");

	dar_pontos("PedroNeves");
	dar_pontos("Porco");
	dar_pontos("Silva");
	dar_pontos("Joca");
	sleep(1);
   trata_NGM("ColmeiasCity", "PedroNeves", 0, 0, "127.000.000.001\0");
   trata_NGM("Never", "Joca", 0, 0, "127.000.000.001\0");

   trata_NGM("ColmeiasCity", "Silva", 0, 0, "127.000.000.001\0");
   trata_NGM("Never", "Porco", 0, 0, "127.000.000.001\0");


  return 0;
  }

/*Funcao Principal*/
int main(int argc, char **argv){


   /*Declaraçoes da funçao main*/
   char *cfg;
   pid_t pid_hof=0;
   pthread_t tid;

   /*Valida Argomentos*/
   if( valida_argumentos(argc,argv, &porto,&cfg,TRUE) == -1 ) exit(EXIT_FAILURE);

   /*Tratamento de Sinais*/
   aceitar_sinais();

   /*Obtem as Dificuldades do ficheiro*/
   if(cfg != NULL) obter_dificuldades(cfg);

   /*Estabelecer sessão*/
   iniciar_comunicacoes(porto, &escuta);

   /*Inicia Lista Indexada*/
   inicia_index();

   pthread_mutex_init(&espera_pontos, NULL);
   pthread_mutex_init(&d_activos, NULL);

   /*Abre os Pipes*/
   pipe(fd_hof1);
   pipe(fd_hof2);

   /*Cria Hall of Fame*/
   inicia_hof(&pid_hof);

   /*Fecha os descritores desnecessarios*/
   close(fd_hof1[READ]);
   close(fd_hof2[WRITE]);

   if (pthread_create(&tid, NULL, interface, NULL) != 0){
      printf("HNS: Erro a criar thread\n");
    }

   muti_thread(&pid_hof);

   /*Tratar do interface gráfico*/
   /*interface_grafico();*/

   return 0;
}
