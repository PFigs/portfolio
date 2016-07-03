----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:50:42 05/05/2010 
-- Design Name: 
-- Module Name:    mux_4_2 - Behavioral 
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

entity mux_4_2 is
    Port ( z_ar_sh : in  STD_LOGIC;
           s_ar_sh : in  STD_LOGIC;
           z_log : in  STD_LOGIC;
           s_log : in  STD_LOGIC;
           z : out  STD_LOGIC;
           s : out  STD_LOGIC;
           SEL : in  STD_LOGIC);
end mux_4_2;

architecture Behavioral of mux_4_2 is

begin

m_z : mux2 port map
	(
        SEL => SEL,
        A0  => z_ar_sh,
        A1  => z_log,
        Z   => z
    );

m_s : mux2 port map
	(
        SEL => SEL,
        A0  => s_ar_sh,
        A1  => s_log,
        Z   => s
    );


end Behavioral;

