package simpop;


/**
 * A classe grelha permite guardar uma representacao virtual do tabuleiro,
 * onde os individuos se irao deslocar.
 * <p>
 * Os pontos sao representados através de objectos da classe Ponto.
 * A estes sao atribuidas arestas, caso seja possivel viajar pelas mesmas.
 * <p>
 * 
 * @see Ponto
 * @see Aresta
 * @see Populacao
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class Grelha 
{
	//Dimensao grelha
	private int iNumColunas;
	private int iNumLinhas;
	
	//Numero Obstaculos
	@SuppressWarnings("unused")
	private int iNumObs;
	
	//Ponto inicial
	private Ponto pInicial;
	private Ponto pFinal;
	private Ponto[][] pListaPontos;

	//Custo maximo de uma aresta
	private int iCmax;
	
	/**
	 * Inicializa uma matriz de pontos com dimensao <code>numlinhas</code> x <code>numcolunas</code>.
	 * A cada ponto sao atribuidas quatro arestas, isto e, caso o ponto nao se encontre num canto.
	 * 
	 * O metodo garante que as arestas nao representaveis, terao o valor <tt>null</tt>.
	 * 
	 * @param numcolunas numero de colunas
	 * @param numlinhas numero de linhas
	 * 
	 * @see Ponto
	 * @see Aresta
	 */
	public void setDimGrelha(int numcolunas, int numlinhas)
	{
		int i;
		int j;
		iNumColunas=numcolunas;
		iNumLinhas=numlinhas;
		
		if(Simulacao.debug)
		{
			System.out.println("@Grelha:Recebi do ficheiro...");
			System.out.println("@Grelha:Numero colunas " + iNumColunas);
			System.out.println("@Grelha:Numero linhas " + iNumLinhas);
			System.out.println();
		}
		
    	//Inicializa matriz
    	pListaPontos = new Ponto[iNumLinhas][iNumColunas];
    	
    	//Inicializa pontos
    	for(i=0;i<iNumColunas;i++)
    	{
    		for(j=0;j<iNumLinhas;j++)
    		{
			
    			pListaPontos[j][i] = new Ponto(j,i);
    			
    			if(Simulacao.debug)
    				System.out.println("Iniciei Posicao " +j +" "+i);

    		}
    	}

    	//Inicializa arestas
    	for(i=0;i<iNumColunas;i++)
    	{
    		for(j=0;j<iNumLinhas;j++)
    		{
    			//Canto inferior esquerdo
    			if(j==0 && i==0){
    				pListaPontos[j][i].setAresta(1,pListaPontos[j+1][i]);
    				pListaPontos[j][i].setAresta(2,pListaPontos[j][i+1]);
    			}
    			//Canto superior esquerdo
    			else if(j==(iNumLinhas-1) && i==0){
    				pListaPontos[j][i].setAresta(3,pListaPontos[j-1][i]);
    				pListaPontos[j][i].setAresta(2,pListaPontos[j][i+1]);
    			}
    			//Canto superior direito
    			else if(j==(iNumLinhas-1) && i==(iNumColunas-1)){
    				pListaPontos[j][i].setAresta(3,pListaPontos[j-1][i]);
    				pListaPontos[j][i].setAresta(0,pListaPontos[j][i-1]);
    			}
    			//Canto inferior direito
    			else if(j==0 && i==(iNumColunas-1)){
    				pListaPontos[j][i].setAresta(1,pListaPontos[j+1][i]);
    				pListaPontos[j][i].setAresta(0,pListaPontos[j][i-1]);
    			}
    			//Aresta esquerda
    			else if(j<(iNumLinhas-1) && i==0){
    				pListaPontos[j][i].setAresta(3,pListaPontos[j-1][i]);
    				pListaPontos[j][i].setAresta(1,pListaPontos[j+1][i]);
    				pListaPontos[j][i].setAresta(2,pListaPontos[j][i+1]);
    			}
    			//Aresta direita
    			else if(j<(iNumLinhas-1) && i==(iNumColunas-1)){
    				pListaPontos[j][i].setAresta(3,pListaPontos[j-1][i]);
    				pListaPontos[j][i].setAresta(1,pListaPontos[j+1][i]);
    				pListaPontos[j][i].setAresta(0,pListaPontos[j][i-1]);
    			}
    			//Aresta inferior
    			else if(j==0 && i<(iNumColunas-1)){
    				pListaPontos[j][i].setAresta(0,pListaPontos[j][i-1]);
    				pListaPontos[j][i].setAresta(1,pListaPontos[j+1][i]);
    				pListaPontos[j][i].setAresta(2,pListaPontos[j][i+1]);
    			}
    			//Aresta superior
    			else if(j==(iNumLinhas-1) && i<(iNumColunas-1)){
    				pListaPontos[j][i].setAresta(2,pListaPontos[j][i+1]);
    				pListaPontos[j][i].setAresta(3,pListaPontos[j-1][i]);
    				pListaPontos[j][i].setAresta(0,pListaPontos[j][i-1]);
    			}
    			//Pontos interiores
    			else{
    				pListaPontos[j][i].setAresta(2, pListaPontos[j][i+1]);
    				pListaPontos[j][i].setAresta(3, pListaPontos[j-1][i]);
    				pListaPontos[j][i].setAresta(1, pListaPontos[j+1][i]);
    				pListaPontos[j][i].setAresta(0, pListaPontos[j][i-1]);
    			}
    		}
    	}
	}

	
	/**
	 * Define o ponto inicial do tabuleiro, para as coordenadas recebidas.
	 *  
	 * @param xinicial coordenada linha
	 * @param yinicial coordenada coluna
	 */
	public void setPontoInicial(int xinicial, int yinicial) 
	{
    	//Guarda referencia do ponto inicial
    	pInicial=pListaPontos[xinicial][yinicial];
    	
    	if(Simulacao.debug)
    	{
    		System.out.println("@Grelha:Recebi do ficheiro...");
			System.out.println("@Grelha:Ponto Inicial X: " + pInicial.iX);
			System.out.println("@Grelah:Ponto Inicial Y: " + pInicial.iY);
    	}
    	
	}
	
	
	/**
	 * Define o ponto final do tabuleiro, para as coordenadas recebidas.
	 * 
	 * @param xfinal coordenada linha
	 * @param yfinal coordenada coluna
	 */
	void setPontoFinal(int xfinal, int yfinal) 
	{
		//Guarda referencia do ponto final
		pFinal = pListaPontos[xfinal][yfinal];
		
		if(Simulacao.debug)
		{	
			System.out.println("@Grelha:Recebi do ficheiro...");
			System.out.println("@Grelha:Ponto Final X: " + pFinal.iX);
			System.out.println("@Grelah:Ponto Final Y: " + pFinal.iY);
			System.out.println();
		}
	}

	/**
	 * Define uma zona especial, atribuindo as arestas que definem o perimetro, o valor <code>custo</code>.
	 * O metodo toma como padrao, que as coordenadas iniciais sao inferiores as coordenadas finais.
	 * @param xi linha inicial
	 * @param yi coluna inicial
	 * @param xf linha final
	 * @param yf coluna final
	 * @param custo valor associado a zona
	 */
	void setPontoEspecial(int xi, int yi, int xf, int yf, int custo)
	{
		int i;
		//Modifica custo das Arestas
		
		//Ponto inicial
		pListaPontos[xi][yi].aArestas[1].setCusto(custo);
		pListaPontos[xi][yi].aArestas[2].setCusto(custo);
		
		//Ponto final
		pListaPontos[xf][yf].aArestas[0].setCusto(custo);
		pListaPontos[xf][yf].aArestas[3].setCusto(custo);
		

		//Ponto xf yi
		pListaPontos[xf][yi].aArestas[3].setCusto(custo);
		pListaPontos[xf][yi].aArestas[2].setCusto(custo);
		
		//Ponto xi yf
		pListaPontos[xi][yf].aArestas[0].setCusto(custo);
		pListaPontos[xi][yf].aArestas[1].setCusto(custo);
		
		//Verticalmente		
		for(i=(xi+1);i<xf; i++)
		{
			pListaPontos[i][yi].aArestas[1].setCusto(custo);
			pListaPontos[i][yi].aArestas[3].setCusto(custo);
			
			pListaPontos[i][yf].aArestas[1].setCusto(custo);
			pListaPontos[i][yf].aArestas[3].setCusto(custo);
			
			if(Simulacao.debug)
			{
				System.out.println("A modificar coluna");
				System.out.println( i +" : " +yi + " e " + i + " : " + (yf));
			}
		}		
		
		//Horizontalmente
		for(i=yi+1;i<yf; i++)
		{
			pListaPontos[xi][i].aArestas[0].setCusto(custo);
			pListaPontos[xi][i].aArestas[2].setCusto(custo);
			
			pListaPontos[xf][i].aArestas[0].setCusto(custo);
			pListaPontos[xf][i].aArestas[2].setCusto(custo);
			
			if(Simulacao.debug)
			{
				System.out.println("A modificar coluna");
				System.out.println( i +" : " +yi + " e " + i + " : " + (yf));
			}
		}
				
		//ACtualiza custo maximo
		if(custo>=1)
			iCmax=custo;
		
	}

	/**
	 * Permite definir o numero de obstaculos, presentes na grelha
	 * 
	 * @param iNum numero total de obstaculos
	 */
	public void setNumObstaculos(int iNum) 
	{
		iNumObs=iNum;
	}


	/**
	 * Define uma posicao como obstaculo. Para isso, o metodo remove
	 * todas as arestas a sua volta, incluindo as suas e as dos seus vizinhos.
	 * As arestas que nao estao definidas sao colocadas a <tt>null</tt>.
	 * 
	 * O metodo garante que o ponto inicial e final nao sao definidos como
	 * obstaculos. Caso contrario termina o programa.
	 * 
	 * @param x linha
	 * @param y coluna
	 * 
	 * @see Ponto
	 * @see Aresta
	 */
	void setObstaculo(int x, int y)
	{
		
		if(pListaPontos[x][y].aArestas[0]!=null){
			pListaPontos[x][y].aArestas[0].getProximo().aArestas[2]=null;
			
		}
		
		if(pListaPontos[x][y].aArestas[1]!=null){
			pListaPontos[x][y].aArestas[1].getProximo().aArestas[3]=null;
			
		}
		
		if(pListaPontos[x][y].aArestas[2]!=null){
			pListaPontos[x][y].aArestas[2].getProximo().aArestas[0]=null;
			
		}
		
		if(pListaPontos[x][y].aArestas[3]!=null){
			pListaPontos[x][y].aArestas[3].getProximo().aArestas[1]=null;
			
		}
		
		if(pInicial.iX==x && pInicial.iY==y)
		{
			System.err.format("Ponto Inicial nao pode ser obstaculo!\n");
			System.exit(-1);
			
		}
		
		if(pFinal.iX==x && pFinal.iY==y)
		{
			System.err.format("Ponto Final nao pode ser obstaculo!\n");
			System.exit(-1);
		}
		
		if(Simulacao.debug)
		{
			System.out.println();
			System.out.println("Encontrado Obstaculo...");
			System.out.println("Coordenada X: " + pListaPontos[x][y].iX);
			System.out.println("Coordenada Y: " + pListaPontos[x][y].iY);
			System.out.println();		
		}
		
		pListaPontos[x][y]=null;
				
	}

	/**
	 * Devolve o ponto inicial do tabuleiro
	 */
	public Ponto getInicial() {return pInicial;}
	
	/**
	 * Devolve o ponto final do tabuleiro
	 */
	public Ponto getFinal() {return pFinal;}
	
	/**
	 * Devolve o custo maximo associado a uma aresta do tabuleiro 
	 */
	public int getMaxCusto() {return iCmax;}
	
	/**
	 * Devolve o numero de linhas
	 */
	public int getN() {	return iNumLinhas;}
	
	/**
	 * Devolve o numero de colunas
	 */
	public int getM() {	return iNumColunas;}
	
	/**
	 * Verifica se o ponto inicial ou final nao se encontram rodeados de obstaculos.
	 * @return True caso seja possivel sair e/ou chegar ao ponto final
	 */
	public boolean validaExtremos()
	{
		if(pInicial.aArestas[0]==null)
			if(pInicial.aArestas[1]==null)
				if(pInicial.aArestas[2]==null)
					if(pInicial.aArestas[3]==null)
					{
						System.err.format("Ponto Inicial esta isolado!\n");
						return false;
					}
		
		
		if(pFinal.aArestas[0]==null)
			if(pFinal.aArestas[1]==null)
				if(pFinal.aArestas[2]==null)
					if(pFinal.aArestas[3]==null)
					{
						System.err.format("Ponto final esta isolado!\n");
						return false;
					}
		
		return true;
	}
	
}

