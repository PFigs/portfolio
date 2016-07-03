/*************************************************
 *    Arquitecturas Avançadas de Computadores
 *             2º Semestre - 2009/2010
 * 
 *    Projecto: I Fase - Simulação Funcional
 * 
 *    Alexander (58958)
 *    Pedro Silva (58035)
 * ***********************************************
 * INSTRUCOES:
 * NOP = 16 bits a zero
 * HALT ?
 **/

#include "main.h"
#include "load.h"
#include "unidades_cc.h"

/*
 *@name load
 *@filename load.c
 *@brief Efectua a leitura do ficheiro para memoria.
 *@param[in] argv Nome do ficheiro a ler.
 *
 *@bug Se ficheiro nao terminado por \n, da barraca!
 **/
void load(char *argv){
   
   extern short int reg[]; /**8 Registos 16 bits*/
   extern unsigned short int mem[];/**Memoria*/
   extern unsigned short int pc;
   extern unsigned short int hmaddr;
   
   int lido=0,rd=0,fd,i,a;
   struct stat flist;
   char *buffer,store[5], *aux;
   _Bool first=TRUE;
   _Bool endereco=FALSE;
   
   /**Obtaning file descriptor**/
   fd=open(argv,O_RDONLY);
   if(fd==-1){
      printf("%s\n",strerror(errno));
      exit(EXIT_FAILURE);
   }

   /**Obtaning file size*/
   if(fstat(fd,&flist)==-1){
      printf("%s\n",strerror(errno));
      exit(EXIT_FAILURE);
   }

   buffer=(char *)calloc(flist.st_size+2,sizeof(char));
   
   /**Reads all file to the buffer*/
   while(lido!=flist.st_size){
      if((rd=read(fd,buffer,flist.st_size*sizeof(char)))==-1){
         printf("%s\n",strerror(errno));
         exit(EXIT_FAILURE);
      }

      if(rd==0)break;

      lido+=rd;
   }

   close(fd);

   /**Sinaliza fim de ficheiro*/
   for(a=flist.st_size;;a--){
      if(buffer[a]=='\n')
         if((buffer[a-1]>='0' && buffer[a-1]<='9')||((store[0]=toupper(buffer[a-1]))>='A' && (store[1]=toupper(buffer[a-1]))<='F')) break;
   }

   buffer[a+1]='*';
   buffer[a]='\n';

   reg[0]=DEFAULT_ADDR;
   pc=DEFAULT_ADDR;

   store[4]=(int)'\0';
   aux=buffer;
   /**Parse File*/
   printf("\nLeitura Ficheiro----------------------------------\n");
   for(i=0,a=0;buffer[i]!='*';){

      memset((void*)store,(int)'\0',sizeof(store));
      
      for(;buffer[i]!='\n';i++){
         if(buffer[i]==' '){
            a=i+1;
            endereco=TRUE;
         }
      }

      /**Deviamos verificar que o que vamos ler é hexadecimal*/
      /**Nao necessita subtrair 1 pk nao foi somado em cima*/
      strncpy(store,buffer+a,sizeof(char)*(i-a));

      if(endereco){
         /**Copia para registo para indexar memoria*/
         sscanf(store,"%hx\n",(unsigned short int *)&reg[0]);
         if(first){
            pc=reg[0];
            first=FALSE;
         }
         endereco=FALSE;

         /**Se for indexada uma posicao de memoria superior, esta e colocada em hmaddr*/
         if(hmaddr<reg[0]) hmaddr=reg[0];
         
         printf("\nSaltar para endereco: %05d (%05x)\n\n",reg[0],reg[0]);
         
      }else{
         /**Coloca em memoria*/
         sscanf(store,"%hx\n",(unsigned short int *)&mem[reg[0]]);
         printf("Conteudo: %05hu (%05x)  |  Posicao: %05d (%05x)\n",mem[reg[0]],mem[reg[0]],reg[0],reg[0]);
         reg[0]++;
         first=FALSE;
      }

      buffer=buffer+i+1;
      i=0;
      a=0;
   }
   printf("\nFim: Leitura de Ficheiro--------------------------\n");
   reg[0]=0;
   
   /**/
   free(aux);
   /**/
}
