----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:35:42 05/04/2010 
-- Design Name: 
-- Module Name:    Flag_Test - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Flag_Test is
    Port ( NEG     : in  STD_LOGIC;
           ZERO 	 : in  STD_LOGIC;
           OVERFLOW: in  STD_LOGIC;
           CARRY   : in  STD_LOGIC;
			  COND 	 : in STD_LOGIC_VECTOR(3 downto 0);
			  OP 	 	 : in STD_LOGIC_VECTOR(1 downto 0);
			  UNJUMP  : in STD_LOGIC;
			  ENABLE  : in STD_LOGIC;
			  SEL		 : in STD_LOGIC;
           Z 		 : out  STD_LOGIC);
end Flag_Test;

architecture Behavioral of Flag_Test is

signal NEGZERO: STD_LOGIC;
signal buff0: STD_LOGIC;
signal buff1: STD_LOGIC;
signal buff2: STD_LOGIC;

begin

	MUX: Mux1x8x1 port map(
		I0  => '1', --Jump false true
		I1  => '0',
      I2  => '0',
      I3  => OVERFLOW,
      I4  => NEG,
      I5  => ZERO,
      I6  => CARRY,
      I7  => NEGZERO,
      SEL => COND(2 downto 0),
      Z 	 => buff0
	);

	-- Calculates Zero or neg
	ORNS: o2 port map(
		A => NEG,
		B => ZERO,
		Z => NEGZERO
	);
	
	-- Compares to condition
	XN0: xno2 port map(
		A => OP(0),
		B => buff0,
		Z => buff1
	);
	
	-- MUX for uncondicional jump
	MUX1: mux2 port map(
		A0  => buff1,
		A1  => UNJUMP,
		Z   => buff2,
		SEL => SEL
	);

	-- Enables output
	AN1: a2 port map(
		A => ENABLE,
		B => buff2,
		Z => Z
	);

end Behavioral;

