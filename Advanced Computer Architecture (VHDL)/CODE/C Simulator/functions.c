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
extern _Bool debug;

/**c=a+b*/
void add_f(short int wc, short int ra, short int rb){
 
   extern short int reg[];
   extern _Bool flag[];
   int c=0;
   short int a,b;
   short unsigned int aux;
   short unsigned int aux1;

   aux=reg[ra];
   aux1=reg[rb];
   
   a=reg[ra];
   b=reg[rb];

   
   c=(aux+aux1);
   c=c&65536;
   
   reg[wc]=reg[ra]+reg[rb];
   
      
   if(reg[wc]==0x0000)
     flag[ZERO]=true;
   if(reg[wc]<0)
     flag[SINAL]=true;
   
  if((((reg[wc])<0)&&(a>0)&&(b>0))||(((reg[wc])>0)&&(a<0)&&(b<0)))
     flag[OVERFLOW]=true;
  if(c==65536)
     flag[CARRY]=true;
  if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d\n", __FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY]);
}

/**c=a+b+1*/
void addinc_f(short int wc, short int ra, short int rb){
  

   extern short int reg[];
   extern _Bool flag[];
   int c=0;
   short int a,b;
   short unsigned int aux;
   short unsigned int aux1;

   aux=reg[ra];
   aux1=reg[rb];
   
   a=reg[ra];
   b=reg[rb];

   
   c=(aux+aux1+1);
   c=c&65536;
   
   reg[wc]=reg[ra]+reg[rb]+1;

   if(reg[wc]==0x0000)
     flag[ZERO]=true;
   if(reg[wc]<0)
     flag[SINAL]=true;
   
  if((((reg[wc])<0)&&(a>0)&&(b>0))||(((reg[wc])>0)&&(a<0)&&(b<0)))
     flag[OVERFLOW]=true;
  if(c==65536)
     flag[CARRY]=true;
  if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n", __FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
  
}


