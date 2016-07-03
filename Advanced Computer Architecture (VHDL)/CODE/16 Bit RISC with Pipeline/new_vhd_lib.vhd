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

package new_vhd_lib is

component full_add_1bit is
    port ( x : in  STD_LOGIC;
           y : in  STD_LOGIC;
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           sum : out  STD_LOGIC);
end component;

component full_add_16 is
    port ( x : in  STD_LOGIC_VECTOR (15 downto 0);
           y : in  STD_LOGIC_VECTOR (15 downto 0);
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           overflow : out  STD_LOGIC;
           sum : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component Reg16 is
    Port ( CLK : in  STD_LOGIC;
           E : in  STD_LOGIC;
           R : in  STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (15 downto 0);
           Q : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component Mux16 is
    Port ( I0 : in  STD_LOGIC_VECTOR (15 downto 0);
           I1 : in  STD_LOGIC_VECTOR (15 downto 0);
           O : out  STD_LOGIC_VECTOR (15 downto 0);
           S : in  STD_LOGIC);
end component;

component Mux8x1 is
    Port ( M0 : in  STD_LOGIC_VECTOR (15 downto 0);
           M1 : in  STD_LOGIC_VECTOR (15 downto 0);
           M2 : in  STD_LOGIC_VECTOR (15 downto 0);
           M3 : in  STD_LOGIC_VECTOR (15 downto 0);
           M4 : in  STD_LOGIC_VECTOR (15 downto 0);
           M5 : in  STD_LOGIC_VECTOR (15 downto 0);
           M6 : in  STD_LOGIC_VECTOR (15 downto 0);
           M7 : in  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0);
			  SEL : in  STD_LOGIC_VECTOR (2 downto 0));
end component;

component Decoder3x8 is
    Port ( D : in  STD_LOGIC_VECTOR (2 downto 0);
           O : out  STD_LOGIC_VECTOR (7 downto 0);
			  E : in STD_LOGIC );
end component;

component Registers is
    Port ( WPort: in STD_LOGIC_VECTOR (15 downto 0);
			  SELWC: in STD_LOGIC_VECTOR (2 downto 0);
           SELA : in STD_LOGIC_VECTOR (2 downto 0);
			  SELB : in STD_LOGIC_VECTOR (2 downto 0);
			  SelWB : in  STD_LOGIC_VECTOR (2 downto 0);
           RegA : out STD_LOGIC_VECTOR (15 downto 0);
			  RegB : out STD_LOGIC_VECTOR (15 downto 0);
			  SELREG  : in  STD_LOGIC;
			  Clock : in  STD_LOGIC;
           Reset : in  STD_LOGIC;
			  WEnable: in STD_LOGIC);
end component;


component MuxSignalExtender4x1 is
    Port ( E0 : in  STD_LOGIC_VECTOR (11 downto 0);
           E1 : in  STD_LOGIC_VECTOR (10 downto 0);
           E2 : in  STD_LOGIC_VECTOR (7 downto 0);
           SEL : in  STD_LOGIC_VECTOR (2 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0));
end component;


component RegBank_ID_EX is
    Port ( PC : in  STD_LOGIC_VECTOR (15 downto 0);
           OPA : in  STD_LOGIC_VECTOR (15 downto 0);
           OPB : in  STD_LOGIC_VECTOR (15 downto 0);
           SIGE : in  STD_LOGIC_VECTOR (15 downto 0);
           OPCODE : in  STD_LOGIC_VECTOR (15 downto 0);
           Z0 : out  STD_LOGIC_VECTOR (15 downto 0);
           Z1 : out  STD_LOGIC_VECTOR (15 downto 0);
           Z2 : out  STD_LOGIC_VECTOR (15 downto 0);
           Z3 : out  STD_LOGIC_VECTOR (15 downto 0);
			  Z4 : out  STD_LOGIC_VECTOR (15 downto 0);
			  CLK : in STD_LOGIC;
			  E: in STD_LOGIC;
			  RST: in STD_LOGIC);
end component;

component ram is

	generic (dim : integer := 1024)	;

	port (

-- bits de controlo de escrita no ficheiro----

		read_file : in STD_LOGIC;

		write_file : in STD_LOGIC;

-----------------------------------------------	

		WE : in STD_LOGIC;

		clk: in STD_LOGIC;

		ADRESS : in STD_LOGIC_VECTOR(15 downto 0);	 

		DATA : in STD_LOGIC_VECTOR (15 downto 0);

		Q : out STD_LOGIC_VECTOR (15 downto 0)

	);

end component;

component RegBank_EX_WB is
    Port ( MEM : in  STD_LOGIC_VECTOR (15 downto 0);
           ALU : in  STD_LOGIC_VECTOR (15 downto 0);
           OPCODE : in  STD_LOGIC_VECTOR (15 downto 0);
			  WC : in   STD_LOGIC_VECTOR (2 downto 0);
           Z0 : out  STD_LOGIC_VECTOR (15 downto 0);
           Z1 : out  STD_LOGIC_VECTOR (15 downto 0);
           Z2 : out  STD_LOGIC_VECTOR (15 downto 0);
			  Z3 : out 	STD_LOGIC_VECTOR (2 downto 0);
           CLK : in  STD_LOGIC;
           E : in  STD_LOGIC;
           RST : in  STD_LOGIC);
end component;

component  Mux1x8x1 is
    Port ( I0 : in  STD_LOGIC;
           I1 : in  STD_LOGIC;
           I2 : in  STD_LOGIC;
           I3 : in  STD_LOGIC;
           I4 : in  STD_LOGIC;
           I5 : in  STD_LOGIC;
           I6 : in  STD_LOGIC;
           I7 : in  STD_LOGIC;
           SEL : in  STD_LOGIC_VECTOR( 2 downto 0);
           Z : out  STD_LOGIC);
end component;

component Constants is
    Port ( opcode : in  STD_LOGIC_VECTOR (15 downto 0);
           rc : in  STD_LOGIC_VECTOR (15 downto 0);
           res : out  STD_LOGIC_VECTOR (15 downto 0));
end component;


component Flag_Test is
    Port ( NEG     : in  STD_LOGIC;
           ZERO 	 : in  STD_LOGIC;
           OVERFLOW: in  STD_LOGIC;
           CARRY   : in  STD_LOGIC;
			  COND 	 : in STD_LOGIC_VECTOR(3 downto 0);
			  OP 	 	 : in STD_LOGIC_VECTOR(1 downto 0);
			  UNJUMP  : in STD_LOGIC;
			  ENABLE  : in STD_LOGIC;
			  SEL		 : in STD_LOGIC;
           Z 		 : out  STD_LOGIC);
end component;


component Reg16HL is
    Port ( CLK : in  STD_LOGIC;
           EH : in  STD_LOGIC;
			  EL : in STD_LOGIC;
           R : in  STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (15 downto 0);
           Q : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component mux3x2x1 is
    Port ( I0 : in  STD_LOGIC_VECTOR (2 downto 0);
           I1 : in  STD_LOGIC_VECTOR (2 downto 0);
           SEL : in  STD_LOGIC;
           Z : out  STD_LOGIC_VECTOR (2 downto 0));
end component;


component Mux16x3x1 is
    Port ( I0 : in  STD_LOGIC_VECTOR (15 downto 0);
           I1 : in  STD_LOGIC_VECTOR (15 downto 0);
           I2 : in  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0);
           SEL : in  STD_LOGIC_VECTOR (1 downto 0));
end component;


--------------------

-----------

--------

--------------

--------------------

component  y_transf is
    Port ( b8 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           yin : in  STD_LOGIC;
           yout : out  STD_LOGIC);
end component;

component  y_transf_16 is
    Port ( yin : in  STD_LOGIC_VECTOR (15 downto 0);
           yout : out  STD_LOGIC_VECTOR (15 downto 0);
           b7 : in  STD_LOGIC;
           b8 : in  STD_LOGIC);
end component;

component zero_detect is 
		Port ( res : in   STD_LOGIC_VECTOR (15 downto 0);
             zero : out  STD_LOGIC);
end component;


component shift_arit_dir is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0);
			  sinal : out  STD_LOGIC;
		     cout : out  STD_LOGIC
			);
