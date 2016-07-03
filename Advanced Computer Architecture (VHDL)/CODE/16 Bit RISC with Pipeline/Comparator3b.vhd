----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 

-- 
-- Create Date:    19:32:09 06/01/2010 
-- Design Name: 
-- Module Name:    Comparator3b - Behavioral 
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
use work.cla_lib.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Comparator3b is
    Port ( I0 : in  STD_LOGIC_VECTOR (2 downto 0);
           I1 : in  STD_LOGIC_VECTOR (2 downto 0);
           Z  : out  STD_LOGIC);
end Comparator3b;

architecture Behavioral of Comparator3b is
signal s0, s1, s2 : STD_LOGIC;
begin


xno_1 : xno2 port map
		(
        A => I0(0),
        B => I1(0),
        Z => s0
		);

xno_2 : xno2 port map
		(
        A => I0(1),
        B => I1(1),
        Z => s1
		);

xno_3 : xno2 port map
		(
        A => I0(2),
        B => I1(2),
        Z => s2
		);
		
o3_1 : a3 port map
		(
        A => s0,
        B => s1,
        D => s2,
        Z => Z
		);

end Behavioral;

