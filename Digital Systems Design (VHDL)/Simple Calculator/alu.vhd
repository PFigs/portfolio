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
use WORK.PSDLIB.ALL;

entity alu is
	generic (N : integer := 8);
    Port ( a : in  STD_LOGIC_VECTOR (N-1 downto 0);
           b : in  STD_LOGIC_VECTOR (N-1 downto 0);
           sel : in  STD_LOGIC_VECTOR(1 downto 0);
           z : out  STD_LOGIC_VECTOR (2*N-1 downto 0));
end alu;

architecture Behavioral of alu is
	signal wire_outinv : STD_LOGIC_VECTOR (N -1 downto 0);
	signal wire_outadder: STD_LOGIC_VECTOR (N -1 downto 0);
	signal wire_outmul: STD_LOGIC_VECTOR (2*N -1 downto 0);
	signal wire_aluout: STD_LOGIC_VECTOR (2*N -1 downto 0);
begin

		-- Adder/Subtractor
		 as: adder 
			 generic map (8)
			 port map (
				a => a,
				b => b,
				sel => sel(0),
				z => wire_outadder
			 );
		
		-- Multiplier
		 mul: multiplier
			 generic map (8)
			 port map (
				a=>a,
				b=>b,
				z=>wire_outmul
			 );
		
		-- Inverter
		 invt: inverter
			 generic map (8)
			 port map (
				a => a,
				z => wire_outinv
			 );
			 
		z<=wire_aluout;
		
		process(sel, wire_outadder, wire_outmul, wire_outinv)
		begin
			-- Select output
			if sel = "00" or sel = "01" then
				wire_aluout(N-1 downto 0) <= wire_outadder;
				wire_aluout(2*N-1 downto N) <= (others => wire_outadder(wire_outadder'high));
			elsif sel = "11" then
				wire_aluout <= wire_outmul;
			else
				wire_aluout(N-1 downto 0) <= wire_outinv;
				wire_aluout(2*N-1 downto N) <= (others => wire_outinv(wire_outinv'high));
			end if;
		end process;
end Behavioral;

