--
library IEEE;
use IEEE.std_logic_1164.all;

entity xo2 is
    port (
        A: in STD_LOGIC;
        B: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end xo2;

architecture xo2 of xo2 is
begin
  -- <<enter your statements here>>
Z <= A xor B after 5ns;
end xo2;
