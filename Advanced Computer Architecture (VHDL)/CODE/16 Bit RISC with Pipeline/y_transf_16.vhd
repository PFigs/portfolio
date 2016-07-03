----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:54:40 04/21/2010 
-- Design Name: 
-- Module Name:    y_transf_16 - Behavioral 
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

entity y_transf_16 is
    Port ( yin : in  STD_LOGIC_VECTOR (15 downto 0);
           yout : out  STD_LOGIC_VECTOR (15 downto 0);
           b7 : in  STD_LOGIC;
           b8 : in  STD_LOGIC);
end y_transf_16;

architecture Behavioral of y_transf_16 is


begin

y_0 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(0),
           yout => yout(0) 
			);

y_1 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(1),
           yout => yout(1) 
			);

y_2 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(2),
           yout => yout(2) 
			);

y_3 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(3),
           yout => yout(3) 
			);

y_4 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(4),
           yout => yout(4) 
			);

y_5 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(5),
           yout => yout(5) 
			);

y_6 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(6),
           yout => yout(6) 
			);

y_7 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(7),
           yout => yout(7) 
			);

y_8 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(8),
           yout => yout(8)
			);

y_9 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(9),
           yout => yout(9) 
			);

y_10 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(10),
           yout => yout(10) 
			);

y_11 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(11),
           yout => yout(11) 
			);

y_12 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(12),
           yout => yout(12) 
			);

y_13 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(13),
           yout => yout(13) 
			);

y_14 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(14),
           yout => yout(14) 
			);

y_15 : y_transf Port map 
			( b8 => b8,
           b7 => b7,
           yin => yin(15),
           yout => yout(15) 
			);


end Behavioral;

