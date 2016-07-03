----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:02:23 04/20/2010 
-- Design Name: 
-- Module Name:    Mux8x1 - Behavioral 
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

entity Mux8x1 is
    Port ( M0 : in  STD_LOGIC_VECTOR (15 downto 0);
           M1 : in  STD_LOGIC_VECTOR (15 downto 0);
           M2 : in  STD_LOGIC_VECTOR (15 downto 0);
           M3 : in  STD_LOGIC_VECTOR (15 downto 0);
           M4 : in  STD_LOGIC_VECTOR (15 downto 0);
           M5 : in  STD_LOGIC_VECTOR (15 downto 0);
           M6 : in  STD_LOGIC_VECTOR (15 downto 0);
           M7 : in  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0);
			  SEL : in  STD_LOGIC_VECTOR (2 downto 0));
end Mux8x1;

architecture Behavioral of Mux8x1 is

	signal leave0 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave1 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave2 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave3 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave4 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave5 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave6 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave7 : STD_LOGIC_VECTOR (15 downto 0);
	
begin

	M0L0 : Mux16 port map(	
		I0 => M0,
		I1 => M1,
		O => leave0,
		S => SEL(0)
	);
	
	M1L0 : Mux16 port map(
		I0 => M2,
		I1 => M3,
		O => leave1,
		S => SEL(0)
	);

	M2L0 : Mux16 port map(
		I0 => M4,
		I1 => M5,
		O => leave2,
		S => SEL(0)
	);
	
	M3L0 : Mux16 port map(
		I0 => M6,
		I1 => M7,
		O => leave3,
		S => SEL(0)
	);

	M4L1 : Mux16 port map(
		I0 => leave0,
		I1 => leave1,
		O => leave4,
		S => SEL(1)
	);
	
	M5L1 : Mux16 port map(
		I0 => leave2,
		I1 => leave3,
		O => leave5,
		S => SEL(1)
	);
	
	M6L2 : Mux16 port map(
		I0 => leave4,
		I1 => leave5,
		O => Z,
		S => SEL(2)
	);

end Behavioral;

