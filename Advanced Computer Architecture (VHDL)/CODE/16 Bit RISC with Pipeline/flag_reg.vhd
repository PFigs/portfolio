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

entity flag_reg is
    Port (
			  CLK : in  STD_LOGIC;
			  z : in  STD_LOGIC;
           s : in  STD_LOGIC;
           c : in  STD_LOGIC;
           o : in  STD_LOGIC;
			  
           b6 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           b8 : in  STD_LOGIC;
           b9 : in  STD_LOGIC;
			  b10 : in  STD_LOGIC;
			  
			  b14 : in  STD_LOGIC;
			  b15 : in  STD_LOGIC;
			  
           zero : out  STD_LOGIC;
           sinal : out  STD_LOGIC;
           cout : out  STD_LOGIC;
           overflow : out  STD_LOGIC;
			  FLAG_EN : out STD_LOGIC_VECTOR(3 downto 0));
end flag_reg;

architecture Behavioral of flag_reg is

signal ez , es, ec, eo : STD_LOGIC;


begin

	------
	-- Flag enables
	-- 0 - zero
	-- 1 - sinal
	-- 2 - carry
	-- 3 - overflow
	FLAG_EN(0)<=ez;
	FLAG_EN(1)<=es;
	FLAG_EN(2)<=ec;
	FLAG_EN(3)<=eo;

	ENABLE_LOGIC : flag_en_logic Port map
			(
			  b15  => b15,
			  b14  => b14,
			  
			  b10  => b10,
           b9   => b9,
           b8   => b8,
           b7   => b7,
           b6   => b6,
			  
           es   => es,
           ec   => ec,
           ez   => ez,
           eo   => eo
			);
			  
ff_z :ffe port map 
	(
		CLK => CLK,
		Reset => '0',
		Enable => ez,
		D => z,
		Q => zero
	 );
	 
ff_s :ffe port map 
	(
		CLK => CLK,
		Reset => '0',
		Enable => es,
		D => s,
		Q => sinal
	 );
	 
ff_c :ffe port map 
	(
		CLK => CLK,
		Reset => '0',
		Enable => ec,
		D => c,
		Q => cout
	 );
ff_o :ffe port map 
	(
		CLK => CLK,
		Reset => '0',
		Enable => eo,
		D => o,
		Q => overflow
	 );

end Behavioral;

