--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   03:13:31 05/12/2010
-- Design Name:   
-- Module Name:   C:/Xilinx/AAC/10.Maio/tadam/teste_mask.vhd
-- Project Name:  tadam
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: mask_addr
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
 
ENTITY teste_mask IS
END teste_mask;
 
ARCHITECTURE behavior OF teste_mask IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT mask_addr
    PORT(
         I : IN  std_logic_vector(15 downto 0);
         Z : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal I : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal Z : std_logic_vector(15 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: mask_addr PORT MAP (
          I => I,
          Z => Z
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name  

   -- Stimulus process
   stim_proc: process
   begin		

		I <= X"FFFF";
      -- insert stimulus here 

      wait;
   end process;

END;
