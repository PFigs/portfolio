-- Time-stamp: "2011-04-22 12:56:49    decode_hexa_chars.vhd    pff@inesc-id.pt"
-------------------------------------------------------------------------------
-- Title      : 3o Laboratorio: Projecto de um Sistema Digital
-- Project    : Projecto de Sistemas Digitais 2010/2011 (2o Sem.)
-------------------------------------------------------------------------------
-- File       : decode_hexa_chars.vhd
-- Author     : Paulo Flores  <pff@inesc-id.pt>
-- Company    : INESC-ID, ECE Dept. IST, TU Lisbon
-- Created    : 2011-04-15
-- Last update: 2011-04-22
-- Platform   : Digilent Xilinix Spartan-3 Starter Board (XC3S1000)
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Convert an ASCII letter (8bits) to the 4bits that corresponde
-- to its hexadecimal representation.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 Instituto Superior Tecnico
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-05-30  1.0      hcn     Created
-- 2011-04-15  1.1      pff     Update header and commnet isHexa generation
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity decode_hexa_chars is
  port (din   : in  std_logic_vector (7 downto 0);
        dout  : out std_logic_vector (3 downto 0);
        isEnd : out std_logic
        -- isHexa : out std_logic
        );
end decode_hexa_chars;

architecture Behavioral of decode_hexa_chars is
begin
  with din select
    dout <=
    X"0" when X"30",
    X"1" when X"31",
    X"2" when X"32",
    X"3" when X"33",
    X"4" when X"34",
    X"5" when X"35",
    X"6" when X"36",
    X"7" when X"37",
    X"8" when X"38",
    X"9" when X"39",
    X"A" when X"41" | X"61",
    X"B" when X"42" | X"62",
    X"C" when X"43" | X"63",
    X"D" when X"44" | X"64",
    X"E" when X"45" | X"65",
    X"F" when X"46" | X"66",
    X"0" when others;

  with din select
    isEnd <= '1' when X"4C" | X"6C",
    '0'          when others;

--  with din select
--    isHexa <= '1' when
--    X"30" | X"31" | X"32" | X"33" | X"34" | X"35" | X"36" | X"37"| X"38"| X"39"|
--    X"41" | X"42" | X"43" | X"44" | X"45" | X"46" |
--    X"61" | X"62" | X"63" | X"64" | X"65" | X"66",
--    '0'           when others;

end Behavioral;
