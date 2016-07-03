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
			cbits	: out	STD_LOGIC_VECTOR(cbits_size-1 downto 0);
			idx	: out	STD_LOGIC_VECTOR(addr_size-1 downto 0);
			clear	: out	STD_LOGIC
			);
end control;

architecture Behavioral of control is
	type   fsm_states is (s_one, s_two, s_three, s_last);
	signal currstate, nextstate : fsm_states;
	signal wire_idx, wire_cnt: std_logic_vector(idx_size-1 downto 0);
	signal wt: std_logic;
	signal wire_clear : std_logic;
	signal count: std_logic;
begin

	--defaults
	clear <= wire_clear;
	-- States
	state_reg : process (clk, rst)
	begin
		if rst = '1' then
			currstate <= s_one;
			wire_clear <= '1';
			wt <= '1';
		elsif clk'event and clk = '1' then
			currstate <= nextstate;
			if wt = '0' then
				wire_clear <= '0';
			else
				wt <= '0';
			end if;
		end if;
	end process;

	state_comb : process (currstate, wire_clear)
	begin
		case currstate is
			when s_one =>  -- E(i)*B(i) {1} ; C(i) + D(i) {2}
				nextstate <= currstate;
				count <= '0';
				cbits <= "00";
				if wire_clear='0' then
					nextstate <= s_two;
				end if;
		
			when s_two =>  -- F(i)*{1}(i) {3}; A(i)/4 - {2}(i) {4}
				nextstate <= s_three;
				count <= '0';
				cbits <= "01";
		
			when s_three => -- {3}*{4}
				nextstate <= s_last;
				count <= '1'; -- counter will now take one cycle to take effect
				cbits <= "11";

			when s_last => -- End?
				cbits <= "10";
				count <= '0';
				if wire_idx = x"1f" then
					nextstate <= s_last;
				else
					nextstate <= s_one;
				end if;
		end case;

	end process;

	process (count)
	begin
		if count='1' then   
			wire_cnt <= wire_idx + 1;
		else
			wire_cnt <= wire_idx;
		end if;
	end process;


	process (clk, rst)
	begin
	   if rst='1' then   
		  wire_idx <= (others=>'0');
	   elsif (clk'event and clk='1') then
			if count = '1' then
				wire_idx <= wire_cnt;
			end if;
	   end if;
	end process;


	idx(4 downto 0) <= wire_idx;
	idx(idx'high downto 5) <= (others => '0');
	
end Behavioral;

