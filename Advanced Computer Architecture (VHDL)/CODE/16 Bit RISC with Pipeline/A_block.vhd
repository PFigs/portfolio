library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.gates.all;

entity A_block is
    Port ( a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           c : in  STD_LOGIC;
           g : out  STD_LOGIC;
           p : out  STD_LOGIC;
           s : out  STD_LOGIC);
end A_block;

architecture Behavioral of A_block is
		signal T1: STD_LOGIC;
begin

	and1 : a2
	port map (
		A => a,
		B => b,	
		Z => g
		);
		
	or1 : o2
	port map (
		A => a,
		B => b,	
		Z => p
		);
		
	xor1 : xo2
	port map (
		A => a,
		B => b,	
		Z => T1
		);

	xor_2 : xo2
	port map (
		A => T1,
		B => c,	
		Z => s
		);

end Behavioral;

