----------------------------------------------------------------------------------
-- Instituto Superior TÃ©cnico 
-- 
-- Projecto Sistemas Digitais
-- 
-- Martim Camacho (56755)
-- Pedro Silva, pedro.silva@ist.utl.pt (58035)
-- 
----------------------------------------------------------------------------------

library IEEE;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use UNISIM.Vcomponents.all;

package psdlib is
	constant cbits_size : integer := 6; -- tamanho dos bits de controlo
	constant idx_size : integer := 5; --endereco memorias
	constant addr_size : integer := 9; --endereco memorias
	constant line_bits : integer :=5; -- numero de bits para representar colunas e linhas;
	constant buff_size: integer:=2;
	constant width: integer:=25; -- tamanho dos CAM
	constant MAXN: integer:=5;
	constant MAXM: integer:=5;
	constant n_bits: integer:=3;
	constant m_bits: integer:=3;
	constant memsize: integer:=20;
	type r_array is array (integer range <>) of std_logic_vector(2*line_bits-1 downto 0);
	
component memsdata is
  port ( 
         addrA : in  std_logic_vector(8 downto 0);
         addrB : in  std_logic_vector(8 downto 0);
         addrC : in  std_logic_vector(8 downto 0);
         addrD : in  std_logic_vector(8 downto 0);
         addrE : in  std_logic_vector(8 downto 0);
         addrF : in  std_logic_vector(8 downto 0);
         doA   : out std_logic_vector(31 downto 0);
         doB   : out std_logic_vector(31 downto 0);
         doC   : out std_logic_vector(31 downto 0);
         doD   : out std_logic_vector(31 downto 0);
         doE   : out std_logic_vector(31 downto 0);
         doF   : out std_logic_vector(31 downto 0);
         clk  : in  std_logic
       );
end component;



component disp7 is
    port(
      disp4   : in  std_logic_vector(3 downto 0);
      disp3   : in  std_logic_vector(3 downto 0);
      disp2   : in  std_logic_vector(3 downto 0);
      disp1   : in  std_logic_vector(3 downto 0);
      clk     : in  std_logic;
      en_disp : out std_logic_vector(4 downto 1);
      segm    : out std_logic_vector(7 downto 0)
      );
end component;



component regp is
	generic(
		bits : integer :=8
	);
	port(
		clk : in std_logic;
		ce : in std_logic;
		r : in std_logic;
		p : in  std_logic_vector (bits-1 downto 0);
		q : out  std_logic_vector (bits-1 downto 0)
	);
end component;


component adder is
	generic (N : integer := 32);
    Port ( a : in  STD_LOGIC_VECTOR (N-1 downto 0);
           b : in  STD_LOGIC_VECTOR (N-1 downto 0);
           sel : in  STD_LOGIC;
           z : out  STD_LOGIC_VECTOR (N-1 downto 0)
	);
end component;


component datapath is
	Port (	clk		: in	STD_LOGIC;
			clear	: in	STD_LOGIC;
			idx		: in	STD_LOGIC_VECTOR(addr_size-1 downto 0);
			cbits	: in	std_logic_vector (cbits_size-1 downto 0); -- bits controlo
			outi	: out	STD_LOGIC_VECTOR (31 downto 0)
			);
end component;


component control is
	Port(	clk	: in	STD_LOGIC;
			rst	: in	STD_LOGIC;
			
			RDaddrCIR: out std_logic_vector(8 downto 0); -- endereco MEM IN
			RDdata: in std_logic_vector(31 downto 0); -- DATA_OUT MEMIN
			
			WRaddrCir: out std_logic_vector(8 downto 0); -- Endereço MEMOUT
			WRenable: out std_logic; -- WE MEM OUT
			
			canSTART: in std_logic; -- ENABLE Circuito3
			
			endd: in std_logic;
			error : in	std_logic;
			cbits	: out	STD_LOGIC_VECTOR(cbits_size-1 downto 0);
			idx	: out	STD_LOGIC_VECTOR(idx_size-1 downto 0);
			m: out std_logic_vector(m_bits-1 downto 0);
			n: out std_logic_vector(m_bits-1 downto 0);
			mn: out std_logic_vector(line_bits-1 downto 0);
			
			
			execDONE: out std_logic;

			CNTbyte2: in std_logic_vector(11 downto 0)		
			
			
			);
end component;


component counterup is 
  port (clk, clr, count : in std_logic; 
        q : out std_logic_vector (idx_size-1 downto 0)); 
