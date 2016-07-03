----------------------------------------------------------------------------------
-- Instituto Superior Técnico 
-- 
-- Projecto Sistemas Digitais
-- 
-- Martim Camacho, martim.camacho@ist.utl.pt (56755)
-- Pedro Silva, pedro.silva@ist.utl.pt (58035)
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.PSDLIB.ALL;


entity control is
	Port(	clk	: in	STD_LOGIC;
			rst	: in	STD_LOGIC;
			
			RDaddrCIR: out std_logic_vector(8 downto 0); -- endereco MEM IN
			RDdata: in std_logic_vector(31 downto 0); -- DATA_OUT MEMIN
			
			WRaddrCir: out std_logic_vector(8 downto 0); -- Endereço MEMOUT
			WRenable: out std_logic; -- WE MEM OUT
			
			canSTART: in std_logic; -- ENABLE Circuito3
			
			endd: in std_logic;
			error : in	std_logic;
			cbits	: out	STD_LOGIC_VECTOR(cbits_size-1 downto 0);
			idx	: out	STD_LOGIC_VECTOR(idx_size-1 downto 0);
			m: out std_logic_vector(m_bits-1 downto 0);
			n: out std_logic_vector(m_bits-1 downto 0);
			mn: out std_logic_vector(line_bits-1 downto 0);
			
			
			execDONE: out std_logic;

			CNTbyte2: in std_logic_vector(11 downto 0)		
			
			
			);
end control;

architecture Behavioral of control is
	type   fsm_states is (s_wait, s_init, s_execute, s_end);
	signal currstate, nextstate : fsm_states;

	signal addr: std_logic_vector(8 downto 0);
	signal stall : std_logic_vector(1 downto 0);
	signal wire_cbits : std_logic_vector(cbits_size-1 downto 0);
	signal wire_WRaddrCir : std_logic_vector(WRaddrCir'range);
	
begin

	cbits <= wire_cbits;
	WRenable <= error;
	WRaddrCir <= wire_WRaddrCir;
	
	-- States
	state_reg : process (clk, rst)
	begin
		if clk'event and clk='1' then
			if rst = '1' then
				currstate <= s_wait;
			else 
				currstate <= nextstate;
			end if;
		end if;
	end process;

	state_comb : process (currstate, stall, endd, error, canstart)
	begin
-- (set)mn (write)mem_out (read)mem_in (flush reset ce)validator
		case currstate is
			when s_wait =>  -- FORCE RESET while canstart \= 1
				wire_cbits <= "0" & "0" & "0" & "010";  -- set & next_line & next_elem & write & flush, reset, enable
				execDONE <= '0';
				if canstart = '1' then
					wire_cbits <= "1" & "1" & "0" & "000";  -- set & next_line & next_elem & write & flush, reset, enable
					nextstate <= s_init;
				else
					nextstate <= s_wait;
				end if;

			when s_init =>   -- Buffer state
				wire_cbits <= "1" & "0" & "0" & "000";  -- set & next_line & next_elem & write & flush, reset, enable
				execDONE <= '0';
				nextstate <= s_execute;
		
			when s_execute =>  -- Increments line element
				-- control line and element feeder
				if stall = "11" then
					wire_cbits <= "0" & "0" & "0" & "001";  -- set(5) & next_line(4) & next_elem(3) & flush(2), reset(1), enable(0)
				elsif stall = "10" then
					wire_cbits <= "0" & "1" & "1" & "001";  -- set(5) & next_line(4) & next_elem(3) & flush(2), reset(1), enable(0)
				else
					wire_cbits <= "0" & "0" & "1" & "001";  -- set(5) & next_line(4) & next_elem(3) & flush(2), reset(1), enable(0)
				end if;
				
				-- control next state
				if endd = '0' then
					nextstate <= s_execute;
				else
					nextstate <= s_end;
				end if;
				
				execDONE <= '0';
		
			when s_end =>
				wire_cbits <= "0" & "0" & "0" & "000"; -- (set)mn (write)mem_out (read)mem_in (flush reset ce)validator
				execDONE <= '1';
				nextstate <= s_end;
		end case;
	end process;


-- OUTPUTS
	RDaddrCIR <= addr;
	idx <= RDdata(4 downto 0) when stall = "00" else
		   RDdata(12 downto 8) when stall = "01" else
		   RDdata(20 downto 16) when stall = "10" else
		   RDdata(28 downto 24) when stall = "11" else
		   (others => '0');	 


-- GENERATORS
	-- ADDR MEM_IN GENERATOR
	process (clk)  -- nao posso usar wire_cbits(1)  como reset
	begin
		if clk'event and clk='1' then
			if rst='1' then
				addr <= (others => '0');
			elsif wire_cbits(4) = '1' then
				addr <= addr + 1;
			end if;
		end if;
	end process;

	-- ADDR MEM_IN GENERATOR
	process (clk)
	begin
		if clk'event and clk='1' then
			if rst='1' or wire_cbits(3)='0' then
				stall <= (others => '0');
			elsif wire_cbits(3) = '1' then
				stall <= stall + 1;
			end if;
		end if;
	end process;


	-- ADDR MEM_OUT GENERATOR
	process (clk)
	begin
		if clk'event and clk='1' then
			if rst='1' then
				wire_WRaddrCir <= (others => '0');
			elsif error='1' and wire_WRaddrCir < memsize then
				wire_WRaddrCir <= wire_WRaddrCir + 1;
			end if;
		end if;
	end process;
	

-- REGISTER
	process (clk)
	begin
		if clk'event and clk='1' then  
			if rst='1' then   
				m <= (others => '0');
				n <= (others => '0');
				mn <= (others => '0');
			elsif wire_cbits(5) ='1' then   -- set
				m <= rddata(2 downto 0);
				n <= rddata(10 downto 8);
				mn <= rddata(20 downto 16);
			end if;
		end if;
	end process;

end Behavioral;

