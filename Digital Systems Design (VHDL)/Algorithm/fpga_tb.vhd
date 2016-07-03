----------------------------------------------------------------------------------
-- Instituto Superior Técnico 
-- 
-- Projecto Sistemas Digitais
-- 
-- Martim Camacho, martim.camacho@ist.utl.pt (56755)
-- Pedro Silva, pedro.silva@ist.utl.pt (58035)
-- 
----------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 

ENTITY fpga_tb IS
END fpga_tb;
 
ARCHITECTURE behavior OF fpga_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT fpga
    PORT(
         clk : IN  std_logic;
         reset : IN  std_logic;
         data : OUT  std_logic_vector(31 downto 0);
         idx : OUT  std_logic_vector(8 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal data : std_logic_vector(31 downto 0);
   signal idx : std_logic_vector(8 downto 0);

   -- Clock period definitions
   constant clk_period : time := 19 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: fpga PORT MAP (
          clk => clk,
          reset => reset,
          data => data,
          idx => idx
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      reset <= '1', '0' after clk_period/2;     
      wait;
   end process;


END;
