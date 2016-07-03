----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:10:47 04/28/2010 
-- Design Name: 
-- Module Name:    shift_unit - Behavioral 
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

entity shift_unit is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
		     b6 : in  STD_LOGIC;
           outb : out  STD_LOGIC_VECTOR (15 downto 0);
		     sinal : out  STD_LOGIC;
		     cout : out  STD_LOGIC;
		     zero : out  STD_LOGIC
			);
end shift_unit;

architecture Behavioral of shift_unit is
signal sh_esq_out, sh_dir_out, aux: STD_LOGIC_VECTOR (15 downto 0);
signal sinal_esq, sinal_dir, cout_esq, cout_dir : STD_LOGIC;

begin

outb <= aux;

shift_esq : shift_log_esq
		Port map( 
					ina => ina,
					outb => sh_esq_out,
					sinal => sinal_esq,
					cout => cout_esq
				);

shift_dir : shift_arit_dir
		Port map( 
					ina => ina,
					outb => sh_dir_out,
					sinal => sinal_dir,
					cout => cout_dir
				);

mux_out: Mux16
		Port map(
					I0 => sh_esq_out ,
					I1 => sh_dir_out,
					O  => aux,
					S  => b6 
				);
				
M0_sinal : mux2 port map(
		A0 => sinal_esq,
		A1 => sinal_dir,
		SEL => b6,
		Z => sinal
	);

M1_cout : mux2 port map(
		A0 => cout_esq,
		A1 => cout_dir,
		SEL => b6,
		Z => cout
	);

zero_flag : zero_detect		
		Port map( res  =>  aux,
			      zero  => zero);

end Behavioral;
