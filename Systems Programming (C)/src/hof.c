#include "hns.h"

extern _Bool debug;
extern int fd_hof1[2];
extern int fd_hof2[2];

/*Ordena o vector de 11 posiçoes com apontadores para as estroturas*/
_Bool ordena(hall_of **top){
	
	unsigned short int i, j;
	
	if(top[0]==NULL){
		top[0]=top[10];
		top[10]=NULL;
		return 1;
	}
	
	/*Procura o Indice para colucar o jogador*/
	for(i=0; i<10; i++){
		
		if(top[i]==NULL){
			break;
			
		}else{
			
			pthread_mutex_lock(&(top[i]->bloq_jog));
			
			if(top[10]->victorias > top[i]->victorias){
				pthread_mutex_unlock(&(top[i]->bloq_jog));
				break;
				
			}else{
				
				if(top[10]->victorias == top[i]->victorias){
					
					if(top[10]->desafios > top[i]->desafios){
						pthread_mutex_unlock(&(top[i]->bloq_jog));
						break;
						
					}else{
						pthread_mutex_unlock(&(top[i]->bloq_jog));
						continue;
					}
					
				}else{
					pthread_mutex_unlock(&(top[i]->bloq_jog));
					continue;
				}
			}
		}
	}
	
	if(i==10){
		if(debug) printf("HOF: Jogador sem pontucao para entrar no top10\n");
		if(top[10]->activo == 0) return 0;
		
		else {
			top[10]=NULL;
			return 1;
		}
	}
	
	if(top[9] != NULL) if(top[9]->activo == 0){
		if(debug) printf("HOF: A eliminar Jogador que nao esta activo: 2\n");
		if(pthread_mutex_destroy(&(top[9]->bloq_jog)) != 0) printf("HOF: Erro ao fechar Mutex (Ordenação)\n");
		free(top[9]);
	}
	
	/*Recoloca os Jogadores*/
	for(j=9; j>i; j--) top[j]=top[(j-1)];
	
	top[i]=top[10];
	
	top[10]=NULL;
	
	return 1;
}

