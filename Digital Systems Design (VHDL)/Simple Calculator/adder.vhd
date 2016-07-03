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
use WORK.PSDLIB.ALL;

entity adder is
	generic (N : integer := 8);
    Port ( a : in  STD_LOGIC_VECTOR (N-1 downto 0);
           b : in  STD_LOGIC_VECTOR (N-1 downto 0);
           sel : in  STD_LOGIC;
           z : out  STD_LOGIC_VECTOR (N-1 downto 0));
end adder;

architecture Behavioral of adder is

	--signal res : std_logic_vector(N downto 0);

begin

		
	process (a, b, sel) 
	begin
		if sel = '0' then 
			z <= a + b; 
		else 
			z <= a - b;
		end if;
	end process;
 

	--	process(clk)
	--	begin
	--		if clk'event and clk = '1' then
	--			if sel='0' then
	--				res <= (a(a'high) & a) + (b(b'high) & b);
	--				z <= res(a'range);
	--				--cout <= res(res'high);	
	--			else
	--				res <= (a(a'high) & a) - (b(b'high) & b);
	--				z <= res(a'range);
	--				--cout <= res(res'high);	
	--			end if;
	--		end if;
	--	end process;
end Behavioral;

