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
#ifdef _ALU_H_
#else
#define _ALU_H_
#define GET_10_6 0x07C0
#define SHIFT_10_6 0x0006

#define GET_5_3 0x0038
#define SHIFT_5_3 0x0003

#define ADD 0 
#define ADDINC 1
#define INCA 3
#define SUBDEC 4
#define SUB 5
#define DECA 6
#define LSL 8
#define ASR 9
#define ZEROS 16
#define AND 17
#define ANDNOTA 18
#define PASSB 19
#define ANDNOTB 20
#define PASSA 21
#define XOR 22
#define OR 23
#define NOR 24
#define XNOR 25
#define PASSNOTA 26
#define ORNOTA 27
#define PASSNOTB 28
#define ORNOTB 29
#define NAND 30
#define ONES 31

#define LOAD 10
#define STORE 11

#define C_MEMA 0x000A
#define MEMA_B 0x000B


void alu(unsigned short int arg);

#endif