/*Insere Pontuação no Jogador e reordena a estrotura*/
void pontua_jogador(arg_thrd *args, char *endr, char *desafios, char *victorias){
	
	FILE *ficheiro;
	hall_of *temp;
	char nome[NOME];
	char nome_f[NOME];
	char pontos[2][VALOR];
	char ip[16];
	unsigned short int i, j;
	int desaf, vict;
	long int deslocamento;
	char enviar[(ENDR+6)];
	
	temp=(hall_of*)atoi(endr);
	
	pthread_mutex_lock(&(temp->bloq_jog));
	temp->activo=0;
	
	/*Actualiza a Pontuação*/
	temp->desafios= (temp->desafios) + (atoi(desafios));
	temp->victorias= (temp->victorias) + (atoi(victorias));
	
	desaf=temp->desafios;
	vict=temp->victorias;
	
	/*Verifica se o jogador ja está no top10*/
	pthread_mutex_lock(&(args->bloq_top));
	for(i=0; i<10; i++){
		if(args->top[i]!=NULL){
			if(temp!=args->top[i]) pthread_mutex_lock(&(args->top[i]->bloq_jog));
			if(strcmp(args->top[i]->nome, temp->nome) == 0){
				if(debug) printf("HOF: O Jogador esta no Top10\n");
				break;
			}
			if(temp!=args->top[i]) pthread_mutex_unlock(&(args->top[i]->bloq_jog));
		}else break;
	}
	
	if(i<10){
		/*Recoloca os Jogadores*/
		for(j=i; j<9; j++) args->top[j]=args->top[(j+1)];
		args->top[9]=NULL;
	}
	
	copiasubs(temp->nome, nome, ' ',31);
	
	/*Ordena o novo jogador*/
	
	strcpy(enviar, "DEL\n\0");
	strcpy(&(enviar[4]), temp->apont_serv);
	i=strlen(enviar);
	enviar[i]='\n';
	enviar[i+1]='\n';
	write(fd_hof2[WRITE], enviar, (i+2)*sizeof(char));
	
	args->top[10]=temp;
	if(ordena(args->top)) pthread_mutex_unlock(&(temp->bloq_jog));
	else{
		pthread_mutex_unlock(&(temp->bloq_jog));
		if(debug) printf("HOF: A eliminar Jogador que nao esta activo: 1\n");
		if(pthread_mutex_destroy(&(temp->bloq_jog)) != 0) printf("HOF: Erro ao fechar Mutex (Ordenação)\n");
		free(temp);
		args->top[10]=NULL;
	}
	
	if(debug) for(i=0; i<10; i++) if(args->top[i]!=NULL) printf("HOF: Top10 %s %s %d %d\n", args->top[i]->nome, args->top[i]->ip, args->top[i]->desafios, args->top[i]->victorias);
	
	pthread_mutex_lock(&(args->ficheiro));
	pthread_mutex_unlock(&(args->bloq_top));
	
	/*Actualiza o Ficheiro*/
	ficheiro=fopen("./init/Top10.txt","r+");
	
	while(1){
		
		/*Copiar dados para uma string e veriifica se esta no fim do ficheiro*/
		if(fscanf(ficheiro, "%s %s %s %s\n", nome_f, ip, pontos[0], pontos[1]) == EOF){
			if(debug) printf("HOF: Fim do Ficheiro\n");
			fclose(ficheiro);
			break;
		}
		
		if(strcmp(nome, nome_f) == 0){
			
			deslocamento = - strlen(pontos[0]) - strlen(pontos[1]) - 2;
			
			fseek(ficheiro, deslocamento, SEEK_CUR);

			fprintf(ficheiro, "%.9d %.9d\n", desaf, vict);
			fflush(ficheiro);
			fclose(ficheiro);
			break;
		}
	}
	
	pthread_mutex_unlock(&(args->ficheiro));
	
	return;
}

/*Verifica se ja existe um ficheiro com pontuações e insere os melhores na estrotura Top*/
void inicia_top(arg_thrd *args){
	
	FILE *ficheiro;
	unsigned short int i;
	int desafios, victorias;

	
	/*Inicializa o Top*/
	for(i=0; i<11; i++) args->top[i]=NULL;
	
	/*Abre o ficheiro*/
	ficheiro=fopen("./init/Top10.txt","r");
	
	if(ficheiro==NULL){
		if(debug) printf("HOF: Ficheiro invalido Top10.txt nao existe\n");
		return;
		
	}else{
		
		while(1){
			
			args->top[10]=(hall_of*)malloc(sizeof(hall_of));
			
			if(pthread_mutex_init(&(args->top[10]->bloq_jog), NULL) == -1){
				printf("HOF: Falha na inicializacao do mutex\n");
				exit(1);
			}
			
			/*Copiar dados para uma string e veriifica se esta no fim do ficheiro*/
			if(fscanf(ficheiro, "%s %s %d %d\n", args->top[10]->nome, args->top[10]->ip, &desafios, &victorias) == EOF){	
				if(debug) printf("HOF: Fim do Ficheiro\n");
				fclose(ficheiro);
				if(pthread_mutex_destroy(&(args->top[10]->bloq_jog)) != 0) printf("HOF: Erro ao fechar Mutex (Ordenação)\n");
				free(args->top[10]);
				break;
			}
			
			copiasubs(args->top[10]->nome, args->top[10]->nome, 31, ' ');
			args->top[10]->desafios=desafios;
			args->top[10]->victorias=victorias;
			
			/*Ordena o novo jogador*/
			if (ordena(args->top) == 0){
				if(debug) printf("HOF: A eliminar Jogador que nao esta activo: 1\n");
				if(pthread_mutex_destroy(&(args->top[10]->bloq_jog)) != 0) printf("HOF: Erro ao fechar Mutex (Ordenação)\n");
				free(args->top[10]);
				args->top[10]=NULL;
			}
		}
		
		if(debug) for(i=0; i<10; i++) if(args->top[i]!=NULL) printf("HOF: Top10 %s %s %d %d\n", args->top[i]->nome, args->top[i]->ip, args->top[i]->desafios, args->top[i]->victorias);
		
	}
	
	/*Inicializa as estroturas*/
	for(i=0; i<10; i++) if(args->top[i]!=NULL) args->top[i]->activo=0;
	
	return;
}

