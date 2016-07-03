package simpop;


/**
 * EvListagem e uma sub classe de Evento, usada para identificar eventos de listagem.
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class EvListagem extends Evento 
{
	static int iObs;
	
	/**
	 * Inicializa o evento para o tempo indicado
	 * @param indHumano sem efeito
	 * @param iTempoAcontecimento tempo em que ira ser realizado
	 */
	EvListagem(Individuo indHumano, double iTempoAcontecimento)
	{
		//Inicializa o evento
		super(indHumano);
		this.dTempo=iTempoAcontecimento;
	}
	
	/**
	 * Redefinicao do metodo Executa() da classe evento.
	 * Imprime observacoes periodicas no terminal.
	 * @param simulacao detalhes da simulacao
	 * @return Evento Proximo evento a ser realizado
	 */
	@Override
	Evento Executa(Simulacao simulacao)
	{
		
		//Actualiza variaveis
		iObs++;
		//Simulacao.iNumEventos++;
		simulacao.setTempo(this.dTempo);
		
		//Gera texto para o terminal
		System.out.println("Observacao: " + iObs);
		System.out.println("\t\tInstante actual: " + this.dTempo);
		System.out.println("\t\tNumero de eventos realizados: " + simulacao.getNumEventos());
		System.out.println("\t\tDimensao da populacao: " + simulacao.getPopActual());	
		System.out.println("\t\tFoi atingido o ponto final: " + (simulacao.getFinalAtingido()?"Sim":"Nao"));
		System.out.print("\t\tCaminho do individuo mais adaptado: ");
		//System.out.print("(" +(pAux.iY+1)+","+(pAux.iX+1)+")");
		System.out.println(simulacao.populacao.imprimeCaminho());
			
		System.out.println("\t\tCusto/Conforto: " + simulacao.populacao.getCustoCaminho() + " / " + simulacao.populacao.getConfortoCaminho());		
		return simulacao.cap.evBuscaEvento();
	}
		
}
