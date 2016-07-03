----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:27:46 04/21/2010 
-- Design Name: 
-- Module Name:    y_transf - Behavioral 
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

entity y_transf is
    Port ( b8 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           yin : in  STD_LOGIC;
           yout : out  STD_LOGIC);
end y_transf;

architecture Behavioral of y_transf is
signal mux_out: STD_LOGIC;
begin

xor_t : xo2	port map (
		A => yin,
		B => b8,
		Z => mux_out
	);
	
mux_t : mux2 port map (
        SEL => b7,
        A0 => mux_out,
        A1 => b8,
        Z =>yout
    );


end Behavioral;

