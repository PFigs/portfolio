--#include "defines.h"
--#include "stdio.h"
--
--/*
--
--  Contador a nivel estrutural
--  Este procedimento define o funcionamento a nivel estrutural do
--  contador binario
--  
-- */
-- 
--/* Valores de registos devem ser inicializados */
--
-- static bit Q[4] ;
-- static bit D[4] ;
-- 
--void init_ffs() {
--  int i;
--  
--  for(i=0; i<4; i++) 
--    Q[i] = ZERO();
--}
--
-- void
-- contador_estrutural_combinatorio()
-- {
--   bit r0,r1;
--   int i; /* Variavel de iteracao */
--
--   bit one;
--
--   one = ONE(); /* Inicializacao de bits 
--                   deve utilizar as primitivas ONE() e ZERO() */
--
--   XO2(Q[0],one,D[0]);
--   
--   XO2(Q[0],Q[1],D[1]);
--      
--   A2(Q[1],Q[0],r0);
--   XO2(Q[2],r0,D[2]);
--   
--   A2(Q[2],r0,r1);
--   XO2(Q[3],r1,D[3]);
--
--   for(i=0; i<4; i++) {
--     LATCH(D[i],Q[i]);
--   }
--
--
-- }
-- 
-- 
-- void
-- contador_estrutural(void)
-- {
--   contador_estrutural_combinatorio();
--   activate_clock();    /* Aqui e' dado o impulso de relogio  */
-- }
--  
-- 
--main() {
--  init_ffs();
--  while (1) {
--    contador_estrutural();
--
--    printf("%d %d %d %d\n", 
--           IS_ONE(Q[3]),
--           IS_ONE(Q[2]),
--           IS_ONE(Q[1]),
--           IS_ONE(Q[0]));
--    
--  }
--}
--
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use work.gates.all;

entity contador is
	port(
		reset : in STD_LOGIC;
		clk : in STD_LOGIC;
		OutPut : out STD_LOGIC_VECTOR(3 downto 0)
		);
end contador;

architecture contador of contador is
	signal Q, D : STD_LOGIC_VECTOR(3 downto 0);	 
	signal one, zero, r0, r1 : STD_LOGIC;
	signal enable : STD_LOGIC;

begin
	one <= '1';
	zero <= '0';
	enable <= '1';
	
--	latch: process (reset)
--	begin
--	        if reset='1' then	--RESET active High
--			Q <= (others =>'0');
--		end if;
--	end process latch;
	xor21 : xo2
	port map (
		A => Q(0),
		B => one,
		Z => D(0)
		);	
	xor22 : xo2
	port map (
		A => Q(0),
		B => Q(1),
		Z => D(1)
		);	
	a21 : a2
	port map (
		A => Q(1),
		B => Q(0),
		Z => r0
		);			
	xor23 : xo2
	port map (
		A => Q(2),
		B => r0,
		Z => D(2)
		);			
	a22 : a2
	port map (
		A => Q(2),
		B => r0,
		Z => r1
		);			
	xor24 : xo2
	port map (
		A => Q(3),
		B => r1,
		Z => D(3)
		);

	FF_Out0 : ffe port map (
		CLK => CLK,
		Reset => reset,
		Enable => enable,
		D => D(0),
		Q => Q(0)
	 );
	FF_Out1 : ffe port map (
		CLK => CLK,
		Reset => reset,
		Enable => enable,
		D => D(1),
		Q => Q(1)
	 );
	FF_Out2 : ffe port map (
		CLK => CLK,
		Reset => reset,
		Enable => enable,
		D => D(2),
		Q => Q(2)
	 );
	FF_Out3 : ffe port map (
		CLK => CLK,
		Reset => reset,
		Enable => enable,
		D => D(3),
		Q => Q(3)
	 );

OutPut <= Q;
end contador;
