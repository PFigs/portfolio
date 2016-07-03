----------------------------------------------------------------------------------
-- Projecto Arquitecturas Avançadas de Computadores
-- 			2º Semestre 2009/2010
-- 
-- Realizado por:
-- Pedro Silva (58035)
-- Oleksandr Yefimochkin (58958)
--
-- Responsável:
-- Leonel Sousa
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.gates.all;
use work.new_vhd_lib.all;

entity mux5x2x1 is
    Port ( I0 : in  STD_LOGIC_VECTOR (4 downto 0);
           I1 : in  STD_LOGIC_VECTOR (4 downto 0);
           Z : out  STD_LOGIC_VECTOR (4 downto 0);
           SEL : in  STD_LOGIC);
end mux5x2x1;

architecture Behavioral of mux5x2x1 is

begin

	M0 : mux2 port map(
      SEL => SEL,
      A0 => I0(0),
      A1 => I1(0),
      Z => Z(0)
    );
	 
 	M1 : mux2 port map(
		SEL => SEL,
      A0 => I0(1),
      A1 => I1(1),
      Z => Z(1)
    );
	 
 	M2 : mux2 port map(
		SEL => SEL,
      A0 => I0(2),
      A1 => I1(2),
      Z => Z(2)
    );
	 
 	M3 : mux2 port map(
		SEL => SEL,
      A0 => I0(3),
      A1 => I1(3),
      Z => Z(3)
    );
	 
 	M4 : mux2 port map(
		SEL => SEL,
      A0 => I0(4),
      A1 => I1(4),
      Z => Z(4)
    );


end Behavioral;

