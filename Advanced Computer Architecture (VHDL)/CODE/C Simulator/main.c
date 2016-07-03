/*************************************************
 *    Arquitecturas Avançadas de Computadores
 *             2º Semestre - 2009/2010
 * 
 *    Projecto: I Fase - Simulação Funcional
 * 
 *    Alexander (58958)
 *    Pedro Silva (58035)
 * ***********************************************
 * */
#include "main.h"
#include "load.h"
#include "unidades_cc.h"
#include "alu.h"

short int reg[8]; /**8 Registos 16 bits */
short int mem[16384]; /**Memoria*/
unsigned short int pc=DEFAULT_ADDR;
_Bool flag[6]={FALSE};
_Bool debug=FALSE;
unsigned short int hmaddr=0;

int main (int argc, char **argv){

   unsigned int ciclos=0;
   short int aux=0;
   short int aux2=1;
   int conta=0;
   
   if(argc<2){
      printf("Argumentos em falta!\nIndique o nome completo do ficheiro a ler.\n");
      exit(0);
   }
   
   load(argv[1]);

   for(;!flag[HALT];aux2++,ciclos+=4){
      
      identifica_instr(&aux,pc);

      if(debug)printf("\n(#%d)IF: %d\n\n",aux2,aux);
      
      switch(aux){

         case 0:
         /**Transferencia controlo*/
            instr_controlo(&pc);
         break;

         case 1:
         /**Constantes TIPO I*/
            instr_constantes(pc,aux);
         break;

         case 2:
         /**ALU & Memoria*/
            alu(mem[pc]);
         break;

         case 3:
         /**Constantes TIPO II*/
            instr_constantes(pc,aux);
         break;

         default:
            printf("ERRO: Operacao desconhecida!\n");
            exit(EXIT_FAILURE);
            break;
      }
      
      if(!flag[JUMP]) pc++;/**tem que sair*/
      else flag[JUMP]=FALSE;
   }
   printf("\n");
   printf("Programa Terminou.\n\n");
   printf("Registos------------------------------------------\n\n");
   printf("R0:%06d\nR1:%06d\nR2:%06d\nR3:%06d\nR4:%06d\nR5:%06d\nR6:%06d\nR7:%06d\n",reg[0],reg[1],reg[2],reg[3],reg[4],reg[5],reg[6],reg[7]);
   printf("\nFim: Registos-------------------------------------\n\n");

   printf("Flags---------------------------------------------\n\n");
   printf("ZERO:%d\nCARRY:%d\nOVERFLOW:%d\nSINAL:%d\n",flag[ZERO],flag[CARRY],flag[OVERFLOW],flag[SINAL]);
   printf("\nFim: Flags----------------------------------------\n\n");
   
   printf("Memoria-------------------------------------------\n\n");
   for(conta=0;conta!=hmaddr+1;conta++)
   {
      printf("(Linha %05d) %06d | %x\n",conta, mem[conta],mem[conta]);
   }
   
   printf("\nFim: Memoria--------------------------------------\n\n");

   printf("Numero total de ciclos: %d\n\n",ciclos);

   printf("Simulacao Terminada\n");
   
   return 0;
}
