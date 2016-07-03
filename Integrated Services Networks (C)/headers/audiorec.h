/**
*	Redes com Integração de Serviços
* 		  Projecto VOIP 2010
*   	IST, Semestre Inverno
*
* Realizado Por:
* Filipe Funenga
* Martim Camacho
* Pedro Silva (58035 - pedro.silva@ist.utl.pt)
*/

BOOL open_files(FILE *fd,char* filename);
BOOL close_files(FILE *fd);
BOOL open_audio(int *aufd);
BOOL close_audio(int fd);
BOOL record(int aufd, FILE *fd, char *soundbuffer);
