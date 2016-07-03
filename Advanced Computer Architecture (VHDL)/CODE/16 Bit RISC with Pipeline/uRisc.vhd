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

entity uRisc is
    Port ( CLK       : in  STD_LOGIC;
           RST       : in  STD_LOGIC;
           EN        : in  STD_LOGIC;
           EN_PC     : in  STD_LOGIC;
           EN_IF_REG : in  STD_LOGIC;
           EN_ID_REG : in  STD_LOGIC;
           EN_EX_REG : in  STD_LOGIC;
           START_PC  : in  STD_LOGIC;
           START_IF  : in  STD_LOGIC;
           START_ID  : in  STD_LOGIC;
           START_EX  : in  STD_LOGIC;
           RDF       : in  STD_LOGIC;
           WRF       : in  STD_LOGIC);
end uRisc;

architecture Behavioral of uRisc is

-- Inst. Fetching Wires
signal wireIF_ID_INST : STD_LOGIC_VECTOR(15 downto 0);
signal wireIF_ID_PC1  : STD_LOGIC_VECTOR(15 downto 0);

-- IF REGPIPE wires
signal wireREGPIPE_IF_PC1    : STD_LOGIC_VECTOR(15 downto 0);
signal wireREGPIPE_IF_OPCODE : STD_LOGIC_VECTOR(15 downto 0);

-- Inst. Decoding Wires
signal wireID_EX_INST   : STD_LOGIC_VECTOR(15 downto 0);
signal wireID_EX_EXTEND : STD_LOGIC_VECTOR(15 downto 0);
signal wireID_EX_OPA    : STD_LOGIC_VECTOR(15 downto 0);
signal wireID_EX_OPB    : STD_LOGIC_VECTOR(15 downto 0);
signal wireID_EX_PC     : STD_LOGIC_VECTOR(15 downto 0);

-- ID REGPIPE wires
signal wireREGPIPE_ID_PC     : STD_LOGIC_VECTOR(15 downto 0);
signal wireREGPIPE_ID_OPA    : STD_LOGIC_VECTOR(15 downto 0);
signal wireREGPIPE_ID_OPB    : STD_LOGIC_VECTOR(15 downto 0);
signal wireREGPIPE_ID_EXTEND : STD_LOGIC_VECTOR(15 downto 0);
signal wireREGPIPE_ID_OPCODE : STD_LOGIC_VECTOR(15 downto 0);

-- Execution Wires
signal wireEX_IF_SEL  : STD_LOGIC;
signal wireEX_IF_JUMP : STD_LOGIC_VECTOR(15 downto 0);

signal wireEX_WB_INST : STD_LOGIC_VECTOR(15 downto 0);
signal wireEX_WB_MEM  : STD_LOGIC_VECTOR(15 downto 0);
signal wireEX_WB_ALU  : STD_LOGIC_VECTOR(15 downto 0);
signal wireEX_WB_WC   : STD_LOGIC_VECTOR( 2 downto 0);

signal wireFLAGS      : STD_LOGIC_VECTOR( 3 downto 0);

-- EX REGPIPE wires
signal wireREGPIPE_EX_MEM    : STD_LOGIC_VECTOR(15 downto 0);
signal wireREGPIPE_EX_ALU    : STD_LOGIC_VECTOR(15 downto 0);
signal wireREGPIPE_EX_OPCODE : STD_LOGIC_VECTOR(15 downto 0);
signal wireREGPIPE_EX_WC     : STD_LOGIC_VECTOR( 2 downto 0);  

-- Write Back Wires
signal wireWB_ID_WRITE_ENABLE : STD_LOGIC;
signal wireWB_ID_STORE_DATA   : STD_LOGIC_VECTOR(15 downto 0);
signal wireWB_ID_WC           : STD_LOGIC_VECTOR( 2 downto 0);

signal PC   	  : STD_LOGIC_VECTOR(15 downto 0);
signal DATAOUT   : STD_LOGIC_VECTOR(15 downto 0);


-- FDU
signal FDU_OPA   : STD_LOGIC_VECTOR(15 downto 0);
signal FDU_OPB   : STD_LOGIC_VECTOR(15 downto 0);

begin

	uIFI: Instruction_Fetching port map(
		-- Outputs
		INST => wireIF_ID_INST,
		PC1  => wireIF_ID_PC1,
		-- Inputs
		DATA => X"0000",
		CLK  => CLK,
		EN_PC=> EN_PC,
		RST  => RST,
		RDF  => RDF,
		WRF  => '0',
		-- From Execution
      JUMP => wireEX_IF_JUMP,
      SEL  => wireEX_IF_SEL
	);
	
	-- REGPIPE
	IF_REGPIPE : RegBank_IF_ID port map(
		NEXTPC => wireIF_ID_PC1,
		INST   => wireIF_ID_INST,
		CLK    => CLK,
		RST	 => RST,
		EN 	 => EN_IF_REG,
		Z0		 => wireREGPIPE_IF_PC1,
		Z1     => wireREGPIPE_IF_OPCODE
	);
	
	uID: Instruction_Decoding port map(
		OPCODE => wireREGPIPE_IF_OPCODE,
		PC1    => wireREGPIPE_IF_PC1,
		-- FROM WB
		WB_INST=> wireREGPIPE_EX_OPCODE,
		DATA   => wireWB_ID_STORE_DATA,
		WC     => wireWB_ID_WC,
		WE		 => wireWB_ID_WRITE_ENABLE,
		CLK    => CLK,
		RST    => RST,
		-- OUTPUTS
		EXTEND => wireID_EX_EXTEND,
		OPA    => wireID_EX_OPA,
		OPB    => wireID_EX_OPB,
		PC     => wireID_EX_PC,
		INST   => wireID_EX_INST
	);

