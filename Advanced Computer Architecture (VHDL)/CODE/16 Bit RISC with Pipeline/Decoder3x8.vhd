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

entity Decoder3x8 is
    Port ( D : in  STD_LOGIC_VECTOR (2 downto 0);
           O : out  STD_LOGIC_VECTOR (7 downto 0);
			  E : in STD_LOGIC); -- efectuar and com todos os bits de sada
end Decoder3x8;

architecture Behavioral of Decoder3x8 is

signal nout : STD_LOGIC_VECTOR (2 downto 0);
signal Z    : STD_LOGIC_VECTOR (7 downto 0);

begin
	
	NEG0 : not1 port map(
		A => D(0),
		Z => nout(0)
	);
	
	NEG1 : not1 port map(
		A => D(1),
		Z => nout(1)
	);
	
	NEG2 : not1 port map(
		A => D(2),
		Z => nout(2)
	);

	NA0 : a3 port map(
		A => nout(0),
		B => nout(1),
		D => nout(2),
		Z => Z(0)
	);

	NA1 : a3 port map(
		A => D(0),
		B => nout(1),
		D => nout(2),
		Z => Z(1)
	);

	NA2 : a3 port map(
		A => nout(0),
		B => D(1),
		D => nout(2),
		Z => Z(2)
	);

	NA3 : a3 port map(
		A => D(0),
		B => D(1),
		D => nout(2),
		Z => Z(3)
	);

	NA4 : a3 port map(
		A => nout(0),
		B => nout(1),
		D => D(2),
		Z => Z(4)
	);

	NA5 : a3 port map(
		A => D(0),
		B => nout(1),
		D => D(2),
		Z => Z(5)
	);

	NA6 : a3 port map(
		A => nout(0),
		B => D(1),
		D => D(2),
		Z => Z(6)
	);

	NA7 : a3 port map(
		A => D(0),
		B => D(1),
		D => D(2),
		Z => Z(7)
	);
	
	An0: a2 port map(
		A => Z(0),
		B => E,
		Z => O(0)
	);
	
	An1: a2 port map(
		A => Z(1),
		B => E,
		Z => O(1)
	);
	
	An2: a2 port map(
		A => Z(2),
		B => E,
		Z => O(2)
	);
	
	An3: a2 port map(
		A => Z(3),
		B => E,
		Z => O(3)
	);
	
	An4: a2 port map(
		A => Z(4),
		B => E,
		Z => O(4)
	);

	An5: a2 port map(
		A => Z(5),
		B => E,
		Z => O(5)
	);

	An6: a2 port map(
		A => Z(6),
		B => E,
		Z => O(6)
	);
	
	An7: a2 port map(
		A => Z(7),
		B => E,
		Z => O(7)
	);

end Behavioral;

