library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.gates.all;
use work.cla_lib.all;

entity Carry_Look_ahead is
    Port ( IN_A : in  STD_LOGIC_VECTOR (15 downto 0);
           IN_B : in  STD_LOGIC_VECTOR (15 downto 0);
           IN_C : in  STD_LOGIC;
           OUT_Q : out  STD_LOGIC_VECTOR (15 downto 0);
           OUT_C : out  STD_LOGIC;
			  OUT_C15:out  STD_LOGIC 
			  );
end Carry_Look_ahead;

architecture Behavioral of Carry_Look_ahead is

	signal T1,NT1:	STD_LOGIC;
	signal gi,pi: std_logic_vector(15 downto 0);
	signal c: std_logic_vector(15 downto 0);
	signal GI_1,PI_1: std_logic_vector(7 downto 0);
	signal GI_2,PI_2: std_logic_vector(3 downto 0);
	signal GI_3,PI_3: std_logic_vector(1 downto 0);
	signal GI_F,PI_F: STD_LOGIC;

begin

	-- 16 blocos A 

	A_0 : A_block
		port map(
			a => IN_A(0),
			b=> IN_B(0),
			c => c(0),
			g =>gi(0),
			p =>pi(0),		
			s =>OUT_Q(0)
		);

	A_1 : A_block
		port map(
			a => IN_A(1),
			b=> IN_B(1),
			c => c(1),
			g =>gi(1),
			p =>pi(1),		
			s =>OUT_Q(1)
		);
		
	A_2 : A_block
		port map(
			a => IN_A(2),
			b=> IN_B(2),
			c => c(2),
			g =>gi(2),
			p =>pi(2),		
			s =>OUT_Q(2)
		);
		
	A_3 : A_block
		port map(
			a => IN_A(3),
			b=> IN_B(3),
			c => c(3),
			g =>gi(3),
			p =>pi(3),		
			s =>OUT_Q(3)
		);
		
	A_4 : A_block
		port map(
			a => IN_A(4),
			b=> IN_B(4),
			c => c(4),
			g =>gi(4),
			p =>pi(4),		
			s =>OUT_Q(4)
		);
		
	A_5 : A_block
		port map(
			a => IN_A(5),
			b=> IN_B(5),
			c => c(5),
			g =>gi(5),
			p =>pi(5),		
			s =>OUT_Q(5)
		);
		
	A_6 : A_block
		port map(
			a => IN_A(6),
			b=> IN_B(6),
			c => c(6),
			g =>gi(6),
			p =>pi(6),		
			s =>OUT_Q(6)
		);
		
	A_7 : A_block
		port map(
			a => IN_A(7),
			b=> IN_B(7),
			c => c(7),
			g =>gi(7),
			p =>pi(7),		
			s =>OUT_Q(7)
		);
		
	A_8 : A_block
		port map(
			a => IN_A(8),
			b=> IN_B(8),
			c => c(8),
			g =>gi(8),
			p =>pi(8),		
			s =>OUT_Q(8)
		);
		
	A_9 : A_block
		port map(
			a => IN_A(9),
			b=> IN_B(9),
			c => c(9),
			g =>gi(9),
			p =>pi(9),		
			s =>OUT_Q(9)
		);

	A_10 : A_block
		port map(
		a => IN_A(10),
		b=> IN_B(10),
		c => c(10),
		g =>gi(10),
		p =>pi(10),		
		s =>OUT_Q(10)
	);
	
	A_11 : A_block
		port map(
		a => IN_A(11),
		b=> IN_B(11),
		c => c(11),
		g =>gi(11),
		p =>pi(11),		
		s =>OUT_Q(11)
	);
	
	A_12 : A_block
		port map(
		a => IN_A(12),
		b=> IN_B(12),
		c => c(12),
		g =>gi(12),
		p =>pi(12),		
		s =>OUT_Q(12)
	);
	
	A_13 : A_block
		port map(
		a => IN_A(13),
		b=> IN_B(13),
		c => c(13),
		g =>gi(13),
		p =>pi(13),		
		s =>OUT_Q(13)
	);
	
	A_14 : A_block
		port map(
		a => IN_A(14),
		b=> IN_B(14),
		c => c(14),
		g =>gi(14),
		p =>pi(14),		
		s =>OUT_Q(14)
	);
	
	A_15 : A_block
		port map(
		a => IN_A(15),
		b=> IN_B(15),
		c => c(15),
		g =>gi(15),
		p =>pi(15),		
		s =>OUT_Q(15)
	);
	
	OUT_C15<=c(15);
	
