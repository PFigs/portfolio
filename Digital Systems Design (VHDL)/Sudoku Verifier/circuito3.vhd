----------------------------------------------------------------------------------
-- Instituto Superior Técnico 
-- 
-- Projecto Sistemas Digitais
-- 
-- Martim Camacho, martim.camacho@ist.utl.pt (56755)
-- Pedro Silva, pedro.silva@ist.utl.pt (58035)
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.PSDLIB.ALL;

library UNISIM;
use UNISIM.VComponents.all;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
--library UNISIM;
--use UNISIM.VComponents.all;

entity circuito3 is
  port (
    CLK       : in  std_logic;
    RST       : in  std_logic;
--~ RDaddrCIR : out std_logic_vector(8 downto 0);
--~ RDdata    : in  std_logic_vector(31 downto 0);
--~ WRaddrCIR : out std_logic_vector(8 downto 0);
--~ WRdata    : out std_logic_vector(31 downto 0);
--~ WRenable  : out std_logic;
clks    : out std_logic;
memout  : out std_logic_vector(31 downto 0);
    canSTART  : in  std_logic;
    execDONE  : out std_logic;
    CNTbyte2  : in  std_logic_vector(11 downto 0)
    );
end circuito3;

architecture beahvioral of circuito3 is

	component clkdiv is
		port(
			clk		:	in std_logic;
			clkout	:	out std_logic
		);
	end component;

  component memsdata is
  port ( 
         dataFROMmemIN  : out  std_logic_vector(31 downto 0);
         addressRDmemIN : in  std_logic_vector(8 downto 0);
         dataTOmemIN    : in  std_logic_vector(3 downto 0);
         enableWRmemIN  : in  std_logic;
         CLK  : in  std_logic
       );
  end component;

  
  signal wire_lle,wire_lce,wire_rle,wire_rce,wire_cle, wire_cce,wire_line,wire_col:std_logic_vector (line_bits-1 downto 0);
  signal wire_endd,wire_cerror,wire_lerror,wire_rerror,wire_error: std_logic;
  signal wire_idx: std_logic_vector(idx_size-1 downto 0);
  signal wire_cbits: std_logic_vector(cbits_size-1 downto 0);
  
  signal wire_m: std_logic_vector(m_bits-1 downto 0);
  signal wire_n: std_logic_vector(n_bits-1 downto 0);
  signal wire_mn: std_logic_vector(line_bits-1 downto 0);

	-- signal debug
   signal RDaddrCIR : std_logic_vector(8 downto 0);
   signal RDdata    : std_logic_vector(31 downto 0);
   signal WRaddrCIR : std_logic_vector(8 downto 0);
   signal WRdata    : std_logic_vector(31 downto 0);
   signal WRenable, wire_enable,  clkd : std_logic;

  
begin  -- beahvioral
	
  ctrl: control
	Port map(	
		clk	=> clk,
		rst	=> rst,
			
		RDaddrCIR => RDaddrCIR,
		RDdata => RDdata,
			
		WRaddrCir => WRaddrCir,
		WRenable => wire_enable,
			
		canSTART => canSTART,
			
		endd => wire_endd,
		error => wire_error,
		cbits	=> wire_cbits,
		idx => wire_idx,
		m => wire_m,
		n => wire_n,
		mn => wire_mn,
			
			
		execDONE => execDONE,

		CNTbyte2 => CNTbyte2
			
		);
  
	validator_comp: validator
	Port map(
		clk => clk,
		ce => wire_cbits(0),
		reset => wire_cbits(1),
		flush => wire_cbits(2),
		idx => wire_idx,

		m => wire_m,
		n => wire_n,
		mn => wire_mn,

		check_end => wire_endd,
		colerror => wire_cerror,
		linerror => wire_lerror,
		regerror => wire_rerror,
		error => wire_error,
		linele => wire_lle,
		linece => wire_lce,
		regle => wire_rle,
		regce => wire_rce,
		colle => wire_cle,
		colce => wire_cce,
		
		lin => wire_line,
		col => wire_col
	);

  
  
	memwriter: mem_writer
	port map(
		clk	=> clk,
		rst	=> rst,
		enable   => wire_enable,
		colerror => wire_cerror,
		linerror => wire_lerror,
		regerror => wire_rerror,
		error => wire_error,
		linele => wire_lle,
		linece => wire_lce,
		regle => wire_rle,
		regce => wire_rce,
		colle => wire_cle,
		colce => wire_cce,
		
		lin => wire_line,
		col => wire_col,

		WRenable   => WRenable,
		WRdata => WRdata
	);


-- CLOCK_DIV
	clk1: clkdiv
	port map (
		clk => clk,
		clkout => clkd
	);

	clks <= clkd;

-- MEMORIAS DEBUG

	memin: memsdata
	port map ( 
         dataFROMmemIN  => RDdata,
         addressRDmemIN => RDaddrCIR,
         dataTOmemIN    =>"0000",
         enableWRmemIN  =>'0',
         CLK  => CLK
      );

	memoria_saida_na_fpga : RAMB16_S4_S36
    port map (
      DOA   => open,                    -- Port A 4-bit Data Output
      DOB   => memout,                  -- Port B 32-bit Data Output
      DOPB  => open,                    -- Port B 4-bit Parity Output
      ADDRA => "000000000000",         -- Port A 12-bit Address InputWRaddrCIR
      ADDRB => WRaddrCIR,              -- Port B 9-bit Address Input
      CLKA  => CLK,                     -- Port A Clock
      CLKB  => CLK,                     -- Port B Clock
      DIA   => "0000",                  -- Port A 4-bit Data Input
      DIB   => WRdata,
      DIPB  => "0000",                  -- Port-B 4-bit parity Input
      ENA   => '1',                     -- Port A RAM Enable Input
      ENB   => '1',                     -- Port B RAM Enable Input
      SSRA  => '0',                     -- Port A Synchronous Set/Reset Input
      SSRB  => '0',                     -- Port B Synchronous Set/Reset Input
      WEA   => '0',                     -- Port A Write Enable Input
      WEB   => WRenable                 -- Port B Write Enable Input
      );

end beahvioral;
