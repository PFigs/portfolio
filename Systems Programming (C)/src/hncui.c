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


#include <curses.h>
#include <stdlib.h>
#include <assert.h>
#include <time.h>
#include <string.h>

#include "hncui.h"
#include "hnccom.h"
#include "tools.h"

/**GAME*/
static WINDOW *wnd;
static CowboyData cowboys[2];
static BulletData *bullets[2];
static char *nome_jogo;
static int maxbalas;
static int mintcwait;
static int mintbwait;
static int mintshoot;
static int contador;

/**THREADS*/
static pthread_mutex_t actualiza, ecra;
static pthread_t reader;
static _Bool quit;
static _Bool espera;

/**DEBUG*/
extern _Bool debug;


/*http://tldp.org/HOWTO/NCURSES-Programming-HOWTO/index.html*/


void lanca_jogo(char **nomes, int *fd)
{
   _Bool side;

   espera=FALSE;

   lock(&actualiza);
   /**Verifica o lado em jogo e preenche o id do jogador*/
   if(debug)printf("A verificar lado\n");
   inicia_lado(nomes, &side);

   if(pthread_create(&reader, NULL, th_jogadas, (void *)&side)!=0)
   {
      printf("ERRO: Falha a lancar thread jogadas!\n");
      exit(EXIT_FAILURE);
   }

   nome_jogo=(char *)calloc(strlen(nomes[NGAME]),sizeof(char));

   strcpy(nome_jogo,nomes[NGAME]);

   if(debug) printf("A DAR INICIO AO JOGO@nome_jogo: %s\n",nome_jogo);

   inicia_mutex();

   memset((void*)cowboys[LEFT].name,(int)'\0',sizeof(cowboys[LEFT].name));
   memset((void*)cowboys[RIGHT].name,(int)'\0',sizeof(cowboys[RIGHT].name));

   if(side == LEFT)
      strncpy(cowboys[LEFT].name,nomes[NP1],strlen(nomes[NP1])%(NAMELEN-1));
   else
      strncpy(cowboys[RIGHT].name,nomes[NP1],strlen(nomes[NP1])%(NAMELEN-1));

   cowboys[side].sfd=*fd;

   unlock(&actualiza);

   while(!espera);


   teclado(nomes,side);

   pthread_join(reader,NULL);

}



/**FUNCOES PRINCIPAIS**/

/*
 * Descobre qual o lado do jogador e preenche alguns detalhes no seu profile
 *
 * name: inicia_lado
 * @param
 *    Nomes e side
 * @return
 *    Nada
 */
void inicia_lado(char **nomes, _Bool *side)
{
   if(nomes[PID][1]=='1')
   {
      *side=LEFT;
   }
   else
      if(nomes[PID][1]=='2')
         *side=RIGHT;
      else
      {
         printf("ERRO: Identificador de jogador incorrecto!\n");
         exit(EXIT_FAILURE);
      }

   if(debug) printf("Sou (%s) jogador P%d\n",nomes[1],(int)(*side+1));

   memset((void*)cowboys[*side].id,(int)'\0',sizeof(cowboys[*side].id));
   strncpy(cowboys[*side].id,nomes[PID],2);
   if(debug) printf("Sou (%s) com ID:%s\n",nomes[1],cowboys[*side].id);

}



/*
 *
 * name: boas_vindas
 * @param
 *    descritor para cliente, lado e nomes
 * @return
 *
 */

