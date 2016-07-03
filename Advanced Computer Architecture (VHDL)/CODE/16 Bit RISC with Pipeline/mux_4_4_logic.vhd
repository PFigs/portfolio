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

entity mux_4_4_logic is
    Port ( b : in  STD_LOGIC_VECTOR (15 downto 0);
           OP : out  STD_LOGIC_VECTOR (4 downto 0));
end mux_4_4_logic;

architecture Behavioral of mux_4_4_logic is
signal nob, SEL: STD_LOGIC;

begin

andb12_b13_nob: a3 port map
		(
        A => b(12),
        B => b(13),
		  D => nob,
        Z => SEL  
		  );
	 
nob15_b14: no2 port map
	(
        A =>b(15) ,
        B => b(14),
        Z => nob
    );

mux_alu_op : mux_4_4 Port map
			( IN0 => ("00000"),
  			  IN1 => b(10 downto 6),
           SEL => SEL,
           OUTS => OP
			);
end Behavioral;