end component;

component shift_log_esq is
    Port ( ina : in STD_LOGIC_VECTOR (15 downto 0);
           outb : out STD_LOGIC_VECTOR (15 downto 0);
		     sinal : out  STD_LOGIC;
		     cout : out  STD_LOGIC
			);
end component;

component xor16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
			  inb : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end component;


component  xnor16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
   		  inb : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component  or16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
		     inb : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component  mux_16_16 is
    Port (  M0  : in  STD_LOGIC_VECTOR (15 downto 0);
			M1  : in  STD_LOGIC_VECTOR (15 downto 0);
			M2  : in  STD_LOGIC_VECTOR (15 downto 0);
			M3  : in  STD_LOGIC_VECTOR (15 downto 0);
			M4  : in  STD_LOGIC_VECTOR (15 downto 0);
			M5  : in  STD_LOGIC_VECTOR (15 downto 0);
			M6  : in  STD_LOGIC_VECTOR (15 downto 0);
			M7  : in  STD_LOGIC_VECTOR (15 downto 0);
			M8  : in  STD_LOGIC_VECTOR (15 downto 0);
			M9  : in  STD_LOGIC_VECTOR (15 downto 0);
			M10 : in  STD_LOGIC_VECTOR (15 downto 0);
			M11 : in  STD_LOGIC_VECTOR (15 downto 0);
			M12 : in  STD_LOGIC_VECTOR (15 downto 0);
			M13 : in  STD_LOGIC_VECTOR (15 downto 0);
			M14 : in  STD_LOGIC_VECTOR (15 downto 0);
			M15 : in  STD_LOGIC_VECTOR (15 downto 0);
			SEL : in  STD_LOGIC_VECTOR (3 downto 0);
			OUTB   : out  STD_LOGIC_VECTOR (15 downto 0));			
