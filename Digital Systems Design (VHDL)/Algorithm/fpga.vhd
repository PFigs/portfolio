----------------------------------------------------------------------------------
-- Instituto Superior Técnico 
-- 
-- Projecto Sistemas Digitais
-- 
-- Martim Camacho, martim.camacho@ist.utl.pt (56755)
-- Pedro Silva, pedro.silva@ist.utl.pt (58035)
-- 
----------------------------------------------------------------------------------
library IEEE;
library UNISIM;
use ieee.numeric_std.all;
use UNISIM.Vcomponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use WORK.PSDLIB.ALL;

entity fpga is
    port ( 
				clk	: in STD_LOGIC;
				reset : in STD_LOGIC;
				data	: out STD_LOGIC_VECTOR(31 downto 0);
				idx	: out STD_LOGIC_VECTOR(addr_size-1 downto 0)
			);
end fpga;

architecture Behavioral of fpga is
	signal wire_cbits: std_logic_vector(cbits_size-1 downto 0);
	signal wire_idx: std_logic_vector(addr_size-1 downto 0);
	signal wire_clear: std_logic;
begin

	dp : datapath
		port map ( 
			clk 	=> clk,
			clear	=> wire_clear,
			cbits	=> wire_cbits, -- bits controlo
			outi 	=> data,
			idx 	=> wire_idx
		);

	ctrl : control
		port map (
			clk		=> clk,
			rst		=> reset,
			cbits	=> wire_cbits,
			clear	=> wire_clear,
			idx 	=> wire_idx
		);
		
		idx <= wire_idx;
end Behavioral;

