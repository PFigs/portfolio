----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:53:29 04/15/2010 
-- Design Name: 
-- Module Name:    full_add_1bit - Behavioral 
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

entity full_add_1bit is
    port ( x : in  STD_LOGIC;
           y : in  STD_LOGIC;
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           sum : out  STD_LOGIC);
end full_add_1bit;

architecture Behavioral of full_add_1bit is
	signal s1,s2,s3 : STD_LOGIC;

begin

	XOR_1 : xo2 port map (
	A => x,
	B => y  ,
	Z => s1
	);

	XOR_2 : xo2 port map (
	A => s1,
	B => cin,
	Z => sum
	);

	AND_1 : a2 port map (
	A => x,
	B => y,
	Z => s2
	);

	AND_2 : a2 port map (
	A => s1,
	B => cin,
	Z => s3
	);

	OR_1 : a2 port map (
	A => s2,
	B => s3,
	Z => cout
	);

end Behavioral;

