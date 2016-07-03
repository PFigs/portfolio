library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.gates.all;


entity B_block is
    Port ( Gij : in  STD_LOGIC;
           Pij : in  STD_LOGIC;
           Gj_i_k : in  STD_LOGIC;
           Pj_i_k : in  STD_LOGIC;
           Gik : out  STD_LOGIC;
           Pik : out  STD_LOGIC;
           Cin : in  STD_LOGIC;
           Cj1 : out  STD_LOGIC);
end B_block;

architecture Behavioral of B_block is
		signal T1,T2 : STD_LOGIC;
begin
  --Propagate seguinte
  
  and1 : a2
	port map (
		A => Pij,
		B => Pj_i_k,	
		Z => Pik 
		);
		
	--Generate Seguinte	
	and_2 : a2
	port map (
		A => Gij,
		B => Pj_i_k,	
		Z => T1
		);
	

	or1 : o2
	port map (
		A => T1,
		B => Gj_i_k,	
		Z => Gik
		);
		
	-- carrys acima
	and_3 : a2
	port map (
		A => Cin,
		B => Pij,	
		Z => T2
		);

	or_2 : o2
	port map (
		A => T2,
		B => Gij,	
		Z => Cj1
		);

	
end Behavioral;