void boas_vindas(int side, int start)
{
   int nrows, ncols;

   wnd=initscr();

   cbreak();
   noecho();
   curs_set(0);

   getmaxyx(wnd,nrows,ncols);

   if(nrows>=NROWS && ncols>=NCOLS)
   {
      wresize(wnd,NROWS,NCOLS);
   }
   else
   {
      close_HN_window();
      printf("ERRO: Terminal nao tem dimensao apropriada.\nPor favor verifique o manual.\n");
      exit(EXIT_FAILURE);
   }

   if(start)
   {
      mvwprintw(wnd, 0, 0, "High Noon - Projecto de Programacao de Sistemas");
      mvwprintw(wnd, NROWS/2, NCOLS/2-strlen("Pressione uma tecla para continuar")/2, "Pressione uma tecla para continuar");

      refresh();

      /**Bloqueia no getch*/
      nodelay(wnd, FALSE);

      /**Espera tres minutos!*/
      alarm(180);
      getch();
      alarm(0);
   }


   keypad(stdscr, TRUE);

   /**Estabelecer timeout com um tempo indicado para esperar mensagens do servidor*/
   /*wtimeout(wnd,2);*/

   nodelay(wnd, TRUE);

   clear();

   mvwprintw(wnd, 0, 0, "A esperar confirmacao do adversario...");

   refresh();

   com_partida(side);

   clear();

   refresh();

}


/*
 * Comunica STR ao servidor.
 * Recebe parametros e o jogo inicia.
 *
 * name: com_partida
 * @param
 *    side
 * @return
 *    nada
 */

void com_partida(int side)
{
   char *mensagem=(char*)NULL;
   char **resposta=(char **)NULL;
   int i, codigo;

   /**enviar mensagem de str*/
   mensagem=escreve_mensagens(NULL,NULL,cowboys[side].id,NULL,mensagem,STR);

   /**Envia mensagem*/
   envia_mensagem_cliente(&cowboys[side].sfd, mensagem);

   alarm(180);
   resposta=espera_resposta(&cowboys[side].sfd, resposta, &codigo);
   alarm(0);

   /**Guardar info recebida*/
   cowboys[LEFT].x = atoi(resposta[1]);
   cowboys[LEFT].y = atoi(resposta[2]);

   cowboys[RIGHT].x = atoi(resposta[3]);
   cowboys[RIGHT].y = atoi(resposta[4]);

   cowboys[LEFT].games = atoi(resposta[5]);
   cowboys[RIGHT].games = atoi(resposta[6]);

   cowboys[LEFT].bulletsleft = atoi(resposta[7]);
   cowboys[RIGHT].bulletsleft = atoi(resposta[7]);

   maxbalas = atoi(resposta[7]);

   /**Devo alocar com respeito ao numero de balas que recebo*/
   bullets[0]=(BulletData *)calloc(maxbalas,sizeof(BulletData));
   bullets[1]=(BulletData *)calloc(maxbalas,sizeof(BulletData));

   for( i = 0; i < maxbalas; i++)
   {
      bullets[0][i].empty=TRUE;
      bullets[1][i].empty=TRUE;
   }

   mintcwait=atoi(resposta[8]);

   mintbwait=atoi(resposta[9]);

   mintshoot=atoi(resposta[10]);


   if(side==LEFT)
      strncpy(cowboys[RIGHT].name,resposta[11],strlen(resposta[11])%(NAMELEN-1));
   else
      strncpy(cowboys[LEFT].name,resposta[11],strlen(resposta[11])%(NAMELEN-1));

}




void teclado(char **nomes, int side)
{
   int c;

   /**Contador para respeitar mintshoot**/
   contador=0;

   /**ponderar verificar check dead no servidor*/
   while (!quit)
   {
      /**SE DEAD, espera por confirmacao do servidor(?)*/
      lock(&actualiza);
      lock(&ecra);
      c = getch();
      switch(c)
      {
         case 'w':
         case KEY_UP:
            move_cowboy_up(nomes, side, &cowboys[side].sfd);
            break;

         case 's':
         case KEY_DOWN:
            move_cowboy_down(nomes, side, &cowboys[side].sfd);
            break;

         case ' ':
         /**So envio se tiver balas disponiveis*/
            /**BLOQUEAR ACESSO!*/
            if (cowboys[side].bulletsleft && !contador)
            {
               /**Para se dar inicio à contagem*/
               contador++;
               fire_bullet( nomes, side, &cowboys[side].sfd);
            }
            break;

         case 'q':
            inicia_saida(nomes[PID], &cowboys[side].sfd, side);
            quit = 1;
            break;
         case 'a':

            break;

         break;
      }

      /**Assim que atinge mintshoot para contagem e mantem valor zero*/
      if(contador)
         contador=(contador+1)%mintshoot;

      unlock(&actualiza);
      unlock(&ecra);
   }

}



