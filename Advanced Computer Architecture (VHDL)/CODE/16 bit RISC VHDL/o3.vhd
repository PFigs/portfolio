--
library IEEE;
use IEEE.std_logic_1164.all;

entity o3 is
    port (
        A: in STD_LOGIC;
        B: in STD_LOGIC;
        D: in STD_LOGIC;
        Z: out STD_LOGIC
    );
end o3;

architecture o3 of o3 is
begin
  -- <<enter your statements here>>
Z <= A or B or D after 6ns;
end o3;
