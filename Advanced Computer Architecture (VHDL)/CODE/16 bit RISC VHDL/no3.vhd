--
library IEEE;
use IEEE.std_logic_1164.all;

entity no3 is
    port (
        A: in STD_LOGIC;
        B: in STD_LOGIC;
        D: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end no3;

architecture no3 of no3 is
begin
  -- <<enter your statements here>>
Z <= not (A or B or D) after 4ns;
end no3;
