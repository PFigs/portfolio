----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:18:49 05/06/2010 
-- Design Name: 
-- Module Name:    Mux16x3x1 - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.gates.all;
use work.new_vhd_lib.all;


entity Mux16x3x1 is
    Port ( I0 : in  STD_LOGIC_VECTOR (15 downto 0);
           I1 : in  STD_LOGIC_VECTOR (15 downto 0);
           I2 : in  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0);
           SEL : in  STD_LOGIC_VECTOR (1 downto 0));
end Mux16x3x1;

architecture Behavioral of Mux16x3x1 is
signal wire0 : STD_LOGIC_VECTOR(15 downto 0);
signal wire1 : STD_LOGIC_VECTOR(15 downto 0);
begin

	MUX0L0: Mux16 port map(
		I0  => I0,
		I1  => I1,
		S => SEL(0),
		O   => wire0
	);

	MUX1L0: Mux16 port map(
		I0  => I2,
		I1  => I1,
		S => SEL(0),
		O   => wire1
	);
	
	MUX2L1: Mux16 port map(
		I0  => wire0,
		I1  => wire1,
		S => SEL(1),
		O   => Z
	);


end Behavioral;

