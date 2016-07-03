package simpop;

/**
 * A classe Aresta permite associar a um {@link Ponto} destino um custo.
 * Cada aresta e unidireccionar, permitindo apenas aceder ao proximo ponto.
 * Por sua vez, através do proximo ponto, e possivel aceder as arestas do mesmo.
 * 
 * A direccao da aresta e baseado num valor inteiro:
 * 
 *  <lu>
 *  <li> Esquerda (0)
 *  <li> Cima (1)
 *  <li> Direita (2)
 *  <li> Esquerda (3)
 *  </lu>
 *  
 * @see Ponto
 * @see Grelha
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class Aresta
{
	int iCusto;
	Ponto pProximo;

	/**
	 * Devolve o custo associado a travessia da aresta pelo individuo. 
	 * Este custo ira influenciar o conforto do individuo.
	 * @return <code>iCusto</code>
	 */
	int getCusto(){return iCusto;}
	
	/**
	 * Devolve o ponto ao qual o individuo irá chegar, ao atravessar esta aresta.
	 * @return Ponto ponto extremo
	 */
	Ponto getProximo(){return pProximo;}
	
	/**
	 * Atribui <code>iCusto</code> ao custo que leva a atravessar a aresta.
	 * @param iCusto valor atribuido ao custo
	 */
	void setCusto(int iCusto){this.iCusto=iCusto;}
	
	/**
	 * Atribui a <code>this.pProximo</code>, o ponto na extremidade da aresta, o ponto <code>pProximo</code>. 
	 * @param pProximo ponto destino
	 */
	void setProximo(Ponto pProximo){this.pProximo=pProximo;}

	/**
	 * Inicializa a aresta com os valores por defeito.
	 * 
	 * <ul> 
	 * <li> <code>iCusto</code> - atribui por omissao o valor 1 ao seu custo
	 * <li> <code>pProximo</code> - ponto a colocar no outro extremo da aresta
	 * </ul> 
	 * <p>
	 * 
	 * @param Proximo ponto destino
	 */
	Aresta(Ponto Proximo)
	{
		this.iCusto=1;
		this.pProximo=Proximo;
	}
	
}
