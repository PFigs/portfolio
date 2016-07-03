--
library IEEE;
use IEEE.std_logic_1164.all;

entity o2 is
    port (
        A: in STD_LOGIC;
        B: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end o2;

architecture o2 of o2 is
begin
  -- <<enter your statements here>>
Z <= A or B after 5ns;
end o2;
