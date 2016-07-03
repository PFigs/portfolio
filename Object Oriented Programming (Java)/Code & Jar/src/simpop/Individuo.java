package simpop;

import java.util.LinkedList;
import java.lang.Math;

import simpop.ETipo;


/**
 * A classe Individuo contem toda a informacao relativa a um individuo.
 * Este individuo pertence a populacao, podendo estar no TOP 5 ou na lista
 * dos restantes individuos, com conforto menor ao menor dos 5 melhores.
 * Sao ainda guardadas outras informacoes, relativamente a sua distancia ao
 * ponto final, comprimento do caminho, entre outros.
 * 
 * @see Populacao
 * @see Grelha
 * @see Simulacao
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class Individuo 
{
	Ponto pPosicao;	
	int iCusto;
	int iComprimento;
	double dDistancia;
	double dConforto;

	boolean bTop5;
	
	//Lista de pontos com caminho percorrido pelo individuo
	LinkedList<Ponto> pCaminho;
	LinkedList<Integer> iCustoCaminho;
	//Vector com os meus eventos
	Evento []evMeusEventos = new Evento[3];
	
	/**
	 * Inicializa um novo individuo e coloca o ponto onde nasceu na lista com o seu caminho.
	 * O numero da populacao actual e actualizado.
	 * 
	 * @param simulacao detalhes da simulacao
	 * @param pInicial Ponto onde nasceu
	 * @param iCusto Custo acumulado até o ponto actual
	 * @param dDistancia Distancia do ultimo ponto ao destino
	 * @param iComprimento Numero de arestas percorridas
	 * @param dConforto Conforto actual do individuo 
	 */
	Individuo(Simulacao simulacao, Ponto pInicial, int iCusto, double dDistancia, int iComprimento, double dConforto)
	{
			
		pCaminho = new LinkedList<Ponto>();
		iCustoCaminho = new LinkedList<Integer>();
		this.pCaminho.addFirst(pInicial);
		this.iCustoCaminho.addFirst(iCusto);
		this.pPosicao = pInicial;
		this.iCusto = iCusto;
		this.dDistancia = dDistancia;
		this.dConforto = dConforto;
		this.iComprimento = iComprimento;
		this.bTop5=false;
		
		simulacao.incPopActual();
		
		if(Simulacao.debug)
		{
			System.out.println("Nasci! Na posicao x: " + pPosicao.iX + " y:" + pPosicao.iY);
			System.out.println("Custo: " + iCusto);
			System.out.println("Distancia: " + dDistancia);
			System.out.println("Conforto: " + dConforto);
		}
		
	}
	
	/**
	 * Calcula o conforto para os atributos actuais do individuo e parametros da simulacao.
	 * O custo, comprimento, distancia e conforto sao as principais variaveis, que afectam 
	 * a variacao do conforto.
	 *  
	 * @param simulacao detalhes da simulacao
	 */
	void CalculaConforto(Simulacao simulacao)
	{
		int k = simulacao.getSensConforto();
		double dAux;
		
		//Primeira fase
		dAux = ((this.iCusto-this.iComprimento+2));
		dAux = (dAux/(((simulacao.grelha.getMaxCusto()-1)*this.iComprimento)+3));
		dAux = Math.pow(1-dAux,k);	
	
		//Segunda fase
		//Calcula distancia ao ponto final
		this.dDistancia = dDistancia(simulacao.grelha.getFinal());
		this.dConforto = (simulacao.grelha.getN()+simulacao.grelha.getM()+1);
		this.dConforto = this.dDistancia/dConforto;
		this.dConforto = Math.pow(1-this.dConforto,k);
		this.dConforto = dAux*this.dConforto;
		
		if(Simulacao.debug)
			System.out.println("AWESOME Conforto: "+dConforto);
	}
	
	
	/**
	 * Permite calcular a distancia do ponto actual do individuo <code>pPosicao</code>
	 * ao ponto <code>pFinal</code> passado ao metodo.
	 * 
	 * A distancia e calculada atraves da formula:
	 * <p>
	 * <code>Math.abs(pFinal.iX-pPosicao.iX)+Math.abs(pFinal.iY-pPosicao.iY)</code>
	 * 
	 * @param pFinal ponto final
	 * @return distancia ao ponto
	 */
	private double dDistancia(Ponto pFinal) {
		
		return Math.abs(pFinal.iX-pPosicao.iX)+Math.abs(pFinal.iY-pPosicao.iY);
	}


	/**
	 * Desloca o individuo para um vizinho aleatorio, verificando e removendo loops.
	 * O salto e feito atraves de uma selecao aleatoria, dentro das arestas disponiveis
	 * do proximo ponto. 
	 * 
	 */
	void InsereCaminho()
	{
		int aleatorio;
		Ponto pSalto;
		

		while(true)
		{
			//Decide aleatoriamente o seu salto
			aleatorio = Simulacao.lotaria.nextInt(4);
			if((pPosicao.aArestas[aleatorio])!=null)
				break;
		}

		pSalto = pPosicao.aArestas[aleatorio].getProximo();

		//Verifico loop
		if(pCaminho.contains(pSalto))
		{
			int iAux;
			int iSize;
			LinkedList<Ponto> pNovoCaminho = new LinkedList<Ponto>();
			LinkedList<Integer> iNovoCustoCaminho = new LinkedList<Integer>();

			iAux=pCaminho.indexOf(pSalto);
			pPosicao = this.pCaminho.get(iAux);

			if(Simulacao.debug2)
				System.out.println("\n\nA REMOVER LOOP:\nVECTOR DE CUSTOS ACUMULADOS: " + this.iCustoCaminho);

			for(iSize=0;iSize<iAux+1;iSize++)
			{
				pNovoCaminho.add(this.pCaminho.get(iSize));
				iNovoCustoCaminho.add(this.iCustoCaminho.get(iSize));
				if(Simulacao.debug2)
					System.out.println("\n\nCUSTO PARCIAL (LOOP): " + iNovoCustoCaminho);	
			}
			
			this.iCusto=iNovoCustoCaminho.getLast();
			this.iComprimento=iSize-1;
			pCaminho=pNovoCaminho;
			iCustoCaminho=iNovoCustoCaminho;
			if(Simulacao.debug2)
			{
				System.out.println("\n\nINSERE CAMINHO:\nNOVO CAMINHO: " + pCaminho);
				System.out.println("TENHO CUSTO (LOOP): " + iCusto);
				System.out.println("TENHO Comprimento (LOOP): " + iComprimento);
				System.out.println("TENHO Conforto (LOOP): " + dConforto);
				System.out.println("TENHO VECTOR CUSTOS (LOOP): " + iNovoCustoCaminho);
				System.out.println();
			}
		}
		else
		{
			iCusto = iCusto + pPosicao.aArestas[aleatorio].getCusto();
			iCustoCaminho.add(iCusto);
			pCaminho.addLast(pSalto); 
			pPosicao=pSalto;
			this.iComprimento++;
			if(Simulacao.debug2)
			{
				System.out.println("\n\nINSERE CAMINHO\n");
				System.out.println("COM CAMINHO: " + pCaminho);
				System.out.println("TENHO CUSTO: " + iCusto);
				System.out.println("TENHO Comprimento: " + iComprimento);
				System.out.println("TENHO Conforto: " + dConforto);
				System.out.println("TENHO VECTOR CUSTOS: " + iCustoCaminho);
				System.out.println();
			}
		}
	
	}
	
	/**
	 * Efectua um clone do individuo.
	 * Obtem uma parcela ou totalidade do caminho do pai.
	 * Actualiza todas as suas variaveis.
	 * 
	 * @param simulacao 
	 * @return indClone Clone do individuo
	 */
	Individuo Clonar(Simulacao simulacao)
	{
		//mudar para clonable?		
		Individuo indClone = new Individuo(simulacao, this.pPosicao, 0, 0, 0, this.dConforto);
		int iAux;
		int i,j;

		//Clone tera sempre o ponto inicial
		indClone.pCaminho=new LinkedList<Ponto>();
		indClone.pCaminho.add(this.pCaminho.get(0));
		
		iAux = (int) Math.round(this.iComprimento*0.9);
		//Copia 90% do caminho
		for(i=1;i<iAux;i++)
		{
			indClone.pCaminho.add(this.pCaminho.get(i));
			indClone.iCustoCaminho.add(this.iCustoCaminho.get(i));
		}
		
		i=(int) Math.round(indClone.dConforto*0.1);

		for(j=iAux;j<i;j++)
		{
			indClone.pCaminho.add(this.pCaminho.get(iAux));
			indClone.iCustoCaminho.add(this.iCustoCaminho.get(iAux));
		}
		
		//Actualiza posicao
		indClone.pPosicao=indClone.pCaminho.getLast();

		//Actualiza distancia
		indClone.dDistancia=dDistancia(indClone.pPosicao);
		indClone.iCusto=indClone.iCustoCaminho.getLast();
		indClone.iComprimento=indClone.pCaminho.size()-1;
		
		//Actualiza conforto
		indClone.CalculaConforto(simulacao);
		if(Simulacao.debug2)
		{
			System.out.println("\nREPRODUCAO\n\nTENHO CAMINHO DO PAI: " + this.pCaminho + "\nMEU CAMINHO: "+ indClone.pCaminho);
			System.out.println("Custo: " + indClone.iCusto + "\nComprimento: "+ indClone.iComprimento + "\nDistancia: " + indClone.dDistancia);
		}
		return indClone;
	}
	
	/**
	* Cria um evento do tipo de deslocamento para o individuo.
	* Verifica se o tempo em que vai ser executado e inferior ao tempo limite da simulacao.
	* 
	* @param simulacao detalhes da simulacao
	* 
	* @see EvDeslocamento
	*/
	public void CriaEvDeslocamento(Simulacao simulacao) 
	{
		double dTempo;
		Evento evAux;
				
		//Coloca evento de deslocamento		
		dTempo=Simulacao.expRandom(((1-Math.log(this.dConforto))*simulacao.getParamDeslocamento())) + simulacao.getTempo();
		
		if(dTempo<=simulacao.getInstFinal())
		{
			evAux = new EvDeslocamento(this,dTempo);
			simulacao.cap.AdicionaEvento(evAux);
			simulacao.cap.incNumEventosRestantes();
			this.evMeusEventos[ETipo.DESLOCAMENTO.idx()]=evAux;
			if(Simulacao.debug)
				System.out.println("Criei Evento Deslocamento em " + dTempo);
		}
	}
	
	
	/**
	 * Cria um evento de reproducao.
	 * O evento e colocado na lista de eventos da CAP, no caso de ocorrer antes do final da simulacao
	 * @param simulacao detalhes da simulacao
	 * @see EvReproducao
	 */
	public void CriaEvReproducao(Simulacao simulacao) 
	{
		double dTempo;
		Evento evAux;
		//Coloca evento de reproducao
		dTempo=Simulacao.expRandom(1-Math.log(this.dConforto)*simulacao.getParamReproducao()) + simulacao.getTempo();
		
		if(dTempo<=simulacao.getInstFinal())
		{
			evAux = new EvReproducao(this,dTempo);
			simulacao.cap.AdicionaEvento(evAux);
			simulacao.cap.incNumEventosRestantes();
			this.evMeusEventos[ETipo.REPRODUCAO.idx()]=evAux;
			if(Simulacao.debug)
				System.out.println("Criei Evento Reproducao em " + dTempo);
		}
		
	}

	/**
	 * Cria um evento de morte.
	 * O evento e colocado na lista de eventos da CAP, no caso de ocorrer antes do final da simulacao
	 * @param simulacao detalhes da simulacao
	 * @see EvMorte
	 */
	public void CriaEvMorte(Simulacao simulacao) 
	{
		double dTempo;
		Evento evAux;

		//Coloca evento de morte
		
		dTempo=Simulacao.expRandom((1-Math.log(1-this.dConforto))*simulacao.getParamMorte())+simulacao.getTempo();
			
		if(dTempo<=simulacao.getInstFinal())
		{
			evAux = new EvMorte(this,dTempo);
			simulacao.cap.AdicionaEvento(evAux);
			simulacao.cap.incNumEventosRestantes();
			this.evMeusEventos[ETipo.MORTE.idx()]=evAux;	

			if(Simulacao.debug)
				System.out.println("Criei Evento Morte em " + dTempo);
		}
	}

	/**
	 * Verifica se a posicao actual do individuo e o ponto final.
	 * @param pFinal coordenadas do ponto final
	 * @param simulacao detalhes da simulacao
	 * @return True caso tenha esteja no ponto final 
	 */
	public boolean PontoFinal(Ponto pFinal, Simulacao simulacao) {
		if(this.pPosicao.iX == pFinal.iX && this.pPosicao.iY == pFinal.iY)
		{
			simulacao.setFinalAtingido(true);
			return true;
		}
			return false;
	}

	/**
	 * Remove os seus eventos futuros, que possam estar presentes na CAP
	 * @param cap contem os eventos a simular
	 * @return true caso o individuo esteja no top5
	 * 
	 * @see CAP
	 */
	boolean RemoveEventosFuturos(CAP cap)
	{
		//Remove os meus eventos futuros, se existirem
		if(this.evMeusEventos[ETipo.REPRODUCAO.idx()]!=null)
		{
			cap.removeEvento(this.evMeusEventos[ETipo.REPRODUCAO.idx()]);
			this.evMeusEventos[ETipo.REPRODUCAO.idx()]=null;
			cap.decNumEventosRestantes();
		}
		if(this.evMeusEventos[ETipo.DESLOCAMENTO.idx()]!=null)
		{
			cap.removeEvento(this.evMeusEventos[ETipo.DESLOCAMENTO.idx()]);
			this.evMeusEventos[ETipo.DESLOCAMENTO.idx()]=null;
			cap.decNumEventosRestantes();
		}
		if(this.evMeusEventos[ETipo.MORTE.idx()]!=null)
		{
			cap.removeEvento(this.evMeusEventos[ETipo.MORTE.idx()]);
			this.evMeusEventos[ETipo.MORTE.idx()]=null;
			cap.decNumEventosRestantes();
		}

		return this.bTop5;
	}

}
	