end component;


component circuito3 is
  port (
    CLK       : in  std_logic;
    RST       : in  std_logic;
    RDaddrCIR : out std_logic_vector(8 downto 0);
    RDdata    : in  std_logic_vector(31 downto 0);
    WRaddrCIR : out std_logic_vector(8 downto 0);
    WRdata    : out std_logic_vector(31 downto 0);
    WRenable  : out std_logic;
    canSTART  : in  std_logic;
    execDONE  : out std_logic;
    CNTbyte2  : in  std_logic_vector(11 downto 0)
    );
end component;

component interface_placa is
  port (
    clk50M                 : in  std_logic;
    D7S3, D7S2, D7S1, D7S0 : in  std_logic_vector(3 downto 0);
    dataleds               : in  std_logic_vector(7 downto 0);
    led                    : out std_logic_vector(7 downto 0);
    an                     : out std_logic_vector(3 downto 0);
    ssg                    : out std_logic_vector(7 downto 0)
    );
end component;

component decode_hexa_chars is
  port (din   : in  std_logic_vector (7 downto 0);
        dout  : out std_logic_vector (3 downto 0);
        isEnd : out std_logic
        -- isHexa : out std_logic
        );
end component;

component encode_hexa_chars is
  port (din  : in  std_logic_vector (3 downto 0);
        dout : out std_logic_vector (7 downto 0)
        );
end component;

component UARTcomponent is
  port (TXD   : out   std_logic := '1';
        RXD   : in    std_logic;
        CLK   : in    std_logic;                      --Master Clock
        DBIN  : in    std_logic_vector (7 downto 0);  --Data Bus in
        DBOUT : out   std_logic_vector (7 downto 0);  --Data Bus out
        RDA   : inout std_logic;                      --Read Data Available
        TBE   : inout std_logic := '1';               --Transfer Bus Empty
        RD    : in    std_logic;                      --Read Strobe
        WR    : in    std_logic;                      --Write Strobe
        PE    : out   std_logic;                      --Parity Error Flag
        FE    : out   std_logic;                      --Frame Error Flag
        OE    : out   std_logic;                      --Overwrite Error Flag
        RST   : in    std_logic := '0');              --Master Reset
end component;

component interface_serie is
  port (TXD         : out std_logic := '1';
        RXD         : in  std_logic := '1';
        CLK         : in  std_logic;
        RST         : in  std_logic;
        RDaddr      : in  std_logic_vector(8 downto 0);   -- READ mem Address
        RDdata      : out std_logic_vector(31 downto 0);  -- READ mem Data
        WRaddr      : in  std_logic_vector(8 downto 0);   -- WRITE mem Address
        WRdata      : in  std_logic_vector(31 downto 0);  -- WRITE mem Data
        WRenable    : in  std_logic;    -- WRITE mem Enable
        WRdataRDbck : out std_logic_vector(31 downto 0);  -- readbeack WRITE mem
        canSTART    : out std_logic;  -- all data read from PC, can start computation
        execDONE    : in  std_logic;  -- computation done, data on mem, can send to PC
        SENDtoPC    : in  std_logic;    -- send data to PC via serial RS232
        CNTbyte2    : out std_logic_vector(11 downto 0);  -- numb. of char read
                                        -- (4bits in READ mem)
        canDEBUG    : out std_logic     -- for mem debug
        );
end component;

component fpga3 is
  port (TXD  : out std_logic := '1';
        RXD  : in  std_logic := '1';
        CLKB : in  std_logic;
        btn  : in  std_logic_vector(3 downto 0);
        swt  : in  std_logic_vector(7 downto 0);
        led  : out std_logic_vector(7 downto 0);
        an   : out std_logic_vector(3 downto 0);
        ssg  : out std_logic_vector(7 downto 0)
        );
end component;

component verifier_decoder is
	port (
		idx : in std_logic_vector (idx_size-1 downto 0);
		en : out std_logic_vector (width-1 downto 0)
	);
end component;

component verifier is
	Port (
		clk : in std_logic;
		ce : in std_logic;
		reset: in std_logic;
		flush: in std_logic;
		enable_bus : in std_logic_vector(width-1 downto 0);
		idx : in std_logic_vector (idx_size-1 downto 0);
		l_i : in std_logic_vector (line_bits-1 downto 0);
		c_i : in std_logic_vector (line_bits-1 downto 0);
		
		error: out std_logic;
		l_e : out std_logic_vector (line_bits-1 downto 0);
		c_e : out std_logic_vector (line_bits-1 downto 0)
	);
