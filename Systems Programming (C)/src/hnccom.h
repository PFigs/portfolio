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

struct sockaddr_in resolve_nome(char* trackername, int trackerport);
void ligacao(unsigned int porto, int *escrita, char *nome_servidor, struct sockaddr_in *dservidor);
void estabelece_sessao(int *sock, struct sockaddr_in server);
void cria_socket(int *sock);
char *escreve_mensagens(char *game, char *player, char *P_ID, char *cmd, char *mensagem, int mode);
int envia_mensagem_cliente(int *sock, char *buffer);
char **recebe_campos(char *id, char **fields, int *fd, int *codigo);
char **espera_resposta(int *fd, char **resposta, int *codigo);