void inicia_saida(char *pid, int *fd, int side)
{
   char *mensagem=(char *)NULL;

   mensagem=escreve_mensagens( NULL, NULL, pid, NULL, mensagem, EXT);

   envia_mensagem_cliente(fd,mensagem);

}


/**THREAD RELATED**/

/*
 * Inicializa os mutexes existentes
 *
 * name: inicia_mutex
 * @param
 *    sem parametros
 * @return
 *    sem retorno
 */

void inicia_mutex(void)
{
   pthread_mutex_init(&actualiza,NULL);
   pthread_mutex_init(&ecra,NULL);
}


/*
 * thread responsavel por receer dados e alterar o terminal
 *
 * name: th_jogadas
 * @param
 *    lado do jogador
 * @return
 *    sem retorno
 */

void *th_jogadas(void *arg)
{
   _Bool side = *(_Bool *)arg;
   int codigo=DRAW;
   char **resposta;
   char temp1[SMALL_BUFF];
   char temp2[SMALL_BUFF];


   lock(&actualiza);

   espera=TRUE;

   debug=FALSE;

   /**Comunica STR ao servidor assim que confirmado pelo jogador*/
   boas_vindas(side,TRUE);

   draw_heading(nome_jogo, cowboys[LEFT].name, cowboys[LEFT].bulletsleft, cowboys[LEFT].games, cowboys[RIGHT].name, cowboys[RIGHT].bulletsleft, cowboys[RIGHT].games, codigo);

   draw_cowboy(LEFT);
   draw_cowboy(RIGHT);

   unlock(&actualiza);


   codigo=NODRAW;

   for(;;)
   {

      /**Espera por comunicacoes*/
      resposta=espera_resposta(&cowboys[side].sfd,resposta,&codigo);

      lock(&actualiza);
      lock(&ecra);

      if(modifica_janela(resposta, side, codigo)) break;

      draw_heading(nome_jogo, cowboys[LEFT].name, cowboys[LEFT].bulletsleft, cowboys[LEFT].games, cowboys[RIGHT].name, cowboys[RIGHT].bulletsleft, cowboys[RIGHT].games, codigo);

      unlock(&actualiza);
      unlock(&ecra);
   }

   quit=TRUE;

   clear();

   refresh();

   wtimeout(wnd,-1);

   mvwprintw(wnd, 1, 0, "Estatísticas finais");

   mvwprintw(wnd, 0, 0, "High Noon - Projecto de Programacao de Sistemas");

   memset((void*)&temp1,(int)'\0',sizeof(temp1));

   mvwprintw(wnd, NROWS/2-1, NCOLS/2-(strlen(cowboys[LEFT].name)+strlen(" Vs ")+strlen(cowboys[RIGHT].name))/2, "%s Vs %s",cowboys[LEFT].name, cowboys[RIGHT].name);

   memset((void*)&temp1,(int)'\0',sizeof(temp1));
   memset((void*)&temp2,(int)'\0',sizeof(temp2));

   sprintf(temp1,"%d",cowboys[LEFT].games);
   sprintf(temp2,"%d",cowboys[RIGHT].games);
   mvwprintw(wnd, NROWS/2, NCOLS/2-(strlen(temp1)+strlen(" Vs ")+strlen(temp2))/2, "%s Vs %s", temp1, temp2);

   mvwprintw(wnd, NROWS-2, 0, "Obrigado por jogar\n");
   mvwprintw(wnd, NROWS-1, 0, "Pressione uma tecla para terminar\n");

   refresh();

   getch();

   close_HN_window();

   delwin(wnd);

   unlock(&actualiza);
   unlock(&ecra);

   pthread_exit(0);
}

