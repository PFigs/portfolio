#include "hns.h"
extern int fd_hof1[2];
extern _Bool saida;
extern _Bool debug;
extern pthread_mutex_t all_full;
extern pthread_mutex_t espera_top;
extern pthread_mutex_t d_activos;
extern unsigned int desafios_activos;


#define BUFF 100

int func_interface_serv(char *funcionalidade,char *desaf);

int valida_arg_serv(char *opc,char *desaf, char *lixo2);

void *interface () {
	
	char lixo[BUFF];
	char desafio[BUFF];
	char opcao[BUFF];
	char aux[BUFF];
	
	pthread_mutex_lock(&espera_top);
	pthread_mutex_lock(&espera_top);
	pthread_mutex_unlock(&espera_top);
	
	/*Imprime Menu*/
	menu_servidor();
	
	printf("Bem vindo ao servidor HNserv.\n\n Indique a sua opção:\n");
	
	
	while(saida==0){
	printf("$ ");
		/*Limpa buffer de teclado e garante que é tudo impresso no ecran*/
	  fflush(stdout);
      memset((void*)lixo,(int)'\0',sizeof(lixo));
      memset((void*)desafio,(int)'\0',sizeof(desafio));
      memset((void*)opcao,(int)'\0',sizeof(opcao));	
		
		
	fgets(aux,BUFF -1,stdin);
	
			
	sscanf(aux,"%s %s %s",opcao,desafio,lixo);
	
	/* Chamada da função que verfica se os argumentos inseridos são válidos*/
	if (valida_arg_serv(opcao,desafio,lixo)==0){
		
		func_interface_serv(opcao,desafio);
		
	}
	
	}	
return 0;	
}	
	
	
	/*Função que verfica se os argumentos inseridos são válidos*/
int valida_arg_serv(char *opc,char *desaf, char *lixo2){
		
		
		if(strcmp(lixo2,"\0")!=0){
			
			printf("Os dados inseridos não correspondem a argumentos válidos.\n\n");
			
			printf("As opções são as seguintes:\n\n");
			printf("l - Listar desafios\n");
			printf("d - Informação sobre desafios\n");
			printf("h - HallOfFame\n");
			printf("x - Terminar o servidor.\n\n");
			return -1;
		}
		
		
		
		if(strcmp(opc,"l")!=0 && strcmp(opc,"d")!=0 && strcmp(opc,"h")!=0 && strcmp(opc,"x")!=0 && strcmp(opc,"n")!=0 && strcmp(opc,"m")!=0 && strcmp(opc,"a")!=0){
			
			printf("A opção seleccionada não é válida.\n\n");
			printf("As opções são as seguintes:\n\n");
			printf("l - Listar desafios\n");
			printf("d - Informação sobre desafios\n");
			printf("h - HallOfFame\n");
			printf("x - Terminar o servidor.\n\n");
			
			return -1;
		}
		

	if(strcmp(desaf,"\0")==0 && strcmp(opc,"d")==0){
			
			printf("Tem de indicar o jogo a que deseja visualizar a informação\n\n");
			printf("exemplo: d \"nome do desafio\"\n");
		/*Falta verificação da existência do jogo*/
		
		return -1;
	}
		return 0;
	}	
		
		
		/*Após serem validados os dados inseridos é chamada esta função
		 *  para verificação e execução da função pretendida*/
int func_interface_serv(char *funcionalidade, char *desaf) {

switch (*funcionalidade) {
		
		case 'l':
		
			if (strcmp(desaf,"\0")!=0){
			
			printf("A opção %s não necessita de argumentos adicionais.\n\n",funcionalidade);
			break;
			}
			
		lista_desafios();
		return 0;
		break;
		
		case 'd':
		
		if (strcmp(desaf,"\0")==0){
			
			printf("A opção %s necessita de saber qual o jogo a listar a info.\n\n",funcionalidade);
			break;
			}
		mostra_desafio(desaf);
		
		return 0;
		break;
		
		case 'h':
		
		if (strcmp(desaf,"\0")!=0){
			
			printf("A opção %s não necessita de argumentos adicionais.\n\n",funcionalidade);
			break;
			}
		
		write(fd_hof1[WRITE], "TOP\n\n", 5*sizeof(char));
		pthread_mutex_lock(&espera_top);
		pthread_mutex_lock(&espera_top);
		pthread_mutex_unlock(&espera_top);
		
		return 0;
		break;
		
		case 'm':
			debug=1;
			break;
		
		case 'n':
			debug=0;
			break;
			
		case 'a':
			if (strcmp(desaf,"\0")==0){
				printf("A opção %s necessita de saber qual o Jogador a listar a info.\n\n",funcionalidade);
				break;
			}
			dar_pontos(desaf);
			break;
		
		case 'x':
		
		if (strcmp(desaf,"\0")!=0){
			
			printf("A opção %s não necessita de argumentos adicionais.\n\n",funcionalidade);
			break;
			}
		
		pthread_mutex_lock(&d_activos);
		if(desafios_activos != 0){
			pthread_mutex_unlock(&d_activos);
			printf("O servidor Nao pode terminar porque ainda existem desafios activos\n");
			break;
		}
		pthread_mutex_unlock(&d_activos);
		saida=1;
		pthread_mutex_unlock(&all_full);
		printf("O servidor Terminou\n\n");
		return 2;
		break;
		
		default:
		printf("Essa opção não existe.\n\n");
		return -1;
		break;
}
return 0;
}

		
	
	
	
