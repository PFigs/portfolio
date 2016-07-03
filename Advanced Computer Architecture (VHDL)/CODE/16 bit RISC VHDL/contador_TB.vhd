---------------------------------------------------------------------------------------------------
--
-- Title       : Test Bench for contador
-- Design      : Gates
-- Author      : 
-- Company     : 
--
---------------------------------------------------------------------------------------------------
--
-- File        : $DSN\src\TestBench\contador_TB.vhd
-- Generated   : 18-04-2004, 10:48
-- From        : D:\Temp\gates\lixo.vhd
-- By          : Active-HDL Built-in Test Bench Generator ver. 1.2s
--
---------------------------------------------------------------------------------------------------
--
-- Description : Automatically generated Test Bench for contador_tb
--
---------------------------------------------------------------------------------------------------

library ieee;
use work.gates.all;
use ieee.std_logic_1164.all;

	-- Add your library and packages declaration here ...

entity contador_tb is
end contador_tb;

architecture TB_ARCHITECTURE of contador_tb is
	-- Component declaration of the tested unit
	component contador
	port(
		reset : in std_logic;
		clk : in std_logic;
		OutPut : out std_logic_vector(3 downto 0) );
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal reset : std_logic;
	signal clk : std_logic;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal OutPut : std_logic_vector(3 downto 0);

	-- Add your code here ...

begin

	-- Unit Under Test port map
	UUT : contador
		port map (
			reset => reset,
			clk => clk,
			OutPut => OutPut
		);

	-- Add your stimulus here ...

	CLK_GEN: process
	begin
		clk <= '0';
		wait for 20ns;
		clk <= '1';
		wait for 20ns;
	end process;

	RST_GEN: process
	begin
		reset <= '0';
		wait for 30ns;
		reset <= '1';
		wait for 40ns;
		reset <= '0';
		wait;
	end process;

end TB_ARCHITECTURE;

configuration TESTBENCH_FOR_contador of contador_tb is
	for TB_ARCHITECTURE
		for UUT : contador
			use entity work.contador(contador);
		end for;
	end for;
end TESTBENCH_FOR_contador;

