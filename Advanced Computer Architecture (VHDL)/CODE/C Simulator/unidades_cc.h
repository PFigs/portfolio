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
#ifdef _UNIDADES_CC_H_

#else

#define _UNIDADES_CC_H_
#define GET_15_14 0xC000
#define GET_13_12 0x3000
#define GET_13_11 0x3800
#define GET_11_8 0x0F00
#define GET_11_0 0x0FFF
#define GET_11 0x0800
#define GET_10 0x0400
#define GET_7 0x0080
#define GET_7_0 0x00FF
#define GET_2_0 0x0007
#define GET_10_0 0x07FF
#define SHIFT_15_14 14
#define SHIFT_13_12 12
#define SHIFT_13_11 11
#define SHIFT_11_8 8
#define FILL_15_11 0xF800
#define FILL_15_8 0xFF00

#define COND_NEG 4
#define COND_ZERO 5
#define COND_CARRY 6
#define COND_NEGZERO 7
#define COND_TRUE 0
#define COND_OVERFLOW 3



void identifica_instr(short int *id, unsigned short int pos);
void instr_constantes(unsigned short int pos, unsigned short int tipo1);
void instr_controlo(unsigned short int *pc);
void parse_cond(short int cond, short int status,unsigned short int *pc);

#endif
