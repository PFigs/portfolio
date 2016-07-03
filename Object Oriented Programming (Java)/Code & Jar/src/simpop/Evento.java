package simpop;

/**
 * Classe abstracta a qual se podem associar diversos tipos de evento.
 * Cada evento tem um individuo e um tempo associado.
 * O instante associado a cada evento sera o tempo actual durante a sua execucao.
 * 
 * @see CAP
 * @see Individuo
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
abstract class Evento 
{
	double dTempo;
	Individuo indHumano;
	
	/**
	 * Construtor que permite associar um individuo ao evento
	 * @param indHumano
	 */
	Evento(Individuo indHumano){this.indHumano=indHumano;}
	
	/**
	 * Metodo abstracto que sera redefinido pelos diversos tipos de eventos.
	 * @param simulacao detalhes da simulacao
	 * @return Evento proximo evento a realizar
	 */
	abstract Evento Executa(Simulacao simulacao);
}
