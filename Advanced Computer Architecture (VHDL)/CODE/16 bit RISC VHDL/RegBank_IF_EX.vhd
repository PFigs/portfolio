----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:37:28 04/19/2010 
-- Design Name: 
-- Module Name:    RegBank_IF_EX - Behavioral 
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
work.new_vhd_lib.all

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegBank_IF_EX is
    Port ( I0 : in  STD_LOGIC_VECTOR (15 downto 0);
			  I1 : in  STD_LOGIC_VECTOR (15 downto 0);
			  ID_RF : out STD_LOGIC_VECTOR (15 downto 0);
			  Registers : out STD_LOGIC_VECTOR (15 downto 0);
           reset : in  STD_LOGIC;
           enable : in  STD_LOGIC;
           clock : in  STD_LOGIC);
end RegBank_IF_EX;

architecture Behavioral of RegBank_IF_EX is
	
begin
	REG_0 : Reg16 port map (
		CLK => clock,
		R => reset,
		E => enable,
		D => I0,
		Q => Registers
		);
	
	REG_1 : Reg16 port map (
		CLK => clock,
		R => reset,
		E => enable,
		D => I1,
		Q => ID_RF
		);
	
end Behavioral;

