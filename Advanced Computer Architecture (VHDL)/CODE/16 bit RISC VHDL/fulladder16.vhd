----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:58:42 04/15/2010 
-- Design Name: 
-- Module Name:    full_add_16 - Behavioral 
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

entity fulladder16 is
    port ( x : in  STD_LOGIC_VECTOR (15 downto 0);
           y : in  STD_LOGIC_VECTOR (15 downto 0);
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           overflow : out  STD_LOGIC;
           sum : out  STD_LOGIC_VECTOR (15 downto 0));
end full_add_16;

architecture Behavioral of full_add_16 is
	signal co0,co1,co2,co3,co4,co5,co6,co7,co8,co9,co10,co11,co12,co13,co14,co15: STD_LOGIC;
	
begin


ADDER0 : full_add_1bit port map (
	x =>x(0) ,
	y => y(0),
	cin => cin,
	cout => co0,
	sum => sum(0)
	);

ADDER1 : full_add_1bit port map (
	x =>x(1) ,
	y => y(1),
	cin => co0,
	cout => co1,
	sum => sum(1)
	);

ADDER2 : full_add_1bit port map (
	x =>x(2) ,
	y => y(2),
	cin => co1,
	cout => co2,
	sum => sum(2)
	);

ADDER3 : full_add_1bit port map (
	x =>x(3) ,
	y => y(3),
	cin => co2,
	cout => co3,
	sum => sum(3)
	);

ADDER4 : full_add_1bit port map (
	x =>x(4) ,
	y => y(4),
	cin => co3,
	cout => co4,
	sum => sum(4)
	);

ADDER5 : full_add_1bit port map (
	x =>x(5) ,
	y => y(5),
	cin => co4,
	cout => co5,
	sum => sum(5)
	);

ADDER6 : full_add_1bit port map (
	x =>x(6) ,
	y => y(6),
	cin => co5,
	cout => co6,
	sum => sum(5)
	);

ADDER7 : full_add_1bit port map (
	x =>x(7) ,
	y => y(7),
	cin => co6,
	cout => co7,
	sum => sum(6)
	);

ADDER8 : full_add_1bit port map (
	x =>x(8) ,
	y => y(8),
	cin => co7,
	cout => co8,
	sum => sum(8)
	);

ADDER9 : full_add_1bit port map (
	x =>x(9) ,
	y => y(9),
	cin => co8,
	cout => co9,
	sum => sum(9)
	);

ADDER10 : full_add_1bit port map (
	x =>x(10) ,
	y => y(10),
	cin => co9,
	cout => co10,
	sum => sum(10)
	);

ADDER11 : full_add_1bit port map (
	x =>x(11),
	y => y(11),
	cin => co10,
	cout => co11,
	sum => sum(11)
	);

ADDER12 : full_add_1bit port map (
	x =>x(12) ,
	y => y(12),
	cin => co11,
	cout => co12,
	sum => sum(12)
	);

ADDER13 : full_add_1bit port map (
	x =>x(13) ,
	y => y(13),
	cin => co12,
	cout => co13,
	sum => sum(13)
	);
	
ADDER14 : full_add_1bit port map (
	x =>x(14) ,
	y => y(14),
	cin => co13,
	cout => co14,
	sum => sum(14)
	);
	
ADDER15 : full_add_1bit port map (
	x =>x(15) ,
	y => y(15),
	cin => co14,
	cout => co15,
	sum => sum(15)
	);

cout <= co15;

XOR_Overflow : xo2 port map (
	A => co14,
	B => co15,
	Z => overflow
	);

end Behavioral;

