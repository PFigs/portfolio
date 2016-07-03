----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:25:56 05/04/2010 
-- Design Name: 
-- Module Name:    logic_unit - Behavioral 
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

entity logic_unit is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
           inb : in  STD_LOGIC_VECTOR (15 downto 0);
			  b6 : in  STD_LOGIC;
			  b7 : in  STD_LOGIC;
			  b8 : in  STD_LOGIC;
			  b9 : in  STD_LOGIC;
           outb : out  STD_LOGIC_VECTOR (15 downto 0);
           zero : out  STD_LOGIC;
           sinal : out  STD_LOGIC);
end logic_unit;

architecture Behavioral of logic_unit is

signal M0, M1, M2, M3, M4, M5, M6, M7, M8, M9, M10, M11, M12, M13, M14, M15 :STD_LOGIC_VECTOR (15 downto 0);
signal notina, notinb ,zeros, ones :STD_LOGIC_VECTOR (15 downto 0);
signal mux16out : STD_LOGIC_VECTOR (15 downto 0);
signal mux16SEL :STD_LOGIC_VECTOR (3 downto 0);


begin
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
mux16SEL(0) <= b6;
mux16SEL(1) <= b7;
mux16SEL(2) <= b8;
mux16SEL(3) <= b9;

zeros <= ("0000000000000000");
ones  <= ("1111111111111111");

M0  <= zeros;
M15 <= ones;

M3  <= inb;
M5  <= ina;

M10 <= notina;
M12 <= notinb;
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

not16a : not16 Port map
			( ina  => ina ,
	        outb  =>notina 
			);

not16b : not16 Port map
			( ina  => inb ,
	        outb  =>notinb 
			);
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
and_M1 : and16 Port map
			( ina  => ina,
	        inb  => inb,
           outb  => M1
			);
and_M2 : and16 Port map
			( ina  => notina,
	        inb  => inb,
           outb  => M2
			);
and_M4 : and16 Port map
			( ina  => ina,
	        inb  => notinb,
           outb  => M4
			);

--------------------------------------------------------------------------------------------------------------------			
--------------------------------------------------------------------------------------------------------------------
xor_M6 : xor16 Port map
			( ina  => ina,
	        inb  => inb,
           outb  => M6
			);
xnor_M9 : xnor16 Port map
			( ina   => ina,
	        inb   => inb,
           outb  => M9
			);
			
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
or_M7 : or16 Port map
			( ina  => ina,
	        inb  => inb,
           outb  => M7
			);
or_M11 : or16 Port map
			( ina  => notina,
	        inb  => inb,
           outb  => M11
			);
or_M13 : or16 Port map
			( ina  => ina,
	        inb  => notinb,
           outb  => M13
			);

--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------
nand_M14 : nand16 Port map
			( ina  => ina,
	        inb  => inb,
           outb  => M14
			);
nor_M8 : nor16 Port map
			( ina  => ina,
	        inb  => inb,
           outb  => M8
			);
--------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

mux16 : mux_16_16 Port map
		(  M0 => M0,
			M1 => M1,
			M2 => M2,
			M3 => M3,
			M4 => M4,
			M5 => M5,
			M6 => M6,
			M7 => M7,
			M8 => M8,
			M9 => M9,
			M10 => M10,
			M11 => M11,
			M12 => M12,
			M13 => M13,
			M14 => M14,
			M15 => M15,
			SEL => mux16SEL,
			OUTB => mux16out
		);
sinal <= mux16out(15);

zero_test : zero_detect Port map
			( res => mux16out,
           zero => zero); 
outb <= mux16out;

end Behavioral;

