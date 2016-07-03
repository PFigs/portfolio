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
#define TOPOFFSET 5

#define NROWS 24
#define NCOLS 80

#define MAXBULLETS 6
#define DRAW 0
#define NODRAW -1
#define EMPATE 10


#define COWBOY_WIDTH 4
#define COWBOY_HEIGHT 5

#define LEFT  0
#define RIGHT 1

#define NAMELEN 20


typedef struct
{
  char name[NAMELEN];
  char id[3];
  int bulletsleft;
  int games;
  int x, y;
  int fires;
  int sfd;

} CowboyData;

typedef struct
{
  int empty;
  int x, y;
} BulletData;



void lanca_jogo(char **nomes, int *fd);

void inicia_mutex(void);

void inicia_lado(char **nomes, _Bool *side);

void boas_vindas(int side,int start);

void com_partida(int side);






void draw_heading(char *game, char* ln, int lb, int lg, char* rn, int rb, int rg, int code);

void close_HN_window();

void delete_cowboy(int side);

void draw_cowboy(int side);

void move_cowboy_up(char **nomes, int side, int *sock);

void move_cowboy_down(char **nomes, int side, int *sock);

void fire_bullet(char **nomes, int side, int *sock);

void move_bullets();

int check_dead(int side);

void inicia_saida(char *id_jogador, int *fd, int side);


int modifica_janela(char **campos, int side, int codigo);

void inicia_jogadas(char **nomes, int side);



void teclado(char **nomes, int side);



void *th_jogadas(void *arg);
