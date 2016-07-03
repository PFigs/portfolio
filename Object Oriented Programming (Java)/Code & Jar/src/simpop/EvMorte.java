package simpop;


/**
* EvDeslocamento e uma sub classe de Evento, usada para identificar eventos de deslocamento.
* @see Evento
*  
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
**/
class EvMorte extends Evento{

	
	EvMorte(Individuo indHumano, double iTempoAcontecimento)
	{
		//Inicializa o evento
		super(indHumano);
		this.dTempo=iTempoAcontecimento;
	}
	/**
	 * Redefinicao do metodo Executa() da classe evento.
	 * Trata a morte do individuo indicado pelo evento.
	 * @param simulacao detalhes da simulacao
	 * @return Evento Proximo evento a ser realizado
	 */
	@Override
	Evento Executa(Simulacao simulacao)
	{
		//Actualiza variaveis
		simulacao.incNumEventos();
		simulacao.cap.decNumEventosRestantes();
		simulacao.setTempo(this.dTempo);
		simulacao.decPopActual();
		
		indHumano.evMeusEventos[ETipo.MORTE.idx()]=null;
		
		//Removo os meus eventos futuros e retiro-me de uma das listas
		if(indHumano.RemoveEventosFuturos(simulacao.cap))
			simulacao.populacao.RemoveTop5(this.indHumano);
		
		simulacao.populacao.removeRestantes(this.indHumano);
		
		if(Simulacao.debug)
			System.out.println("Executei Evento Morte em " + this.dTempo);
		
		return simulacao.cap.evBuscaEvento();
	}
}