package simpop;

import java.util.LinkedList;


/**
 * Contem informacao sobre os indivíduos na grelha.
 * Mantem os melhores individuos num vector (TOP 5)
 * e os restantes numa lista.
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class Populacao 
{
	//Vector com os 5 melhores individuos
	private Individuo []indTop5 = new Individuo[5];
	
	//Individuos com conforto inferior ao menor conforto presente no TOP5
	private LinkedList<Individuo> indRestantes = new LinkedList<Individuo>();
	
	//Melhor caminho
	private LinkedList<Ponto> pMelhorCaminho = new LinkedList<Ponto>();
	
	private double dConfortoCaminho;
	private int iCustoCaminho;
	
	//Menor valor de conforto no TOP5
	private double dMenorConfortoTop;
	private int iUltimoTop;
	
	
	/**
	 * Cria a lista com o numero de individuos indicados pelo ficheiro XML.
	 * @param simulacao detalhes da simulacao
	 */
	Populacao(Simulacao simulacao)
	{
		Ponto pAux = simulacao.grelha.getInicial();
		int iNumPop = simulacao.getPopInicial();
		//ATENCAO: Tem que se dar ponto inicial
		for(;iNumPop>0;iNumPop--)
		{
			//cria novo individuo, insere o mesmo na lista e coloca o ponto inicial no seu caminho
			Individuo indHumano = new Individuo(simulacao, pAux, 0, 0, 0, 0);

			indHumano.CalculaConforto(simulacao);
			
			//Coloca o individuo na lista e cria os seus eventos
			this.InsereIndividuo(indHumano, simulacao);
			
			//Cria os eventos para o individuo
			this.CriaEventos(simulacao, indHumano);
		}
	}
	
	
	/**
	 * Coloca um individuo numa das listas, top5 ou restantes.
	 * Por fim, cria os eventos de morte, deslocamento e reproducao.
	 * 
	 * O individuo entra aumtomaticamente no Top5 se existir alguma posicao vaga, inserindo-o por ordem de menor conforto.
	 * Caso contrario verifica se pode entrar no Top5
	 * 
	 * @param indHumano indiviudo a colocar na lista
	 */
	void InsereIndividuo(Individuo indHumano,Simulacao simulacao)
	{

		//caso haja um lugar por preencher entra directamente no TOP5
		if(this.iUltimoTop!=5)
		{
			int i;

			if(this.iUltimoTop>0)
			{
				for(i=0;i<=this.iUltimoTop;i++)
				{
					if(indTop5[i]!=null)
					{
						if(indHumano.dConforto>this.indTop5[i].dConforto)
						{
							int j;
							//Desloca vizinho
							for(j=i;j<iUltimoTop;j++)
								this.indTop5[j+1]=this.indTop5[j];	
							this.indTop5[i]=indHumano;
							break;
						}
					}
					else
					{
						this.indTop5[i]=indHumano;
						indHumano.bTop5=true;
					}
				}

				if(iUltimoTop==4) this.dMenorConfortoTop=indHumano.dConforto;
			}
			else
			{
				this.indTop5[0]=indHumano;
			}
			iUltimoTop++;
			indHumano.bTop5=true;
		}
		else if (indHumano.dConforto > this.dMenorConfortoTop)
		{
			ColocaTop5(indHumano,simulacao);
		}
		else if (indHumano.dConforto == this.dMenorConfortoTop)
		{
			this.indRestantes.addFirst(indHumano);
		}
		else
		{
			this.indRestantes.addLast(indHumano);
		}

	}
	
	/**
	 * Calcula o conforto do individuo e cria os seus eventos de deslocamento, reproducao e morte.
	 * 
	 * @param simulacao detalhes da simulacao 
	 * @param indHumano indivudo ao qual o evento devera ficar associado 
	 */
	void CriaEventos(Simulacao simulacao, Individuo indHumano) 
	{
		//Cria novo evento de deslocamento
		indHumano.CriaEvDeslocamento(simulacao);
	
		//cria novo evento de reproducao
		indHumano.CriaEvReproducao(simulacao);
		
		//cria novo evento de morte
		indHumano.CriaEvMorte(simulacao);
				
	}

	/**
	 * Averigua se o individuo deve ser colocado no Top5 e actualiza o melhor caminho
	 * 
	 * @param indHumano individuo a testar
	 */
	void ActualizaTop5(Individuo indHumano, Simulacao simulacao) 
	{

		if(indHumano.dConforto>this.dMenorConfortoTop)
			this.ColocaTop5(indHumano, simulacao);
		
		if(indHumano.dConforto<this.dMenorConfortoTop && indHumano.bTop5)
			this.RemoveTop5(indHumano);				
	}

	/**
	 * Coloca o indivudo no Top5.
	 * Para isso, o ultimo individuo presente no top5 e removido para a lista dos restantes.
	 * Por fim, o menor valor no Top5 e actualizado com o novo individuo na ultima posicao.
	 * Para alem disso, o melhor caminho e actualizado caso seja o #1 e ainda nao tenha chegado
	 * ao ponto.
	 * 
	 * @param simulacao detalhes da simulacao
	 * @param indHumano individuo a colocar no top5
	 */
	void ColocaTop5(Individuo indHumano, Simulacao simulacao) 
	{
		boolean bAlterarTop=false;
		
		//Se nao estiver no Top5
		if(!indHumano.bTop5)
		{
			int j;
			int i;
			
			simulacao.populacao.removeRestantes(indHumano);
			
			//coloco ultimo no topo da lista dos restantes
			if(this.indTop5[4]!=null)
			{
				this.indTop5[4].bTop5=false;
				this.indRestantes.addFirst(this.indTop5[4]);
			}
			
			for(i=0;;i++)
			{
				if(indHumano.dConforto>indTop5[i].dConforto) break;
				if(i==4)break;
			}

			//empurro o individuo que esta a ocupar o meu lugar
			for(j=4;j!=i && j-1 != -1;j--)
				this.indTop5[j]=this.indTop5[j-1];

			//coloco-me em posicao
			indHumano.bTop5=true;
			this.indTop5[i]=indHumano;
			if(i==0) bAlterarTop=true;
			//actualizo menor valor de conforto
			this.dMenorConfortoTop=this.indTop5[4].dConforto;
		}
		else
		{
			int j;
			int k;
			Individuo indAux = indHumano;
			
			bAlterarTop=true;
			//obtenho o meu indice
			for(k=0;k<5;++k)
				if(indHumano==indTop5[k]) break;
			//Desloco-me dentro do Top5
			for(j=0;j<5;++j)
			{
				//Encontrei menor
				if(indTop5[j]==null)break;
				if(indHumano.dConforto>indTop5[j].dConforto)
				{
					indAux=indTop5[j];
					indTop5[j]=indHumano;
					indTop5[k]=indAux;
					break;
				}
			}
			
			//Tenho que colocar no sitio;
			this.insereOrdenado(k,indTop5[k]);
			
		}
		
		if(!simulacao.getFinalAtingido() && bAlterarTop && indHumano.dConforto>this.dConfortoCaminho)
		{
			LinkedList<Ponto> pAux = new LinkedList<Ponto>();
			int iAux;
			
			if(Simulacao.debug2)
			{
				System.out.println("A alterar Top5:\nComprimento: " + this.indTop5[0].iComprimento + "\nConforto: "+this.indTop5[0].dConforto );
				System.out.println("Caminho Original: " + indHumano.pCaminho);
				System.out.println();
			}
			
			for(iAux=0;iAux<this.indTop5[0].iComprimento+1;iAux++)
			{
				pAux.add(this.indTop5[0].pCaminho.get(iAux));
			}
			
			this.dConfortoCaminho=this.indTop5[0].dConforto;
			this.iCustoCaminho=this.indTop5[0].iCusto;
			this.pMelhorCaminho=pAux;
			
			if(Simulacao.debug2)
				System.out.println("Caminho Copiado: " + pMelhorCaminho);
			
		}
		
				
	}
	
	/**
	 * Ordena o inidividuo dentro do top5
	 * 
	 * @param idx ultimo indice ordenado
	 * @param indHumano individuo
	 */
	private void insereOrdenado(int idx, Individuo indHumano) 
	{
		int j;
		
		//Verifico com um valor mais elevado que o meu
		for(j=idx;j<5;++j)
		{
			//Encontrei maior
			if(indTop5[j]==null)break;
			if(indHumano.dConforto<indTop5[j].dConforto)
			{
				indTop5[idx]=indTop5[j];
				indTop5[j]=indHumano;
				insereOrdenado(j,indTop5[j]);
				break;
			}
		}
		
	}

	/**
	 * Remove um individuo do Top5, colocando novo individuo no top
	 * 
	 * @param indHumano individuo a remover do Top5
	 */
	public void RemoveTop5(Individuo indHumano) 
	{
		int i;
		int j;

		indHumano.bTop5=false;
		//Retiro-me da lista e coloco primeiro do povo
		for(i=0;i<5;i++)
		{
			//procurao a minha posicao
			if(this.indTop5[i]==indHumano)
			{
				//desloco os meus vizinhos
				for(j=i;j<4;j++)
					this.indTop5[j]=this.indTop5[j+1];
				
				if(!indRestantes.isEmpty())
				{
					if((this.indTop5[4]=indRestantes.removeFirst())!=null)
						this.indTop5[4].bTop5=true;
					else	
						this.indTop5[4]=null;
				}
				
				break;
			}
		}
		
		this.indRestantes.addFirst(indHumano);
	}

	/**
	 * Remove todos os individuos que nao estao no Top5, assim como, os seus eventos futuros
	 * @param simulacao detalhes da simulacao
	 */
	public void Epidemia(Simulacao simulacao) 
	{
		Individuo indAux;
		int counter=0;
		
		while(!this.indRestantes.isEmpty())
		{
			if((indAux=this.indRestantes.removeFirst())!=null)
				counter++;
			
			indAux.RemoveEventosFuturos(simulacao.cap);
			
		}
		simulacao.setPopActual(simulacao.getPopActual()-counter);
		
		System.gc();
		
	}

	/**
	 * Devolve o conforto associado ao melhor caminho
	 */
	public double getConfortoCaminho() {return this.dConfortoCaminho;}

	/**
	 * Atribui o valor ao conforto do melhor caminho
	 * @param dConforto conforto do individuo
	 */
	public void setConfortoCaminho(double dConforto) {this.dConfortoCaminho=dConforto;}
	
	/**
	 * Atribui o valor ao custo do melhor caminho
	 * @param iCusto custo associado ao caminho do individuo
	 */
	public void setCustoCamiho(int iCusto) {this.iCustoCaminho=iCusto;}
	
	/**
	 * Guarda a referência para o melhor caminho
	 * @param pCaminhoInd copia do melhor caminho
	 * @see Individuo
	 */
	public void setMelhorCaminho(LinkedList<Ponto> pCaminhoInd) {this.pMelhorCaminho=pCaminhoInd;}

	/**
	 * Remove o individuo da lista dos individuos, que nao estao no Top5 
	 * @param indHumano individuo a remover
	 * @see Individuo
	 */
	public void removeRestantes(Individuo indHumano) { this.indRestantes.remove(indHumano);}


	/**
	 * Imprime o melhor caminho 
	 * @return (Xi,Yi)..(Xn,Yn) string com o melhor caminho
	 */
	public String imprimeCaminho() {
		return pMelhorCaminho.toString();
	}

	/**
	 * Devolve o custo associado ao melhor caminho
	 */
	public int getCustoCaminho() {return this.iCustoCaminho;}
	

}
