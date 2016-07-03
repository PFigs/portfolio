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

entity RegBank_IF_ID is
    Port ( NEXTPC : in  STD_LOGIC_VECTOR (15 downto 0);
           INST : in  STD_LOGIC_VECTOR (15 downto 0);
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           Z0 : out  STD_LOGIC_VECTOR (15 downto 0);
           Z1 : out  STD_LOGIC_VECTOR (15 downto 0));
end RegBank_IF_ID;

architecture Behavioral of RegBank_IF_ID is

begin


	KEEP_NEXT_PC: Reg16 port map(
		CLK => CLK,
		E => EN,
      R => RST,
      D => NEXTPC,
      Q => Z0
	);
	
	KEEP_INST: Reg16 port map(
		CLK => CLK,
		E => EN,
      R => RST,
      D => INST,
      Q => Z1
	);
	
end Behavioral;

