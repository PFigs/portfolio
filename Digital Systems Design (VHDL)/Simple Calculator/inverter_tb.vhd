--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:35:48 03/06/2011
-- Design Name:   
-- Module Name:   C:/Users/martim camacho/Documents/My Dropbox/IST/PSD/Laboratorios/Lab 1/Codigo/Calculadora/inverter_tb.vhd
-- Project Name:  Calculadora
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: inverter
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
 
ENTITY inverter_tb IS
END inverter_tb;
 
ARCHITECTURE behavior OF inverter_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT inverter
    PORT(
         a : IN  std_logic_vector(7 downto 0);
         z : OUT  std_logic_vector(7 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal a : std_logic_vector(7 downto 0) := (others => '0');

 	--Outputs
   signal z : std_logic_vector(7 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: inverter PORT MAP (
          a => a,
          z => z
        );

   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      -- insert stimulus here

		a <= "00000000", "00010101" after 200 ns;

      wait;
   end process;

END;
