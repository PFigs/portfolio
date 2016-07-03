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

entity datapath is
    Port (	clk		: in  STD_LOGIC;
			clear	: in  STD_LOGIC;
			cbits	: in std_logic_vector (cbits_size-1 downto 0); -- bits controlo
			idx		: in std_logic_vector (addr_size-1 downto 0); -- bits controlo
			outi	: out  STD_LOGIC_VECTOR (31 downto 0)
         );
end datapath;

architecture Behavioral of datapath is
	signal wire_a : std_logic_vector(31 downto 0);
	signal wire_b : std_logic_vector(31 downto 0);
	signal wire_c : std_logic_vector(31 downto 0);
	signal wire_d : std_logic_vector(31 downto 0);
	signal wire_e : std_logic_vector(31 downto 0);
	signal wire_f : std_logic_vector(31 downto 0);
	signal wire_mula, wire_mulb, wire_mulrs :std_logic_vector(31 downto 0);
	signal wire_mulrs_tmp : std_logic_vector  (63 downto 0) ;
	signal wire_suba, wire_subb, wire_subrs, wire_subrs_tmp : std_logic_vector(31 downto 0);
	signal wire_mem_we : std_logic;
begin

-- DATA MEMORY
	MEMDATA : memsdata
		port map(
			addrA => idx,
			addrB => idx,
			addrC => idx,
			addrD => idx,
			addrE => idx,
			addrF => idx,
			doA   => wire_a,
			doB   => wire_b,
			doC   => wire_c,
			doD   => wire_d,
			doE   => wire_e,
			doF   => wire_f,
			clk  => clk
		);


-- INPUT DECISION
	-- MUX MUL INPUT
		wire_mula <= wire_e when cbits(0) ='0' else -- E1
						 wire_mulrs; -- E2&E3;
	 
		wire_mulb <= wire_b when cbits(1 downto 0) ="00" else -- E1
						 wire_f when cbits(1 downto 0) = "01" else -- E2
						 wire_subrs; -- WHEN CBITS(1 downto 0) = "11" -- E3
	
	-- MUX SUB INPUT
		wire_suba <= wire_c when cbits(0)='0' else -- E1
						 wire_a(31) & wire_a(31) & wire_a(31 downto 2); -- E2 & E3
						  
		wire_subb <= wire_d when cbits(0)='0' else -- E1
						 wire_subrs; -- E2 & E3

-- ARITHMETIC UNIT
	-- ADD/SUB
		addsub: adder
			port map (
				a => wire_suba,
				b => wire_subb,
				sel => cbits(0), -- 0 = c+d; 1 = a-(c+d);
				z => wire_subrs_tmp
			);

	-- MULT INIT
		wire_mulrs_tmp <= wire_mula * wire_mulb;

-- RESULT KEEPERS

	-- SUB
	subrs: regp
		port map(
			clk => clk,
			clear => clear,
			p => wire_subrs_tmp,
			q => wire_subrs
		);

	-- MUL
	mulrs: regp
		port map(
			clk => clk,
			clear => clear,
			p => wire_mulrs_tmp(31 downto 0),
			q => wire_mulrs
		);

-- OUTPUT MEMORY
	wire_mem_we <= cbits(1) and cbits(0);
	MEM_OUT : RAMB16_S36
		port map (ADDR  => idx,
			CLK	=> clk,
			DI	=> wire_mulrs_tmp(31 downto 0),
			DIP	=> x"0",
			EN	=> '1',
			SSR	=> '0',
			DO	=> outi,
			WE	=> wire_mem_we
		);

	
-- OBJECTIVO: FREQUENCIA

end Behavioral;

