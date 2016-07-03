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

entity Instruction_Decoding is
    Port ( PC1     : in  STD_LOGIC_VECTOR (15 downto 0);
			  OPCODE  : in  STD_LOGIC_VECTOR (15 downto 0);
			  WB_INST : in  STD_LOGIC_VECTOR (15 downto 0);
           EXTEND  : out STD_LOGIC_VECTOR (15 downto 0);
			  OPA     : out STD_LOGIC_VECTOR (15 downto 0);
			  OPB     : out STD_LOGIC_VECTOR (15 downto 0);
			  PC      : out STD_LOGIC_VECTOR (15 downto 0);
			  INST    : out STD_LOGIC_VECTOR (15 downto 0);
			  DATA    : in  STD_LOGIC_VECTOR (15 downto 0);
			  WC      : in  STD_LOGIC_VECTOR (2 downto 0);
			  CLK     : in  STD_LOGIC;
			  RST     : in  STD_LOGIC;
			  WE		 : in 	STD_LOGIC);
end Instruction_Decoding;

architecture Behavioral of Instruction_Decoding is

signal wireOPA : STD_LOGIC_VECTOR (15 downto 0);
signal wireOPB : STD_LOGIC_VECTOR (15 downto 0);
signal COMPA, COMPB, COMPC : STD_LOGIC;
signal FWDA, FWDB : STD_LOGIC;
signal JUMP : STD_LOGIC;
signal IDMEM_WB, STORE_WB, STORE_ID, IDCONTROL : STD_LOGIC;
signal wireSTORE_WB0, wireSTORE_WB1 : STD_LOGIC;
signal wireSTORE0, wireSTORE1 : STD_LOGIC;
signal mustFWDCTE, wireFWDB, wireFWDA: STD_LOGIC;
signal mustFWDSTORE, mustFWDJMP: STD_LOGIC;
signal nota,notb, TYPE_III: STD_LOGIC;

begin

	CHECKRA : Comparator3b port map(
		I0 => WC,
		I1 => OPCODE(5 downto 3),
		Z  => COMPA
	);

	CHECKRB : Comparator3b port map(
		I0 => WC,
		I1 => OPCODE(2 downto 0),
		Z  => COMPB
	);

	
	MUXRA : Mux16 port map(
		I0 => wireOPA,
		I1 => DATA,
		O  => OPA,
		S  => FWDA
	);


	MUXRB : Mux16 port map(
		I0 => wireOPB,
		I1 => DATA,
		O  => OPB,
		S  => FWDB
	);
	
--- Verifica se WC de EX é igual ao WC de WB

	COMP_WC_WC : Comparator3b port map(
		I0 => OPCODE(13 downto 11),
		I1 => WB_INST(13 downto 11),
		Z  => COMPC
	);

-- verifica se no andar de WB esta um salto
	notJUMP : o2 port map(
		A => WB_INST(15),
		B => WB_INST(14),
		Z => JUMP
	);

-- Se os WC == RX faz fwd
	GETOPA0 : a3 port map(
		A => JUMP,
		B => COMPA,
		D => STORE_WB,
		Z => wireFWDA
	);	
	
	GETOPA1 : o3 port map(
		A => wireFWDA,
		B => mustFWDCTE,
		D => mustFWDJMP,
		Z => FWDA
	);	
	
	GETOPB0 : a3 port map(
		A => JUMP,
		B => COMPB,
		D => STORE_WB,
		Z => wireFWDB
	);
	
	-- Caso CTE 
	GETOPB1 : o3 port map(
		A => wireFWDB,
		B => mustFWDCTE,
		D => mustFWDJMP,
		Z => FWDB
	);
	
	
	-- STORE
	STOREAUX0: no2 port map(
		A => WB_INST(10),
		B => WB_INST(8),
		Z => wireSTORE_WB0
	);

	STOREAUX1: a3 port map(
		A => WB_INST(9),
		B => WB_INST(7),
		D => WB_INST(6),
		Z => wireSTORE_WB1
	);

	notSTORE: na3 port map(
		A => wireSTORE_WB0,
		B => wireSTORE_WB1,
		D => IDMEM_WB,
		Z => STORE_WB
	);
	
	MEMNEGA: not1 port map(
		A => WB_INST(14),
		Z => nota
	);
	
   MEVERIFICA: a2 port map(
		A =>WB_INST(15),
		B =>nota,
		Z =>IDMEM_WB
	);
	
-- Com instrucao de memoria em WB tem que se fazer fwd
	
	CTE_BOOTH_SIDES : a2 port map(
		A => COMPC,
		B => WB_INST(14),
		Z => mustFWDCTE
	);
	
	-- Logica para decidir se JL ou nao

	IDCONTROL_NOR : no2 port map(
		A => OPCODE(15),
		B => OPCODE(14),
		Z => IDCONTROL
	);
	
	AND_TYPE_III: a3 port map(
		A => IDCONTROL,
		B => OPCODE(13),
		D => OPCODE(12),
		Z => TYPE_III
	);
	
	isJLJR : a2 port map(
		A => TYPE_III,
		B => COMPB,
		Z => mustFWDJMP
	);
	

	REGFILE : Registers port map(
		WPort   => DATA,
		SELWC   => OPCODE(13 downto 11),
      SELA    => OPCODE( 5 downto  3),
		SELB    => OPCODE( 2 downto  0),
		SelWB   => WC,
      RegA    => wireOPA,
		RegB    => wireOPB,
		SELREG  => OPCODE(14),
		Clock   => CLK,
      Reset   => RST,
		WEnable => WE
	);

-- Buggy: Need to decode incoming signal. 00 01 and 11 not enough
	SIGNALEXTEND : MuxSignalExtender4x1 port map(
		E0  => OPCODE(11 downto  0),
      E1  => OPCODE(10 downto  0),
      E2  => OPCODE( 7 downto  0),
      SEL => OPCODE(15 downto 13),
      Z   => EXTEND
	);
	
	PC   <= PC1;
	INST <= OPCODE;

end Behavioral;

