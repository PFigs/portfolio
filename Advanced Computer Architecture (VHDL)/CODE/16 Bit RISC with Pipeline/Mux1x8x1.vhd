----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:37:48 05/04/2010 
-- Design Name: 
-- Module Name:    Mux1x8x1 - Behavioral 
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

entity Mux1x8x1 is
    Port ( I0 : in  STD_LOGIC;
           I1 : in  STD_LOGIC;
           I2 : in  STD_LOGIC;
           I3 : in  STD_LOGIC;
           I4 : in  STD_LOGIC;
           I5 : in  STD_LOGIC;
           I6 : in  STD_LOGIC;
           I7 : in  STD_LOGIC;
           SEL : in  STD_LOGIC_VECTOR( 2 downto 0);
           Z : out  STD_LOGIC);
end Mux1x8x1;

architecture Behavioral of Mux1x8x1 is
signal leave0  : STD_LOGIC;
signal leave1  : STD_LOGIC;
signal leave2  : STD_LOGIC;
signal leave3  : STD_LOGIC;
signal leaveL0 : STD_LOGIC;
signal leaveL1 : STD_LOGIC;
begin

	MUX0L0: mux2 port map(
		A0  => I0,
		A1  => I1,
		Z   => leave0,
		SEL => SEL(0)
	);

	MUX1L0: mux2 port map(
		A0  => I2,
		A1  => I3,
		Z   => leave1,
		SEL => SEL(0)
	);
	
	MUX2L0: mux2 port map(
		A0  => I4,
		A1  => I5,
		Z   => leave2,
		SEL => SEL(0)
	);
	
	MUX3L0: mux2 port map(
		A0  => I6,
		A1  => I7,
		Z   => leave3,
		SEL => SEL(0)
	);
	
	MUX4L1: mux2 port map(
		A0  => leave0,
		A1  => leave1,
		Z   => leaveL0,
		SEL => SEL(1)
	);
	
	MUX5L1: mux2 port map(
		A0  => leave2,
		A1  => leave3,
		Z   => leaveL1,
		SEL => SEL(1)
	);
	
	MUX5L2: mux2 port map(
		A0  => leaveL0,
		A1  => leaveL1,
		Z   => Z,
		SEL => SEL(2)
	);

end Behavioral;

