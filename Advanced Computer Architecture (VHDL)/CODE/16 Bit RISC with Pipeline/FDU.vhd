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

entity FDU is
    Port ( FWD_WB  : in  STD_LOGIC_VECTOR (15 downto 0);
			  ID_OPA  : in  STD_LOGIC_VECTOR (15 downto 0);
			  ID_OPB  : in  STD_LOGIC_VECTOR (15 downto 0);			  
           WB_INST : in  STD_LOGIC_VECTOR (15 downto 0);
           ID_INST : in  STD_LOGIC_VECTOR (15 downto 0);
           OPA : out  STD_LOGIC_VECTOR (15 downto 0);
           OPB : out  STD_LOGIC_VECTOR (15 downto 0));
end FDU;

architecture Behavioral of FDU is

signal COMPA, COMPB, COMPC : STD_LOGIC;
signal FWDA, FWDB : STD_LOGIC;
signal JUMP : STD_LOGIC;
signal IDMEM_WB, IDMEM_ID, STORE_WB, STORE_ID, IDCONTROL : STD_LOGIC;
signal wireSTORE_WB0, wireSTORE_WB1 : STD_LOGIC;
signal wireSTORE0, wireSTORE1 : STD_LOGIC;
signal mustFWDCTE, wireFWDB: STD_LOGIC;
signal mustFWDSTORE, mustFWDJMP: STD_LOGIC;
signal nota,notb, TYPE_III: STD_LOGIC;
begin


--- Verifica se RA de EX é igual ao WC de WB
	COMP_RA_WC : Comparator3b port map(
		I0 =>ID_INST(5 downto 3),
		I1 =>WB_INST(13 downto 11),
		Z => COMPA
	);

--- Verifica se RB de EX é igual ao WC de WB

	COMP_RB_WC : Comparator3b port map(
		I0 => ID_INST(2 downto 0),
		I1 => WB_INST(13 downto 11),
		Z  => COMPB
	);


--- Verifica se WC de EX é igual ao WC de WB

	COMP_WC_WC : Comparator3b port map(
		I0 => ID_INST(13 downto 11),
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
	GETOPA : a3 port map(
		A => JUMP,
		B => COMPA,
		D => STORE_WB,
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
	
	
	-- LOAD
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
	
	
	MEMNEGA1: not1 port map(
		A => ID_INST(14),
		Z => notb
	);
	
   MEVERIFICA1: a2 port map(
		A =>ID_INST(15),
		B =>notb,
		Z =>IDMEM_ID
	);
	
-- Com instrucao de memoria em WB tem que se fazer fwd
	
	CTE_BOOTH_SIDES : a2 port map(
		A => COMPC,
		B => WB_INST(14),
		Z => mustFWDCTE
	);
	
	-- Logica para decidir se JL ou nao

	IDCONTROL_NOR : no2 port map(
		A => ID_INST(15),
		B => ID_INST(14),
		Z => IDCONTROL
	);
	
	AND_TYPE_III: a3 port map(
		A => IDCONTROL,
		B => ID_INST(13),
		D => ID_INST(12),
		Z => TYPE_III
	);
	
	isJLJR : a2 port map(
		A => TYPE_III,
		B => COMPB,
		Z => mustFWDJMP
	);
	
	
	
	
-- TODO:
-- ATENCAO! HA CASOS ONDE NAO SE PODE FAZER FWD!!!!!!
-- QUAIS:
-- @EX  |  @WB
-- ALU  |  ALU  OK!
-- ALU  |  MEM  OK!
-- ALU  |  JMP  NOT!
-- ALU  |  CST  OK!
-- JMP  |  ALU  OK! (ATENCAO JL, tem que puxar valor actualizado)
-- JMP  |  JMP  NOT
-- JMP  |  CST  OK! (ATENCAO JL, tem que puxar valor actualizado)
-- JMP  |  MEM  OK! (ATENCAO JL, tem que puxar valor actualizado)
-- STR  ...
-- LDD  | !JMP  OK!
-- QQ   | LDD   NOT! FALSO!!!!!!!
-- CTE  | CTE   OK!
-- MEM  | CTE   OK!


--- Mux para decidir 
	MUX_FWDA : Mux16 port map(
		I0 => ID_OPA,
		I1 => FWD_WB,
		O  => OPA,
		S  => FWDA
	);

	MUX_FWDB : Mux16 port map(
		I0 => ID_OPB,
		I1 => FWD_WB,
		O  => OPB,
		S  => FWDB
	);


end Behavioral;

