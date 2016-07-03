--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   17:24:56 05/30/2010
-- Design Name:   
-- Module Name:   G:/AAC/AACcarryloockahead/CARRYLOOCKAHEAD/cla_full_add_16_TB.vhd
-- Project Name:  CARRYLOOCKAHEAD
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: cla_full_add_16
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
 
ENTITY cla_full_add_16_TB IS
END cla_full_add_16_TB;
 
ARCHITECTURE behavior OF cla_full_add_16_TB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT cla_full_add_16
    PORT(
         cin : IN  std_logic;
         x : IN  std_logic_vector(15 downto 0);
         y : IN  std_logic_vector(15 downto 0);
         sum : OUT  std_logic_vector(15 downto 0);
         cout : OUT  std_logic;
         overflow : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal cin : std_logic := '0';
   signal x : std_logic_vector(15 downto 0) := (others => '0');
   signal y : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal sum : std_logic_vector(15 downto 0);
   signal cout : std_logic;
   signal overflow : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: cla_full_add_16 PORT MAP (
          cin => cin,
          x => x,
          y => y,
          sum => sum,
          cout => cout,
          overflow => overflow
        );
 
   stim_proc: process
   begin		
		x <= ("1111111111111111");
		y <= ("0000000000000001");
		cin <='0';
		wait for 200ns;

		x <= ("0000000000000000");
		y <= ("0000000000000001");
		cin <='1';
		wait for 200ns;


		x <= ("1000000000000000");
		y <= ("1000000000000001");
		cin <='0';
		wait for 200ns;


		x <= ("1000000000000000");
		y <= ("1000000000000001");
		cin <='1';
		wait for 200ns;


		x <= ("0000000000000000");
		y <= ("0000000000000001");
		cin <='0';
		wait for 200ns;




		x <= ("0000000001100000");
		y <= ("0000010100000001");
		cin <='0';
		wait for 200ns;
		
		
		x <= ("0110000000000000");
		y <= ("0000001100000001");
		cin <='1';
		wait for 200ns;
   end process;

END;
