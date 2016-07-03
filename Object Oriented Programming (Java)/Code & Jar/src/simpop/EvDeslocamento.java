package simpop;

import java.util.LinkedList;

/**
 * EvDeslocamento e uma sub classe de Evento, usada para identificar eventos de deslocamento.
 * @see Evento
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class EvDeslocamento extends Evento
{
	/**
	 * Inicializa o evento com <code>iTempoAcontecimento</code> e associa-o a <code>indHumano</code>.
	 * @param indHumano individuo associado ao evento
	 * @param iTempoAcontecimento tempo em que ira ocorrer
	 */
	EvDeslocamento(Individuo indHumano, double iTempoAcontecimento)
	{
		//Inicializa o evento
		super(indHumano);
		this.dTempo=iTempoAcontecimento;
	}
	
	/**
	 * Redefinicao do metodo Executa() da classe evento.
	 * Efectua um deslocamento aleatorio para o individuo,
	 * criando um novo evento no futuro.
	 *
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
		
		indHumano.evMeusEventos[ETipo.DESLOCAMENTO.idx()]=null;
		
		//Efectua salto e guarda caminnho
		indHumano.InsereCaminho();

		//actualiza conforto
		indHumano.CalculaConforto(simulacao);
		
		if(Simulacao.debug2)
			System.out.println("TENHO Conforto (ACTUALIZADO): " + indHumano.dConforto);		
		
		//Verifica se pertence ao Top5
		simulacao.populacao.ActualizaTop5(indHumano, simulacao);
		
		if((simulacao.getFinalAtingido() && indHumano.PontoFinal(simulacao.grelha.getFinal(), simulacao) 
				&& (indHumano.iCusto<simulacao.populacao.getCustoCaminho())) 
				|| (!simulacao.getFinalAtingido() && indHumano.PontoFinal(simulacao.grelha.getFinal(),simulacao)))
		{
			LinkedList<Ponto> pCaminhoAux = new LinkedList<Ponto>();
			int iAux;
			
			for(iAux=0;iAux<indHumano.pCaminho.size();iAux++)
			{
				pCaminhoAux.add(indHumano.pCaminho.get(iAux));
			}
			simulacao.populacao.setConfortoCaminho(indHumano.dConforto);
			simulacao.populacao.setCustoCamiho(indHumano.iCusto);
			simulacao.populacao.setMelhorCaminho(pCaminhoAux);
		}
			
		//Cria um novo evento futuro
		indHumano.CriaEvDeslocamento(simulacao);
		
		return simulacao.cap.evBuscaEvento();
	}
	
}

