--
library IEEE;
use IEEE.std_logic_1164.all;

entity xno2 is
    port (
        A: in STD_LOGIC;
        B: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end xno2;

architecture xno2 of xno2 is
begin
  -- <<enter your statements here>>
Z <= not(A xor B) after 5ns;
end xno2;
