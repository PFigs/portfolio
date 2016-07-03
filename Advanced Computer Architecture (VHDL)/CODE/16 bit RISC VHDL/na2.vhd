--
library IEEE;
use IEEE.std_logic_1164.all;

entity na2 is
    port (
        A: in STD_LOGIC;
        B: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end na2;

architecture na2 of na2 is
begin
  -- <<enter your statements here>>
Z <= not(A and B) after 3ns;
end na2;
