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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY teste_urisc IS
END teste_urisc;
 
ARCHITECTURE behavior OF teste_urisc IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT uRisc
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         EN : IN  std_logic;
         EN_PC : IN  std_logic;
         EN_IF_REG : IN  std_logic;
         EN_ID_REG : IN  std_logic;
         EN_EX_REG : IN  std_logic;
			START_PC  : IN  std_logic;
			START_IF  : IN  std_logic;
			START_ID  : IN  std_logic;
			START_EX  : IN  std_logic;
         RDF : IN  std_logic;
         WRF : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal EN : std_logic := '0';
   signal EN_PC : std_logic := '0';
   signal EN_IF_REG : std_logic := '0';
   signal EN_ID_REG : std_logic := '0';
   signal EN_EX_REG : std_logic := '0';
   signal START_PC  : std_logic := '0';
   signal START_IF  : std_logic := '0';
   signal START_ID  : std_logic := '0';
   signal START_EX  : std_logic := '0';
   signal RDF : std_logic := '0';
   signal WRF : std_logic := '0';

	constant period : time := 500ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: uRisc PORT MAP (
          CLK => CLK,
          RST => RST,
          EN => EN,
          EN_PC => EN_PC,
          EN_IF_REG => EN_IF_REG,
          EN_ID_REG => EN_ID_REG,
          EN_EX_REG => EN_EX_REG,
          START_PC => START_PC,
          START_IF => START_IF,
          START_ID => START_ID,
          START_EX => START_EX,
          RDF => RDF,
          WRF => WRF
        );
 
   clock :process
   begin
		CLK <= '0';
		wait for period/2;
		CLK <= '1';
		wait for period/2;
   end process;
 
   enable_PC :process
	VARIABLE i: integer:=2;
   begin
			if i>1 then
				wait until (START_PC = '1');
				i:=0;
			end if;
			EN_PC <= '1';
			wait for period/2;
			EN_PC <= '0';
			wait for period/2;
   end process;
 
	enable_IF :process
	VARIABLE i: integer:=2;
   begin
			if i>1 then
				wait until (START_IF = '1');
				i:=0;
			end if;
			EN_IF_REG <= '1';
			wait for period/2;
			EN_IF_REG <= '0';
			wait for period/2;
   end process;
 
 
	enable_ID :process
	VARIABLE i: integer:=2;
   begin
			if i>1 then
				wait until (START_ID = '1');
				i:=0;
			end if;
			EN_ID_REG <= '1';
			wait for period/2;
			EN_ID_REG <= '0';
			wait for period/2;
   end process;
 
	enable_EX :process
	VARIABLE i: integer:=2;
   begin
			if i>1 then
				wait until (START_EX = '1');
				i:=0;
			end if;
			EN_EX_REG <= '1';
			wait for period/2;
			EN_EX_REG <= '0';
			wait for period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin
		RDF <= '1','0' after 2*period;
		--WRF <= '0','1' after 1050 ns;
		RST <= '1','0' after 2*period;
		START_IF <= '0','1' after 3*period+period/4;
		START_ID <= '0','1' after 3*period+period/4+period;
		START_EX <= '0','1' after 3*period+period/4+2*period;
		START_PC <= '0','1' after 3*period+period/4+3*period;
		wait;
   end process;

END;
