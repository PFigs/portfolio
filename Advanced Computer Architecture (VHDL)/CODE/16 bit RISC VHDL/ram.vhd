----------------------------------------------------------------------------------

----------------------------------------------------------------------------------

-------------------------- Componente memoria ------------------------------------

----------------------------------------------------------------------------------

-- Entrada de configuracao:														--

--  dim - dimensao da memoria (numero de palavra de 16 bits)					--

--																				--

-- Portos de entrada de controlo de leitura e escrita nos ficheiros:			--

--	read_file  - carrega a memoria com os dados presentes no ficheiro "rom.out"	--

--  write_file - carrega no ficheiro "data.out" os dados presentes na memoria	--

--																				--

-- Portos de acesso a memoria:													--

--   WE 	- enable de escrita													--

--   clk    - sinal de relogio													--

--   ADRESS - endere�o de acesso a memoria										--

--	 DATA   - entrada de daos para escrita										--

--   Q      - saida de dados para leitura									    --

----------------------------------------------------------------------------------

--           Componente memoria desenvolvida para a disciplina de 			    --

--                 Aplicacoes Avancadas de Microprocessadores 					--

----------------------------------------------------------------------------------

----------------------------------------------------------------------------------



library IEEE;

use IEEE.std_logic_1164.all;

use IEEE.std_logic_unsigned.all;

use STD.TEXTIO.all;

use STD.TEXTIO;

use IEEE.STD_LOGIC_TEXTIO.all;	





entity ram is

	generic (dim : integer := 1024)	;

	port (

-- bits de controlo de escrita no ficheiro----

		read_file : in STD_LOGIC;

		write_file : in STD_LOGIC;

-----------------------------------------------	

		WE : in STD_LOGIC;

		clk: in STD_LOGIC;

		ADRESS : in STD_LOGIC_VECTOR(15 downto 0);	 

		DATA : in STD_LOGIC_VECTOR (15 downto 0);

		Q : out STD_LOGIC_VECTOR (15 downto 0)

	);

end ram;



architecture ram_arch of ram is



type ram_mem_type is array (dim-1 downto 0) of STD_LOGIC_VECTOR (15 downto 0);

signal ram_mem, ram_mem2 : ram_mem_type;

	

begin



------------------------------------------------------------------------------

-- acesso a memoria ----------------------------------------------------------

------------------------------------------------------------------------------



process (clk)

	variable ADDRwr_TEMP: integer;

	begin

	  if((clk'event) and (clk='1')) then 

		if (read_file = '1') then

			ram_mem <= ram_mem2;

		elsif ((WE = '1') and (not (read_file = '1'))) then 

			ADDRwr_TEMP := CONV_INTEGER(ADRESS); 

				assert(dim > ADDRwr_TEMP)

				     report " Tentou aceder a uma posicao de memoria nao defenida!"

     					severity ERROR; --FAILURE; --WARNING;

  			ram_mem(ADDRwr_TEMP) <= DATA;

		end if;

	  end if;	

	end process;								

	Q <= ram_mem(CONV_INTEGER(ADRESS));

	

------------------------------------------------------------------------------

--quando read_file transita para '1' o ficheiro rom.out e escrito na memoria--

------------------------------------------------------------------------------



le: process(read_file)

file INFILE : TEXT  is in "teste";

variable DATA_TEMP : STD_LOGIC_VECTOR(15 downto 0);	

variable IN_LINE: LINE;  		



variable index :integer;

begin			 

	if((read_file'event) and (read_file='1')) then

	  index := 0;

	  while NOT(endfile(INFILE)) loop

		readline(INFILE,IN_LINE);	

		hread(IN_LINE, DATA_TEMP);	

		ram_mem2(index) <= DATA_TEMP;

		index := index + 1;

	  end loop;

	end if;		

end process le;	



--------------------------------------------------------------------------------

--quando write_file transita para '1' a memoria e escrita no ficheiro data.out--

--------------------------------------------------------------------------------



esc: process( write_file)	

file OUTFILE : TEXT  is out "data.out";

variable OUT_LINE : LINE;

variable index :integer;

begin

if((write_file'event) and (write_file='1')) then

	  index := 0;

		while (index < dim) loop	

--		write(OUT_LINE,index);

--		write(OUT_LINE,":");

		hwrite(OUT_LINE,ram_mem(index));

		writeline(OUTFILE,OUT_LINE);	

		index := index + 1;

	  end loop;

	end if;	

end process esc;	



end ram_arch;

