----------------------------------------------------------------------------------
-- Instituto Superior Técnico 
-- 
-- Projecto Sistemas Digitais
-- 
-- Martim Camacho ()
-- Pedro Silva, pedro.silva@ist.utl.pt (58035)
-- 
----------------------------------------------------------------------------------

-- Flip Flop with edge-triggered positive (sincronous set)

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use WORK.PSDLIB.ALL;

entity ffp is
    Port ( c : in  STD_LOGIC;
           d : in  STD_LOGIC;
           e : in  STD_LOGIC;
           q : out  STD_LOGIC);
end ffp;

architecture Behavioral of ffp is

begin

	process(c)
	begin
		if (c'event and c='1') then
			if (e='1') then
				q <= d;
			end if;
		end if;
	end process;

end Behavioral;

