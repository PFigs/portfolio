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
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use WORK.PSDLIB.ALL;

entity counter is
	port( 
		CLK : in std_logic;
		CLR : in std_logic;
		ce : in std_logic;
		limit: in std_logic_vector(line_bits-1 downto 0);
		Q : out std_logic_vector(line_bits-1 downto 0);
		overflow : out std_logic
	);
end counter;

architecture archi of counter is
    signal tmp: std_logic_vector(line_bits-1 downto 0);
begin
    process (CLK)
    begin
        if (CLK'event and CLK='1') then
			if (CLR='1') then
				tmp <= (others => '0');
			elsif (ce = '1') then
				tmp <= tmp + 1;
			end if;
			if tmp = limit-1 and ce='1' then
				tmp <= (others => '0');
			end if;
		end if;
	end process;

	 overflow <= '1' when tmp = limit-1 else
					 '1' when conv_integer('0'&tmp) = width-1 else
					 '0';
    Q <= tmp;

end archi;
