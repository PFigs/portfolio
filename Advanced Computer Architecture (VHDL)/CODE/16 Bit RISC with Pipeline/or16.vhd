----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:52:20 05/03/2010 
-- Design Name: 
-- Module Name: - Behavioral 
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


---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity or16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
		     inb : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end or16;

architecture Behavioral of or16 is

begin

or_0 : o2 port map (
        A => ina(0),
        B => inb(0),
        Z => outb(0) 
			);
or_1 : o2 port map (
        A => ina(1),
        B => inb(1),
        Z => outb(1) 
			);
or_2 : o2 port map (
        A => ina(2),
        B => inb(2),
        Z => outb(2) 
			);
or_3 : o2 port map (
        A => ina(3),
        B => inb(3),
        Z => outb(3) 
			);
or_4 : o2 port map (
        A => ina(4),
        B => inb(4),
        Z => outb(4) 
			);
or_5 : o2 port map (
        A => ina(5),
        B => inb(5),
        Z => outb(5) 
			);
or_6 : o2 port map (
        A => ina(6),
        B => inb(6),
        Z => outb(6) 
			);
or_7 : o2 port map (
        A => ina(7),
        B => inb(7),
        Z => outb(7) 
			);
or_8 : o2 port map (
        A => ina(8),
        B => inb(8),
        Z => outb(8) 
			);
or_9 : o2 port map (
        A => ina(9),
        B => inb(9),
        Z => outb(9) 
			);
or_10 : o2 port map (
        A => ina(10),
        B => inb(10),
        Z => outb(10) 
			);
or_11 : o2 port map (
        A => ina(11),
        B => inb(11),
        Z => outb(11) 
			);
or_12 : o2 port map (
        A => ina(12),
        B => inb(12),
        Z => outb(12) 
			);
or_13 : o2 port map (
        A => ina(13),
        B => inb(13),
        Z => outb(13) 
			);
or_14 : o2 port map (
        A => ina(14),
        B => inb(14),
        Z => outb(14) 
			);
or_15 : o2 port map (
        A => ina(15),
        B => inb(15),
        Z => outb(15) 
			);

end Behavioral;
