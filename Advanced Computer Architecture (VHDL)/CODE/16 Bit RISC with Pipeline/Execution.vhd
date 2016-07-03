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

entity Execution is
    Port ( OPCODE : in  STD_LOGIC_VECTOR (15 downto 0);
           OPA    : in  STD_LOGIC_VECTOR (15 downto 0);
           OPB    : in  STD_LOGIC_VECTOR (15 downto 0);
           ADDR   : in  STD_LOGIC_VECTOR (15 downto 0);
           PC     : in  STD_LOGIC_VECTOR (15 downto 0);
			  CLK		: in STD_LOGIC;
			  RST		: in STD_LOGIC;
			  WRF    : in STD_LOGIC;
			  RDF    : in STD_LOGIC;
			  TOIFSEL: out STD_LOGIC;
			  TOIFMUX: out STD_LOGIC_VECTOR (15 downto 0);
			  MEM    : out STD_LOGIC_VECTOR (15 downto 0);
			  INST   : out STD_LOGIC_VECTOR (15 downto 0);
			  ALU		: out STD_LOGIC_VECTOR (15 downto 0);
			  WC		: out STD_LOGIC_VECTOR ( 2 downto 0);
			  FLAGS  : out STD_LOGIC_VECTOR ( 3 downto 0));
end Execution;

architecture Behavioral of Execution is
signal leave0: STD_LOGIC;
signal leave1: STD_LOGIC;
signal leave2: STD_LOGIC;
signal leave3: STD_LOGIC;
signal leave4: STD_LOGIC;
signal leave5: STD_LOGIC;

signal tosel: STD_LOGIC;
signal toenable: STD_LOGIC;

signal buff2: STD_LOGIC_VECTOR(15 downto 0);

signal MASKED_ADDR: STD_LOGIC_VECTOR(15 downto 0);

signal FLAG_NEG: STD_LOGIC;
signal FLAG_OVR: STD_LOGIC;
signal FLAG_ZERO: STD_LOGIC;
signal FLAG_CRY: STD_LOGIC;

--signals to control the output of ALU / CONST / CONTROL
signal TOEX0 : STD_LOGIC_VECTOR(15 downto 0);
signal TOEX1 : STD_LOGIC_VECTOR(15 downto 0);


signal TOALU0: STD_LOGIC_VECTOR (15 downto 0);
signal TOALU1: STD_LOGIC_VECTOR (15 downto 0);
signal ALU_OP: STD_LOGIC_VECTOR (4 downto 0);

signal IDCONTROL: STD_LOGIC;
-- Responsible for controling which register will be written
signal TOWC : STD_LOGIC_VECTOR(2 downto 0);
signal SELWC: STD_LOGIC;

signal REQOPB: STD_LOGIC;

begin

--MUX Operands
	-- Mux OP1 ALU
	OPA_PC_MUX0 : Mux16 port map(
		I0 => PC,
		I1 => OPA,
		O  => TOALU0, 
		S  => tosel
	);
	
	-- Mux OP2 ALU
	OPB_ADDR_MUX1 : Mux16 port map(
		I0 => ADDR,
		I1 => OPB,
		O  => TOALU1, 
		S  => tosel
	);
	
	-- Decides which signal to let into ALU
	-- Based on ALU ID
	ALUID_AND : a2 port map(
		A => OPCODE(15),
		B => leave0,
		Z => tosel
	);
	
	ALUID_NEG : not1 port map(
		A => OPCODE(14),
		Z => leave0
	);
	
-- MEM
	MEM_EX : ram port map(
		read_file  => RDF,
		write_file => WRF,
		WE 	 => toenable,
		clk 	 => CLK,
		ADRESS => MASKED_ADDR,
		DATA   => OPB,
		Q 		 => MEM
	);
	
	MASK_MEM_ADDR : mask_addr port map(
		I => OPA,
		Z => MASKED_ADDR
	);
	
	-- Control Write on Memory	
	MEM_WR_NOR : no2 port map(
		A => OPCODE(10),
		B => OPCODE(8),
		Z => leave1
	);
	
	MEM_WR_AND1: a3 port map(
		A => OPCODE(7),
		B => OPCODE(6),
		D => tosel,
		Z => leave2
	);
	
	MEM_WR_AND0: a3 port map(
		A => leave1,
		B => OPCODE(9),
		D => leave2,
		Z => toenable
	);
	
-- ALU
	
	MUX_OPERATION: mux5x2x1 port map(
		I0  => ("00000"),
		I1  => OPCODE(10 downto 6),
		Z   => ALU_OP,
		SEL => OPCODE(15)
	);
	
	
	 uALU: alu_unit port map(
		A => TOALU0,
      B => TOALU1,
		b15 =>OPCODE(15),
      b14 =>OPCODE(14),
      b10 => ALU_OP(4),
      b9 => ALU_OP(3),
      b8 => ALU_OP(2),
      b7 => ALU_OP(1),
      b6 => ALU_OP(0),
		CLK => CLK,
      Z => TOEX0,
      sinal => FLAG_NEG,
      cout => FLAG_CRY,
      zero => FLAG_ZERO,
      overflow => FLAG_OVR
	);
	
	FLAGS(0)<= FLAG_ZERO;
	FLAGS(1)<= FLAG_NEG;
	FLAGS(2)<= FLAG_CRY;
	FLAGS(3)<= FLAG_OVR;
	
--NEED ATENTION!
-- Constants
	CONSTANTES: Constants port map(
		opcode => OPCODE,
		rc => OPB,
		res => TOEX1
	);
			
-- Control
	-- Verifies ID for control type
	IDCONTROL_NOR : no2 port map(
		A => OPCODE(15),
		B => OPCODE(14),
		Z => IDCONTROL
	);
	
	-- Decides which register to write
	-- Generate SEL
	SEL_WC_AND: a3 port map(
		A => IDCONTROL,
		B => OPCODE(13),
		D => OPCODE(12),
		Z => SELWC
	);
	
	SEL_WC_MUX: mux3x2x1 port map(
		I0 => OPCODE(13 downto 11),
		I1 => "111",
		Z => TOWC,
		SEL => SELWC
	);
	
	
	WC <= TOWC;

-- FLAG TEST NOW AT BDU

-- MULTIPLEX OUTPUTS OF ALU, CONTROL AND CONSTANT UNITS
	-- IF CONTROL, then we route output from ALU!
	OUTPUTMUX_UNITS: Mux16 port map(
		I0 => TOEX0,
      I1 => TOEX1,
      O => buff2,
      S => OPCODE(14)
	);
	
	OUTPUTMUX_RB: mux16 port map(
		I0 => buff2,
		I1 => PC,
		O  => ALU,
		S  => REQOPB
	);
	
	OUTPUTMUX_IF: mux16 port map(
		I0 => buff2,
		I1 => OPB,
		O  => TOIFMUX,
		S  => REQOPB
	);
	
-- Generate OPb request (only for control type III)
	AND_OPB_REQ: a3 port map(
		A => IDCONTROL,
		B => OPCODE(13),
		D => OPCODE(12),
		Z => REQOPB
	);
	
	INST <= OPCODE;

end Behavioral;

