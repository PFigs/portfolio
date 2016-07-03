----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:16:40 05/07/2010 
-- Design Name: 
-- Module Name:    mux_4_4 - Behavioral 
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

entity mux_4_4 is
    Port ( IN0 : in  STD_LOGIC_VECTOR (4 downto 0);
  			  IN1 : in  STD_LOGIC_VECTOR (4 downto 0);
           SEL : in  STD_LOGIC;
           OUTS : out  STD_LOGIC_VECTOR (4 downto 0));
end mux_4_4;

architecture Behavioral of mux_4_4 is

begin
m_0 : mux2 port map
	(
        SEL => SEL,
        A0 => IN0(0),
        A1 => IN1(0),
        Z => OUTS(0)
    );
m_1 : mux2 port map
	(
        SEL => SEL,
        A0 => IN0(1),
        A1 => IN1(1),
        Z => OUTS(1)
    );
m_2 : mux2 port map
	(
        SEL => SEL,
        A0 => IN0(2),
        A1 => IN1(2),
        Z => OUTS(2)
    );
m_3 : mux2 port map
	(
        SEL => SEL,
        A0 => IN0(3),
        A1 => IN1(3),
        Z => OUTS(3)
	);
		  
m_4 : mux2 port map
	(
        SEL => SEL,
        A0 => IN0(4),
        A1 => IN1(4),
        Z => OUTS(4)
    );


end Behavioral;

