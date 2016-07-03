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

entity xnor16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
		   inb : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end xnor16;

architecture Behavioral of xnor16 is

begin

xnor_0 : xno2 port map (
        A => ina(0),
        B => inb(0),
        Z => outb(0) 
			);
xnor_1 : xno2 port map (
        A => ina(1),
        B => inb(1),
        Z => outb(1) 
			);
xnor_2 : xno2 port map (
        A => ina(2),
        B => inb(2),
        Z => outb(2) 
			);
xnor_3 : xno2 port map (
        A => ina(3),
        B => inb(3),
        Z => outb(3) 
			);
xnor_4 : xno2 port map (
        A => ina(4),
        B => inb(4),
        Z => outb(4) 
			);
xnor_5 : xno2 port map (
        A => ina(5),
        B => inb(5),
        Z => outb(5) 
			);
xnor_6 : xno2 port map (
        A => ina(6),
        B => inb(6),
        Z => outb(6) 
			);
xnor_7 : xno2 port map (
        A => ina(7),
        B => inb(7),
        Z => outb(7) 
			);
xnor_8 : xno2 port map (
        A => ina(8),
        B => inb(8),
        Z => outb(8) 
			);
xnor_9 : xno2 port map (
        A => ina(9),
        B => inb(9),
        Z => outb(9) 
			);
xnor_10 : xno2 port map (
        A => ina(10),
        B => inb(10),
        Z => outb(10) 
			);
xnor_11 : xno2 port map (
        A => ina(11),
        B => inb(11),
        Z => outb(11) 
			);
xnor_12 : xno2 port map (
        A => ina(12),
        B => inb(12),
        Z => outb(12) 
			);
xnor_13 : xno2 port map (
        A => ina(13),
        B => inb(13),
        Z => outb(13) 
			);
xnor_14 : xno2 port map (
        A => ina(14),
        B => inb(14),
        Z => outb(14) 
			);
xnor_15 : xno2 port map (
        A => ina(15),
        B => inb(15),
        Z => outb(15) 
			);

end Behavioral;