/*Insere um novo Jogador na estrotura de dados e ficheiro*/
void cria_novo_jogador(arg_thrd *args, char *msg, char *nome, char *IP){
	
	FILE *ficheiro;
	hall_of *temp;
	char linha[NOME];
	char ip_temp[16];
	int p_jogos=0;
	int p_inst=0;
	unsigned short int i;
	_Bool alocar=1;
	char enviar[(ENDR+ENDR+7)];
	
	pthread_mutex_lock(&(args->ficheiro));
	
	/*Abre o ficheiro*/
	ficheiro=fopen("./init/Top10.txt","a+");
	
	/*Verifica se o ficheiro e valido*/
	if(ficheiro==NULL){
		
		if(debug) printf("HOF: Ficheiro invalido Top10.txt nao existe\n");
		
	}else{
		
		while(1){
			
			/*Copiar dados para uma string e veriifica se esta no fim do ficheiro*/
			if(fscanf(ficheiro, "%s %s %d %d\n", linha, ip_temp, &p_inst, &p_jogos) == EOF){
				
				if(debug) printf("HOF: Fim do Ficheiro\n");
				
				/*Insere novo Jogador no Ficheiro*/	
				copiasubs(nome, linha, ' ',31);
				fprintf(ficheiro, "%s %s 000000000 000000000\n", linha, IP);
				fflush(ficheiro);
				fclose(ficheiro);
				p_jogos=0;
				p_inst=0;
				pthread_mutex_unlock(&(args->ficheiro));
				break;
			}
			
			if(debug) printf("HOF: Ficheiro = %s %s %d %d\n", linha, ip_temp, p_inst, p_jogos);
			
			/*Verifica se os nomes coincidem*/
			copiasubs(linha, linha, 31, ' ');
			if( strcmp(linha, nome) == 0 ){
				if(debug) printf("HOF: Jogador Já existente no Ficheiro\n");
				fclose(ficheiro);
				pthread_mutex_unlock(&(args->ficheiro));

				/*Verifica se está no top10*/
				pthread_mutex_lock(&(args->bloq_top));
				for(i=0; i<10; i++){
					pthread_mutex_lock(&(args->top[i]->bloq_jog));
					if(strcmp(linha, args->top[i]->nome) == 0){
						alocar=0;
						if(debug) printf("HOF: O Jogador Já existe no HOF\n");
						break;
					}
					pthread_mutex_unlock(&(args->top[i]->bloq_jog));
				}
				pthread_mutex_unlock(&(args->bloq_top));
				break;
			}
		}
	}
	
	/*if(alocar) pthread_mutex_unlock(&(args->ficheiro));*/
		
	if(alocar){
		/*Aloca o Jogador*/
		temp=(hall_of*)malloc(sizeof(hall_of));
			
	}else{
			temp=args->top[i];
		}
	
	if(debug) printf("HOF: Endereço recebido %s\n",msg);
	
	/*Inicializa os mutexes para bloquear o Jogador*/
	if(alocar) if(pthread_mutex_init(&(temp->bloq_jog), NULL) == -1){
		printf("HOF: Falha na inicializacao do mutex\n");
		exit(1);
	}
		
	if(alocar) pthread_mutex_lock(&(temp->bloq_jog));
	
	if(alocar){
		/*Inicializa variáveis*/
		temp->victorias=p_jogos;
		temp->desafios=p_inst;
		strcpy(temp->nome, nome);
	}
	strcpy(temp->apont_serv, msg);
	strcpy(temp->ip, IP);
	temp->activo=1;
	
	strcpy(enviar, "END\n\0");
	strcpy(&(enviar[4]), temp->apont_serv);
	i=strlen(enviar);
	enviar[i]='\n';
	sprintf(&enviar[(i+1)], "%i", (int)temp);
	if(debug) printf("HOF: Endereço a enviar %s\n",&enviar[(i+1)]);
	i=strlen(enviar);
	enviar[i]='\n';
	enviar[i+1]='\n';
	write(fd_hof2[WRITE], enviar, (i+2)*sizeof(char));
		
	pthread_mutex_unlock(&(temp->bloq_jog));
	
	return;
}

