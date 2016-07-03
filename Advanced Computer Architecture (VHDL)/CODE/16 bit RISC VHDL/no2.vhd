--
library IEEE;
use IEEE.std_logic_1164.all;

entity no2 is
    port (
        A: in STD_LOGIC;
        B: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end no2;

architecture no2 of no2 is
begin
  -- <<enter your statements here>>
Z <= not (A or B) after 3ns;
end no2;