--
-- Control Data Unit 
-- Colocar somador para detectar saltos
-- Fazer o que a ALU estava a fazer antigamente com os saltos
-- 
		BDU_unit: BDU port map (
		    OPCODE_ID => wireREGPIPE_IF_OPCODE,
          OPCODE_EX => wireREGPIPE_ID_OPCODE,
          NEXTPC => wireREGPIPE_IF_PC1,
          OFFSET => wireID_EX_EXTEND,
          OPB_ID => wireID_EX_OPB,
          OPB_EX_MEM => wireEX_WB_MEM,
          OPB_EX_ALU => wireEX_WB_ALU,
          FLAGS => wireFLAGS,
          TOIFMUX => wireEX_IF_JUMP,
          TOIFSEL => wireEX_IF_SEL
      );
--
-- Atenção: Como é que se vai fazer com JL e JR?
-- E necessario averiguar se na saida da ALU foi calculado valor para 
-- o RB da instrucao actual. Pois, esse será o valor a enviar para o IF.
--

	ID_REGPIPE : RegBank_ID_EX port map(
		OPCODE => wireID_EX_INST,
		PC   	 => wireID_EX_PC,
		OPA  	 => wireID_EX_OPA,
		SIGE   => wireID_EX_EXTEND,
		OPB    => wireID_EX_OPB,
		CLK    => CLK,
		E      => EN_ID_REG,
		RST    => RST,
		Z0     => wireREGPIPE_ID_PC,
		Z1     => wireREGPIPE_ID_OPA,
		Z2     => wireREGPIPE_ID_OPB,
		Z3     => wireREGPIPE_ID_EXTEND,
		Z4     => wireREGPIPE_ID_OPCODE
	);


	uEX: Execution port map (
		OPCODE  => wireREGPIPE_ID_OPCODE,
	   PC      => wireREGPIPE_ID_PC,
      OPA     => FDU_OPA,
      OPB     => FDU_OPB,
      ADDR    => wireREGPIPE_ID_EXTEND,
		CLK	  => CLK,
		RST	  => RST,
		WRF     => WRF,
		RDF     => RDF,
		-- OUTPUTS
		--TO IF
		TOIFSEL => open,
		TOIFMUX => open,
		--TO WB
		INST    => wireEX_WB_INST,
		MEM     => wireEX_WB_MEM,
		ALU	  => wireEX_WB_ALU,
		WC		  => wireEX_WB_WC,
		FLAGS   => wireFLAGS
	);
--
-- FDU
-- Entradas:
-- wireREGPIPE_EX_MEM
-- wireREGPIPE_EX_ALU
-- wireREGPIPE_EX_INST ----contem RA, RB, ID, etc
--
-- Saidas:
-- toOPA
-- toOPB
--
	FDU_unit : FDU port map(
      WB_INST => wireREGPIPE_EX_OPCODE,
      ID_INST => wireREGPIPE_ID_OPCODE,
		FWD_WB  => wireWB_ID_STORE_DATA,
		ID_OPA  => wireREGPIPE_ID_OPA,
		ID_OPB  => wireREGPIPE_ID_OPB,
      OPA => FDU_OPA,
      OPB => FDU_OPB
	);


-- No seu interior 
--
	
	-- Register bank
	EX_REGPIPE: RegBank_EX_WB port map(
      OPCODE => wireEX_WB_INST,
		MEM    => wireEX_WB_MEM,
      ALU    => wireEX_WB_ALU,
		WC 	 => wireEX_WB_WC,
      Z0 	 => wireREGPIPE_EX_MEM,
      Z1 	 => wireREGPIPE_EX_ALU,
      Z2     => wireREGPIPE_EX_OPCODE,
		Z3 	 => wireREGPIPE_EX_WC,
      CLK 	 => CLK,
      E 		 => EN_EX_REG,
      RST    => RST
	);
	
	
	uWB: WriteBack port map( 
	   OPCODE  => wireREGPIPE_EX_OPCODE,
		MEM     => wireREGPIPE_EX_MEM,
      ALU     => wireREGPIPE_EX_ALU,
      WC      => wireREGPIPE_EX_WC,
		-- OUTPUTS
      WPort   => wireWB_ID_STORE_DATA,
      DSTREG  => wireWB_ID_WC,
      WEnable => wireWB_ID_WRITE_ENABLE
	);
	
end Behavioral;

