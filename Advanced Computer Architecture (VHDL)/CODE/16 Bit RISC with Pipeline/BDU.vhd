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

entity BDU is
    Port ( NEXTPC 	 : in   STD_LOGIC_VECTOR (15 downto 0);
           OFFSET 	 : in   STD_LOGIC_VECTOR (15 downto 0);
           OPB_ID		 : in   STD_LOGIC_VECTOR (15 downto 0);
			  OPB_EX_MEM : in   STD_LOGIC_VECTOR (15 downto 0);
			  OPB_EX_ALU : in   STD_LOGIC_VECTOR (15 downto 0);
			  OPCODE_ID  : in   STD_LOGIC_VECTOR (15 downto 0);
			  OPCODE_EX  : in   STD_LOGIC_VECTOR (15 downto 0);
			  FLAGS		 : in   STD_LOGIC_VECTOR ( 3 downto 0);
			  -- Flags_FWD
           TOIFMUX 	 : out  STD_LOGIC_VECTOR (15 downto 0);
           TOIFSEL 	 : out  STD_LOGIC);
end BDU;

architecture Behavioral of BDU is

signal adder_output : STD_LOGIC_VECTOR (15 downto 0);
signal wire_OPB_WB  : STD_LOGIC_VECTOR (15 downto 0);
signal wire_MUX_OPB : STD_LOGIC_VECTOR (15 downto 0);
signal TYPE_III 	  : STD_LOGIC;
signal IDCONTROL    : STD_LOGIC;
signal IFINSTMEM    : STD_LOGIC;
signal FLAG_B       : STD_LOGIC;
signal IDALUEX      : STD_LOGIC;
signal nota      	  : STD_LOGIC;
signal IDMEM    	  : STD_LOGIC;
signal wireSTORE0	  : STD_LOGIC;
signal wireSTORE1	  : STD_LOGIC;
signal wireSTORE2	  : STD_LOGIC;
signal STORE   	  : STD_LOGIC;
signal wireLOAD3 	  : STD_LOGIC;
signal wireLOAD4 	  : STD_LOGIC;
signal wireLOAD5	  : STD_LOGIC;
signal LOAD 		  : STD_LOGIC;
signal COMPB		  : STD_LOGIC;
signal notOP14		  : STD_LOGIC;

begin


	
-- MUX para decidir se deve passar OPB ou end de salto: FEITO
	MUX_IF_OP : Mux16 port map(
		I0 => adder_output,
		I1 => wire_MUX_OPB,
		O  => TOIFMUX,
		S  => TYPE_III
	);

--- somador
	Adder : cla_full_add_16 port map ( 
		cin      =>'0',
		x        =>OFFSET,
		y 	      =>NEXTPC,
		sum      =>adder_output,
		cout     => open,
		overflow => open
	);

-- Testa as flags. Tem que se ter em conta se houve alteracao na instrucao actual
	FT: Flag_Test port map(
		ZERO 	   => FLAGS(0),
		NEG      => FLAGS(1),
		CARRY    => FLAGS(2),
		OVERFLOW => FLAGS(3),
		COND     => OPCODE_ID(11 downto 8),
		OP       => OPCODE_ID(13 downto 12),
		ENABLE   => IDCONTROL,
		SEL	   => OPCODE_ID(13),
		UNJUMP	=> OPCODE_ID(13),
		Z        => TOIFSEL
	);	


-- Logica para decidir se JL ou nao

	IDCONTROL_NOR : no2 port map(
		A => OPCODE_ID(15),
		B => OPCODE_ID(14),
		Z => IDCONTROL
	);
	
	AND_TYPE_III: a3 port map(
		A => IDCONTROL,
		B => OPCODE_ID(13),
		D => OPCODE_ID(12),
		Z => TYPE_III
	);


-- Verifica se se trata de uma instrucao de MEM ou ALU
	MEMNEGA14: not1 port map(
		A => OPCODE_ID(14),
		Z => nota
	);
	
   MEVERIFICA: a2 port map(
		A =>OPCODE_ID(15),
		B =>nota,
		Z =>IDMEM
	);
	
	-- Checks MEM
	-- STORE
	MEMUL1s: a3 port map(
		A => OPCODE_ID(9),
		B => OPCODE_ID(7),
		D => OPCODE_ID(6),
		Z => wireSTORE0
	);

	MEMNOR0s: no2 port map(
		A => OPCODE_ID(10),
		B => OPCODE_ID(8),
		Z => wireSTORE1
	);

	MEMAN4: a2 port map(
		A => wireSTORE0,
		B => wireSTORE1,
		Z => wireSTORE2
	);
-- COND END

	isSTORE: a2 port map(
		A => IDMEM,
		B => wireSTORE2,
		Z => STORE
	);

	-- LOAD
	NAN10: na3 port map(
		A => OPCODE_ID(10),
		B => OPCODE_ID(8),
		D => OPCODE_ID(6),
		Z => wireLOAD3
	);

	AN11: a2 port map(
		A => OPCODE_ID(9),
		B => OPCODE_ID(7),
		Z => wireLOAD4
	);

	AN12: a2 port map(
		A => wireLOAD3,
		B => wireLOAD4,
		Z => wireLOAD5
	);
	
	isLOAD: a2 port map(
		A => IDMEM,
		B => wireLOAD5,
		Z => LOAD
	);	
	
	-- Gen SEL
	NOR14: no2 port map(
		A => STORE,
		B => LOAD,
		Z => IFINSTMEM
	);
--- Este Sinal entra num mux que selecciona MEM ou ALU

	MUX_ALU_MEM : Mux16 port map(
		I0 => OPB_EX_ALU,
		I1 => OPB_EX_MEM,
		O  => wire_OPB_WB,
		S  => IFINSTMEM
	);
			  
-- Saida entra num MUX com valor actual de RB, que sera seleccionado, se B)
	
	--Se controlo tipo III && WC==RB
	COMP_RB_WC : Comparator3b port map(
		I0 => OPCODE_ID(2 downto 0),
		I1 => OPCODE_EX(13 downto 11),
		Z  => COMPB
	);
	
	ALUID_NEG : not1 port map(
		A => OPCODE_EX(14),
		Z => notOP14
	);
	
	ALUID_AND : a2 port map(
		A => OPCODE_EX(15),
		B => notOP14,
		Z => IDALUEX
	);
	
	AND_RB_WC_ALU : a3 port map(
		A => COMPB,
		B => TYPE_III,
		D => IDALUEX, 
		Z => FLAG_B
	);
	
	MUX_FWD_OPB : Mux16 port map
	(
		I0 => OPB_ID,
		I1 => wire_OPB_WB,
		O  => wire_MUX_OPB,
		S  => FLAG_B
	);
-- 

-- Caso se trate de um salto condicional, tem que se averiguar o salto com as flags actuais



-- DONE

--A) Se JCd = if not (JL||JR), Verificar se instrucao de EX é de ALU e testar com flags actuais

--B) Se JL || JR e no andar de EX WC == RB, entao decido por SAIDA ALU ou MEM, caso contrario Rb do ID.



end Behavioral;

