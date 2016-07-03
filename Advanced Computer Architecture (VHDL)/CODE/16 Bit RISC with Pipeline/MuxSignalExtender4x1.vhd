----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:41:30 05/02/2010 
-- Design Name: 
-- Module Name:    MuxSignalExtender4x1 - Behavioral 
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

-- Mux recebe 3 constantes
-- O sinal é extendido nas portas

entity MuxSignalExtender4x1 is
    Port ( E0 : in  STD_LOGIC_VECTOR (11 downto 0);
           E1 : in  STD_LOGIC_VECTOR (10 downto 0);
           E2 : in  STD_LOGIC_VECTOR (7 downto 0);
           SEL : in  STD_LOGIC_VECTOR (2 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0));
end MuxSignalExtender4x1;

architecture Behavioral of MuxSignalExtender4x1 is
	signal leave0 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave1 : STD_LOGIC_VECTOR (15 downto 0);
begin


	-- CONTROL MUX 8 and 12 bits
	M0L0 : Mux16 port map(
		-- 8 bits const
		I0 (15) => E2(7),
		I0 (14) => E2(7),
		I0 (13) => E2(7),
		I0 (12) => E2(7),
		I0 (11) => E2(7),
		I0 (10) => E2(7),
		I0 (9) => E2(7),
		I0 (8) => E2(7),
		I0 (7 downto 0) => E2(7 downto 0),
	
		-- 12 bits const
		I1 (15) => E0(11),
		I1 (14) => E0(11),
		I1 (13) => E0(11),
		I1 (12) => E0(11),
		I1 (11 downto 0) => E0(11 downto 0),
	
		O => leave0,
		S => SEL(0)
	);
	
	-- 8 bit Mux
	M1L0 : Mux16 port map(
		-- 11 bits const
		I0(15) => E1(10),
		I0(14) => E1(10),
		I0(13) => E1(10),
		I0(12) => E1(10),
		I0(11) => E1(10),
		I0(10 downto 0) => E1(10 downto 0),

		
		I1 (15) => E2(7),
		I1 (14) => E2(7),
		I1 (13) => E2(7),
		I1 (12) => E2(7),
		I1 (11) => E2(7),
		I1 (10) => E2(7),
		I1 (9) => E2(7),
		I1 (8) => E2(7),
		I1 (7 downto 0) => E2(7 downto 0),
		
		O => leave1,
		S => SEL(2)
	);
	
	-- Mux de saida
		M2L1 : Mux16 port map(
		I0 => leave0,
		I1 => leave1,
		O => Z,
		S => SEL(1)
	);
	
	
end Behavioral;

