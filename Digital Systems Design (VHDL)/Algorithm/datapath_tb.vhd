--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:56:16 03/29/2011
-- Design Name:   
-- Module Name:   C:/Users/martim camacho/Documents/My Dropbox/IST/PSD/Laboratorios/Lab 2/Algoritmo/datapath_tb.vhd
-- Project Name:  Algoritmo
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: datapath
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
 
ENTITY datapath_tb IS
END datapath_tb;
 
ARCHITECTURE behavior OF datapath_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT datapath
    PORT(
         clk : IN  std_logic;
         cbits : IN  std_logic_vector(1 downto 0);
         idx : IN  std_logic_vector(8 downto 0);
         outi : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal cbits : std_logic_vector(1 downto 0) := (others => '0');
   signal idx : std_logic_vector(8 downto 0) := (others => '0');

 	--Outputs
   signal outi : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: datapath PORT MAP (
          clk => clk,
          cbits => cbits,
          idx => idx,
          outi => outi
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
      wait for 100 ns;	
 
      idx <= "000000000";
		cbits <= "00", "01" after 30 ns, "11" after 40 ns, "00" after 50 ns;

      wait;
   end process;

END;
