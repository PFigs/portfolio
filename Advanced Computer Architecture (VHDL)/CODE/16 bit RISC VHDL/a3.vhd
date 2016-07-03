--
library IEEE;
use IEEE.std_logic_1164.all;

entity a3 is
    port (
        A: in STD_LOGIC;
        B: in STD_LOGIC;
        D: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end a3;

architecture a3 of a3 is
begin
  -- <<enter your statements here>>
Z <= A and B and D after 6ns;
end a3;
