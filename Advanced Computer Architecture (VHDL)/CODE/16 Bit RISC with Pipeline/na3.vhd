--
library IEEE;
use IEEE.std_logic_1164.all;

entity na3 is
    port (
        A: in STD_LOGIC;
        B: in STD_LOGIC;
        D: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end na3;

architecture na3 of na3 is
begin
  -- <<enter your statements here>>
Z <= not(A and B and D) after 4ns;
end na3;
