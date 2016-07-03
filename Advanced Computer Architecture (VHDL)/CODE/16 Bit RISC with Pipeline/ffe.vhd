--
library IEEE;
use IEEE.std_logic_1164.all;

entity ffe is
    port (
        CLK: in STD_LOGIC;
		Reset: in STD_LOGIC;
		Enable: in STD_LOGIC;
        D: in STD_LOGIC;
        Q: out STD_LOGIC
    );
end ffe;

architecture ffe of ffe is
begin
  -- <<enter your statements here>>
process(CLK) begin
	if(clk'event and clk='1') then
		if (Reset ='1') then
			Q <= '0';
		elsif (Enable='1') then Q <= D after 3ns;
		end if;
	end if;
end process;
end ffe;