end component;

component  logic_unit is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
           inb : in  STD_LOGIC_VECTOR (15 downto 0);
			  b6 : in  STD_LOGIC;
			  b7 : in  STD_LOGIC;
			  b8 : in  STD_LOGIC;
			  b9 : in  STD_LOGIC;
           outb : out  STD_LOGIC_VECTOR (15 downto 0);
           zero : out  STD_LOGIC;
           sinal : out  STD_LOGIC);
end component;

component  nor16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
	        inb : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component not16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component  and16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
	        inb : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component  nand16 is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
	        inb : in  STD_LOGIC_VECTOR (15 downto 0);
           outb : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component  shift_unit is
    Port ( ina : in  STD_LOGIC_VECTOR (15 downto 0);
		     b6 : in  STD_LOGIC;
           outb : out  STD_LOGIC_VECTOR (15 downto 0);
		     sinal : out  STD_LOGIC;
		     cout : out  STD_LOGIC;
		     zero : out  STD_LOGIC
			);
end component;

component  arithmetic_unit is
    Port ( ra : in  STD_LOGIC_VECTOR (15 downto 0);
           rb : in  STD_LOGIC_VECTOR (15 downto 0);
           b8 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           b6 : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           overflow : out  STD_LOGIC;
           zero : out  STD_LOGIC;
           sinal : out  STD_LOGIC;
           res : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component arith_shift_unit is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0);
           b6 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           b8 : in  STD_LOGIC;
           b9 : in  STD_LOGIC;
           sinal : out  STD_LOGIC;
           cout : out  STD_LOGIC;
           zero : out  STD_LOGIC;
           overflow : out  STD_LOGIC);
end component;

component flag_en_logic is
    Port ( b15 : in  STD_LOGIC;
			  b14 : in  STD_LOGIC;
			  b10 : in  STD_LOGIC;
           b9 : in  STD_LOGIC;
           b8 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           b6 : in  STD_LOGIC;
           es : out  STD_LOGIC;
           ec : out  STD_LOGIC;
           ez : out  STD_LOGIC;
           eo : out  STD_LOGIC);
end component;

component flag_reg is
    Port (
			  CLK : in  STD_LOGIC;
			  z : in  STD_LOGIC;
           s : in  STD_LOGIC;
           c : in  STD_LOGIC;
           o : in  STD_LOGIC;
			  
           b6 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           b8 : in  STD_LOGIC;
           b9 : in  STD_LOGIC;
			  b10 : in  STD_LOGIC;
			  
			  b14 : in  STD_LOGIC;
			  b15 : in  STD_LOGIC;
			  
           zero : out  STD_LOGIC;
           sinal : out  STD_LOGIC;
           cout : out  STD_LOGIC;
           overflow : out  STD_LOGIC;
			  FLAG_EN : out STD_LOGIC_VECTOR(3 downto 0));
end component;

component mux_4_2 is
    Port ( z_ar_sh : in  STD_LOGIC;
           s_ar_sh : in  STD_LOGIC;
           z_log : in  STD_LOGIC;
           s_log : in  STD_LOGIC;
           z : out  STD_LOGIC;
           s : out  STD_LOGIC;
           SEL : in  STD_LOGIC);
end component;

component  alu_unit is
    Port ( A : in  STD_LOGIC_VECTOR (15 downto 0);
           B : in  STD_LOGIC_VECTOR (15 downto 0);

           b15 : in  STD_LOGIC;
           b14 : in  STD_LOGIC;

           b10 : in  STD_LOGIC;
           b9 : in  STD_LOGIC;
           b8 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           b6 : in  STD_LOGIC;
			  CLK : in  std_logic;
           Z : out  STD_LOGIC_VECTOR (15 downto 0);
           sinal : out  STD_LOGIC;
           cout : out  STD_LOGIC;
           zero : out  STD_LOGIC;
           overflow : out  STD_LOGIC);
end component;

