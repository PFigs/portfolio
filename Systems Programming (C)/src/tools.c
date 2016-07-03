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

extern _Bool debug;



void activa_sinais(void)
{
   void (*old_handler)(int);

   if(signal(SIGALRM,tratamento)==SIG_ERR)
   {
      printf("Impossivel tratar SIGALRM!\n");
      exit(EXIT_FAILURE);
   }

   if(signal(SIGUSR1,tratamento)==SIG_ERR)
   {
      printf("Impossivel tratar SIGUSR1!\n");
      exit(EXIT_FAILURE);
   }

   if(signal(SIGUSR2,tratamento)==SIG_ERR)
   {
      printf("Impossivel tratar SIGUSR2!\n");
      exit(EXIT_FAILURE);
   }


   if((old_handler=signal(SIGPIPE,SIG_IGN))==SIG_ERR)
   {
      printf("Impossivel tratar SIGPIPE!\n");
      exit(EXIT_FAILURE);
   }


}


/**
 * name: trata sinais
 * @param
 *    codigo do sinal
 * @return
 *    efectua instrução consoante o sinal que apanhar
 */

void tratamento(int num)
{
   switch(num){
      case SIGALRM:
         if(debug) printf("DEBUG@tratamento: Expirou alarme!\n");
         exit(EXIT_FAILURE);
         break;

      case SIGUSR1:
         if(debug) printf("DEBUG@tratamento: Gerado SIGUSR1 => Acorda movimento!\n");
         break;

      case SIGUSR2:
         if(debug) printf("DEBUG@tratamento: Gerado SIGUSR1 => Acorda bala!\n");
         break;
   }

}




/**
 * name: valida_argumentos
 * @param
 *    argc e argv
 * @return
 *    0 em caso de erro
 *    1 em caso correcto
 *    2 em caso de debug
 */
int valida_argumentos(int argc, char** argv, int *porto, char **fich, _Bool server)
{
   int aux=0;

   if(server)
   {
      /**Numero de argumentos correcto?*/
      if(argc>=4){
         if(strcmp(argv[3],"-d")==0) debug=TRUE;
				else debug=FALSE;
      }else
      {
         if(argc<2)
         {
            printf("Argumentos em falta!\nPor favor iniciar com <executavel> <porto> <ficheiro.cfg>\n");
            exit(EXIT_FAILURE);
         }
      }

      /**Obtem dados*/
      aux=atoi(argv[1]);

      if(argc>=3) (*fich)=copia_nome(argv[2], *fich);
      else (*fich)=NULL;

      if(valida_porto(aux)==-1) return -1;

      *porto=aux;

      if(debug) printf("DEBUG: Em escuta no porto: %d\n", *porto);

      /**Sucesso!*/
      return 0;
   }
   else
   {
         /**Numero de argumentos correcto?*/
   if(argc==6){
      if(strcmp(argv[5],"-d")==0) debug=TRUE;
      else debug=FALSE;
   }else
   {
      if(argc!=5)
      {
         printf("Argumentos em falta!\n");
         printf("Por favor iniciar com <executavel> <nome/ipv4 servidor> <porto> <nome_jogo> <nome_jogador>\n");
         exit(EXIT_FAILURE);
      }
   }


   /**Obtem dados*/
   aux=atoi(argv[2]);

   if(valida_porto(aux)==-1) return -1;

   *porto=aux;

   if(debug) printf("DEBUG: Servidor em escuta no porto: %d\n", *porto);


   /**Sucesso!*/
   return 0;
   }

   return -1;
}


/**
 * name: valida_porto
 *
 * @param
 *    porto a validar
 *
 * @return
 *    retorna 0 se porto estiver num intervalo aceitável;
 *    retorna -1 caso contrário.
 *
 */

short int valida_porto(int aux)
{
   /**Valores permitidos?*/
   if(aux<=0)
   {
      printf("O número do porto tem que ser superior a zero\n");
      return -1;
   }

   if(aux>0 && aux<=1023)
   {
      printf("Porto dentro do intervalo de portos atribuidos pela IANA. Por favor use outro porto.\n");
      return -1;
   }

   if(aux<=65535) return 0;

   return -1;

}

