--
--  File: gates.vhd
--  created by Leoenel Sousa: 22/10/02 12:52:55
--
library IEEE;
use IEEE.std_logic_1164.all;

package gates is

component xo2 is
port (
		A: in STD_LOGIC;
		B: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;

component xno2 is
port (
		A: in STD_LOGIC;
		B: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;
	
component na2 is
port (
		A: in STD_LOGIC;
		B: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;

component na3 is
port (
		A: in STD_LOGIC;
		B: in STD_LOGIC;
		D: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;

component a2 is
port (
		A: in STD_LOGIC;
		B: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;

component a3 is
port (
		A: in STD_LOGIC;
		B: in STD_LOGIC;
		D: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;

component no2 is
port (
		A: in STD_LOGIC;
		B: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;

component no3 is
port (
		A: in STD_LOGIC;
		B: in STD_LOGIC;
		D: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;

component o2 is
port (
		A: in STD_LOGIC;
		B: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;

component o3 is
port (
		A: in STD_LOGIC;
		B: in STD_LOGIC;
		D: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;

component not1 is
port (
		A: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;


component mux2 is
port (
		SEL: in STD_LOGIC;
		A0: in STD_LOGIC;
		A1: in STD_LOGIC;
		Z: out STD_LOGIC
	 );
end component;

component ffe is
port (
		CLK: in STD_LOGIC;
		Reset: in STD_LOGIC;
		Enable: in STD_LOGIC;
		D: in STD_LOGIC;
		Q: out STD_LOGIC
	 );
end component;


end package gates;
