--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:35:43 03/02/2011
-- Design Name:   
-- Module Name:   C:/Users/martim camacho/Documents/My Dropbox/IST/PSD/Laboratorios/Lab 1/Codigo/Calculadora/regp_tb.vhd
-- Project Name:  Calculadora
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: regp
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
 
ENTITY regp_tb IS
END regp_tb;
 
ARCHITECTURE behavior OF regp_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT regp
    PORT(
         c : IN  std_logic;
         d : IN  std_logic_vector(7 downto 0);
         e : IN  std_logic;
         q : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal c : std_logic := '0';
   signal d : std_logic_vector(7 downto 0) := (others => '0');
   signal e : std_logic := '0';

 	--Outputs
   signal q : std_logic_vector(7 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   constant c_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: regp PORT MAP (
          c => c,
          d => d,
          e => e,
          q => q
        );

   -- Clock process definitions
   c_process :process
   begin
		c <= '0';
		wait for c_period/2;
		c <= '1';
		wait for c_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	

      wait for c_period*10;

		  d <= "00000000",
				 "00000011" after 50 ns,
				 "11111100" after 150 ns;
			
		  e <= '0',
				 '1' after 100 ns,
				 '0' after 200 ns;

      wait;
   end process;

END;
