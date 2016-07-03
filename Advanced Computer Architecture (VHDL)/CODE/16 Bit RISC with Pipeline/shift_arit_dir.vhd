----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:41:38 04/28/2010 
-- Design Name: 
-- Module Name:    shift_arit_dir - Behavioral 
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

entity shift_arit_dir is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0);
			  sinal : out  STD_LOGIC;
		     cout : out  STD_LOGIC
			);
end shift_arit_dir;

architecture Behavioral of shift_arit_dir is

begin
cout <= ina(0);
sinal <= ina(15);

outb(0) <= ina(1);
outb(1) <= ina(2);
outb(2) <= ina(3);
outb(3) <= ina(4);
outb(4) <= ina(5);
outb(5) <= ina(6);
outb(6) <= ina(7);
outb(7) <= ina(8);
outb(8) <= ina(9);
outb(9) <= ina(10);
outb(10) <= ina(11);
outb(11) <= ina(12);
outb(12) <= ina(13);
outb(13) <= ina(14);
outb(14) <= ina(15);
outb(15) <= ina(15);


end Behavioral;

