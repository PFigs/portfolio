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

entity not16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end not16;

architecture Behavioral of not16 is

begin

not_0 : not1 port map (
        A => ina(0),
        Z => outb(0)
    );
	
not_1 : not1 port map (
        A => ina(1),
        Z => outb(1)
    );
not_2 : not1 port map (
        A => ina(2),
        Z => outb(2)
    );
not_3 : not1 port map (
        A => ina(3),
        Z => outb(3)
    );
not_4 : not1 port map (
        A => ina(4),
        Z => outb(4)
    );
not_5 : not1 port map (
        A => ina(5),
        Z => outb(5)
    );
not_6 : not1 port map (
        A => ina(6),
        Z => outb(6)
    );
not_7 : not1 port map (
        A => ina(7),
        Z => outb(7)
    );
not_8 : not1 port map (
        A => ina(8),
        Z => outb(8)
    );
not_9 : not1 port map (
        A => ina(9),
        Z => outb(9)
    );
not_10 : not1 port map (
        A => ina(10),
        Z => outb(10)
    );
not_11 : not1 port map (
        A => ina(11),
        Z => outb(11)
    );
not_12 : not1 port map (
        A => ina(12),
        Z => outb(12)
    );
not_13 : not1 port map (
        A => ina(13),
        Z => outb(13)
    );
not_14 : not1 port map (
        A => ina(14),
        Z => outb(14)
    );
not_15 : not1 port map (
        A => ina(15),
        Z => outb(15)
    );
end Behavioral;
