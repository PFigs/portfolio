----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    00:47:42 04/21/2010 
-- Design Name: 
-- Module Name:    Decoder3x8 - Behavioral 
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
use IEEE.std_logic_1164.all;
use work.gates.all;
use work.new_vhd_lib.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Decoder3x8 is
    Port ( D : in  STD_LOGIC_VECTOR (2 downto 0);
           Z : out  STD_LOGIC_VECTOR (7 downto 0));
end Decoder3x8;

architecture Behavioral of Decoder3x8 is

signal nout : STD_LOGIC_VECTOR (2 downto 0);

begin
	
	NEG0 : not1 port map(
		A => D(0),
		Z => nout(0)
	);
	
	NEG1 : not1 port map(
		A => D(1),
		Z => nout(1)
	);
	
	NEG2 : not1 port map(
		A => D(2),
		Z => nout(2)
	);

	NA0 : a3 port map(
		A => nout(0),
		B => nout(1),
		D => nout(2),
		Z => Z(0)
	);

	NA1 : a3 port map(
		A => D(0),
		B => nout(1),
		D => nout(2),
		Z => Z(1)
	);

	NA2 : a3 port map(
		A => nout(0),
		B => D(1),
		D => nout(2),
		Z => Z(0)
	);

	NA3 : a3 port map(
		A => D(0),
		B => D(1),
		D => nout(2),
		Z => Z(0)
	);

	NA4 : a3 port map(
		A => nout(0),
		B => nout(1),
		D => D(2),
		Z => Z(0)
	);

	NA5 : a3 port map(
		A => D(0),
		B => nout(1),
		D => D(2),
		Z => Z(0)
	);

	NA6 : a3 port map(
		A => nout(0),
		B => D(1),
		D => D(2),
		Z => Z(0)
	);

	NA7 : a3 port map(
		A => D(0),
		B => D(1),
		D => D(2),
		Z => Z(0)
	);

end Behavioral;

