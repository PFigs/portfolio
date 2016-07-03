package simpop;

import java.io.File;
import java.io.IOException;
import java.util.Random;

import javax.xml.parsers.ParserConfigurationException;
import javax.xml.parsers.SAXParser;
import javax.xml.parsers.SAXParserFactory;

import org.xml.sax.SAXException;


/**
 * A classe Simulacao contem toda a informacao sobre a populacao e tabuleiro a simular.
 * Esta classe pede a leitura de um ficheiro xml, que e passado como argumento, atraves da linha de comandos.
 * Como atributos, para alem de alguns inteiros, contem uma grelha, com a representacao do ficheiro, uma populacao, com os individuos actuais
 * e uma cap, com os eventos a simular.
 *
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 * <p>
 */
public class Simulacao 
{
	//Obtidos do ficheiro
	private int iInstFinal;
	private int iPopInicial;
	private int iPopMaxima;
	private int iSensConforto;
	private int iParamMorte;
	private int iParamReproducao;
	private int iParamDeslocamento;
	
	//Modificados durante a execucao
	private int iPopActual;
	private int iNumEventos=0;
	private double dTempo;
	protected Populacao populacao;
	protected Grelha grelha;
	protected CAP cap;
	
	
	//Variavel para obter numero aleatorio
	static Random lotaria = new Random();
	
	//Associacoes
	
	//Controlo
	private Boolean bFinalAtingido=false;

	//Debug
	static boolean debug;
	static boolean debug2;
		
	
	/**
	 *Permite inicializar os parametros da simulacao
	 *
	 *@param instfinal instante final da simulacao
	 *@param popinicial populacao inicial
	 *@param popmaxima populacao maxima
	 *@param sensconforto sensibilidade ao conforto
	 */
	public void setSimulacao (int instfinal, int popinicial, int popmaxima, int sensconforto)
	{
		this.iInstFinal=instfinal;
		this.iPopInicial=popinicial;
		this.iPopMaxima=popmaxima;
		this.iSensConforto=sensconforto;
		
		if(debug)
		{
			System.out.println();
			System.out.println("@Sim:Recebi do ficheiro...");
			System.out.println("@Sim:Instante Final " + iInstFinal);
			System.out.println("@Sim:Populacao Inicial " + iPopInicial);
			System.out.println("@Sim:Populacao Maxima " + iPopMaxima);
			System.out.println("@Sim:Sensibilidade Conforto " + iSensConforto);
			System.out.println();
		}
    		
	}	
	
	
	/**
	 * Inicializa os parametros dos eventos
	 * 
	 * @param iParam parametro referente ao evento
	 * @param eTipoEv tipo de evento
	 */
	public void setParam(int iParam, ETipo eTipoEv)
	{
		switch(eTipoEv)
		{
		case MORTE:
			//Morte
			iParamMorte=iParam;
			if(debug)
				System.out.println("Morte " + iParamMorte);
			break;
		case REPRODUCAO:
			//Reproducao
			iParamReproducao=iParam;
			if(debug)
				System.out.println("Reproducao " + iParamReproducao);
			break;
			
		case DESLOCAMENTO:
			//Mutacao
			iParamDeslocamento=iParam;
			if(debug)
				System.out.println("Mutacao " + iParamDeslocamento);
			break;
		
		}
		
	}
	
	
	/**
	 * Obtem uma observacao de uma variavel aleatoria de media m.
	 * 
	 * @param m media da observacao
	 * @return valor observado da variavel aleatoria
	 */
	static double expRandom(double m) 
	{
		double next = lotaria.nextDouble();
		return -m*Math.log(1.0-next);
	}
	
	
	/**
	 * Da inicio ao programa
	 * @param argumentos nome do ficheiro XML
	 */
	public static void main(String[] argumentos)
	{
		Simulacao simulacao = new Simulacao();
		LeitorXML leitorXML = new LeitorXML(simulacao);
		
		debug=false;
		
		//Efectua a leitura do ficheiro XML
		try{
			simulacao.Start(argumentos[0], leitorXML);
		}
		catch(Exception e){
			System.out.println("ERRO: Simulacao <ficheiro.xml>");
			System.exit(-1);
		}
		
		//Inicia CAP
		simulacao.cap = new CAP(simulacao);
		
		simulacao.populacao = new Populacao(simulacao);		
		
		Evento evAux;
		//Obtem o primeiro evento
		if((evAux = simulacao.cap.evBuscaEvento())!=null)
			for(simulacao.dTempo=0, simulacao.iNumEventos=0;true;)
			{	
				//Executa o proximo evento e recebe o proximo
				if((evAux=evAux.Executa(simulacao))==null)break;			
				if(simulacao.cap.getNumEventosRestantes()==0) 
				{
					evAux.Executa(simulacao);
					break;
				}
				if(simulacao.iPopActual==0)
				{ 
					//Gera texto para o terminal
					System.out.println("Observacao: " + (EvListagem.iObs+1));
					System.out.println("\t\tInstante actual: " + simulacao.dTempo);
					System.out.println("\t\tNumero de eventos realizados: " + simulacao.iNumEventos);
					System.out.println("\t\tDimensao da populacao: " + simulacao.iPopActual);	
					System.out.println("\t\tFoi atingido o ponto final: " + (simulacao.getFinalAtingido()?"Sim":"Nao"));
					System.out.print("\t\tCaminho do individuo mais adaptado: ");
					//System.out.print("(" +(pAux.iY+1)+","+(pAux.iX+1)+")");
					System.out.println(simulacao.populacao.imprimeCaminho());
					System.out.println("\t\tCusto/Conforto: " + simulacao.populacao.getCustoCaminho() + " / " + simulacao.populacao.getConfortoCaminho());
					break;
				}
			}	
		//Garante limpeza final
		System.gc();
	}


