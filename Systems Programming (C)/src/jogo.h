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



#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

#define NROWS 24
#define NCOLS 80

#define FIFO 50

#define JOGO 0
#define P1 1
#define P2 2
#define FD_P1 3
#define FD_P2 4
#define FD_HOF 5
#define PTR_P1 6
#define PTR_P2 7
#define DEBUG 8
#define MINTCWAIT 9
#define MINTBWAIT 10
#define MAXNFIRED 11
#define MINTSHOOT 12

#define UP_SELF 1
#define DOWN_SELF 2
#define UP_OTHER 3
#define DOWN_OTHER 4

#define TOPOFFSET 5

#define MAXBULLETS 6

#define COWBOY_WIDTH 4
#define COWBOY_HEIGHT 5

#define LEFT  0
#define RIGHT 1

#define NAMELEN 20


typedef struct{
   char *name;
   char *init;
   int sfd;
   int bulletsleft;
   int games;

   int x, y;

   _Bool morto;
   _Bool mov_up, mov_down;

} profile;


typedef struct{

  int empty;
  int x, y;

} BulletData;


typedef struct{

   char *name;

   char *ptr_p1;
   char *ptr_p2;
   int nr_jogos;
   int mintbwait;
   int mintshoot;
   int mintcwait;
   int maxnfired;
   int pthof;

} details;

int responde_movimento(char *p1_msg, char *p2_msg, int geral, int side);

void guarda_argumentos(char **argv);

char **efectua_leitura(char **fields, int fd, int *code);
char **gere_campos(char *id, char **fields, int fd, int *code);

void trata_jogador(int side);
void *th_init(void *arg);
void *th_movimento(void *arg);
void *th_sinais(void *args);
void *th_bala(void *arg);

void inicia_mutex(void);
void inicia_partida(void);

void regista_movimento(int side, _Bool *mov_pro, _Bool *mov_contra, int id);
int responde(char **msg, int *sock, int code, int side);
int resposta_directa(int *sock, char *buffer);

int move_balas(void);

int check_dead(int side);
void regista_inicio(int side, int start);
void efectua_limpeza(void);
