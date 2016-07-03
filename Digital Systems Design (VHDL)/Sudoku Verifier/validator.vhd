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
library UNISIM;
use ieee.numeric_std.all;
use UNISIM.Vcomponents.all;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use WORK.PSDLIB.ALL;

entity validator is
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
end validator;

architecture Behavioral of validator is
	signal wire_lic : std_logic_vector(line_bits-1 downto 0);
	signal wire_cic : std_logic_vector(line_bits-1 downto 0);
	signal wire_lel : std_logic_vector(line_bits-1 downto 0);
	signal wire_cel : std_logic_vector(line_bits-1 downto 0);
	signal wire_aux : std_logic_vector(width-1 downto 0);
	signal wire_lineflush: std_logic;
	signal wire_regionflush: std_logic;
	signal wire_colflush: std_logic;
	signal wire_lineoverflow: std_logic;
	signal wire_coloverflow: std_logic;
	signal wire_regoverflow: std_logic;
	signal wire_linerror: std_logic;
	signal wire_regerror: std_logic;
	signal wire_colerror: std_logic;
	signal wire_colce: std_logic_vector(width-1 downto 0);
	signal wire_countce: std_logic;
	signal wire_regionenable: std_logic_vector(MAXN-1 downto 0);
	signal wire_colerrortmp: std_logic_vector (width-1 downto 0);
	signal wire_enable: std_logic_vector (width-1 downto 0);
	signal wire_regerrortmp: std_logic_vector (MAXN-1 downto 0);
	signal wire_regposerror: std_logic_vector(2*line_bits-1 downto 0);
	signal wire_colposerror: std_logic_vector(2*line_bits-1 downto 0);
	signal wire_colout: r_array(0 to width-1);
	signal wire_regionout: r_array(0 to MAXN-1);
	signal wire_resetflush: std_logic;
	signal wire_nreg : std_logic_vector(line_bits-1 downto 0);
	

begin



	-- decoder with enable for every bit
	decode: verifier_decoder
		port map (
			idx => idx,
			en => wire_enable
		);


	wire_resetflush <= reset or flush;

	wire_countce <= wire_coloverflow and ce;
	linecnt: counter
	port map( 
		CLK => clk,
		CLR => wire_resetflush,
		ce => wire_countce,
		limit => mn,
		Q => wire_lic,
		overflow => wire_lineoverflow
	);
	
	
	colcnt: counter
	port map(
		clk => clk,
		ce => ce,
		clr => wire_resetflush,
		limit => mn,
		Q => wire_cic,
		overflow => wire_coloverflow
	);
	
	lin <= wire_lic;
	col <= wire_cic;
	
	-- line verifier
	wire_lineflush <= wire_coloverflow or flush or reset;
	line: verifier
		port map(
		 clk => clk,
		 ce => ce,
		 enable_bus => wire_enable,
		 reset => wire_resetflush,
		 flush => wire_lineflush,
		 idx => idx,
		 l_i => wire_lic,
		 c_i => wire_cic,
		 
		 error => wire_linerror,
		 l_e => wire_lel,
		 c_e => wire_cel
		);
		
		-- decoder with enable for every number
		decoder: verifier_decoder
			port map (
				idx => wire_cic,
				en => wire_aux
			);


		regdecoder: region_decoder
			port map (
				clk => clk,
				ce => ce,
				reset => wire_resetflush,
				m => m,
				n => n,
				overflow => wire_regoverflow,
				nreg => wire_nreg,
				q => wire_regionenable
		);
		-- vector with 0s on missing numbers
		wire_colflush <= (wire_coloverflow and wire_lineoverflow) or flush or reset;
		colverifiers: for i in 0 to width-1 generate
			wire_colce(i) <= wire_aux(i) and ce;
			col:verifier
			port map(
			 clk => clk,
			 ce => wire_colce(i),
			 reset => wire_resetflush,
			 enable_bus => wire_enable,
			 flush => wire_colflush,
			 idx => idx,
			 l_i => wire_lic,
			 c_i => wire_cic,
			 
			 error => wire_colerrortmp(i),
			 l_e => wire_colout(i)(2*line_bits-1 downto line_bits),
			 c_e => wire_colout(i)(line_bits-1 downto 0)
			);
		end generate colverifiers;



		-- vector with 0s on missing numbers
		wire_regionflush <= wire_regoverflow or flush or reset;
		regionverifiers: for i in 0 to MAXN-1 generate
			region:verifier
			port map(
			 clk => clk,
			 ce => wire_regionenable(i),
			 reset => wire_resetflush,
			 enable_bus => wire_enable,
			 flush => wire_regionflush,
			 idx => idx,
			 l_i => wire_lic,
			 c_i => wire_cic,
			 
			 error => wire_regerrortmp(i),
			 l_e => wire_regionout(i)(2*line_bits-1 downto line_bits),
			 c_e => wire_regionout(i)(line_bits-1 downto 0)
			);
		end generate regionverifiers;




		wire_colerror <= wire_colerrortmp(conv_integer('0'&wire_cic));
		wire_regerror <= wire_regerrortmp(conv_integer('0'&wire_nreg));
		error <= wire_linerror or wire_colerror or wire_regerror;
		colerror <= wire_colerror;
		linerror <= wire_linerror;
		regerror <= wire_regerror;
		
		linele <= wire_lel;
		linece <= wire_cel;
		
		wire_colposerror <= wire_colout(conv_integer('0'&wire_cic));
		colle <= wire_colposerror(2*line_bits-1 downto line_bits);
		colce <= wire_colposerror(line_bits-1 downto 0);
		
		wire_regposerror <= wire_regionout(conv_integer('0'&wire_nreg));
		regle <= wire_regposerror(2*line_bits-1 downto line_bits);
		regce <= wire_regposerror(line_bits-1 downto 0);
		
		
		check_end <= wire_lineoverflow and wire_coloverflow and wire_regoverflow;
		
end Behavioral;

