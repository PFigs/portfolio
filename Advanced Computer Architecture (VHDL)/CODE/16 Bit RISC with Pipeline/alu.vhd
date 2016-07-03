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

entity alu_unit is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);

           b15 : in  STD_LOGIC;
           b14 : in  STD_LOGIC;

           b10 : in  STD_LOGIC;
           b9 : in  STD_LOGIC;
           b8 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           b6 : in  STD_LOGIC;
			  CLK : in  std_logic;
           Z : out  STD_LOGIC_VECTOR (15 downto 0);
           sinal : out  STD_LOGIC;
           cout : out  STD_LOGIC;
           zero : out  STD_LOGIC;
           overflow : out  STD_LOGIC);
end alu_unit;

architecture Behavioral of alu_unit is

signal  z_ar_sh, s_ar_sh, z_log, s_log : STD_LOGIC;
signal  z_aux, s_aux, c_aux, o_aux : STD_LOGIC;
signal arsh_out, log_out : STD_LOGIC_VECTOR (15 downto 0);

signal wireZero,wireSinal, wireCarry, wireOverflow : STD_LOGIC;
signal FLAG_EN : STD_LOGIC_VECTOR(3 downto 0);

begin

	ar_sh_unit : arith_shift_unit port map(
		A => A,
		B => B,
		Z => arsh_out,
		b6 => b6,
		b7 => b7,
		b8 => b8,
		b9 => b9,
		sinal => s_ar_sh,
		cout => c_aux,
		zero => z_ar_sh,
		overflow => o_aux
		);

	log_unit : logic_unit port map( 
		ina   => A,
      inb   => B,
		b6 => b6,
		b7 => b7,
		b8 => b8,
		b9 => b9,
		outb  => log_out,
		zero  => z_log,
		sinal => s_log
		);


	sig_mux : mux_4_2 port map( 
		z_ar_sh => z_ar_sh,
		s_ar_sh => s_ar_sh,
		z_log   => z_log,
		s_log   => s_log,
		z       => z_aux,
		s       => s_aux,
		SEL     => b10
	);


	mux_out : Mux16 Port map(
		I0 => arsh_out,
		I1 => log_out,
		O  => Z,
		S  => b10
	);
			
	f_reg : flag_reg Port map(
		CLK => CLK,
		z => z_aux ,
		s => s_aux,
		c => c_aux,
		o => o_aux,
			  
		b6 => b6,
		b7 => b7,
		b8 => b8,
		b9 => b9,
		b10 => b10,
		b14 => b14,
		b15 => b15,

      zero => wireZero,
      sinal => wireSinal,
      cout => wireCarry,
		overflow => wireOverflow,
		
		FLAG_EN => FLAG_EN
	);

-- Actualiza as flags que foram alteradas  
	REFRESH_ZERO: mux2 port map(
		A0  => wireZero,
		A1  => z_aux,
		Z   => zero,
		SEL => FLAG_EN(0)
	);
	
	REFRESH_SINAL: mux2 port map(
		A0  => wireSinal,
		A1  => s_aux,
		Z   => sinal,
		SEL => FLAG_EN(1)
	);
	
	REFRESH_CARRY: mux2 port map(
		A0  => wireCarry,
		A1  => c_aux,
		Z   => cout,
		SEL => FLAG_EN(2)
	);	  
	  
	REFRESH_OVER: mux2 port map(
		A0  => wireOverflow,
		A1  => o_aux,
		Z   => overflow,
		SEL => FLAG_EN(3)
	);			  	  
		
end Behavioral;