/*Mostra O Top10*/
void show_top(arg_thrd *args){
	
	unsigned short int i;
	
	pthread_mutex_lock(&(args->bloq_top));
	
	for(i=0; i<10; i++){
		
		if(args->top[i]!=NULL){
			
			pthread_mutex_lock(&(args->top[i]->bloq_jog));
			printf("%d. %s\nIP:%s Desafios:%d Jogos:%d\n", i+1, args->top[i]->nome, args->top[i]->ip, args->top[i]->desafios, args->top[i]->victorias);
			pthread_mutex_unlock(&(args->top[i]->bloq_jog));
		
		}else if(i==0){
				printf("Não Existem Jogadores Activos\n");
				break;
				}else break;
		
	}
	
	pthread_mutex_unlock(&(args->bloq_top));
	
	write(fd_hof2[WRITE], "TOP\n\n", 5*sizeof(char));
	
	return;
}

/*Responde ao pedido de informação sobre o jogador*/
void informa(arg_thrd *args, char *endr1, char *endr2){
	
	hall_of *temp;
	char enviar[(ENDR+ENDR+27)];
	unsigned short int tamanho;
	
	temp=(hall_of*)atoi(endr1);
	
	strcpy(enviar, "SCR\n\0");
	
	pthread_mutex_lock(&(temp->bloq_jog));
	strcpy(&(enviar[4]), temp->apont_serv);
	tamanho=strlen(enviar);
	enviar[tamanho]='\n';
	sprintf(&enviar[(tamanho+1)], "%d", temp->victorias);
	tamanho=strlen(enviar);
	enviar[tamanho]='\n';
	pthread_mutex_unlock(&(temp->bloq_jog));
	
	
	temp=(hall_of*)atoi(endr2);
	
	pthread_mutex_lock(&(temp->bloq_jog));
	strcpy(&(enviar[(tamanho+1)]), temp->apont_serv);
	tamanho=strlen(enviar);
	enviar[tamanho]='\n';
	sprintf(&enviar[(tamanho+1)], "%d", temp->victorias);
	tamanho=strlen(enviar);
	enviar[tamanho]='\n';
	enviar[tamanho+1]='\n';
	pthread_mutex_unlock(&(temp->bloq_jog));	
	
	write(fd_hof2[WRITE], enviar, (tamanho+2)*sizeof(char));
	
	return;
}

