--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:51:48 05/20/2011
-- Design Name:   
-- Module Name:   /home/silva/Documents/Dropbox/IST/5 Ano/2 Semestre/PSD/Laboratorios/Lab 3/debug/sudoku_mem/tb_tester.vhd
-- Project Name:  sudoku_mem
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: tester
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
 
ENTITY tb_tester IS
END tb_tester;
 
ARCHITECTURE behavior OF tb_tester IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT tester
    PORT(
         m : OUT  std_logic_vector(2 downto 0);
         n : OUT  std_logic_vector(2 downto 0);
         mn : OUT  std_logic_vector(5 downto 0);
         clk : IN  std_logic;
         rst : IN  std_logic;
         en : IN  std_logic;
         rdata : IN  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal en : std_logic := '0';
   signal rdata : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal m : std_logic_vector(2 downto 0);
   signal n : std_logic_vector(2 downto 0);
   signal mn : std_logic_vector(5 downto 0);

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: tester PORT MAP (
          m => m,
          n => n,
          mn => mn,
          clk => clk,
          rst => rst,
          en => en,
          rdata => rdata
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
      -- hold reset state for 100 ns.
      rst <= '1', '0' after 100 ns;
      rdata <= X"00040203",X"00070202" after 200 ns,X"00050401" after 211 ns;
      en<= '0', '1' after 120 ns, '0' after 160 ns, '1' after 200 ns, '0' after 220 ns;
      -- insert stimulus here 

      wait;
   end process;

END;
