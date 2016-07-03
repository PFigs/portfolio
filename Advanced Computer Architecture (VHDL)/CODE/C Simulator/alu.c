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
#include "unidades_cc.h"
#include "functions.h"
#include "alu.h"

extern _Bool debug;

/*Função que recebe uma instrução do tipo ALU e devolve um vector de 4 elementos hexadecimais [WC|OP|RA|RB]*/
void alu(unsigned short int arg){

   extern _Bool flag[];
   extern short int reg[8]; /**8 Registos 16 bits */
   extern short int mem[16384]; /**Memoria*/
   extern unsigned short int hmaddr;

   short int wc;
   short int op;
   short int ra;
   short int rb;

   flag[ZERO]=FALSE;
   flag[SINAL]=FALSE;
   flag[CARRY]=FALSE;
   flag[OVERFLOW]=FALSE;
   
   /**WC*/
   wc=arg;
   wc=wc&GET_13_11;
   wc=wc>>SHIFT_13_11;
    
   /**OP*/
   op = arg;
   op=op&GET_10_6;
   op = op>>SHIFT_10_6;
    
   /**RA*/
   ra=arg;
   ra=ra&GET_5_3;
   ra=ra>>SHIFT_5_3;
    
   /**RB*/
   rb=arg;
   rb=rb&GET_2_0;

   if(debug)printf("IN:ALU\nOP: %d\nWC: %d\nRa: %d\nRb: %d\n--------\n",op,wc,ra,rb);
    
   switch(op){
     
  /**Ruxinho*/     
     case ADD:
         add_f(wc,ra,rb);
         break;

     case ADDINC:
         addinc_f(wc,ra,rb);
         break;

     case INCA:
         inca_f(wc,ra,rb);         
         break;

     case SUBDEC:
         subdec_f(wc,ra,rb);
         break;

     case SUB:
         sub_f(wc,ra,rb);
         break;
  
     case  DECA:
         deca_f(wc,ra,rb);
         break;
  
     case LSL:
         lsl_f(wc,ra,rb);
         break;
  
     case ASR:
         asr_f(wc,ra,rb);
         break;
  
     case ZEROS:
         zeros_f(wc,ra,rb);
         break;
  
     case AND:
         and_f(wc,ra,rb);
         break;
  
     case ANDNOTA:
         andnota_f(wc,ra,rb);
         break;

     case PASSB:
         passb_f(wc,ra,rb);
         break;
  /**Xilva*/
      case ANDNOTB:
         andnotb_f(wc,ra,rb);
         break;

      case PASSA:
         passa_f(wc,ra,rb);
         break;

      case XOR:
         xor_f(wc,ra,rb);
         break;

      case OR:
         or_f(wc,ra,rb);
         break;

      case NOR:
         nor_f(wc,ra,rb);
         break;

      case XNOR:
         xnor_f(wc,ra,rb);
         break;

      case PASSNOTA:
         passnota_f(wc,ra,rb);
         break;

      case ORNOTA:
         ornota_f(wc,ra,rb);
         break;

      case PASSNOTB:
         passnotb_f(wc,ra,rb);
         break;

      case ORNOTB:
         ornotb_f(wc,ra,rb);
         break;

      case NAND:
         nand_f(wc,ra,rb);
         break;

      case ONES:
         ones_f(wc,ra,rb);
         break;
         
         
/**MEMORIA*/
      case C_MEMA:
         reg[wc]= mem[(unsigned int)reg[ra]];
         if(debug)printf("Load: C=MEM[A]\nC: %d\tA: %d\n",reg[wc],reg[ra]);
         /*  if(reg[wc]<0)reg[wc]*=-1;*/
         break;
         
      case MEMA_B:
         mem[(unsigned short int)reg[ra]] = reg[rb];
         if(debug)printf("Store: MEM[A]=B\nA: %d\tB: %d\n",mem[(unsigned short int) reg[ra]],reg[rb]);
         if(hmaddr<reg[ra]) hmaddr=reg[ra];
         
         break;          

      default:
         printf("Instrucao Ignorada!\n");
         break;
    }
}