/**c=a+1*/
void inca_f(short int wc, short int ra, short int rb){
   extern short int reg[];
   extern _Bool flag[];
   unsigned int c=0;
   short int a;
   short unsigned int aux;

   aux=reg[ra];
   
   a=reg[ra];

   
   c=(aux+1);
   c&=65536;
   reg[wc]=reg[ra]+1;

   
   if(reg[wc]==0x0000)
     flag[ZERO]=true;
   
   if(reg[wc]<0)
     flag[SINAL]=true;

   if((reg[wc]<0&&a>0))
     flag[OVERFLOW]=TRUE;

   if(c==65536)
     flag[CARRY]=TRUE;

   if(debug)printf("%s\nWC=%d\nRA=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


/**c=a-b-1*/
void subdec_f(short int wc, short int ra, short int rb){
  
   extern short int reg[];
   extern _Bool flag[];
   int c=0;
   short int a,b;
   short unsigned int aux;
   short unsigned int aux1;

   aux=reg[ra];
   aux1=reg[rb];
      
   a=reg[ra];
   b=reg[rb];

   c=(aux-aux1-1);
   c=c&65536;
   reg[wc]=reg[ra]-reg[rb]-1;
   if(reg[wc]==0x0000)
     flag[ZERO]=true;
   
   if(reg[wc]<0)
     flag[SINAL]=true;

   if((((reg[wc])>0)&&(a<0)&&(b>0))||(((reg[wc])<0)&&(a>0)&&(b<0)))
     flag[OVERFLOW]=true;
   if(c==65536)
     flag[CARRY]=true;
   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n", __FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


/**c=a-b*/
void sub_f(short int wc, short int ra, short int rb){
  
   extern short int reg[];
   extern _Bool flag[];
   int c=0;
   short int a,b;
   short unsigned int aux;
   short unsigned int aux1;

   aux=reg[ra];
   aux1=reg[rb];
   
   a=reg[ra];
   b=reg[rb];

   c=(aux-aux1);
   c=c&65536;   
   reg[wc]=reg[ra]-reg[rb];   

   if(reg[wc]==0x0000)
     flag[ZERO]=true;
   if(reg[wc]<0)
     flag[SINAL]=true;
   if((((reg[wc])>0)&&(a<0)&&(b>0))||(((reg[wc])<0)&&(a>0)&&(b<0)))
     flag[OVERFLOW]=true;
   if(c==65536)
     flag[CARRY]=true;

   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);

}


/**c=a-1*/
void deca_f(short int wc, short int ra, short int rb){
  
   extern short int reg[];
   extern _Bool flag[];
   int c=0;
   short int a;
   short unsigned int aux;

   aux=reg[ra];
   
   a=reg[ra];
   
   c=(aux-1);

   c=c&65536;   

   reg[wc]=reg[ra]-1;  

   if(reg[wc]==0x0000)
     flag[ZERO]=true;
   if(reg[wc]<0)
     flag[SINAL]=true;

   /**Perguntar*/
   if(((reg[wc]>0)&&(a<0)))
     flag[OVERFLOW]=true;
   if(c==65536)
     flag[CARRY]=true;
   if(debug)printf("%s\nWC=%d\nRA=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra], flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


/**Shift logico esq. Perguntar*/
void lsl_f(short int wc, short int ra, short int rb){
 
   extern short int reg[];
   extern _Bool flag[];
   short unsigned int c=0;
   short int a,b;
   
   a=reg[ra];
   b=reg[rb];

   c=reg[ra]&0x00008000;

   reg[wc]=reg[ra]<<1;
   
   if(reg[wc]==0x0000)
     flag[ZERO]=true;
     
   if(reg[wc]<0)
     flag[SINAL]=true;

   if(c==32768)
     flag[CARRY]=true;

   if(debug)printf("%s:Shift Logico Esquerda\nWC=%d\nRA=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra], flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


/**Shift Aritm dir.*/
void asr_f(short int wc, short int ra, short int rb){
  
   extern short int reg[];
   extern _Bool flag[];
   short unsigned int aux=32768;
   short int c=0;
     
   aux=aux&reg[ra];
   
   c=reg[ra]&1;
   reg[wc]=(reg[ra]>>1)|aux;

   if(reg[wc]==0x0000)
     flag[ZERO]=true;
   if(reg[wc]<0)
     flag[SINAL]=true;
  if(c==1)
     flag[CARRY]=true;
  if(debug)printf("%s:Shift Aritmetico Direita\nWC=%d\nRA=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra], flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


/**Zeros c=0*/
void zeros_f(short int wc, short int ra, short int rb){
  
   extern short int reg[];
   extern _Bool flag[];
   
   reg[wc]=reg[wc]&0x0000;
   if(debug)printf("%s\nWC=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);

}
   
/**c=(a)and(b)*/
void and_f(short int wc, short int ra, short int rb){
  
   extern short int reg[];
   extern _Bool flag[];
   
   reg[wc]=reg[ra]&reg[rb];   
   
   if(reg[wc]==0x0000)
     flag[ZERO]=true;
   if(reg[wc]<0)
     flag[SINAL]=true;

   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}

   /**c=(not(a))and(b)*/
void andnota_f(short int wc, short int ra, short int rb){
  

   extern short int reg[];
   extern _Bool flag[];
   
   reg[wc]=(~reg[ra])&reg[rb];

   if(reg[wc]==0x0000)
     flag[ZERO]=true;
   if(reg[wc]<0)
     flag[SINAL]=true;
   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}

   /**C=B, no flags*/
void passb_f(short int wc, short int ra, short int rb){
  

   extern short int reg[];
   extern _Bool flag[];
   
   reg[wc]=reg[rb];
   if(debug)printf("%s\nWC=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


void andnotb_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];
   
   reg[wc]=(reg[ra] & (~reg[rb]));
   if(reg[wc]==0) flag[ZERO]=TRUE;
   if(reg[wc]<0) flag[SINAL]=TRUE;
if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}

void passa_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];
   
   reg[wc]=reg[ra];
   if(reg[wc]==0)flag[ZERO]=TRUE;
   if(reg[wc]<0)flag[SINAL]=TRUE;
   if(debug)printf("%s\nWC=%d\nRA=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


void xor_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];
   
   reg[wc]=reg[ra] ^ reg[rb];
   if(reg[wc]==0)flag[ZERO]=TRUE;
   if(reg[wc]<0)flag[SINAL]=TRUE;
   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


void or_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];

   reg[wc]=reg[ra] | reg[rb];
   
   if(reg[wc]==0)flag[ZERO]=TRUE;

   if(reg[wc]<0)flag[SINAL]=TRUE;

   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


void nor_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];

   reg[wc]=(~reg[ra]) & (~reg[rb]);
   if(reg[wc]==0)flag[ZERO]=TRUE;
   if(reg[wc]<0)flag[SINAL]=TRUE;
   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


void xnor_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];

   reg[wc]=~(reg[ra] ^ reg[rb]);
   if(reg[wc]==0)flag[ZERO]=TRUE;
   if(reg[wc]<0)flag[SINAL]=TRUE;
   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


void passnota_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];

   reg[wc]=~reg[ra];
   if(reg[wc]==0)flag[ZERO]=TRUE;
   if(reg[wc]<0)flag[SINAL]=TRUE;
   if(debug)printf("%s\nWC=%d\nRA=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}



void ornota_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];

   reg[wc]=(~reg[ra]) | reg[rb];
   if(reg[wc]==0)flag[ZERO]=TRUE;
   if(reg[wc]<0)flag[SINAL]=TRUE;
   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}



void passnotb_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];

   reg[wc]=~reg[rb];
   if(reg[wc]==0)flag[ZERO]=TRUE;
   if(reg[wc]<0)flag[SINAL]=TRUE;
   if(debug)printf("%s\nWC=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


void ornotb_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];

   reg[wc]= reg[ra] | (~reg[rb]);
   if(reg[wc]==0)flag[ZERO]=TRUE;
   if(reg[wc]<0)flag[SINAL]=TRUE;
   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


void nand_f(short int wc, short int ra, short int rb){

   extern short int reg[];
   extern _Bool flag[];

   reg[wc]=(~reg[ra]) | (~reg[rb]);
   if(reg[wc]==0)flag[ZERO]=TRUE;
   if(reg[wc]<0)flag[SINAL]=TRUE;
   if(debug)printf("%s\nWC=%d\nRA=%d\nRB=%d\n[ZERO]=%d [SINAL]=%d [OVERFLOW]=%d [CARRY]=%d (%s:%d)\n",__FUNCTION__,reg[wc], reg[ra],reg[rb],flag[ZERO],flag[SINAL],flag[OVERFLOW],flag[CARRY],__FILE__,__LINE__);
}


void ones_f(short int wc, short int ra, short int rb){

   extern short int reg[];

   reg[wc]=1;

   if(debug)printf("%s\nWC=%d (%s:%d)\n",__FUNCTION__,reg[wc],__FILE__,__LINE__);
}



