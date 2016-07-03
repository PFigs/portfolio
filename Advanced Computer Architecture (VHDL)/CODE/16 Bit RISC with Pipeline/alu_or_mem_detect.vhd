----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:28:45 05/16/2010 
-- Design Name: 
-- Module Name:    alu_or_mem_detect - Behavioral 
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

entity alu_or_mem_detect is
    Port ( b15 : in  STD_LOGIC;
           b14 : in  STD_LOGIC;
           alu_or_mem : out  STD_LOGIC);
end alu_or_mem_detect;

architecture Behavioral of alu_or_mem_detect is

begin


end Behavioral;

