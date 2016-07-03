-----------------------------------------------------------------------------
-- Vhdl model created by vec2mem, (c) 2006-2011 Horacio Neto, Paulo Flores.
-- Command: vec2mem rnd   1073741823 1301579652 
-----------------------------------------------------------------------------

library ieee;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use UNISIM.Vcomponents.all;

entity memsdata is
  port ( 
         dataFROMmemIN  : out  std_logic_vector(31 downto 0);
         addressRDmemIN : in  std_logic_vector(8 downto 0);
         dataTOmemIN    : in  std_logic_vector(3 downto 0);
         enableWRmemIN  : in  std_logic;
         CLK  : in  std_logic
       );

end memsdata;

architecture GENERATED of memsdata is


begin

  memoria_entrada_na_fpga : RAMB16_S4_S36
	generic map (
      INIT_00       =>
      --X"0000000000000000000000000001020302030001010103020302010000040202"
      X"0000000000000000000000000001020302030001010103020001010000040202"
      -- 						|		|		|		|		|		|
      )
    port map (
      DOA   => open,                    -- Port A 4-bit Data Output
      DOB   => dataFROMmemIN,           -- Port B 32-bit Data Output
      DOPB  => open,                    -- Port B 4-bit Parity Output
      ADDRA => "000000000000",                    -- Port A 12-bit Address Input
      ADDRB => addressRDmemIN,          -- Port B 9-bit Address Input
      CLKA  => CLK,                     -- Port A Clock
      CLKB  => CLK,                     -- Port B Clock
      DIA   => "0000",                    -- Port A 4-bit Data Input
      DIB   => X"00000000",             -- Port B 32-bit Data Input
      DIPB  => "0000",                  -- Port-B 4-bit parity Input
      ENA   => '1',                     -- Port A RAM Enable Input
      ENB   => '1',                     -- Port B RAM Enable Input
      SSRA  => '0',                     -- Port A Synchronous Set/Reset Input
      SSRB  => '0',                     -- Port B Synchronous Set/Reset Input
      WEA   => enableWRmemIN,           -- Port A Write Enable Input
      WEB   => '0'                      -- Port B Write Enable Input
      );

end GENERATED;
