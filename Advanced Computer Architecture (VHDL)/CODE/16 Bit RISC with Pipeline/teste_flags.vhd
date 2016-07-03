--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:20:04 05/18/2010
-- Design Name:   
-- Module Name:   /home/silva/Documents/Dropbox/IST/4 Ano/2º Semestre/AAC/Projecto/Parte II/Codigo/17.Maio/4/tadam/teste_flags.vhd
-- Project Name:  tadam
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Flag_Test
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
 
ENTITY teste_flags IS
END teste_flags;
 
ARCHITECTURE behavior OF teste_flags IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Flag_Test
    PORT(
         NEG : IN  std_logic;
         ZERO : IN  std_logic;
         OVERFLOW : IN  std_logic;
         CARRY : IN  std_logic;
         COND : IN  std_logic_vector(3 downto 0);
         OP : IN  std_logic_vector(1 downto 0);
         UNJUMP : IN  std_logic;
         ENABLE : IN  std_logic;
         SEL : IN  std_logic;
         Z : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal NEG : std_logic := '0';
   signal ZERO : std_logic := '0';
   signal OVERFLOW : std_logic := '0';
   signal CARRY : std_logic := '0';
   signal COND : std_logic_vector(3 downto 0) := (others => '0');
   signal OP : std_logic_vector(1 downto 0) := (others => '0');
   signal UNJUMP : std_logic := '0';
   signal ENABLE : std_logic := '0';
   signal SEL : std_logic := '0';

 	--Outputs
   signal Z : std_logic;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Flag_Test PORT MAP (
          NEG => NEG,
          ZERO => ZERO,
          OVERFLOW => OVERFLOW,
          CARRY => CARRY,
          COND => COND,
          OP => OP,
          UNJUMP => UNJUMP,
          ENABLE => ENABLE,
          SEL => SEL,
          Z => Z
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 

   -- Stimulus process
   stim_proc: process
   begin		

      -- insert stimulus here 
		-- 04FD
		NEG <= '0';
		ZERO <= '1','0' after 500 ns;
		
		COND <= "0101";
		OP <= "00";
		ENABLE <= '1';
      wait;
   end process;

END;