end component;

component counter is
	port( 
		CLK : in std_logic;
		ce : in std_logic;
		CLR : in std_logic;
		limit: in std_logic_vector(line_bits-1 downto 0);
		Q : out std_logic_vector(line_bits-1 downto 0);
		overflow : out std_logic
	);
end component;

component region_decoder is
	Port (
		clk : in std_logic;
		ce : in std_logic;
		reset: in std_logic;
		m: in std_logic_vector (m_bits-1 downto 0);
		n: in std_logic_vector (n_bits-1 downto 0);
		overflow: out std_logic;
		nreg : out std_logic_vector(line_bits-1 downto 0);
		q: out std_logic_vector(MAXN-1 downto 0)
	);
end component;


component ram_36_36 is
port(

--DOA : out std_logic_vector(31 downto 0); -- Port A 32-bit Data Output
DOB : out std_logic_vector(31 downto 0); -- Port B 32-bit Data Output
DOPA1 : out std_logic_vector(3 downto 0); -- Port A 4-bit Parity Output
DOPB1 : out std_logic_vector(3 downto 0);  -- Port B 4-bit Parity Output
DOPA2 : out std_logic_vector(3 downto 0); -- Port A 4-bit Parity Output
DOPB2 : out std_logic_vector(3 downto 0);  -- Port B 4-bit Parity Output
sel : in std_logic;
ADDRA : in std_logic_vector(8 downto 0);  -- Port A 9-bit Address Input
ADDRB : in std_logic_vector(8 downto 0);  -- Port B 9-bit Address Input
CLKA : in std_logic; -- Port A Clock
CLKB : in std_logic; -- Port B Clock
DIA : in std_logic_vector(31 downto 0); -- Port A 32-bit Data Input
DIB : in std_logic_vector(31 downto 0); -- Port B 32-bit Data Input
DIPA : in std_logic_vector(3 downto 0); -- Port A 4-bit parity Input
DIPB : in std_logic_vector(3 downto 0); -- Port-B 4-bit parity Input
ENA :in std_logic; -- Port A RAM Enable Input
--ENB : in std_logic; -- PortB RAM Enable Input
SSRA : in std_logic; -- Port A Synchronous Set/Reset Input
SSRB :in std_logic; -- Port B Synchronous Set/Reset Input
WEA :in std_logic -- Port A Write Enable Input
--WEB :in std_logic -- Port B Write Enable Input
);
end component;


component validator is
	Port (
		clk : in std_logic;
		ce : in std_logic;
		reset: in std_logic;
		flush: in std_logic;
		idx : in std_logic_vector (idx_size-1 downto 0);

		m: in std_logic_vector (m_bits-1 downto 0);
		n: in std_logic_vector (n_bits-1 downto 0);
		mn: in std_logic_vector (line_bits-1 downto 0);

		check_end: out std_logic;
		colerror: out std_logic;
		linerror: out std_logic;
		regerror: out std_logic;
		error: out std_logic;
		linele : out std_logic_vector (line_bits-1 downto 0);
		linece : out std_logic_vector (line_bits-1 downto 0);
		regle : out std_logic_vector (line_bits-1 downto 0);
		regce : out std_logic_vector (line_bits-1 downto 0);
		colle : out std_logic_vector (line_bits-1 downto 0);
		colce : out std_logic_vector (line_bits-1 downto 0);
		lin : out std_logic_vector (line_bits-1 downto 0);
		col : out std_logic_vector (line_bits-1 downto 0)
	);
end component;


component mem_writer is
	port(
		clk	   : in std_logic;
		rst : in std_logic;
		enable : in std_logic;
		colerror: in std_logic;
		linerror: in std_logic;
		regerror: in std_logic;
		error: in std_logic;
		linele : in std_logic_vector (line_bits-1 downto 0);
		linece : in std_logic_vector (line_bits-1 downto 0);
		regle : in std_logic_vector (line_bits-1 downto 0);
		regce : in std_logic_vector (line_bits-1 downto 0);
		colle : in std_logic_vector (line_bits-1 downto 0);
		colce : in std_logic_vector (line_bits-1 downto 0);
		lin : in std_logic_vector (line_bits-1 downto 0);
		col : in std_logic_vector (line_bits-1 downto 0);
		
		WRenable   : out std_logic;
		WRdata    : out std_logic_vector(31 downto 0)
		);
end component;


--component  is
--port ();
--end component;

end package psdlib;

