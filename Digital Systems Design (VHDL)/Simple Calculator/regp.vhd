----------------------------------------------------------------------------------
-- Instituto Superior Técnico 
-- 
-- Projecto Sistemas Digitais
-- 
-- Martim Camacho, martim.camacho@ist.utl.pt (56755)
-- Pedro Silva, pedro.silva@ist.utl.pt (58035)
-- 
----------------------------------------------------------------------------------

-- Flip Flop with edge-triggered positive (sincronous set)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use WORK.PSDLIB.ALL;

entity regp is
	 generic (N : integer := 8);
    Port ( c : in  STD_LOGIC;
           d : in  STD_LOGIC_VECTOR(N-1 downto 0);
           e : in  STD_LOGIC;
           q : out  STD_LOGIC_VECTOR(N-1 downto 0));
end regp;

architecture Behavioral of regp is

begin

	REGP: for i in d'range generate
		fp: ffp
			port map (
				c => c,
				e => e,
				d => d(i),
				q => q(i)
			);
	end generate;
end Behavioral;