/*Função Hall of Fame*/
void *func_hof(void *argumentos){
		
		arg_thrd *estr_args=(arg_thrd*)argumentos;
		unsigned short int i, j;
		char mensagem[4][NOME];
		
		while(1){
			
			/*Fica à espera até o read ficar disponivel*/
			pthread_mutex_lock(&(estr_args->bloq_read));
			
			/*Verifica se é para sair*/
			if(estr_args->saida){
					pthread_mutex_unlock(&(estr_args->bloq_read));
					return 0;
				}
			
			/*Actualiza as threads disponiveis -1*/
			pthread_mutex_lock(&(estr_args->bloq_disp));
			estr_args->disponiveis = (estr_args->disponiveis) -1;
			
			/*Verifica a ocupação de threads*/
			if( estr_args->disponiveis <=1 ) pthread_mutex_unlock(&(estr_args->all_full));
			
			pthread_mutex_unlock(&(estr_args->bloq_disp));
			
			i=0;
			j=0;
			while(1){
				read(fd_hof1[READ], &mensagem[j][i], sizeof(char));
				
				/*Verifica se não estamos presente do 1º caracter da string*/
				if(i!=0){
				
					/*Verifica se é o fim da mensagem*/
					if(mensagem[j][(i-1)] == '\n' && mensagem[j][i] == '\n'){
						
						mensagem[j][(i-1)]='\0';
						break;
					}
					
					/*Verifica se terminamos o parametro*/
					if(mensagem[j][(i-1)] == '\n'){
						
						mensagem[j+1][0]=mensagem[j][i];
						mensagem[j][(i-1)]='\0';
						j++;
						i=1;
						continue;
					}
					i++;
				}else{
					i++;
				}
			}
			
			
			if(debug){
				printf("HOF: Mensagem do Pipe:");
				for(i=0; i<=j; i++) printf(" %s",mensagem[i]);
				printf("\n");
			}
			
			/*Identificalão da mensagem*/
			
			switch(mensagem[0][1]){
				
				/*ADD*/
				case 'D':
						pthread_mutex_unlock(&(estr_args->bloq_read));
						pontua_jogador(estr_args, mensagem[1], mensagem[2], mensagem[3]);
						break;
				
				/*NPC*/		
				case 'P':
						pthread_mutex_unlock(&(estr_args->bloq_read));
						cria_novo_jogador(estr_args, mensagem[1], mensagem[2], mensagem[3]);
						break;
				
				/*SCR*/		
				case 'C':
						pthread_mutex_unlock(&(estr_args->bloq_read));
						informa(estr_args, mensagem[1], mensagem[2]);
						break;
						
				/*TOP*/		
				case 'O':
						pthread_mutex_unlock(&(estr_args->bloq_read));
						show_top(estr_args);
						break;						
				
				/*SHD*/
				case 'H':
						estr_args->saida=1;
						pthread_mutex_unlock(&(estr_args->all_full));
						pthread_mutex_unlock(&(estr_args->bloq_read));
						return 0;						
						break;	
										
				default:
						pthread_mutex_unlock(&(estr_args->bloq_read));
						if(debug) printf("HOF: ERRO, mensagem desconhecida\n");
						break;
			}
			
			/*Actualiza as threads disponiveis +1*/
			pthread_mutex_lock(&(estr_args->bloq_disp));
			estr_args->disponiveis = (estr_args->disponiveis) +1;
			pthread_mutex_unlock(&(estr_args->bloq_disp));
			
		}
		
	return 0;
}

/*Cria e inicializa uma estrotura de 8 threads*/
mult_thread *cria_grupo(arg_thrd *args){
	
	mult_thread *temp;
	unsigned short int i;
	
	/*Aloca uma estrotura para 8 threads*/
	temp=(mult_thread*)malloc(sizeof(mult_thread));
	
	/*Inicializa os seus campos*/
	temp->next=NULL;
	
	/*Actualiza as threads disponiveis*/
	pthread_mutex_lock(&(args->bloq_disp));
	args->disponiveis = (args->disponiveis) + 8;
	pthread_mutex_unlock(&(args->bloq_disp));
	
	/*Inicia a 8 threads*/
	for (i=0; i<8; i++) {
		if (pthread_create(&(temp->grupo_thd[i]), NULL, func_hof, (void*)args) != 0) {
			printf("HOF: Erro a criar thread=%d\n", i);
		}
	} 
	
	return temp;
}

