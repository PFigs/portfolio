----------------------------------------------------------------------------------
-- Instituto Superior TÃ©cnico 
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

entity verifier is
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
end verifier;

architecture Behavioral of verifier is
	signal wire_error: std_logic;
	signal wire_zero: std_logic_vector (width-1 downto 0);
	signal wire_cetemp: std_logic_vector(width-1 downto 0);
	signal wire_retemp: std_logic;
	signal wire_used : std_logic_vector( width-1 downto 0 );
	signal wire_aux : std_logic_vector (width-1 downto 0);
	signal wire_pos_in : std_logic_vector (2*line_bits-1 downto 0);
	signal wire_pos : std_logic_vector (2*line_bits-1 downto 0);
	signal wire_rout: r_array(0 to width-1);
begin

	wire_aux <= enable_bus;
	
	-- vector with 0s on missing numbers
	bitvector: for i in 0 to width-1 generate
		bitvector:regp
		generic map ( bits => 1 )
		port map (
			clk=>clk,
			ce => wire_cetemp(i),
			r => wire_retemp,
			p(0) => '1',
			q(0) => wire_used(i)
		);
	end generate bitvector;

		
	-- array com colunas e linhas da primeira aparicao de um número
	positionarray: for i in 0 to width-1 generate
		wire_cetemp(i) <= wire_aux(i) and ce and not wire_error;
		positionarray:regp
			generic map ( bits => 2*line_bits )
			port map (
				clk=>clk,
				ce=> wire_cetemp(i),
				r => wire_retemp,
				p => wire_pos_in,
				q => wire_rout(i)
			);
	end generate positionarray;
		
		wire_zero <= (others => '0');
		
		wire_retemp <= reset or flush;
	
		error <= wire_error;
		wire_error <= '0' when (wire_used and wire_aux) = wire_zero
					else '1';
		
		wire_pos_in(2*line_bits-1 downto line_bits) <= l_i;
		wire_pos_in(line_bits-1 downto 0) <= c_i;
		
		wire_pos <= wire_rout(conv_integer('0'&idx));
		l_e <= wire_pos(2*line_bits-1 downto line_bits);
		c_e <= wire_pos(line_bits-1 downto 0);
		
end Behavioral;