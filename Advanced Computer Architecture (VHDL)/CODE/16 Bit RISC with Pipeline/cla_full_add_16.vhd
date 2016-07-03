----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:12:34 05/30/2010 
-- Design Name: 
-- Module Name:    cla_full_add_16 - Behavioral 
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
use work.cla_lib.all;
use work.gates.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity cla_full_add_16 is
    Port ( cin : in  STD_LOGIC;
           x : in  STD_LOGIC_VECTOR (15 downto 0);
           y : in  STD_LOGIC_VECTOR (15 downto 0);
           sum : out  STD_LOGIC_VECTOR (15 downto 0);
           cout : out  STD_LOGIC;
           overflow : out  STD_LOGIC);
end cla_full_add_16;

architecture Behavioral of cla_full_add_16 is
	signal c15,c16 : STD_LOGIC;
begin


	cla: Carry_Look_ahead Port map
				( IN_A => x,
				  IN_B => y,
				  IN_C => cin,
				  OUT_Q => sum,
				  OUT_C => c16,
				  OUT_C15 => c15
				 );
	
	-- Flags
	xo2_0:xo2 port map
				(
					A=>c15,
					B=>c16,
					Z=>overflow
				);

	cout <= c16;

end Behavioral;

