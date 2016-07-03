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

entity mem_writer is
	port(
		clk : in std_logic;
		rst : in std_logic;
		enable : in std_logic;
		colerror: in std_logic;
		linerror: in std_logic;
		regerror: in std_logic;
		error: in std_logic;
		linele : in std_logic_vector (line_bits-1 downto 0);
		linece : in std_logic_vector (line_bits-1 downto 0);
		regle : in std_logic_vector (line_bits-1 downto 0);
		regce : in std_logic_vector (line_bits-1 downto 0);
		colle : in std_logic_vector (line_bits-1 downto 0);
		colce : in std_logic_vector (line_bits-1 downto 0);
		lin : in std_logic_vector (line_bits-1 downto 0);
		col : in std_logic_vector (line_bits-1 downto 0);
		
		WRenable   : out std_logic;
		WRdata    : out std_logic_vector(31 downto 0)
		);
end mem_writer;

architecture Behavioral of mem_writer is
	signal wire_sel: std_logic_vector(3 downto 0);
	signal wire_data: std_logic_vector(31 downto 0);

begin

	wire_sel <=  error & colerror & linerror & regerror;
	with wire_sel select
	wire_data <= "00000000000" & lin & col & linele & linece & enable when "1010",
			"00000000000"  & lin & col & regle & regce  & enable when "1001",
			"00000000000" & lin & col & linele & linece & enable when "1011",
			"00000000000" & lin & col & colle & colce & enable when others;
					
	process (clk)
	begin
		if clk'event and clk='1' then  
			if rst='1' then   
				WRDATA <= (others => '0');
				WRenable <= '0';
			elsif enable = '1' then   -- set
				WRDATA <= "0" & wire_data(wire_data'high downto 1);
				WRenable <= wire_data(0);
			end if;
		end if;
	end process;

	--WRenable <= WRDATA(0);


	--~ wire_sel <=  error & colerror & linerror & regerror;

	--~ with wire_sel select
		--~ WRDATA <= "000000000000" & lin & col & linele & linece when "1010",
				  --~ "000000000000" & lin & col & regle & regce when "1001",
				  --~ "000000000000" & lin & col & linele & linece when "1011",  -- Modificado Silva: Nao contemplava caso erro na mesma linha e regiao
				  --~ "000000000000" & lin & col & colle & colce when others;
					 
end Behavioral;