int modifica_janela(char **campos, int side, int codigo)
{
   int i;

   switch(codigo)
   {
      case NSH:

         if(strcmp(campos[1],"P2")==0)
            side=RIGHT;
         if(strcmp(campos[1],"P1")==0)
            side=LEFT;

         /**SE SYNC - TEM QUE ACTIVAR THREAD PARA ACTUALIZAR BALAS**/
         for ( i = 0; i < maxbalas; i++ )
         {
            if ( bullets[side][i].empty )
            {
               break;
            }
         }

         if ( i < maxbalas )
         {
            bullets[side][i].empty = FALSE;
            bullets[side][i].y = cowboys[side].y + 2;
/***BLOQUEAR*/
            cowboys[side].bulletsleft--;

            if ( side == LEFT )
            {
               bullets[side][i].x = cowboys[side].x+4;
               move(bullets[side][i].y, bullets[side][i].x);
               delch();
               insch('>');
            }
            else
            {
               bullets[side][i].x = cowboys[side].x-1;
               move(bullets[side][i].y, bullets[side][i].x);
               delch();
               insch('<');
            }
            refresh();
         }

         return FALSE;

      break;


      case REL:
/****BLOQUEAR***/
         cowboys[LEFT].bulletsleft=maxbalas;
         cowboys[RIGHT].bulletsleft=maxbalas;
         free(campos[0]);
         return FALSE;

      break;


      case BLT:
         /**Move as balas*/
         if(!check_dead(LEFT) && !check_dead(RIGHT))
         {
            for ( i = 0; i < maxbalas; i++ ) {
               if ( bullets[side][i].empty )
               {
                  break;
               }
            }

            if(i<maxbalas+1) move_bullets();
         }

         free(campos[0]);
         return FALSE;

      break;

      case MOV:
         if(strcmp(campos[1],"P1")==0)
            side = LEFT;
         else
            side = RIGHT;

         delete_cowboy(side);

         cowboys[side].y = atoi(campos[2]);

         draw_cowboy(side);
         return FALSE;
         break;

      case EOG:

         clear();

         if(strcmp(campos[1],"P1")==0)
         {
            mvwprintw(wnd, NROWS/2, NCOLS/2-(strlen("VENCEDOR DA PARTIDA: ")+strlen(cowboys[LEFT].name))/2, "Vencedor da partida: %s",cowboys[LEFT].name);
            cowboys[LEFT].games=atoi(campos[2]);
         }
         else if(strcmp(campos[1],"P2")==0)
         {
            mvwprintw(wnd, NROWS/2, NCOLS/2-(strlen("VENCEDOR DA PARTIDA: ")+strlen(cowboys[RIGHT].name))/2, "Vencedor da partida: %s",cowboys[RIGHT].name);
            cowboys[RIGHT].games=atoi(campos[2]);
         }
         else
         {
            mvwprintw(wnd, NROWS/2-4, NCOLS/2-(strlen("VENCEDOR DA PARTIDA: JOGADOR EMPATE"))/2, "Vencedor da partida: Empate");
         }
         wtimeout(wnd,-1);

         mvwprintw(wnd, 0, 0, "High Noon - Projecto de Programacao de Sistemas");
         /**Colocar numero da partida?*/

         mvwprintw(wnd, 1, 0, "Fim da Partida Numero: %d",cowboys[RIGHT].games+cowboys[LEFT].games);

         mvwprintw(wnd, NROWS-1, 0, "Pressione uma tecla qualquer para começar um novo jogo\n");

         refresh();

         getch();

         clear();

         refresh();
         /**Recebe novamente tudo*/

         close_HN_window();

         /*delwin(wnd);*/

         boas_vindas(side,FALSE);

         com_partida(side);

         clear();

         refresh();

         draw_cowboy(LEFT);
         draw_cowboy(RIGHT);
         return FALSE;
         break;

      case EXT:
         if(strcmp(campos[1],"P1")==0)
            side = LEFT;
         else
            side = RIGHT;

         cowboys[side].games=atoi(campos[2]);

         cowboys[!side].games=atoi(campos[3]);

         return TRUE;
         break;

      case ERR:
         break;

      default:
         close_HN_window();
         printf("ERRO: Mensagem nao reconhecida!\n");
         exit(EXIT_FAILURE);
      break;

   }
   return FALSE;
}




