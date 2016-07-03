package simpop;

import java.util.Comparator;

/**
 * Classe que implementa o comparador de eventos.
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class ComparaEventos implements Comparator<Evento>{

	/**
	 * Compara os tempos de execucao de <code>ev1</code> e <code>ev2</code>.
	 * @return 0 caso ocorram no mesmo instante, -1 caso <code>ev1</code> seja menor e 1 caso contrario.
	 */
	public int compare(Evento ev1, Evento ev2) 
	{	
		if(ev1.dTempo<ev2.dTempo) return -1;
		if(ev1.dTempo==ev2.dTempo) return 0;
		if(ev1.dTempo>ev2.dTempo) return 1;
		return 0;
	}

	
}