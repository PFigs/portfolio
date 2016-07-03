/*************************************************
 *    Arquitecturas Avançadas de Computadores
 *             2º Semestre - 2009/2010
 * 
 *    Projecto: I Fase - Simulação Funcional
 * 
 *    Alexander (58958)
 *    Pedro Silva (58035)
 * ***********************************************
 **/

#include "main.h"
#include "unidades_cc.h"

extern _Bool debug;

/*
 *@name identifica_instr
 *@filename load.c
 *@brief Identifica o tipo de instrucao.
 *@param[out] id O decimal que representa o tipo.
 *@param[in] pos Primeira posicao de memoria a ler.
 *
 **/
void identifica_instr(short int *id, unsigned short int pos){

   extern short int mem[];
   
   *id = mem[pos] & GET_15_14;
   
   *id >>= SHIFT_15_14 ;

   *id &= 0x0003;

} 

/*
 *@name instr_constantes
 *@filename load.c
 *@brief Descodifica as instrucoes referentes a constantes.
 *@param[in] pos Posicao de memoria com instrucao.
 *@param[in] tipo1 Formato da instrucao.
 **/
void instr_constantes(unsigned short int pos, unsigned short int tipo1){

   extern short int mem[];
   extern short int reg[];
   short int aux;
   short int aux2;
   
   if(tipo1==1){
      /**Obtem registo WC*/
      aux = mem[pos] & GET_13_11;

      /**Desloca os bits*/
      aux >>= SHIFT_13_11;

      /**Guarda no registo WC a constante de 11bits*/
      reg[aux] = mem[pos] & GET_10_0;
      /**Efectua a extensão do bit sinal*/
      if((reg[aux]&GET_10)==GET_10)
         reg[aux]|=FILL_15_11;

      if(debug)printf("Constantes Tipo I\nWC=Constante\nWC: %d\nConstante: %d\n",aux,reg[aux]);
   }else{
      if(debug)printf("Instrucao LCL: C = Const8 | (C & 0xff00)\n");
      /**Obtem registo WC*/
      aux = mem[pos] & GET_13_11;
      
      /**Desloca os bits*/
      aux >>= 11;

      /**Verifica 10o bit - lcl(0) ou lch(1)*/
      if((mem[pos] & GET_10) != GET_10){
         /**Instrucao lcl (0)*/
         aux2 = mem[pos] & GET_7_0;
         if(debug) printf("Ct8: %d\n",aux2);
         /*if((aux2&GET_7)==GET_7)
            aux2|=FILL_15_8;
         */
         
   /**Efectua um or com and de 0xFF00*/
         if(debug) printf("C: %d\n",reg[aux]);
         reg[aux] = aux2 | (reg[aux] & 0xFF00);
         if(debug) printf("C = %d\n",reg[aux]);

         
      }else{
         /**Instrucao lch(1)*/
         if(debug)printf("Instrucao LCH: C = (Const8 << 8) | (C & 0x00ff)\n");
         aux2 = mem[pos] & GET_7_0;
         if(debug) printf("Ct8: %d\n",aux2);
         /**Efectua extensao bit sinal
         if((reg[aux]&GET_7)==GET_7)
            reg[aux]|=FILL_15_8;*/
        
         aux2 <<= 8;
         if(debug) printf("<<Ct8: %d\nC: %d\n",aux2,reg[aux]);
         reg[aux] = aux2 | (reg[aux] & 0x00FF);
         if(debug) printf("C=%d\n",reg[aux]);
      }
   }

}


/*
 *@name instr_controlo
 *@filename load.c
 *@brief Descodifica as instrucoes referentes a transferencia de controlo.
 *@param[in] pc Endereco para program counter.
 *@param[in] pos Posicao de memoria com instrucao.
 **/
