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

entity Registers is
    Port ( WPort   : in  STD_LOGIC_VECTOR (15 downto 0);
			  SELWC   : in  STD_LOGIC_VECTOR ( 2 downto 0);
           SELA 	 : in  STD_LOGIC_VECTOR ( 2 downto 0);
			  SELB 	 : in  STD_LOGIC_VECTOR ( 2 downto 0);
			  SelWB 	 : in  STD_LOGIC_VECTOR ( 2 downto 0);
           RegA 	 : out STD_LOGIC_VECTOR (15 downto 0);
			  RegB 	 : out STD_LOGIC_VECTOR (15 downto 0);
			  SELREG  : in  STD_LOGIC;
			  Clock 	 : in  STD_LOGIC;
           Reset 	 : in  STD_LOGIC;
			  WEnable : in  STD_LOGIC);
end Registers;

architecture Behavioral of Registers is

	signal leave0, leave1, leave2, leave3,
			 leave4, leave5, leave6, leave7  
					   : STD_LOGIC_VECTOR (15 downto 0);
	signal decoded : STD_LOGIC_VECTOR ( 7 downto 0);
	signal MuxedReg: STD_LOGIC_VECTOR ( 2 downto 0);
	
begin
	-- Todos os registos tem o valor a ser escrito a entrada
	---- Escrita e controlada pelo wenable
	R0 : Reg16 port map (
		D => WPort,
		Q => leave0,
		CLK => Clock,
		R => Reset,
		E => decoded(0)
	);
	
	
	R1 : Reg16 port map (
		D => WPort,
		Q => leave1,
		CLK => Clock,
		R => Reset,
		E => decoded(1)
	);
	
	
	R2 : Reg16 port map (
		D => WPort,
		Q => leave2,
		CLK => Clock,
		R => Reset,
		E => decoded(2)
	);
	
	
	R3 : Reg16 port map (
		D => WPort,
		Q => leave3,
		CLK => Clock,
		R => Reset,
		E => decoded(3)
	);
	
	
	R4 : Reg16 port map (
		D => WPort,
		Q => leave4,
		CLK => Clock,
		R => Reset,
		E => decoded(4)
	);
	
	R5 : Reg16 port map (
		D => WPort,
		Q => leave5,
		CLK => Clock,
		R => Reset,
		E => decoded(5)
	);	
	
	R6 : Reg16 port map (
		D => WPort,
		Q => leave6,
		CLK => Clock,
		R => Reset,
		E => decoded(6)
	);	
	
	R7 : Reg16 port map (
		D => WPort,
		Q => leave7,
		CLK => Clock,
		R => Reset,
		E => decoded(7)
	);
	
	-- Seleciona operando A
	MuxA : Mux8x1 port map(
		M0 => leave0,
		M1 => leave1,
		M2 => leave2,
		M3 => leave3,
		M4 => leave4,
		M5 => leave5,
		M6 => leave6,
		M7 => leave7,
		Z => RegA,
		SEL => SelA
	);
	
	-- Seleciona operando B
	MuxB : Mux8x1 port map(
		M0 => leave0,
		M1 => leave1,
		M2 => leave2,
		M3 => leave3,
		M4 => leave4,
		M5 => leave5,
		M6 => leave6,
		M7 => leave7,
		Z => RegB,
		SEL => MuxedReg
	);
	
	MUX_RB_WC : mux3x2x1 port map(
		I0  => SELB,
		I1  => SELWC,
		SEL => SELREG,
		Z   => MuxedReg
	);
	
	-- Decoder selecciona registo a escrever
	DEC : Decoder3x8 port map(
		D => SelWB,
		O => decoded,
		E => WEnable
	);
	
end Behavioral;