/**PROVENIENTES DE HNDEMO**/
void draw_heading(char *game, char* ln, int lb, int lg, char* rn, int rb, int rg, int code)
{
   if(code==DRAW || code == EOG)
   {
      mvwprintw(wnd, 0, (NCOLS - strlen(game))/2,"%s",game);

      mvwprintw(wnd, 1, 0,"NOME: %s",ln);
      mvwprintw(wnd, 3, 0,"VICTORIAS: %d",lg);

      mvwprintw(wnd, 1, NCOLS - NAMELEN - 7,"NOME: %s",rn);
      mvwprintw(wnd, 3, NCOLS - NAMELEN - 7,"VICTORIAS: %d",rg);
   }

   if(code == NSH || code == BLT || code == DRAW || code == EOG)
   {
      mvwprintw(wnd, 2, 0,"BALAS: %d",lb);
      mvwprintw(wnd, 2, NCOLS - NAMELEN - 7,"BALAS: %d",rb);
   }

   refresh();
}

void close_HN_window()
{
   endwin();
}

void delete_cowboy(int side)
{
   int i;

   assert(side == RIGHT || side == LEFT);

   for ( i = 0; i < COWBOY_HEIGHT; i++ ) {
      move(cowboys[side].y+i, cowboys[side].x);
      delch(); delch(); delch(); delch();
      insch(' '); insch(' '); insch(' '); insch(' ');
   }

   refresh();
}

void draw_cowboy(int side)
{
   assert(side == RIGHT || side == LEFT);

   move(cowboys[side].y, cowboys[side].x+side);
   delch(); delch(); delch();
   insch('_'); insch('M'); insch('_');

   move(cowboys[side].y+1, cowboys[side].x+side+1);
   delch();
   insch('|');

   move(cowboys[side].y+2, cowboys[side].x+side);
   delch(); delch(); delch();
   insch('-'); insch('O'); insch('-');

   move(cowboys[side].y+3, cowboys[side].x+side+1);
   delch();
   insch('|');

   move(cowboys[side].y+4, cowboys[side].x+side);
   delch(); delch(); delch();
   insch('\\'); insch(' '); insch('/');

   if ( side == LEFT ) {
      move(cowboys[side].y+2, cowboys[side].x+3);
      delch();
      insch('>');
   }
   else {
      move(cowboys[side].y+2, cowboys[side].x);
      delch();
      insch('<');
   }

   refresh();
}

void move_cowboy_up(char **nomes, int side, int *sock)
{
   char *mensagem=(char *)NULL;

   assert(side == RIGHT || side == LEFT);

   mensagem=escreve_mensagens( NULL, NULL, nomes[PID], "UP",mensagem, MOV);

   envia_mensagem_cliente(sock,mensagem);

   free(mensagem);
}

void move_cowboy_down(char **nomes, int side, int *sock)
{
   char *mensagem=(char *)NULL;

   assert(side == RIGHT || side == LEFT);

   mensagem=escreve_mensagens( NULL, NULL, nomes[PID], "DW",mensagem, MOV);

   envia_mensagem_cliente(sock,mensagem);

   free(mensagem);
}

void fire_bullet(char **nomes, int side, int *sock)
{
   char *mensagem=(char *)NULL;

   /*termina o programa se uma das expressões for falsa*/
   assert(side == RIGHT || side == LEFT);

   mensagem=escreve_mensagens( NULL, NULL, nomes[PID], NULL, mensagem, NSH);

   envia_mensagem_cliente(sock,mensagem);
}

