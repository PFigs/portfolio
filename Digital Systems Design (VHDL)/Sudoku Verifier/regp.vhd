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
library UNISIM;
use ieee.numeric_std.all;
use UNISIM.Vcomponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use WORK.PSDLIB.ALL;

entity regp is
	generic(
		bits : integer :=8
	);
	port(
		clk : in std_logic;
		ce : in std_logic;
		r : in std_logic;
		p : in  std_logic_vector (bits-1 downto 0);
		q : out  std_logic_vector (bits-1 downto 0)
	);
end regp;

architecture Behavioral of regp is
begin
	process (clk)
	begin
		if clk'event and clk='1' then  
			if r='1' then   
				q <= (others => '0');
			elsif ce ='1' then
				q <= p;
			end if;
		end if;
	end process;
end Behavioral;

