--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:21:16 05/30/2010
-- Design Name:   
-- Module Name:   G:/AAC/AACcarryloockahead/CARRYLOOCKAHEAD/TBCarryLoockAhead.vhd
-- Project Name:  CARRYLOOCKAHEAD
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Carry_Look_ahead
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
 
ENTITY TBCarryLoockAhead IS
END TBCarryLoockAhead;
 
ARCHITECTURE behavior OF TBCarryLoockAhead IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Carry_Look_ahead
    PORT(
         IN_A : IN  std_logic_vector(15 downto 0);
         IN_B : IN  std_logic_vector(15 downto 0);
         IN_C : IN  std_logic;
         OUT_Q : OUT  std_logic_vector(15 downto 0);
         OUT_C : OUT  std_logic;
         OUT_C15 : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal IN_A : std_logic_vector(15 downto 0) := (others => '0');
   signal IN_B : std_logic_vector(15 downto 0) := (others => '0');
   signal IN_C : std_logic := '0';

 	--Outputs
   signal OUT_Q : std_logic_vector(15 downto 0);
   signal OUT_C : std_logic;
   signal OUT_C15 : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Carry_Look_ahead PORT MAP (
          IN_A => IN_A,
          IN_B => IN_B,
          IN_C => IN_C,
          OUT_Q => OUT_Q,
          OUT_C => OUT_C,
          OUT_C15 => OUT_C15
        );
 

   stim_proc: process
		variable op : integer;
		variable aux : std_logic_vector(8 downto 6);

	begin		
		IN_A <= ("0000000000000000");
		IN_B <= ("0000000000000001");
		IN_C <='0';
		wait for 200ns;

		IN_A <= ("0000000000000000");
		IN_B <= ("0000000000000001");
		IN_C <='1';
		wait for 200ns;


		IN_A <= ("1000000000000000");
		IN_B <= ("1000000000000001");
		IN_C <='0';
		wait for 200ns;


		IN_A <= ("1000000000000000");
		IN_B <= ("1000000000000001");
		IN_C <='1';
		wait for 200ns;



			wait;
	end process;

END;
