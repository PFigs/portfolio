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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity verifier_decoder is
	port (
		idx : in std_logic_vector (idx_size-1 downto 0);
		en : out std_logic_vector (width-1 downto 0)
	);
end verifier_decoder;

architecture Behavioral of verifier_decoder is

begin

	process(idx)
	begin
		for i in 0 to width-1 loop
			if conv_integer('0'&idx) = i then
				en(i) <= '1';
			else
				en(i) <= '0';
			end if;
		end loop;
	end process;
	
--		with conv_integer('0'&idx) select
--			en <=       (00 => '1', others => '0') when 00,
--							(01 => '1', others => '0') when 01,
--							(02 => '1', others => '0') when 02,
--							(03 => '1', others => '0') when 03,
--							(04 => '1', others => '0') when 04,
--							(05 => '1', others => '0') when 05,
--							(06 => '1', others => '0') when 06,
--							(07 => '1', others => '0') when 07,
--							(08 => '1', others => '0') when 08,
--							(09 => '1', others => '0') when 09,
--							(10 => '1', others => '0') when 10,
--							(11 => '1', others => '0') when 11,
--							(12 => '1', others => '0') when 12,
--							(13 => '1', others => '0') when 13,
--							(14 => '1', others => '0') when 14,
--							(15 => '1', others => '0') when 15,
--							(16 => '1', others => '0') when 16,
--							(17 => '1', others => '0') when 17,
--							(18 => '1', others => '0') when 18,
--							(19 => '1', others => '0') when 19,
--							(20 => '1', others => '0') when 20,
--							(21 => '1', others => '0') when 21,
--							(22 => '1', others => '0') when 22,
--							(23 => '1', others => '0') when 23,
--							(24 => '1', others => '0') when others;

end Behavioral;

