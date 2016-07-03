----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:56:14 04/19/2010 
-- Design Name: 
-- Module Name:    Registers - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.gates.all;
use work.new_vhd_lib.all;

entity Registers is
    Port ( Reg0 : in  STD_LOGIC_VECTOR (15 downto 0);
           Reg1 : in  STD_LOGIC_VECTOR (15 downto 0);
           Reg2 : in  STD_LOGIC_VECTOR (15 downto 0);
           Reg3 : in  STD_LOGIC_VECTOR (15 downto 0);
           Reg4 : in  STD_LOGIC_VECTOR (15 downto 0);
           Reg5 : in  STD_LOGIC_VECTOR (15 downto 0);
           Reg6 : in  STD_LOGIC_VECTOR (15 downto 0);
           Reg7 : in  STD_LOGIC_VECTOR (15 downto 0);
           RegA : out  STD_LOGIC_VECTOR (15 downto 0);
			  RegB : out  STD_LOGIC_VECTOR (15 downto 0);
           SelID : in  STD_LOGIC_VECTOR (2 downto 0);
			  SelWB : in  STD_LOGIC_VECTOR (2 downto 0);
           Clock : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
			  Enable: in STD_LOGIC);
end Registers;

architecture Behavioral of Registers is

	signal leave0 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave1 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave2 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave3 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave4 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave5 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave6 : STD_LOGIC_VECTOR (15 downto 0);
	signal leave7 : STD_LOGIC_VECTOR (15 downto 0);
	
	signal decoded : STD_LOGIC_VECTOR (7 downto 0);

begin

	-- Dúvidas:
	-- E o registo destino?
	-- Colocar um AND do enable com saida do decoder? Julgo que assim seja

	R0 : Reg16 port map (
		D => Reg0,
		Q => leave0,
		CLK => Clock,
		R => Reset,
		E => decoded(0)
	);
	
	
	R1 : Reg16 port map (
		D => Reg1,
		Q => leave1,
		CLK => Clock,
		R => Reset,
		E => decoded(1)
	);
	
	
	R2 : Reg16 port map (
		D => Reg2,
		Q => leave2,
		CLK => Clock,
		R => Reset,
		E => decoded(2)
	);
	
	
	R3 : Reg16 port map (
		D => Reg3,
		Q => leave3,
		CLK => Clock,
		R => Reset,
		E => decoded(3)
	);
	
	
	R4 : Reg16 port map (
		D => Reg4,
		Q => leave4,
		CLK => Clock,
		R => Reset,
		E => decoded(4)
	);
	
	R5 : Reg16 port map (
		D => Reg5,
		Q => leave5,
		CLK => Clock,
		R => Reset,
		E => decoded(5)
	);	
	
	R6 : Reg16 port map (
		D => Reg6,
		Q => leave6,
		CLK => Clock,
		R => Reset,
		E => decoded(6)
	);	
	
	R7 : Reg16 port map (
		D => Reg7,
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
		SEL => SelID
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
		SEL => SelID
	);
	
	-- Colocar decoder
	DEC : Decoder3x8 port map(
		D => SelWB ,
		Z => decoded
	);
	
end Behavioral;

