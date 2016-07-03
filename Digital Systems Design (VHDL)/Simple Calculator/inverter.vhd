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

entity inverter is
	generic (N : integer := 8);
    Port ( a : in  STD_LOGIC_VECTOR (N-1 downto 0);
           z : out  STD_LOGIC_VECTOR (N-1 downto 0));
end inverter;

architecture Behavioral of inverter is

begin

	z <= not a;

end Behavioral;

