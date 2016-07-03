package simpop;

/**
 * EvReproducao e uma sub classe de Evento, usada para identificar eventos de reproducao.
 * 
 * @see Evento
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class EvReproducao extends Evento {
	
	/**
	 * Inicializa o evento no tempo especificado e efectua a associacao ao seu individuo
	 * @param indHumano individuo associado
	 * @param iTempoAcontecimento tempo em que ira ser realizado
	 */
	EvReproducao(Individuo indHumano, double iTempoAcontecimento)
	{
		//Inicializa o evento
		super(indHumano);
		this.dTempo=iTempoAcontecimento;
	}
	
	/**
	 * Redefinicao do metodo Executa() da classe evento.
	 * O individuo sofre reproducao.
	 *
	 * @return Evento Proximo evento a ser realizado
	 */
	@Override
	Evento Executa(Simulacao simulacao)
	{
		Individuo indFilho;
		//Actualiza variaveis		
		simulacao.incNumEventos();
		simulacao.cap.decNumEventosRestantes();
		simulacao.setTempo(dTempo); 
		
		indHumano.evMeusEventos[ETipo.REPRODUCAO.idx()]=null;
		indHumano.CriaEvReproducao(simulacao);
		
		if(Simulacao.debug)
			System.out.println("Executei Evento Reproducao em " + this.dTempo);
		
		//Clona-se e actualiza as suas variaveis
		indFilho = indHumano.Clonar(simulacao);
		
		simulacao.populacao.InsereIndividuo(indFilho,simulacao);
		
		if(simulacao.getPopActual()>=simulacao.getPopMaxima())
			simulacao.populacao.Epidemia(simulacao);
		else
			simulacao.populacao.CriaEventos(simulacao, indFilho);
		
		return simulacao.cap.evBuscaEvento();
	}
}
