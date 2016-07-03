/*
 * INSTITUTO SUPERIOR TECNICO
 *  PROGRAMACAO DE SISTEMAS
 *    PROJECTO HIGH NOON
 *
 *  Semestre Inverno 09/10
 *
 * Este ficheiro contem a funcao
 * main do programa cliente
 *
 * Realizado Por:
 *    Eduardo Santos (58008)
 *    Pedro Neves (58011)
 *    Pedro Silva(58035)
 */

#include "tools.h"
#include "hnccom.h"
#include "hnc.h"
#include "hncui.h"

/**NOTA O CLIENTE E SEMPRE O JOGADOR 1, O ID E QUE O DESTIGUE*/

int main (int argc, char** argv)
{
   struct sockaddr_in dservidor;
   int porto;
   int escrita, i;
   char **nomes=(char **)NULL;

   /**Activa tratamento de sinais*/
   activa_sinais();

   /**Validacao de dados*/
   valida_argumentos(argc,argv,&porto,NULL,FALSE);

   nomes=guarda_nomes(nomes, argv);

   /**Estabelece ligacao com o servidor*/
   ligacao(porto, &escrita, nomes[NSERVER], &dservidor);

   /**executa o programa gestor, que ira permitir comunicar com o servidor*/
   nomes=regista_jogador(nomes, &escrita);

   if(debug)printf("Tenho ID: %s\n",nomes[PID]);
   fflush(stdout);

   /**lanca jogo*/
   if(debug)printf("A lancar jogo\n");
   lanca_jogo(nomes, &escrita);


   for(i=3;i;i--)
   {
      free(nomes[i]);
   }

   return 0;
}


char **regista_jogador(char** nomes, int *sock)
{
   char **resposta=(char**)NULL;
   char *mensagem=(char*)NULL;
   int codigo;

   /**Compoe mensagem a enviar*/
   mensagem=escreve_mensagens(nomes[NGAME], nomes[NP1] , NULL , NULL, mensagem, NGM);

   /**Envia mensagem*/
   envia_mensagem_cliente(sock, mensagem);
   if(debug)printf("C:DEBUG@regista_jogador: mensagem enviada com sucesso!\n");

   /**Espera resposta - SO RECEBER QUANDO SE CONECTAR O 2P*/
   resposta=espera_resposta(sock, resposta, &codigo);

   strcpy(nomes[PID],resposta[1]);

   free(mensagem);

   return nomes;
}