	//set
	/**
	 * Atribui iPop como o valor actual da populacao
	 * @param iPop
	 */
	public void setPopActual(int iPop) {this.iPopActual=iPop;}
	
	/**
	 * Atribui o tempo actual ao tempo de simulacao
	 * @param dTempo tempo actual
	 */
	public void setTempo(double dTempo) { this.dTempo=dTempo;}
	
	/**
	 * Sinaliza que o final foi atingido. Verdadeiro caso tenha sido atingido. 
	 * @param finalAtingido Valor da condicao
	 */
	public void setFinalAtingido(boolean finalAtingido) { this.bFinalAtingido=finalAtingido ;}
	

	
	//get
	
	/**
	 * Devolve o instante final da simulacao
	 */
	public int getInstFinal() { return this.iInstFinal;}
	
	/**
	 * Devolve o valor inicial da populacao
	 */
	public int getPopInicial() {return this.iPopInicial;}
	
	/**
	 * Devolve o parametro de sensibilidade ao conforto 
	 */
	public int getSensConforto() {return this.iSensConforto;}
	
	/**
	 * Devolve o parametro associado ao evento de deslocamento
	 */
	public int getParamDeslocamento() {return this.iParamDeslocamento;}
	
	/**
	 * Devolve o parametro associado ao evento morte
	 */
	public int getParamMorte() {return this.iParamMorte;}
	
	/**
	 * Devolve o parametro associado ao evento reproducao
	 */
	public int getParamReproducao() {return this.iParamReproducao;}
	
	/**
	 * Devolve o tempo actual da simulacao
	 */
	public double getTempo() {return this.dTempo;}
	
	/**
	 * Devolve o numeros de individuos vivos
	 */
	public int getPopActual() {return this.iPopActual;}
	
	/**
	 * Devolve o valor maximo para a populacao
	 */
	public int getPopMaxima() {return this.iPopMaxima;}
	
	/**
	 * Verifica se o ponto final foi atingido
	 */
	public boolean getFinalAtingido() {return this.bFinalAtingido;}
	
	/**
	 * Devolve o numero de eventos realizados
	 */
	public int getNumEventos() {return this.iNumEventos;}
	
	//inc e dec
	/**
	 * Incrementa o numero de eventos realizados
	 */
	public void incNumEventos() {this.iNumEventos++;}
	
	/**
	 * Incrementa o numero de individuos vivos
	 */
	public void incPopActual() {this.iPopActual++;}
	
	/**
	 * Decrementa o numero de individuos vivos
	 */
	public void decPopActual() {this.iPopActual--;}
	
	
	/**
	 * Inicia a leitura do ficheiro XML, verificando se o ficheiro cumpre as especificacoes do ficheiro DTD.
	 * @param sArg Nome do ficheiro XML 
	 * @param handler objecto da classe que implementa DefaultHandler
	 * 
	 * @see LeitorXML
	 */

	private void Start(String sArg, LeitorXML handler) 
	{
		String sFileName = sArg;
		
		
		//cria analisador SAX
	    try
	    {
	    	SAXParserFactory saxFact = SAXParserFactory.newInstance();
	    	SAXParser saxParser = saxFact.newSAXParser();
	    	saxFact.setValidating(true);
	    	
	  
	    	// analisa o documento com este manipulador
	    	saxParser.parse(new File(sFileName), handler);
	    }
	    catch(IOException e)
	    {
	    	System.err.println("Erro de IO");
	    	System.exit(-1);
	    }
	    catch(SAXException e)
	    {
	    	System.err.println("Ficheiro de entrada mal formatado");
	    	System.exit(-1);
	    }
	    catch(ParserConfigurationException e)
	    {
	    	System.err.println("Erro configuracao do analisador");
	    	System.exit(-1);
	    }
	}

}
