----------------------------------------------------------------------------------
-- Projecto Arquitecturas Avanadas de Computadores
-- 			2 Semestre 2009/2010
-- 
-- Realizado por:
-- Pedro Silva (58035)
-- Oleksandr Yefimochkin (58958)
--
-- Responsvel:
-- Leonel Sousa
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.gates.all;
use work.new_vhd_lib.all;

entity mux3x2x1 is
    Port ( I0 : in  STD_LOGIC_VECTOR (2 downto 0);
           I1 : in  STD_LOGIC_VECTOR (2 downto 0);
           SEL : in  STD_LOGIC;
           Z : out  STD_LOGIC_VECTOR (2 downto 0));
end mux3x2x1;

architecture Behavioral of mux3x2x1 is

begin

	MUX0L0: mux2 port map(
		A0 => I0(0),
		A1 => I1(0),
		Z => Z(0),
		SEL => SEL
	);

	MUX1L0: mux2 port map(
		A0 => I0(1),
		A1 => I1(1),
		Z => Z(1),
		SEL => SEL
	);

	MUX1L1: mux2 port map(
		A0 => I0(2),
		A1 => I1(2),
		Z => Z(2),
		SEL => SEL
	);



end Behavioral;

