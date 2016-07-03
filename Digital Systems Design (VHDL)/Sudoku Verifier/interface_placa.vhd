------------------------------------------------------------------------
--     interface_placa.vhd -- Demonstrate basic Pegasus function
------------------------------------------------------------------------
--     Derivado de S3demo em http://www.digilentinc.com/
------------------------------------------------------------------------
--
--  Inputs:
--              clk50M          - system clock (50Mhz clock)
--              D7Si            - values for the four 7 segments
--              dataleds        - value for the leds
--
--  Outputs:
--              led             - discrete LEDs on the board (8 leds)
--              an              - anode lines for the 7-seg displays (4 disps)
--              ssg             - cathodes (7-segment lines) for the displays
--
------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

entity interface_placa is
  port (
    clk50M                 : in  std_logic;
    D7S3, D7S2, D7S1, D7S0 : in  std_logic_vector(3 downto 0);
    dataleds               : in  std_logic_vector(7 downto 0);
    led                    : out std_logic_vector(7 downto 0);
    an                     : out std_logic_vector(3 downto 0);
    ssg                    : out std_logic_vector(7 downto 0)
    );
end interface_placa;

architecture Behavioral of interface_placa is

  signal clkdiv          : std_logic_vector(15 downto 0) := (others => '0');
  signal hexad, ctr_disp : std_logic_vector(3 downto 0);
  signal dig             : std_logic_vector(6 downto 0);
  signal tmux_disp       : std_logic_vector(1 downto 0);

begin

  led <= dataleds;
  ssg <= '1' & dig;                     -- dot is always off
  an  <= ctr_disp;

  -- Divide the master clock (50Mhz) down to an aprox 3Hz frequency.
  process (clk50M)
  begin
    if clk50M = '1' and clk50M'event then
      clkdiv <= clkdiv + 1;
    end if;
  end process;
  -- cclk <= clkdiv(23); -- para visualizacao na placa
  -- cclk <= clkdiv(3); -- para simulacao

  tmux_disp <= clkdiv(15 downto 14);    -- para visualizacao na placa
  -- tmux_disp <= clkdiv(3 downto 2) ; -- para simulacao
  ctr_disp  <= "0111" when tmux_disp = "00" else
               "1011" when tmux_disp = "01" else
               "1101" when tmux_disp = "10" else
               "1110";
  hexad <= D7S0 when tmux_disp = "00" else
           D7S1 when tmux_disp = "01" else
           D7S2 when tmux_disp = "10" else
           D7S3;

  dig <= "1000000" when hexad = X"0" else
         "1111001" when hexad = X"1" else
         "0100100" when hexad = X"2" else
         "0110000" when hexad = X"3" else
         "0011001" when hexad = X"4" else
         "0010010" when hexad = X"5" else
         "0000010" when hexad = X"6" else
         "1111000" when hexad = X"7" else
         "0000000" when hexad = X"8" else
         "0010000" when hexad = X"9" else
         "0001000" when hexad = X"A" else
         "0000011" when hexad = X"b" else
         "1000110" when hexad = X"C" else
         "0100001" when hexad = X"d" else
         "0000110" when hexad = X"E" else
         "0001110" when hexad = X"F" else
         "1111111";

end Behavioral;

