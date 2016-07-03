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
use WORK.PSDLIB.ALL;

entity datapath is
	generic (N : integer := 8);
    Port ( clk: in std_logic;
		   ent : in  STD_LOGIC_VECTOR (N-1 downto 0);
           res : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           oper: in STD_LOGIC_VECTOR (1 downto 0);
           enable : in STD_LOGIC_VECTOR (1 downto 0);
           data : out  STD_LOGIC_VECTOR (2*N-1 downto 0));
end datapath;

 architecture Behavioral of datapath is

	signal wire_muxreg, wire_alu, wire_reg1: std_logic_vector (N*2-1 downto 0);
	signal wire_reg2: std_logic_vector (N-1 downto 0);

begin

	-- MUX
	mux: process (res, oper, enable, wire_alu, ent)
	begin
	if res = '1' then
		wire_muxreg <= wire_alu;
		--wire_muxreg(N-1 downto 0) <= wire_alu(wire_alu'high downto 0);
		--wire_muxreg(N*2-1 downto N) <= (others => wire_alu(wire_alu'high));
	else
		wire_muxreg(N-1 downto 0) <= ent(ent'high downto 0);
		wire_muxreg(N*2-1 downto N) <= (others =>ent(ent'high));
	end if;
	end process;

	-- REG1 -- 16 bits
	process (clk)
		begin
		   if clk'event and clk='1' then  
			  if rst='1' then   
				 wire_reg1 <= ( others => '0');
			  elsif (enable(0)='1') then
				 wire_reg1 <= wire_muxreg;
			  end if;
		   end if;
	end process;
		
	-- REG2 -- 8 bits
	process (clk)
		begin
		   if clk'event and clk='1' then  
			  if rst='1' then   
				 wire_reg2 <= ( others => '0');
			  elsif (enable(1)='1') then
				 wire_reg2 <= ent;
			  end if;
		   end if;
	end process;

	-- Put inside ALU
		alu0: alu
			port map (
				a => wire_reg1 (N-1 downto 0),
				b => wire_reg2,
				sel => oper,
				z => wire_alu
			);

	-- Data select
	datasel: process (res, enable, wire_reg1, ent)
	begin
		if res = '1' and enable(0)='0' then
			-- show result
			data <= wire_reg1;
		elsif enable(1) = '1'  then	--00 -> ent 01 -> resultado 10 -> 'Ent Reg1'
			-- show REG1 & ENT
			data <= wire_reg1(N-1 downto 0) & ent(N-1 downto 0);
		else
			-- show ENT
			data(N-1 downto 0) <= ent(ent'high downto 0);
			data(N*2-1 downto N) <= (others =>ent(ent'high));
		end if;
	end process;

end Behavioral;