char *copia_nome(char *fonte, char *destino)
{
   unsigned int cnt;

   cnt=strlen(fonte);
   if(debug) printf("DEBUG:\n\tFicheiro:%s\n\tComprimento:%d\n", fonte, cnt);

   destino = (char *)calloc(cnt+1,sizeof(char));

   strcpy(destino,fonte);
   destino[cnt]='\0';

   return destino;
}


/**
 *
 * name: erro
 * @param
 *    numero associado ao erro
 *       1: Memoria insuficiente
 * @return
 *    sem retorno
 */

void erro(unsigned short int num)
{
   switch (num){

      case 1:
         printf("ERRO FATAL: Memória insuficiente!\n A terminar...\n");
         exit(EXIT_FAILURE);
      break;

   }
}


/**
 * name: guarda_nomes
 *
 * @param
 *    vector de nomes e parâmetros da linha
 *
 * @return
 *    vector de nomes actualizados
 *
 */

char **guarda_nomes(char **nomes, char **argv)
{
   /**Aloca vector de nomes*/
    /* 4 nomes:
     * - IP/nome servidor;
     * - Nome jogo;
     * - Nome jogador 1;
     * - ID do jogador 1;
     */

   nomes = (char **) calloc(3,sizeof(char *));

   /**Salvaguarda IP*/
   nomes[NSERVER]=(char *)calloc(strlen(argv[1])+1,sizeof(char));
   strcpy(nomes[NSERVER],argv[1]);
   if(debug) printf("DEBUG@guarda_nomes: IP/nome do servidor: %s\n", nomes[0]);

   /**Salvaguarda nome do jogo*/
   nomes[NGAME]=(char *)calloc(strlen(argv[3])+1,sizeof(char));
   strcpy(nomes[NGAME],argv[3]);

   /**Salvaguarda nome do jogador*/
   nomes[NP1]=(char *)calloc(strlen(argv[4])+1,sizeof(char));
   strcpy(nomes[NP1],argv[4]);
   if(debug) printf("DEBUG@guarda_nomes: Sera comunicado %s@%s\n", nomes[2],nomes[1]);

   nomes[PID]=(char *)calloc(strlen("P1")+1,sizeof(char));

   return nomes;

}


/**
 * name: converte_id
 *
 * converte a string num numero
 *
 * @param
 *    campo identificador
 *
 * @return
 *    numero associado ao campo
 */

int converte_id(char *id)
{

   if(id[0]=='N')
   {
      if(strcmp(id,"NGM")==0)
      {
         return NGM;
      }
        else if(strcmp(id,"NSH")==0)
      {
         return NSH;
      }
   }

   if(id[0]=='S'){

      if(strcmp(id,"STR")==0)
      {
         return STR;
      }
      else if(strcmp(id,"SHD")==0)
      {
         return SHD;
      }
   }

   if(id[0]=='E'){
      if(strcmp(id,"EOG")==0)
      {
         return EOG;
      }
      else if(strcmp(id,"EXT")==0)
      {
         return EXT;
      }
      else if(strcmp(id,"BDR")==0)
      {
         return BDR;
      }
      else if(strcmp(id,"ERR")==0)
      {
         return ERR;
      }
   }

   if(strcmp(id,"MOV")==0)
   {
      return MOV;
   }
   else if(strcmp(id,"BLT")==0)
   {
      return BLT;
   }
   else if(strcmp(id,"CNT")==0)
   {
      return CNT;
   }
   else if(strcmp(id,"VAL")==0)
   {
      return VAL;
   }
   else if(strcmp(id,"REL")==0)
   {
      return REL;
   }


   return 0;

}



void lock(pthread_mutex_t *porta)
{
   pthread_mutex_lock(porta);
}


void unlock(pthread_mutex_t *porta)
{
   pthread_mutex_unlock(porta);
}
