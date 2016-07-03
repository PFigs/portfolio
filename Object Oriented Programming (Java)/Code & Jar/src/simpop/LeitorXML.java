package simpop;
import org.xml.sax.Attributes;
import org.xml.sax.SAXException;
import org.xml.sax.SAXParseException;
import org.xml.sax.helpers.DefaultHandler;
/**
 * Efectua a leitura do ficheiro xml, actualizando o valor
 * das variaveis nas clases Simulacao e Grelha.
 * 
 * Para alem disso, permite a validacao do ficheiro
 * de entrada.
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
class LeitorXML extends DefaultHandler{
	
	//Nome do ficheiro
	private String sFileName;
	
	//Temporarias
	private int xinicial;
	private int yinicial;
	private int xfinal;
	private int yfinal;
	private int custo;
	private int num;
	//temporario
	private String TempVal;

	//Associacao

	Simulacao simAux;
	
	
	LeitorXML(Simulacao simulacao){
		simAux = simulacao;
		simAux.grelha = new Grelha();
	}
	
	
	public void startDocument ()throws SAXException
	{	
		if(Simulacao.debug)
			System.out.println("Inicio analise de "+ sFileName);
		
	}
	
	public void error(SAXParseException exception) throws SAXException {
	       // Bring things to a crashing halt
        System.out.println("**Parsing Error**" + "  Line:    " + exception.getLineNumber() +
        		" " +  "  URI:     " + exception.getSystemId() + " " +   "  Message: " +
        		exception.getMessage());
        throw new SAXException("Error encountered");
	}

	public void endDocument()throws SAXException
	{
		if(Simulacao.debug)
			System.out.println("Concluida analise");
		if(!simAux.grelha.validaExtremos())
		{
			System.err.format("Individuos sem asas!\n");
			System.exit(-1);
		}
				
	}
	
	
	/**
	 * Implementa o metodo startElement do analisador SAX. 
	 * &Tem como funcao actualizar variaveis nas classes Simulacao e Grelha. 
	 */
	public void startElement(String sUri, String sName, String sTag, Attributes aAtributos)throws SAXException
	{
	    
	    if (sTag.equals("simulacao"))
	    {	    	
	    	
    		simAux.setSimulacao(Integer.parseInt(aAtributos.getValue("instfinal")),
	    			Integer.parseInt(aAtributos.getValue("popinicial")),
	    			Integer.parseInt(aAtributos.getValue("popmaxima")),
	    			Integer.parseInt(aAtributos.getValue("sensconforto")));
    		
	    }
	    else if(sTag.equals("grelha"))
	    {
	    	simAux.grelha.setDimGrelha(Integer.parseInt(aAtributos.getValue("numcolunas")),
	    			Integer.parseInt(aAtributos.getValue("numlinhas")));	    	
	    }else if(sTag.equals("pontoinicial"))
	    {
	    	
	    	simAux.grelha.setPontoInicial(Integer.parseInt(aAtributos.getValue("yinicial"))-1,
	    	Integer.parseInt(aAtributos.getValue("xinicial"))-1);
	    	
	    }else if(sTag.equals("pontofinal"))
	    {
	    	simAux.grelha.setPontoFinal(Integer.parseInt(aAtributos.getValue("yfinal"))-1,
	    			Integer.parseInt(aAtributos.getValue("xfinal"))-1);
	    }
	    else if(sTag.equals("zonascustoespecial"))
	    {
	    	if(Simulacao.debug)
	    		System.out.println("Tenho zona custo especial");
	    }
	    else if(sTag.equals("zona"))
	    {
	    	//Guardar localmente numero de zonas e pontos iniciais e finais.
	    	xinicial = Integer.parseInt(aAtributos.getValue("xinicial"));
	    	yinicial = Integer.parseInt(aAtributos.getValue("yinicial"));
	    	xfinal   = Integer.parseInt(aAtributos.getValue("xfinal"));
	    	yfinal   = Integer.parseInt(aAtributos.getValue("yfinal"));
	    }
	    else if(sTag.equals("obstaculos"))
	    {
	    	num=Integer.parseInt(aAtributos.getValue("num"));
	    }
	    else if(sTag.equals("obstaculo"))
	    {
	    	if(num>0)
	    	{
	    		simAux.grelha.setObstaculo(Integer.parseInt(aAtributos.getValue("ypos"))-1,
	    			Integer.parseInt(aAtributos.getValue("xpos"))-1);
	    		num--;
	    	}
	    }
	    else if(sTag.equals("eventos"))
	    {
	    	if(Simulacao.debug)
	    		System.out.println("A processar eventos");
	    }
	    else if(sTag.equals("morte"))
	    {
	    	simAux.setParam(Integer.parseInt(aAtributos.getValue("param")),ETipo.MORTE);
	    }
	    else if(sTag.equals("reproducao"))
	    {
	    	simAux.setParam(Integer.parseInt(aAtributos.getValue("param")),ETipo.REPRODUCAO);
	    }
	    else if(sTag.equals("mutacao"))
	    {
	    	simAux.setParam(Integer.parseInt(aAtributos.getValue("param")),ETipo.DESLOCAMENTO);
	    }
	    else
	    {
	    	System.out.println("Erro");
	    }
	}
	
	
	/**
	 * Efectua a leitura do custo da zona especial 
	 */
	public void characters(char[] ch, int start, int length) throws SAXException 
	{
		TempVal = new String(ch,start,length);
	}
	
	/**
	 * Actualiza a grelha com a zona de custo especial, assim que obtiver todos os detalhes sobre esta 
	 */
	public void endElement(String namespaceURI, String localName,String qualifiedName)throws SAXException {
		    
		      if (qualifiedName.equals("zona"))
		      {
		    	  custo = Integer.parseInt(TempVal);
		    	  simAux.grelha.setPontoEspecial(yinicial-1, xinicial-1, yfinal-1, xfinal-1, custo);
		      }
	}



}
