package simpop;

/**
 * A classe Ponto associa a uma coordenada do tabuleiro, quatro arestas (se possível).
 * 
 * @see Aresta
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class Ponto 
{
	int iX;
	int iY;
	Aresta aArestas[] = new Aresta[4];
	
	Ponto(int iX, int iY) {
		this.iX = iX;
		this.iY = iY;
	}
	
	/**
	 * Inicia uma aresta e o ponto para o qual aponta.
	 * A aresta tem quatro sentidos possiveis:
	 *  0 - Esquerda
	 *  1 - Cima
	 *  2 - Direita
	 *  3 - Baixo
	 * 
	 * @param pos indica a sua direcao 
	 * @param Proximo o ponto destino
	 */
	public void setAresta(int pos,Ponto Proximo){
		
		this.aArestas[pos] = new Aresta(Proximo);
				
		if(Simulacao.debug)
			System.out.println("X=" + this.aArestas[pos].pProximo.iX + "Y=" + this.aArestas[pos].pProximo.iY);
		
	}
	
	/**
	 * Retorna a posicao actual como uma string (x,y)
	 */
	@Override 
	public String toString() {
		return String.format("(%d,%d)",this.iY+1,this.iX+1);
	}
	
}
