----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:58:45 05/04/2010 
-- Design Name: 
-- Module Name:    nor16 - Behavioral 
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

entity nor16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
	        inb : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end nor16;

architecture Behavioral of nor16 is

begin

nor_0 : no2 port map (
        A => ina(0),
        B => inb(0),
        Z => outb(0) 
			);
nor_1 : no2 port map (
        A => ina(1),
        B => inb(1),
        Z => outb(1) 
			);
nor_2 : no2 port map (
        A => ina(2),
        B => inb(2),
        Z => outb(2) 
			);
nor_3 : no2 port map (
        A => ina(3),
        B => inb(3),
        Z => outb(3) 
			);
nor_4 : no2 port map (
        A => ina(4),
        B => inb(4),
        Z => outb(4) 
			);
nor_5 : no2 port map (
        A => ina(5),
        B => inb(5),
        Z => outb(5) 
			);
nor_6 : no2 port map (
        A => ina(6),
        B => inb(6),
        Z => outb(6) 
			);
nor_7 : no2 port map (
        A => ina(7),
        B => inb(7),
        Z => outb(7) 
			);
nor_8 : no2 port map (
        A => ina(8),
        B => inb(8),
        Z => outb(8) 
			);
nor_9 : no2 port map (
        A => ina(9),
        B => inb(9),
        Z => outb(9) 
			);
nor_10 : no2 port map (
        A => ina(10),
        B => inb(10),
        Z => outb(10) 
			);
nor_11 : no2 port map (
        A => ina(11),
        B => inb(11),
        Z => outb(11) 
			);
nor_12 : no2 port map (
        A => ina(12),
        B => inb(12),
        Z => outb(12) 
			);
nor_13 : no2 port map (
        A => ina(13),
        B => inb(13),
        Z => outb(13) 
			);
nor_14 : no2 port map (
        A => ina(14),
        B => inb(14),
        Z => outb(14) 
			);
nor_15 : no2 port map (
        A => ina(15),
        B => inb(15),
        Z => outb(15) 
			);

end Behavioral;