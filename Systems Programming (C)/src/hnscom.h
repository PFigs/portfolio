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

void iniciar_comunicacoes(int porto, int *sock);
void associa_porto(int sockfd, struct sockaddr_in details);
void cria_socket(int *sock);
void escuta_porto(int listenfd, int port);
struct sockaddr_in configura_socket(int port, _Bool TCP);

void recebe_mensagens(int listenfd, int port);
char **decompoe_mensagem(char **fields, int fd, int *code);
char **gere_campos(char *id, char **fields, int fd, int *code);
char* responde(char *msg, int *sock, int code);

extern _Bool debug;
