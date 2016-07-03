/*************************************************
 *    Arquitecturas Avançadas de Computadores
 *             2º Semestre - 2009/2010
 * 
 *    Projecto: I Fase - Simulação Funcional
 * 
 *    Alexander (58958)
 *    Pedro Silva (58035)
 * ***********************************************
 * Registos:
 * R0 - Endereço
 * R1 - Valor decimal da instrucao
 * 
 * NOTAS:
 * 16 bits
 * 8 registos
 * 42 operações
 * 3 operandos
 * big endian!
 * 
 * 
 * BUGS:
 * Se stack !unsigned , valores guardados ficam negativos
 * 
 * */
#ifdef _MAIN_H_
#else
#define _MAIN_H_

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <errno.h>
#include <unistd.h>
#include <limits.h>
#include <errno.h>
#include <ctype.h>


#define BUFSIZE 10
#define DEFAULT_ADDR 0

#define ZERO 0
#define SINAL 1
#define CARRY 2
#define OVERFLOW 3
#define JUMP 4
#define HALT 5

#define FALSE 0
#define TRUE !(FALSE)

#endif

