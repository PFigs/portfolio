----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    21:28:45 05/04/2010 
-- Design Name: 
-- Module Name:    arith_shift_unit - Behavioral 
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

entity arith_shift_unit is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0);
           b6 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           b8 : in  STD_LOGIC;
           b9 : in  STD_LOGIC;
           sinal : out  STD_LOGIC;
           cout : out  STD_LOGIC;
           zero : out  STD_LOGIC;
           overflow : out  STD_LOGIC);
end arith_shift_unit;

architecture Behavioral of arith_shift_unit is

signal shift_out, arith_out : STD_LOGIC_VECTOR (15 downto 0);
signal sinal_ar, zero_ar, cout_ar, sinal_sh, zero_sh, cout_sh : STD_LOGIC;

begin

shift_c :  shift_unit Port map
			( ina => A,
		     b6 => b6,
           outb => shift_out,
		     sinal => sinal_sh,
		     cout => cout_sh,
		     zero => zero_sh
			);
			

arith_c : arithmetic_unit Port map
			( ra => A,
           rb => B,
           b8 => b8,
           b7 => b7,
           b6 => b6,
           cout => cout_ar,
           overflow => overflow,
           zero => zero_ar,
           sinal => sinal_ar,
           res => arith_out
			 );

mux_sinal: mux2 port map
	(
		SEL => b9,
		A0  => sinal_ar,
		A1  => sinal_sh,
		Z   => sinal
	 );
mux_zero: mux2 port map
	(
		SEL => b9,
		A0  => zero_ar,
		A1  => zero_sh,
		Z   => zero
	 );
mux_cout: mux2 port map
	(
		SEL => b9,
		A0  => cout_ar,
		A1  => cout_sh,
		Z   => cout
	 );
mux_out : Mux16 Port map
			( I0 => arith_out,
           I1 => shift_out,
           O  => Z,
           S  => b9
			);
end Behavioral;

