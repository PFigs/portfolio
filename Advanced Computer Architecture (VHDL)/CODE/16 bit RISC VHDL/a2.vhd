--
library IEEE;
use IEEE.std_logic_1164.all;

entity a2 is
    port (
        A: in STD_LOGIC;
        B: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end a2;

architecture a2 of a2 is
begin
  -- <<enter your statements here>>
Z <= A and B after 5ns;
end a2;
