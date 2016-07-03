--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:59:48 05/23/2011
-- Design Name:   
-- Module Name:   /home/silva/Documents/Dropbox/IST/PSD_TEMP/debug/sudoku_mem/tb_circuito.vhd
-- Project Name:  sudoku_mem
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: circuito3
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY tb_circuito IS
END tb_circuito;
 
ARCHITECTURE behavior OF tb_circuito IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT circuito3
    PORT(
         CLK : IN  std_logic;
         RST : IN  std_logic;
         clks : OUT  std_logic;
         memout : OUT  std_logic_vector(31 downto 0);
         canSTART : IN  std_logic;
         execDONE : OUT  std_logic;
         CNTbyte2 : IN  std_logic_vector(11 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal CLK : std_logic := '0';
   signal RST : std_logic := '0';
   signal canSTART : std_logic := '0';
   signal CNTbyte2 : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal clks : std_logic;
   signal memout : std_logic_vector(31 downto 0);
   signal execDONE : std_logic;

   -- Clock period definitions
   constant CLK_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: circuito3 PORT MAP (
          CLK => CLK,
          RST => RST,
          clks => clks,
          memout => memout,
          canSTART => canSTART,
          execDONE => execDONE,
          CNTbyte2 => CNTbyte2
        );

   -- Clock process definitions
   CLK_process :process
   begin
		CLK <= '0';
		wait for CLK_period/2;
		CLK <= '1';
		wait for CLK_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		rst <= '1', '0' after 50 ns;
		canstart <= '0', '1' after 100 ns;

      -- insert stimulus here 

      wait;
   end process;

END;
