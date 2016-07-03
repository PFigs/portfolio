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
use WORK.PSDLIB.ALL;

entity regp is
	 generic (N: integer:=32);
    Port ( clk : in  STD_LOGIC;
			  clear: in std_logic;
           p : in  STD_LOGIC_VECTOR (N-1 downto 0);
           q : out  STD_LOGIC_VECTOR (N-1 downto 0));
end regp;

architecture Behavioral of regp is

begin
	process (clk,clear)
	begin
		if clear = '1' then
			q <= (others => '0');
		elsif clk'event and clk='1' then  
			q <= p;
		end if;
end process;
 

end Behavioral;

