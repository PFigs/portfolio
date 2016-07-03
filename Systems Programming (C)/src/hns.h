#include <stdlib.h>
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/wait.h>
#include <unistd.h>
#include <string.h>
#include <strings.h>
#include <ctype.h>
#include <pthread.h>
#include <netinet/in.h>
#include <netdb.h>
#include <time.h>
#include <fcntl.h>
#include <signal.h>
#include <stdio_ext.h>
#include <time.h>

#define max(A,B) ((A)>=(B)?(A):(B))

#define READ 0
#define WRITE 1

/*Tamanho da String Para guardar Nomes*/
#define NOME 40

/*Tamanho da string de buffer dos ficheiros*/
#define STRI 60

/*Comprimento maximo de digitos das dificuldades -1*/
#define VALOR 10

/*Comprimento do Vector que guarda os endereços*/
#define ENDR 12

enum menu { NAO, SIM };
enum modos {ok, ja_existe, nao_existe, arena_em_jogo, sem_index};

/*Estrutura de Dados das Instancias*/
typedef struct{
    pthread_mutex_t bloq_arena;
    char nome[NOME];
    struct jogador *jogador_esq;
    struct jogador *jogador_drt;
    struct arena *arena_next;
    struct arena *arena_forward;
    struct tm *hora_local;
    pid_t pid_jogo;
    _Bool elimin;
}arena;

/*Estrutura de Dados dos Jogadores*/
typedef struct{
    pthread_mutex_t bloq_jogador;
    pthread_mutex_t espera_end;
    struct jogador *jogador_next;
    struct jogador *jogador_forward;
    struct arena *my_arena;
    char nome[NOME];
    char ip[16];
    unsigned int porto;
    char apont_hof[ENDR];
    int connsock;
}jogador;

/*Estrutura de Dados dos Jogadores Nos processos Instancias*/
typedef struct {
    unsigned short int balas;
    char apont_hof[ENDR];
}player;

/*Estrutura de Dados dos Jogadores no Hall of Fame*/
typedef struct {
    pthread_mutex_t bloq_jog;
    char apont_serv[ENDR];
    unsigned int victorias;
    unsigned int desafios;
    char nome[NOME];
    char ip[16];
    _Bool activo;
}hall_of;

/*Estrutura de Dados do Multi-Thread*/
typedef struct {
    pthread_t grupo_thd[8];
    struct mult_thread *next;
}mult_thread;

/*Estrutura de Dados para enviar as variáveis para as threads*/
typedef struct {
	pthread_mutex_t bloq_top;
	pthread_mutex_t bloq_read;
	pthread_mutex_t bloq_disp;
	pthread_mutex_t all_full;
	pthread_mutex_t ficheiro;
	unsigned short int disponiveis;
	hall_of* top[11];
	_Bool saida;
}arg_thrd;

void menu_servidor();
void error(char *msg);
void tratamento_sinais(int sigNumb);
void aceitar_sinais();
void espaco(short int x);
unsigned short int copiac(char *origem, char destino[], char caracter);
void obter_dificuldades(char *file_pontos);
unsigned short int trata_NGM(char *inst, char *jog, int connsock, int porto, char* IP);
void inicia_index();
void inicia_hof(pid_t *pid_hof);
unsigned short int compara(char *s1, char *s2, char c1);
void copiasubs(char *s1, char *s2, char c2, char c1);
void guarda_end(char * end_estr, char * end_hof);
void muti_thread(pid_t *pid_hof);
unsigned short int mostra_desafio(char *inst);
unsigned short int lista_desafios();
void eliminar(char *apontador);
void *interface();
void *preenche();
void dar_pontos(char *nome);
