--
library IEEE;
use IEEE.std_logic_1164.all;

entity not1 is
    port (
        A: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end not1;

architecture not1 of not1 is
begin
  -- <<enter your statements here>>
Z <= not A  after 2ns;
end not1;
