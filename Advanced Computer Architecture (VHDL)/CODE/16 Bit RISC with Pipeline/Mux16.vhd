----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:54:38 04/19/2010 
-- Design Name: 
-- Module Name:    Mux16 - Behavioral 
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


-- 2x1

entity Mux16 is
    Port ( I0 : in  STD_LOGIC_VECTOR (15 downto 0);
           I1 : in  STD_LOGIC_VECTOR (15 downto 0);
           O : out  STD_LOGIC_VECTOR (15 downto 0);
           S : in  STD_LOGIC);
end Mux16;

architecture Behavioral of Mux16 is

begin

	M0 : mux2 port map(
		A0 => I0(0),
		A1 => I1(0),
		SEL => S,
		Z => O(0)
	);

	M1 : mux2 port map(
		A0 => I0(1),
		A1 => I1(1),
		SEL => S,
		Z => O(1)
	);
	
	M2 : mux2 port map(
		A0 => I0(2),
		A1 => I1(2),
		SEL => S,
		Z => O(2)
	);
	
	M3 : mux2 port map(
		A0 => I0(3),
		A1 => I1(3),
		SEL => S,
		Z => O(3)
	);
	
	M4 : mux2 port map(
		A0 => I0(4),
		A1 => I1(4),
		SEL => S,
		Z => O(4)
	);
	
	M5 : mux2 port map(
		A0 => I0(5),
		A1 => I1(5),
		SEL => S,
		Z => O(5)
	);
	
	M6 : mux2 port map(
		A0 => I0(6),
		A1 => I1(6),
		SEL => S,
		Z => O(6)
	);
	
	M7 : mux2 port map(
		A0 => I0(7),
		A1 => I1(7),
		SEL => S,
		Z => O(7)
	);
	
	M8 : mux2 port map(
		A0 => I0(8),
		A1 => I1(8),
		SEL => S,
		Z => O(8)
	);
	
	M9 : mux2 port map(
		A0 => I0(9),
		A1 => I1(9),
		SEL => S,
		Z => O(9)
	);
	
	M10 : mux2 port map(
		A0 => I0(10),
		A1 => I1(10),
		SEL => S,
		Z => O(10)
	);
	
	M11 : mux2 port map(
		A0 => I0(11),
		A1 => I1(11),
		SEL => S,
		Z => O(11)
	);
	
	M12 : mux2 port map(
		A0 => I0(12),
		A1 => I1(12),
		SEL => S,
		Z => O(12)
	);
	
	M13 : mux2 port map(
		A0 => I0(13),
		A1 => I1(13),
		SEL => S,
		Z => O(13)
	);
	
	M14 : mux2 port map(
		A0 => I0(14),
		A1 => I1(14),
		SEL => S,
		Z => O(14)
	);
	
	M15 : mux2 port map(
		A0 => I0(15),
		A1 => I1(15),
		SEL => S,
		Z => O(15)
	);
	
end Behavioral;

