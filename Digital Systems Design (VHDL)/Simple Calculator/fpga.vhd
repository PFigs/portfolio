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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use WORK.PSDLIB.ALL;

library UNISIM;
use UNISIM.VComponents.all;

entity fpga is
  port (
    mclk : in  std_logic;                     -- master clock 50MHz
    btn  : in  std_logic_vector(3 downto 0);  -- buttons
    sw   : in  std_logic_vector(7 downto 0);  -- switches
    led  : out std_logic_vector(7 downto 0);  -- leds
    an   : out std_logic_vector(3 downto 0);  -- display selectors
    seg  : out std_logic_vector(7 downto 0)   -- display 7-segments + point
    );
end fpga;

architecture behavioral of fpga is

  signal clk50M, clk_disp, clk10Hz : std_logic;
  signal wire_cbits                : std_logic_vector(4 downto 0);
  signal wire_disp                 : std_logic_vector(15 downto 0);
  signal wire_reset                : std_logic;

begin

	cu : control
		port map(
			-- in
			clk => clk10Hz, 
			oper => btn,
			-- out
			rst => wire_reset,
			leds => led,
			cbits => wire_cbits
		);

	du : datapath
		port map(
			clk => clk10Hz,
			ent => sw,
			res => wire_cbits(2),
			rst => wire_reset,
			oper => wire_cbits(1 downto 0),
			enable => wire_cbits(4 downto 3),
			data => wire_disp 
		);

	inst_clkdiv : clkdiv port map(
		clk      => mclk,
		clk50M   => clk50M,
		clk10Hz => clk10Hz,
		clk_disp => clk_disp
    );

	inst_disp7 : disp7 port map(
		disp4   => wire_disp(15 downto 12),
		disp3   => wire_disp(11 downto 8),
		disp2   => wire_disp(7 downto 4),
		disp1   => wire_disp(3 downto 0),
		clk     => clk_disp,
		en_disp => an,
		segm    => seg
    );

end behavioral;

