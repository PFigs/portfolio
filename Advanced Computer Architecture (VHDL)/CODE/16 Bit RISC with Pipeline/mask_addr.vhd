----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    03:08:27 05/12/2010 
-- Design Name: 
-- Module Name:    mask_addr - Behavioral 
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

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mask_addr is
    Port ( I : in  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0));
end mask_addr;

architecture Behavioral of mask_addr is

begin

	Z(0)  <= I(0);
	Z(1)  <= I(1);
	Z(2)  <= I(2);
	Z(3)  <= I(3);
	Z(4)  <= I(4);
	Z(5)  <= I(5);
	Z(6)  <= I(6);
	Z(7)  <= I(7);
	Z(8)  <= I(8);
	Z(9)  <= I(9);
	Z(10) <= '0';
	Z(11) <= '0';
	Z(12) <= '0';
	Z(13) <= '0';
	Z(14) <= '0';
	Z(15) <= '0';


end Behavioral;

