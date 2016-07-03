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

ENTITY teste_BDU IS
END teste_BDU;
 
ARCHITECTURE behavior OF teste_BDU IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BDU
    PORT(
         NEXTPC 		: IN  std_logic_vector(15 downto 0);
         OFFSET 		: IN  std_logic_vector(15 downto 0);
         OPB_ID 		: IN  std_logic_vector(15 downto 0);
         OPB_EX_MEM 	: IN  std_logic_vector(15 downto 0);
         OPB_EX_ALU 	: IN  std_logic_vector(15 downto 0);
         OPCODE_ID 	: IN  std_logic_vector(15 downto 0);
         OPCODE_EX 	: IN  std_logic_vector(15 downto 0);
         FLAGS 		: IN  std_logic_vector(3 downto 0);
			----
         TOIFMUX : OUT  std_logic_vector(15 downto 0);
         TOIFSEL : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal NEXTPC : std_logic_vector(15 downto 0) := (others => '0');
   signal OFFSET : std_logic_vector(15 downto 0) := (others => '0');
   signal OPB_ID : std_logic_vector(15 downto 0) := (others => '0');
   signal OPB_EX_MEM : std_logic_vector(15 downto 0) := (others => '0');
   signal OPB_EX_ALU : std_logic_vector(15 downto 0) := (others => '0');
   signal OPCODE_ID : std_logic_vector(15 downto 0) := (others => '0');
   signal OPCODE_EX : std_logic_vector(15 downto 0) := (others => '0');
   signal FLAGS : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal TOIFMUX : std_logic_vector(15 downto 0);
   signal TOIFSEL : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BDU PORT MAP (
          NEXTPC => NEXTPC,
          OFFSET => OFFSET,
          OPB_ID => OPB_ID,
          OPB_EX_MEM => OPB_EX_MEM,
          OPB_EX_ALU => OPB_EX_ALU,
          OPCODE_ID => OPCODE_ID,
          OPCODE_EX => OPCODE_EX,
          FLAGS => FLAGS,
          TOIFMUX => TOIFMUX,
          TOIFSEL => TOIFSEL
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 

   -- Stimulus process
   stim_proc: process
   begin		
		NEXTPC <= X"0001";
      OFFSET <= X"0001";
      OPB_ID <= X"0005";
      OPB_EX_MEM <= X"000F";
      OPB_EX_ALU <= X"000A";
      OPCODE_ID <= X"3807",x"0000" after 700 ns;
      OPCODE_EX <= x"B800",
			x"0000" after 100 ns,
			x"0807" after 200 ns,
			x"BAA7" after 300 ns,
			x"AAA7" after 400 ns,
			x"BAE7" after 500 ns,
			x"AAA3" after 600 ns;
      FLAGS <= "1111";
		wait;
   end process;

END;