component RegBank_IF_ID is
    Port ( NEXTPC : in  STD_LOGIC_VECTOR (15 downto 0);
           INST : in  STD_LOGIC_VECTOR (15 downto 0);
           CLK : in  STD_LOGIC;
           RST : in  STD_LOGIC;
           EN : in  STD_LOGIC;
           Z0 : out  STD_LOGIC_VECTOR (15 downto 0);
           Z1 : out  STD_LOGIC_VECTOR (15 downto 0));
end component;


-- Blocks
component Instruction_Fetching is
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
end component;

component Instruction_Decoding is
    Port ( PC1     : in  STD_LOGIC_VECTOR (15 downto 0);
	 		  WB_INST : in  STD_LOGIC_VECTOR (15 downto 0);
	        OPCODE  : in  STD_LOGIC_VECTOR (15 downto 0);
           EXTEND  : out STD_LOGIC_VECTOR (15 downto 0);
			  OPA     : out STD_LOGIC_VECTOR (15 downto 0);
			  OPB     : out STD_LOGIC_VECTOR (15 downto 0);
			  PC      : out STD_LOGIC_VECTOR (15 downto 0);
			  INST    : out STD_LOGIC_VECTOR (15 downto 0);
			  DATA    : in  STD_LOGIC_VECTOR (15 downto 0);
			  WC      : in  STD_LOGIC_VECTOR (2 downto 0);
			  CLK     : in  STD_LOGIC;
			  RST     : in  STD_LOGIC;
			  WE		 : in  STD_LOGIC);
end component;

component Execution is
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
end component;

component WriteBack is
    Port ( MEM     : in  STD_LOGIC_VECTOR (15 downto 0);
           ALU     : in  STD_LOGIC_VECTOR (15 downto 0);
           OPCODE  : in  STD_LOGIC_VECTOR (15 downto 0);
			  WC 		 : in  STD_LOGIC_VECTOR (2 downto 0);
           WPort   : out  STD_LOGIC_VECTOR (15 downto 0);
           DSTREG  : out  STD_LOGIC_VECTOR (2 downto 0);
           WEnable : out  STD_LOGIC);
end component;

component mux5x2x1 is
    Port ( I0 : in  STD_LOGIC_VECTOR (4 downto 0);
           I1 : in  STD_LOGIC_VECTOR (4 downto 0);
           Z : out  STD_LOGIC_VECTOR (4 downto 0);
           SEL : in  STD_LOGIC);
end component;

component mask_addr is
    Port ( I : in  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component FDU is
	Port ( FWD_WB  : in  STD_LOGIC_VECTOR (15 downto 0);
		ID_OPA  : in  STD_LOGIC_VECTOR (15 downto 0);
		ID_OPB  : in  STD_LOGIC_VECTOR (15 downto 0);			  
		WB_INST : in  STD_LOGIC_VECTOR (15 downto 0);
		ID_INST : in  STD_LOGIC_VECTOR (15 downto 0);
		OPA : out  STD_LOGIC_VECTOR (15 downto 0);
		OPB : out  STD_LOGIC_VECTOR (15 downto 0));
end component;


component BDU is
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
end component;


component Comparator3b is
    Port ( I0 : in  STD_LOGIC_VECTOR (2 downto 0);
           I1 : in  STD_LOGIC_VECTOR (2 downto 0);
           Z  : out  STD_LOGIC);
end component;


component A_block is
    Port ( a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           c : in  STD_LOGIC;
           g : out  STD_LOGIC;
           p : out  STD_LOGIC;
           s : out  STD_LOGIC);
end component;



component B_block is
    Port ( Gij : in  STD_LOGIC;
           Pij : in  STD_LOGIC;
           Gj_i_k : in  STD_LOGIC;
           Pj_i_k : in  STD_LOGIC;
           Gik : out  STD_LOGIC;
           Pik : out  STD_LOGIC;
           Cin : in  STD_LOGIC;
           Cj1 : out  STD_LOGIC);
end component;




component Carry_Look_ahead is
    Port ( IN_A : in  STD_LOGIC_VECTOR (15 downto 0);
           IN_B : in  STD_LOGIC_VECTOR (15 downto 0);
           IN_C : in  STD_LOGIC;
           OUT_Q : out  STD_LOGIC_VECTOR (15 downto 0);
           OUT_C : out  STD_LOGIC;
			  OUT_C15:out  STD_LOGIC 
			  );
end component;


component cla_full_add_16 is
    Port ( cin : in  STD_LOGIC;
           x : in  STD_LOGIC_VECTOR (15 downto 0);
           y : in  STD_LOGIC_VECTOR (15 downto 0);
           sum : out  STD_LOGIC_VECTOR (15 downto 0);
           cout : out  STD_LOGIC;
           overflow : out  STD_LOGIC);
end component;




end package new_vhd_lib;

