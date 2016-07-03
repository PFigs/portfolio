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

entity and16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
	        inb : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end and16;

architecture Behavioral of and16 is

begin

and_0 : a2 port map (
        A => ina(0),
        B => inb(0),
        Z => outb(0) 
			);
and_1 : a2 port map (
        A => ina(1),
        B => inb(1),
        Z => outb(1) 
			);
and_2 : a2 port map (
        A => ina(2),
        B => inb(2),
        Z => outb(2) 
			);
and_3 : a2 port map (
        A => ina(3),
        B => inb(3),
        Z => outb(3) 
			);
and_4 : a2 port map (
        A => ina(4),
        B => inb(4),
        Z => outb(4) 
			);
and_5 : a2 port map (
        A => ina(5),
        B => inb(5),
        Z => outb(5) 
			);
and_6 : a2 port map (
        A => ina(6),
        B => inb(6),
        Z => outb(6) 
			);
and_7 : a2 port map (
        A => ina(7),
        B => inb(7),
        Z => outb(7) 
			);
and_8 : a2 port map (
        A => ina(8),
        B => inb(8),
        Z => outb(8) 
			);
and_9 : a2 port map (
        A => ina(9),
        B => inb(9),
        Z => outb(9) 
			);
and_10 : a2 port map (
        A => ina(10),
        B => inb(10),
        Z => outb(10) 
			);
and_11 : a2 port map (
        A => ina(11),
        B => inb(11),
        Z => outb(11) 
			);
and_12 : a2 port map (
        A => ina(12),
        B => inb(12),
        Z => outb(12) 
			);
and_13 : a2 port map (
        A => ina(13),
        B => inb(13),
        Z => outb(13) 
			);
and_14 : a2 port map (
        A => ina(14),
        B => inb(14),
        Z => outb(14) 
			);
and_15 : a2 port map (
        A => ina(15),
        B => inb(15),
        Z => outb(15) 
			);

end Behavioral;