void move_bullets()
{
  int i, side;

  for ( i = 0; i < maxbalas; i++ ) {
    for ( side = LEFT; side <= RIGHT; side++ ) {
      if ( !bullets[side][i].empty ) {
        move(bullets[side][i].y, bullets[side][i].x);
        delch();
        insch(' ');
        if ( side == LEFT ) {
          bullets[side][i].x++;
          if ( bullets[side][i].x >= NCOLS ) {
            bullets[side][i].empty = 1;
          }
          else {
            move(bullets[side][i].y, bullets[side][i].x);
            delch();
            insch('>');
          }
        }
        else {
          bullets[side][i].x--;
          if ( bullets[side][i].x < 0 ) {
            bullets[side][i].empty = 1;
          }
          else {
            move(bullets[side][i].y, bullets[side][i].x);
            delch();
            insch('<');
          }
        }
      }
    }
  }

  refresh();
}

int check_dead(int side)
{
  int other = (side + 1) % 2;
  int i;
  int dead = 0;

  for ( i = 0; i < maxbalas; i++ ) {
    if ( bullets[other][i].empty ) continue;

    if ( side == LEFT ) {
      if ( bullets[other][i].y == cowboys[side].y ) {
        if ( (bullets[other][i].x == cowboys[side].x) ||
             (bullets[other][i].x == cowboys[side].x + 1) ||
             (bullets[other][i].x == cowboys[side].x + 2)) {
          dead = 1;
        }
      }
      else if ( (bullets[other][i].y == cowboys[side].y+1) ||
                (bullets[other][i].y == cowboys[side].y+3) ) {
        if ( (bullets[other][i].x == cowboys[side].x+1) ) {
          dead = 1;
        }
      }
      else if ( bullets[other][i].y == cowboys[side].y+2 ) {
        if ( (bullets[other][i].x == cowboys[side].x) ||
             (bullets[other][i].x == cowboys[side].x + 1) ||
             (bullets[other][i].x == cowboys[side].x + 2) ||
             (bullets[other][i].x == cowboys[side].x + 3)) {
          dead = 1;
        }
      }
      else if ( bullets[other][i].y == cowboys[side].y+4 ) {
        if ( (bullets[other][i].x == cowboys[side].x) ||
             (bullets[other][i].x == cowboys[side].x + 2)) {
          dead = 1;
        }
      }
    }

    if ( side == RIGHT ) {
      if ( bullets[other][i].y == cowboys[side].y ) {
        if ( (bullets[other][i].x == cowboys[side].x+1) ||
             (bullets[other][i].x == cowboys[side].x + 2) ||
             (bullets[other][i].x == cowboys[side].x + 3)) {
          dead = 1;
        }
      }
      else if ( (bullets[other][i].y == cowboys[side].y+1) ||
                (bullets[other][i].y == cowboys[side].y+3) ) {
        if ( (bullets[other][i].x == cowboys[side].x+2) ) {
          dead = 1;
        }
      }
      else if ( bullets[other][i].y == cowboys[side].y+2 ) {
        if ( (bullets[other][i].x == cowboys[side].x) ||
             (bullets[other][i].x == cowboys[side].x + 1) ||
             (bullets[other][i].x == cowboys[side].x + 2) ||
             (bullets[other][i].x == cowboys[side].x + 3)) {
          dead = 1;
        }
      }
      else if ( bullets[other][i].y == cowboys[side].y+4 ) {
        if ( (bullets[other][i].x == cowboys[side].x + 1) ||
             (bullets[other][i].x == cowboys[side].x + 3)) {
          dead = 1;
        }
      }
    }
  }

  return dead;
}


void efectua_limpeza(void)
{
   pthread_mutex_destroy(&actualiza);
   pthread_mutex_destroy(&ecra);
}

