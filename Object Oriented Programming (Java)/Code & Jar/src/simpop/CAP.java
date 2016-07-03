package simpop;

import java.util.Comparator;
import java.util.PriorityQueue;

/**
 * A classe CAP contem uma lista ordenada (por tempo de execucao), dos eventos a serem simulados.
 *
 * @see Evento
 *
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class CAP 
{	
	//Eventos realizados
	private int iNumEventosRestantes=0;
	
	//Comparador de eventos
	private Comparator<Evento> comparador = new ComparaEventos();
	
	//Lista de prioridade com os eventos a serem simulados
	private PriorityQueue<Evento> evListaEventos;
	
	/**
	 * Inicializa a CAP com todos os eventos de listagem.
	 * @param simulacao detalhes da simulacao
	 */
	CAP(Simulacao simulacao)
	{
		int iTempo;
		int iAux=simulacao.getInstFinal();
		
		evListaEventos  = new PriorityQueue<Evento>(simulacao.getPopInicial()*3, comparador);
		
		//Adiciona eventos de listagem na CAP
		for(iTempo=0;iTempo<=simulacao.getInstFinal();iTempo=iTempo+iAux/20)
		{
			Evento evEventoAux = new EvListagem(null,iTempo);
			AdicionaEvento(evEventoAux);
		}
	}
	
	
	/**
	 * Adiciona um evento a lista de eventos a executar.
	 * @param eEvento Evento a ser adicionado
	 */
	void AdicionaEvento(Evento eEvento)
	{
		evListaEventos.add(eEvento);
		
	}
	
	/**
	 * Retira primeiro evento da lista de eventos.
	 */
	Evento evBuscaEvento(){return evListaEventos.poll();}
	
	/**
	 * Obtem o numero de eventos restantes na CAP. 
	 */
	public int getNumEventosRestantes() {return this.iNumEventosRestantes;}
	
	/**
	 * Coloca Num como o numero de eventos restantes na CAP 
	 */
	public void setNumEventosRestantes(int Num) {this.iNumEventosRestantes=Num;}

	/**
	 * Incrementa o numero de eventos restantes,
	 */
	public void incNumEventosRestantes() {this.iNumEventosRestantes++;}
	
	/**
	 * Decrementa o numero de eventos restantes,
	 */
	public void decNumEventosRestantes() {this.iNumEventosRestantes--;}

	/**
	 * Remove o evento da lista de eventos.
	 * @param evento evento a remover
	 */
	public void removeEvento(Evento evento) {this.evListaEventos.remove(evento);}

}
