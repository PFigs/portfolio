----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:   
-- Design Name: 
-- Module Name:    Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.gates.all;
use work.new_vhd_lib.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux_16_16 is
    Port (  M0  : in  STD_LOGIC_VECTOR (15 downto 0);
			M1  : in  STD_LOGIC_VECTOR (15 downto 0);
			M2  : in  STD_LOGIC_VECTOR (15 downto 0);
			M3  : in  STD_LOGIC_VECTOR (15 downto 0);
			M4  : in  STD_LOGIC_VECTOR (15 downto 0);
			M5  : in  STD_LOGIC_VECTOR (15 downto 0);
			M6  : in  STD_LOGIC_VECTOR (15 downto 0);
			M7  : in  STD_LOGIC_VECTOR (15 downto 0);
			M8  : in  STD_LOGIC_VECTOR (15 downto 0);
			M9  : in  STD_LOGIC_VECTOR (15 downto 0);
			M10 : in  STD_LOGIC_VECTOR (15 downto 0);
			M11 : in  STD_LOGIC_VECTOR (15 downto 0);
			M12 : in  STD_LOGIC_VECTOR (15 downto 0);
			M13 : in  STD_LOGIC_VECTOR (15 downto 0);
			M14 : in  STD_LOGIC_VECTOR (15 downto 0);
			M15 : in  STD_LOGIC_VECTOR (15 downto 0);
			SEL : in  STD_LOGIC_VECTOR (3 downto 0);
			OUTB   : out  STD_LOGIC_VECTOR (15 downto 0)

		);
end mux_16_16;

architecture Behavioral of mux_16_16 is

signal mux8control :  STD_LOGIC_VECTOR (2 downto 0);
signal mux2control :  STD_LOGIC;
signal mux8out1, mux8out2 :  STD_LOGIC_VECTOR (15 downto 0);
begin

mux8control <= SEL(2 downto 0);
mux2control <= SEL(3);

mux8_1_1 :Mux8x1 Port map
		(    M0  => M0, 
           M1  => M1,
           M2  => M2,
           M3  => M3,
           M4  => M4,
           M5  => M5,
           M6  => M6,
           M7  => M7,
           Z   => mux8out1,
		   SEL => mux8control
		);
mux8_1_2 : Mux8x1 Port map
		(  M0  => M8, 
           M1  => M9,
           M2  => M10,
           M3  => M11,
           M4  => M12,
           M5  => M13,
           M6  => M14,
           M7  => M15,
           Z   => mux8out2,
		   SEL => mux8control
		);
mux_2_1: Mux16 Port map 
			( I0 => mux8out1,
           I1 => mux8out2,
           O  => OUTB,
           S  => mux2control);
		
		
end Behavioral;