/*Terminha o Processo hall of fame*/
void sair_hof(arg_thrd *args, mult_thread *pool_threads){
	
	unsigned short int i;
	
	if(debug) printf("HOF: A processar Pedido de Saida (Fechar Threads)\n");
	
	/*Confirma a saida*/
	write(fd_hof2[WRITE], "SHD\n\n", 5*sizeof(char));
	
	/*Fecha os descritores dos Pipes*/
	close(fd_hof1[READ]);
	close(fd_hof2[WRITE]);
	
	while(1){
		for(i=0; i<8; i++) pthread_join(pool_threads->grupo_thd[i], NULL);
		
		if(pool_threads->next != NULL){
			free(pool_threads);
			pool_threads=(mult_thread*)pool_threads->next;
			continue;
		}else{
			free(pool_threads);
			break;
		}
	}
	if(debug) printf("HOF: As Threads ja terminaram\n");
	
	/*Fecha Mutexes*/
	pthread_mutex_unlock(&(args->all_full));
	if(pthread_mutex_destroy(&(args->bloq_disp))!=0 || pthread_mutex_destroy(&(args->bloq_read))!=0 || pthread_mutex_destroy(&(args->all_full))!=0 || pthread_mutex_destroy(&(args->ficheiro))!=0 || pthread_mutex_destroy(&(args->bloq_top))!=0) printf("HOF: Erro ao fechar Mutex (Saida)\n");
	
	/*Elimina o Top10*/
	for(i=0; i<10; i++){
		if(args->top[i] !=NULL){
			if(pthread_mutex_destroy(&(args->top[i]->bloq_jog)) != 0) printf("HOF: Erro ao fechar Mutex (Saida)\n");
			free(args->top[i]);
		}
	}
	
	/*kill(getpid(),SIGKILL);*/
	return;
}

/*Cria Processo Hall of Fame*/
void inicia_hof(pid_t *pid_hof){
	
	/*A thread principal trata da gestão do numero de threads activas*/
	if ( (*pid_hof=fork()) == 0){
		
		mult_thread *mt_thrds;
		mult_thread *mt_temp;
		arg_thrd args;
		
		
		if(debug) printf("HOF: Processo Hall of Fame Iniciado\n");
		
		/*Fecha os descritores desnecessarios*/
		close(fd_hof1[WRITE]);
		close(fd_hof2[READ]);
		
		args.disponiveis=0;
		args.saida=0;
		
		/*Inicializa os mutexes para bloquear a vareavel disponiveis e o apontador para a estrutura hall_of*/
		if(pthread_mutex_init(&(args.bloq_disp), NULL) == -1 || pthread_mutex_init(&(args.bloq_read), NULL) == -1 || pthread_mutex_init(&(args.all_full), NULL) == -1 || pthread_mutex_init(&(args.ficheiro), NULL) == -1 || pthread_mutex_init(&(args.bloq_top), NULL) == -1){
			printf("HOF: Falha na inicializacao do mutex\n");
			exit(1);
		}
		
		pthread_mutex_lock(&(args.all_full));
		
		inicia_top(&args);
		
		/*Cria o 1º grupo de 8 threads*/
		mt_thrds=cria_grupo(&args);
		mt_temp=mt_thrds;
	
		/*Inicia a analise à disponibilidade das threads*/
		while(1){
			
			/*Fica retido até estarem praticamente todas as threads ocupadas*/
			pthread_mutex_lock(&(args.all_full));
			
			if(args.saida == 1){
				sair_hof(&args, mt_thrds);
				if(debug) printf("HOF: HOF terminou\n");
				break;
			}
			
			if(debug) printf("HOF: As threads estao todas ocupadas, criado novo grupo com mais 8 threads\n");
				
			mt_temp->next=(void*)cria_grupo(&args);			
			mt_temp=(mult_thread*)mt_temp->next;
			
			/*Verifica se ainda é preciso mais threads*/
			pthread_mutex_lock(&(args.bloq_disp));
			
			if( args.disponiveis <=1 ){
				pthread_mutex_unlock(&(args.bloq_disp));
				pthread_mutex_unlock(&(args.all_full));
				continue;
			}
			
			pthread_mutex_unlock(&(args.bloq_disp));
	
		}
		
		_exit(0);
		
	}else{
		return;
	}
	
}
