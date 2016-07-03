----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:24:03 04/21/2010 
-- Design Name: 
-- Module Name:    arithmetic_unit - Behavioral 
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
use work.new_vhd_lib.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity arithmetic_unit is
    Port ( ra : in  STD_LOGIC_VECTOR (15 downto 0);
           rb : in  STD_LOGIC_VECTOR (15 downto 0);
           b8 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           b6 : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           overflow : out  STD_LOGIC;
           zero : out  STD_LOGIC;
           sinal : out  STD_LOGIC;
           res : out  STD_LOGIC_VECTOR (15 downto 0));
end arithmetic_unit;

architecture Behavioral of arithmetic_unit is

signal yt, zerotest :  STD_LOGIC_VECTOR (15 downto 0);

begin


y_transform : y_transf_16 port map 
			( yin  => rb,
           yout  => yt,
           b7  => b7,
           b8  => b8
			);
--
--entity cla_full_add_16 is
--    Port ( cin : in  STD_LOGIC;
--           x : in  STD_LOGIC_VECTOR (15 downto 0);
--           y : in  STD_LOGIC_VECTOR (15 downto 0);
--           sum : out  STD_LOGIC_VECTOR (15 downto 0);
--           cout : out  STD_LOGIC;
--           overflow : out  STD_LOGIC);
adder : cla_full_add_16 port map
			( x => ra,
           y => yt,
           cin => b6,
           cout => cout,
           overflow => overflow,
			  sum => zerotest
			);

res <= zerotest;
sinal <= zerotest(15);

zero_test : zero_detect	Port map
				( res => zerotest,
              zero => zero
				 );



end Behavioral;