-- 1º andar blocos B	
	B1_0 : B_block
	port map(
		Gij=> gi(0),
		Pij=> pi(0),
		Gj_i_k => gi(1),
		Pj_i_k =>pi(1),
		Gik =>GI_1(0),		
		Pik =>PI_1(0),
		Cin =>c(0),		
		Cj1 =>c(1)


	);
	
	B3_2 : B_block
	port map(
		Gij=> gi(2),
		Pij=> pi(2),
		Gj_i_k => gi(3),
		Pj_i_k =>pi(3),
		Gik =>GI_1(1),		
		Pik =>PI_1(1),
		Cin =>c(2),		
		Cj1 =>c(3)


	);
	
	B5_4 : B_block
	port map(
		Gij=> gi(4),
		Pij=> pi(4),
		Gj_i_k => gi(5),
		Pj_i_k =>pi(5),
		Gik =>GI_1(2),		
		Pik =>PI_1(2),
		Cin =>c(4),		
		Cj1 =>c(5)


	);
	
	B7_6 : B_block
	port map(
		Gij=> gi(6),
		Pij=> pi(6),
		Gj_i_k => gi(7),
		Pj_i_k =>pi(7),
		Gik =>GI_1(3),		
		Pik =>PI_1(3),
		Cin =>c(6),		
		Cj1 =>c(7)


	);
	
	B9_8 : B_block
	port map(
		Gij=> gi(8),
		Pij=> pi(8),
		Gj_i_k => gi(9),
		Pj_i_k =>pi(9),
		Gik =>GI_1(4),		
		Pik =>PI_1(4),
		Cin =>c(8),		
		Cj1 =>c(9)


	);
	
	B11_10 : B_block
	port map(
		Gij=> gi(10),
		Pij=> pi(10),
		Gj_i_k => gi(11),
		Pj_i_k =>pi(11),
		Gik =>GI_1(5),		
		Pik =>PI_1(5),
		Cin =>c(10),		
		Cj1 =>c(11)


	);
	
	B13_12 : B_block
	port map(
		Gij=> gi(12),
		Pij=> pi(12),
		Gj_i_k => gi(13),
		Pj_i_k =>pi(13),
		Gik =>GI_1(6),		
		Pik =>PI_1(6),
		Cin =>c(12),		
		Cj1 =>c(13)


	);
	
	B15_14 : B_block
	port map(
		Gij=> gi(14),
		Pij=> pi(14),
		Gj_i_k => gi(15),
		Pj_i_k =>pi(15),
		Gik =>GI_1(7),		
		Pik =>PI_1(7),
		Cin =>c(14),		
		Cj1 =>c(15)


	);
	--2º nivel blocos B
	
	B3_0 : B_block
	port map(
		Gij=> GI_1(0),
		Pij=> PI_1(0),
		Gj_i_k => GI_1(1),
		Pj_i_k => PI_1(1),
		Gik =>GI_2(0),		
		Pik =>PI_2(0),
		Cin =>c(0),		
		Cj1 =>c(2)
	);
	
	
	B7_4 : B_block
	port map(
		Gij=> GI_1(2),
		Pij=> PI_1(2),
		Gj_i_k => GI_1(3),
		Pj_i_k =>PI_1(3),
		Gik =>GI_2(1),		
		Pik =>PI_2(1),
		Cin =>c(4),		
		Cj1 =>c(6)
	);
	
	B11_8 : B_block
	port map(
		Gij=> GI_1(4),
		Pij=> PI_1(4),
		Gj_i_k => GI_1(5),
		Pj_i_k =>PI_1(5),
		Gik =>GI_2(2),		
		Pik =>PI_2(2),
		Cin =>c(8),		
		Cj1 =>c(10)
	);
	
	B15_12 : B_block
	port map(
		Gij=> GI_1(6),
		Pij=> PI_1(6),
		Gj_i_k => GI_1(7),
		Pj_i_k =>PI_1(7),
		Gik =>GI_2(3),		
		Pik =>PI_2(3),
		Cin =>c(12),		
		Cj1 =>c(14)
	);
	
	
	--3ª andar de blocos B
	
	
	B7_0 : B_block
	port map(
		Gij=> GI_2(0),
		Pij=> PI_2(0),
		Gj_i_k => GI_2(1),
		Pj_i_k => PI_2(1),
		Gik =>GI_3(0),		
		Pik =>PI_3(0),
		Cin =>c(0),		
		Cj1 =>c(4)
	);
	
	B15_8 : B_block
	port map(
		Gij=> GI_2(2),
		Pij=> PI_2(2),
		Gj_i_k => GI_2(3),
		Pj_i_k => PI_2(3),
		Gik =>GI_3(1),		
		Pik =>PI_3(1),
		Cin =>c(8),		
		Cj1 =>c(12)
	);
	
	--4º ANDAR DE BLOCOS B
	B_F : B_block
	port map(
		Gij=> GI_3(0),
		Pij=> PI_3(0),
		Gj_i_k => GI_3(1),
		Pj_i_k => PI_3(1),
		Gik =>GI_F,		
		Pik =>PI_F,
		Cin =>c(0),		
		Cj1 =>c(8)
	);
	
	--CALCULO DO ULTIMO CARRY
	
	and_1 : a2
	port map (
		A => c(0),
		B => PI_F,		
		Z => T1
		);
		
		

	or_1 : o2
	port map (
		A => T1,
		B => GI_F,	
		Z => OUT_C
		);
	
	c(0)<=IN_C;
	
end Behavioral;

