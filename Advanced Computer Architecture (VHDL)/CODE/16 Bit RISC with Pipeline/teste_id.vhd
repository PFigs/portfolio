
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY teste_id IS
END teste_id;
 
ARCHITECTURE behavior OF teste_id IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Instruction_Decoding
    PORT(
         PC1 : IN  std_logic_vector(15 downto 0);
         OPCODE : IN  std_logic_vector(15 downto 0);
         EXTEND : OUT  std_logic_vector(15 downto 0);
         OPA : OUT  std_logic_vector(15 downto 0);
         OPB : OUT  std_logic_vector(15 downto 0);
         PC : OUT  std_logic_vector(15 downto 0);
         INST : OUT  std_logic_vector(15 downto 0);
         DATA : IN  std_logic_vector(15 downto 0);
         WC : IN  std_logic_vector(2 downto 0);
         CLK : IN  std_logic;
         RST : IN  std_logic;
         WE : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal PC1 : std_logic_vector(15 downto 0) := (others => '0');
   signal OPCODE : std_logic_vector(15 downto 0) := (others => '0');
   signal DATA : std_logic_vector(15 downto 0) := (others => '0');
   signal WC : std_logic_vector(2 downto 0) := (others => '0');
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal WE : std_logic := '0';

 	--Outputs
   signal EXTEND : std_logic_vector(15 downto 0);
   signal OPA : std_logic_vector(15 downto 0);
   signal OPB : std_logic_vector(15 downto 0);
   signal PC : std_logic_vector(15 downto 0);
   signal INST : std_logic_vector(15 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Instruction_Decoding PORT MAP (
          PC1 => PC1,
          OPCODE => OPCODE,
          EXTEND => EXTEND,
          OPA => OPA,
          OPB => OPB,
          PC => PC,
          INST => INST,
          DATA => DATA,
          WC => WC,
          CLK => CLK,
          RST => RST,
          WE => WE
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
   CLK <= not CLK after 25 ns;
   -- Stimulus process
   stim_proc: process
   begin
		
      DATA <= X"0001",
				  X"0002" after 400 ns,
				  X"0003" after 500 ns,
				  X"0004" after 600 ns,
				  X"0005" after 700 ns,
				  X"0006" after 800 ns,
				  X"0007" after 900 ns,
				  X"0008" after 1000 ns;
      
		WC   <=  "000",
				   "001" after 400 ns,
				   "010" after 500 ns,
				   "011" after 600 ns,
				   "100" after 700 ns,
				   "101" after 800 ns,
				   "110" after 900 ns,
				   "111" after 1000 ns;
      
		RST <= '1','0' after 200 ns;
      WE <= '1';

		OPCODE <= X"4007" after 1200 ns,--coloca R0 na saida em vez de R7
					 X"4807" after 1300 ns,--coloca R1 na saida em vez de R7
					 X"5007" after 1400 ns,--coloca R2 na saida em vez de R7
					 X"5807" after 1500 ns,--coloca R3 na saida em vez de R7
					 X"6007" after 1600 ns,--coloca R4 na saida em vez de R7
					 X"6807" after 1700 ns,--coloca R5 na saida em vez de R7
					 X"7007" after 1800 ns,--coloca R6 na saida em vez de R7
					 X"7807" after 1900 ns,--coloca R7 na saida em vez de R7
					 X"9003" after 2000 ns;--coloca R3 na saida em vez de R0

		
      wait;
   end process;

END;
