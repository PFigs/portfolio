----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:51:52 04/21/2010 
-- Design Name: 
-- Module Name:    zero_detect - Behavioral 
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

entity zero_detect is
    Port ( res : in   STD_LOGIC_VECTOR (15 downto 0);
           zero : out  STD_LOGIC); 
end zero_detect;

architecture Behavioral of zero_detect is

signal nor3o1 ,nor3o2 ,nor3o3 ,nor3o4 ,nor3o5 ,notout : STD_LOGIC;
signal nand3o1 ,nand3o2 : STD_LOGIC;


begin

nor_3_1 : no3 port map
		(
        A => res(0),
        B => res(1),
        D => res(2),
        Z => nor3o1
      );
nor_3_2 : no3 port map
		(
        A => res(3),
        B => res(4),
        D => res(5),
        Z => nor3o2
      );
nor_3_3 : no3 port map
		(
        A => res(6),
        B => res(7),
        D => res(8),
        Z => nor3o3
      );
nor_3_4 : no3 port map
		(
        A => res(9),
        B => res(10),
        D => res(11),
        Z => nor3o4
      );
nor_3_5 : no3 port map
		(
        A => res(12),
        B => res(13),
        D => res(14),
        Z => nor3o5
      );
not_1 : not1 port map
		(
        A => res(15),
        Z => notout
      );

nand_3_1 : na3 port map
		(
        A => nor3o1,
        B => nor3o2,
        D => nor3o3,
        Z => nand3o1
      );

nand_3_2 : na3 port map
		(
        A => nor3o4,
        B => nor3o5,
        D => notout,
        Z => nand3o2
      );

no2_1 : no2 port map
		(
        A => nand3o1,
        B => nand3o2,
        Z => zero
      );
end Behavioral;

