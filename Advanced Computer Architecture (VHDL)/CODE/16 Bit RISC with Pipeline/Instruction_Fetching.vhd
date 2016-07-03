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

entity Instruction_Fetching is
    Port ( INST : out STD_LOGIC_VECTOR (15 downto 0);
			  PC1  : out STD_LOGIC_VECTOR (15 downto 0);
           JUMP : in  STD_LOGIC_VECTOR (15 downto 0);
			  DATA : in  STD_LOGIC_VECTOR(15 downto 0);
			  CLK  : in  STD_LOGIC;
			  EN_PC: in  STD_LOGIC;
			  RST  : in  STD_LOGIC;
			  RDF  : in  STD_LOGIC;
			  WRF  : in  STD_LOGIC;
           SEL  : in  STD_LOGIC);
end Instruction_Fetching;

architecture Behavioral of Instruction_Fetching is

signal PC : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal ADDR_MKD : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal STOREPC : STD_LOGIC_VECTOR(15 downto 0);
signal NEXTPC : STD_LOGIC_VECTOR(15 downto 0);
signal CRYOUT : STD_LOGIC;
signal OVFLOW : STD_LOGIC;

begin

	PCREG : Reg16 port map(
		CLK => CLK,
      E   => EN_PC,
      R   => RST,
      D   => STOREPC,
      Q   => PC
	);
	
	ADDR_MKD(9 downto 0) <= PC (9 downto 0);
	
	INSTMEM : ram 
	generic map (dim => 1024)
	port map(
		read_file  => RDF,
		write_file => WRF,
		WE 	 => '0',
		clk 	 => CLK,
		ADRESS => ADDR_MKD,
		DATA   => X"0000",
		Q 		 => INST
	);

	
	ADDER: full_add_16 port map(
		x 			=> PC,
		y 			=> (X"0000"),
      cin 		=> ('1'),
      cout 		=> CRYOUT,
      overflow => OVFLOW,
      sum 	 	=> NEXTPC
	);

	MUX_PC_JUMP : Mux16 port map(
		I0 => NEXTPC,
		I1 => JUMP,
		O  => STOREPC,
		S  => SEL
	);

	PC1 <= STOREPC;

end Behavioral;

