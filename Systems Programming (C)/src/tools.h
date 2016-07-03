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

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <arpa/inet.h>
#include <netdb.h>
#include <unistd.h>
#include <signal.h>
#include <curses.h>
#include <pthread.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>


#define NGM 1
#define STR 2
#define NSH 3
#define MOV 4
#define EOG 5
#define CNT 6
#define EXT 7
#define VAL 8
#define BDR 9
#define SHD 10
#define REL 11
#define BLT 12
#define BRK 13
#define IGN 14
#define WRK 15


#define NSERVER 0
#define NGAME 1
#define NP1 2
#define PID 3

#define SMALL_BUFF 10
#define MAX_BUFF 100
#define MAX_CMD 20
#define GIG_BUFF 200
#define MAX_FIELD 50

#define READ 0
#define WRITE 1

char **guarda_nomes(char **nomes, char **argv);
void erro(unsigned short int num);
char *copia_nome(char *fonte, char *destino);
short int valida_porto(int aux);
int valida_argumentos(int argc, char** argv, int *porto, char **fich, _Bool server);
void activa_sinais(void);
void tratamento(int num);
int converte_id(char *id);
void unlock(pthread_mutex_t *porta);

void lock(pthread_mutex_t *porta);
