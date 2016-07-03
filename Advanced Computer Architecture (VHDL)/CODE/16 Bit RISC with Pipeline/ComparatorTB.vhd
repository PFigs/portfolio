--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:27:41 06/01/2010
-- Design Name:   
-- Module Name:   G:/AAC/AACcarryloockahead/CARRYLOOCKAHEAD/ComparatorTB.vhd
-- Project Name:  CARRYLOOCKAHEAD
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Comparator3b
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
USE ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
 
ENTITY ComparatorTB IS
END ComparatorTB;
 
ARCHITECTURE behavior OF ComparatorTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Comparator3b
    PORT(
         I0 : IN  std_logic_vector(2 downto 0);
         I1 : IN  std_logic_vector(2 downto 0);
         Z : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal I0 : std_logic_vector(2 downto 0) := (others => '0');
   signal I1 : std_logic_vector(2 downto 0) := (others => '0');

 	--Outputs
   signal Z : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Comparator3b PORT MAP (
          I0 => I0,
          I1 => I1,
          Z => Z
        );
 

   stim_proc: process
   begin		


          I0  <= "010";
          I1  <= "110";
          wait for 100ns;


          I0  <= "111";
          I1  <= "110";
          wait for 100ns;


          I0  <= "010";
          I1  <= "111";
          wait for 100ns;


          I0  <= "010";
          I1  <= "010";
          wait for 100ns;


      wait;
   end process;

END;