void instr_controlo(unsigned short int *pc){

   extern short int mem[];
   extern short int reg[];
   extern _Bool flag[];
   short int aux;
   short int aux2;
   short int sinal;
   
   /**Obtem Operacao*/
   aux = mem[*pc] & GET_13_12;
   aux >>= SHIFT_13_12;
   if(debug)printf("CONTROLO\nOperacao: %d\n",aux);

   /**Efectuar um switch ao aux*/
   switch(aux){
      case 0:
      case 1:
         /*Tipo I*/
         aux2 = mem[*pc] & GET_11_8; /*obtem COND*/
         aux2 >>= SHIFT_11_8;
         /** Se verificar flags com condicao flag[JUMP]=TRUE;*/
         if(debug) printf("Salto Condicional\nCondicao: %d (%s:%d)\n",aux2,__FILE__, __LINE__);
         parse_cond(aux2,aux,pc);
         break;
         
      case 2:
         /*Tipo II*/
         /**Offset*/
         aux2=(short int)(mem[*pc] & GET_11_0);
         sinal = aux2 & GET_11;
         sinal>>=11;
         if((sinal)==1)
            aux2=aux2|0xF000;
         
         /**Soma Offset*/
         aux2 = *pc + 1 + aux2;
         if(*pc != aux2){
            *pc = aux2;
            flag[JUMP]=TRUE;
            if(debug)printf("Controlo TIPO II\nJUMP INCONDICIONAL\nPC=%d\n",*pc);
         }else{
            flag[HALT]=TRUE;
            if(debug)printf("Controlo TIPO II\nTerminar Programa!\n");
         }
            
         break;
      case 3:
         /*Tipo III*/
         if((mem[*pc] & GET_11) == GET_11){
            /**Jump Register*/
            *pc=reg[mem[*pc] & GET_2_0]; /*Armazena conteudo de RB em PC*/
            flag[JUMP]=TRUE;
            if(debug)printf("Controlo TIPO III\nJUMP REGISTER\nPC=%d\n",*pc);
         }else{
           /**Jump and Link*/
            reg[7]= *pc+1;
            *pc=reg[mem[*pc] & GET_2_0]; /*Armazena conteudo de RB em PC*/
            flag[JUMP]=TRUE;
            if(debug)printf("Controlo TIPO III\nJUMP REGISTER\nREG[7]=%d\nPC=%d\n",reg[7],*pc);
         }
         break;

   }

}



void parse_cond(short int cond, short int status,unsigned short int *pc){

   extern short int mem[];
   extern _Bool flag[];
   short int aux;
   
   aux = mem[*pc] & GET_7_0;
   
   if((aux & 0x0080)==0x0080)
      aux|=0xFF00;

   if(debug) printf("FLAGS -> [SINAL]:%d  [ZERO]:%d [CARRY]:%d  [OVERFLOW]:%d\n",flag[SINAL],flag[ZERO],flag[CARRY],flag[OVERFLOW]);
   
   switch(cond){
      case COND_CARRY:
         if(flag[CARRY]==status){
            *pc = *pc+1+aux;
            flag[JUMP]=TRUE;
            if(debug) printf("Jump Taken!\n");
         }
         if(debug)printf("Salto Condicional c/ Carry\nEstado: %d\nPC if taken: %d (%s:%d)\n",status,*pc,__FILE__,__LINE__);
      break;

      case COND_NEG:
         if(flag[SINAL]==status){
            *pc = *pc+1+aux;
            flag[JUMP]=TRUE;
            if(debug) printf("Jump Taken!\n");
         }
         if(debug)printf("Salto Condicional c/ Sinal\nEstado: %d\nPC if taken: %d (%s:%d)\n",status,*pc,__FILE__,__LINE__);
      break;

      case COND_NEGZERO:
         if(flag[SINAL]==status || flag[ZERO]==status){
            *pc = *pc+1+aux;
            flag[JUMP]=TRUE;
            if(debug) printf("Jump Taken!\n");
         }
         if(debug)printf("Salto Condicional c/ <= Zero\nEstado: %d\nPC if taken: %d (%s:%d)\n",status,*pc,__FILE__,__LINE__);
      break;

      case COND_OVERFLOW:
         if(flag[OVERFLOW]==status){
            *pc = *pc+1+aux;
            flag[JUMP]=TRUE;
            if(debug) printf("Jump Taken!\n");
         }
         if(debug)printf("Salto Condicional c/ Overflow\nEstado: %d\nPC if taken: %d (%s:%d)\n",status,*pc,__FILE__,__LINE__);
      break;

      case COND_TRUE:
         /**NOP**/
         if(debug)printf("NOP\n");
      break;

      case COND_ZERO:
         if(flag[ZERO]==status){
            *pc = *pc+1+aux;
            flag[JUMP]=TRUE;
            if(debug) printf("Jump Taken!\n");
         }
         if(debug)printf("Salto Condicional c/ Zero\nEstado: %d\nPC if taken: %d (%s:%d)\n",status,*pc,__FILE__,__LINE__);
      break;

      default:
         printf("Operacao Controlo Desonhecida! (%s:%d)\n",__FILE__,__LINE__);
      break;


   }



}
