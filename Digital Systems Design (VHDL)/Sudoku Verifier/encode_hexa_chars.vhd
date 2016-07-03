-- Time-stamp: "2011-04-22 12:56:57    encode_hexa_chars.vhd    pff@inesc-id.pt"
-------------------------------------------------------------------------------
-- Title      : 3o Laboratorio: Projecto de um Sistema Digital
-- Project    : Projecto de Sistemas Digitais 2010/2011 (2o Sem.)
-------------------------------------------------------------------------------
-- File       : encode_hexa_chars.vhd
-- Author     : Paulo Flores  <pff@inesc-id.pt>
-- Company    : INESC-ID, ECE Dept. IST, TU Lisbon
-- Created    : 2011-04-15
-- Last update: 2011-04-22
-- Platform   : Digilent Xilinix Spartan-3 Starter Board (XC3S1000)
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Convert 4bits (hexadecimal) to its ASCII letter
-- representation (8bits)
-------------------------------------------------------------------------------
-- Copyright (c) 2011 Instituto Superior Tecnico
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-05-30  1.0      hcn     Created
-- 2011-04-15  1.1      pff     Update header
-------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity encode_hexa_chars is
  port (din  : in  std_logic_vector (3 downto 0);
        dout : out std_logic_vector (7 downto 0)
        );
end encode_hexa_chars;

architecture Behavioral of encode_hexa_chars is
begin
  with din select
    dout <=
    X"30" when X"0",
    X"31" when X"1",
    X"32" when X"2",
    X"33" when X"3",
    X"34" when X"4",
    X"35" when X"5",
    X"36" when X"6",
    X"37" when X"7",
    X"38" when X"8",
    X"39" when X"9",
    X"41" when X"A",
    X"42" when X"B",
    X"43" when X"C",
    X"44" when X"D",
    X"45" when X"E",
    X"46" when X"F",
    X"58" when others;
end Behavioral;
