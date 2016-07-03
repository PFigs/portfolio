package simpop;


/**
 * Classe que contem um tipo enumerado para os eventos realizados.
 * Existe um indice associado a cada designacao textual:
 * 0 - Deslocamento
 * 1 - Reproducao
 * 2 - Morte
 * 3 - Listagem
 * 
 * @author Filipe Veiga <tt>(55062 - flipveiga@gmail.com)</tt>
 * <p>
 * Joao Santos <tt>(57988 - joaovgsantos@ist.utl.pt)</tt>
 * <p>
 * Pedro Silva  <tt>(58035 - pedro.silva@ist.utl.pt)</tt>
 */
public enum ETipo 
{
	DESLOCAMENTO (0),
	REPRODUCAO   (1),
	MORTE 		 (2),
	LISTAGEM	 (3);

	private final int idx;   // in kilograms

	/**
	 * Atribui o indice ao designacao textual do evento
	 * @param idx indice
	 */
	ETipo(int idx) {this.idx = idx;}

	/**
	 * Devolve o indice associado a designacao textual
	 */
	public int idx(){return idx;}
}