----------------------------------------------------------------------------------
-- Projecto Arquitecturas Avançadas de Computadores
-- 			2º Semestre 2009/2010
-- 
-- Realizado por:
-- Pedro Silva (58035)
-- Oleksandr Yefimochkin (58958)
--
-- Responsável:
-- Leonel Sousa
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.gates.all;
use work.new_vhd_lib.all;

entity WriteBack is
    Port ( MEM     : in   STD_LOGIC_VECTOR (15 downto 0);
           ALU     : in   STD_LOGIC_VECTOR (15 downto 0);
           OPCODE  : in   STD_LOGIC_VECTOR (15 downto 0);
			  WC 		 : in   STD_LOGIC_VECTOR (2 downto 0);
           WPort   : out  STD_LOGIC_VECTOR (15 downto 0);
           DSTREG  : out  STD_LOGIC_VECTOR (2 downto 0);
           WEnable : out  STD_LOGIC);
end WriteBack;

architecture Behavioral of WriteBack is
signal nota: STD_LOGIC;

signal tosel: STD_LOGIC;

signal IDMEM: STD_LOGIC;
signal LOAD: STD_LOGIC;
signal IDCONTROL: STD_LOGIC;
signal JUMPREGISTER: STD_LOGIC;
signal STORE: STD_LOGIC;
signal JUNTRUE: STD_LOGIC;
signal JFALSE: STD_LOGIC;
signal JUMPS: STD_LOGIC;

signal wire0: STD_LOGIC;
signal wire1: STD_LOGIC;
signal wire2: STD_LOGIC;
signal wire3: STD_LOGIC;
signal wire4: STD_LOGIC;
signal wire5: STD_LOGIC;
signal wire6: STD_LOGIC;
signal buff7: STD_LOGIC;
signal buff8: STD_LOGIC;
signal wire8: STD_LOGIC;

begin

	MUX: Mux16 port map(
		I0 =>MEM,
		I1 =>ALU,
		O 	=>WPort,
		S 	=>tosel
	);
	
	-- Checks MEM ID
	MEMNEGA14: not1 port map(
		A => OPCODE(14),
		Z => nota
	);
	
   MEVERIFICA: a2 port map(
		A =>OPCODE(15),
		B =>nota,
		Z =>IDMEM
	);
	
	-- Checks MEM
	-- STORE
	MEMUL1s: a3 port map(
		A => OPCODE(9),
		B => OPCODE(7),
		D => OPCODE(6),
		Z => wire0
	);

	MEMNOR0s: no2 port map(
		A => OPCODE(10),
		B => OPCODE(8),
		Z => wire1
	);

	MEMAN4: a2 port map(
		A => wire0,
		B => wire1,
		Z => wire2
	);
-- COND END

	isSTORE: a2 port map(
		A => IDMEM,
		B => wire2,
		Z => STORE
	);
		
	-- Control
	-- JUMP REGISTER
	CONTROLID: no2 port map(
		A => OPCODE(15),
		B => OPCODE(14),
		Z => IDCONTROL
	);
	
	AN7: a3 port map(
		A => OPCODE(13),
		B => OPCODE(12),
		D => OPCODE(11),
		Z => wire6
	);
	
	isJUMP_REGISTER: a2 port map(
		A => wire6,
		B => IDCONTROL,
		Z => JUMPREGISTER
	);
	
	--JUMP FALSE
	isJUMP_FALSE : no2 port map(
		A => OPCODE(13),
		B => OPCODE(12),
		Z => JFALSE
	);
	
	--JUMP & INC
	isJUMP_TRUE: xo2 port map(
		A => OPCODE(13),
		B => OPCODE(12),
		Z => JUNTRUE
	);
	
	
	-- Generate WE
	JUMP_TRUE: a2 port map(
		A => IDCONTROL,
		B => JUNTRUE,
		Z => buff7
	);
	
	
	JUMP_FALSE: a2 port map(
		A => JFALSE,
		B => IDCONTROL,
		Z => buff8
	);
	
	
	WE_ID: o2 port map(
		A => buff7,
		B => buff8,
		Z => JUMPS
	);
	
	WE_OR: o2 port map(
		A => JUMPS,
		B => JUMPREGISTER,
		Z => wire8
	);
	
	WE_OR2: no2 port map(
		A => wire8,
		B => STORE,
		Z => WEnable
	);

--- SEL

	-- LOAD
	NAN10: na3 port map(
		A => OPCODE(10),
		B => OPCODE(8),
		D => OPCODE(6),
		Z => wire3
	);

	AN11: a2 port map(
		A => OPCODE(9),
		B => OPCODE(7),
		Z => wire4
	);

	AN12: a2 port map(
		A => wire3,
		B => wire4,
		Z => wire5
	);
	
	AN13: a2 port map(
		A => IDMEM,
		B => wire5,
		Z => LOAD
	);	
	
	-- Gen SEL
	NOR14: no2 port map(
		A =>STORE,
		B =>LOAD,
		Z =>tosel
	);

	-- REG DST
	DSTREG <= WC;

end Behavioral;

