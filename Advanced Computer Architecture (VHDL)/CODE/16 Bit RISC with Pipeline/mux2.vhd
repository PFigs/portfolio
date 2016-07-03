--
library IEEE;
use IEEE.std_logic_1164.all;

entity mux2 is
    port (
        SEL: in STD_LOGIC;
        A0: in STD_LOGIC;
        A1: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end mux2;

architecture mux2 of mux2 is
begin
  -- <<enter your statements here>>
Z <= (A0 and (not SEL)) or (A1 and SEL) after 6ns;
end mux2;
