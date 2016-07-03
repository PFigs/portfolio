
library IEEE;
use IEEE.std_logic_1164.all;

entity clkdiv is
	port( clk:in std_logic;
		  clkout:out std_logic);
end clkdiv;

architecture behavior of clkdiv is
	begin
	process(clk)
	variable cnt : integer range 0 to 2;
	begin
		if(clk'event and clk='1') then
			if(cnt=2)then
				cnt:=1;
				clkout<='1';
				else
				cnt := cnt+1;
				clkout<='0';
				end if;
			end if;
	end process;
end behavior;
