--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:55:34 05/11/2010
-- Design Name:   
-- Module Name:   C:/Xilinx/AAC/10.Maio/tadam/teste_ram.vhd
-- Project Name:  tadam
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: ram
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
 
ENTITY teste_ram IS
END teste_ram;
 
ARCHITECTURE behavior OF teste_ram IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT ram
    PORT(
         read_file : IN  std_logic;
         write_file : IN  std_logic;
         WE : IN  std_logic;
         clk : IN  std_logic;
         ADRESS : IN  std_logic_vector(15 downto 0);
         DATA : IN  std_logic_vector(15 downto 0);
         Q : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal read_file : std_logic := '0';
   signal write_file : std_logic := '0';
   signal WE : std_logic := '0';
   signal clk : std_logic := '0';
   signal ADRESS : std_logic_vector(15 downto 0) := (others => '0');
   signal DATA : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal Q : std_logic_vector(15 downto 0);

   -- Clock period definitions
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: ram PORT MAP (
          read_file => read_file,
          write_file => write_file,
          WE => WE,
          clk => clk,
          ADRESS => ADRESS,
          DATA => DATA,
          Q => Q
        );


 

   -- Stimulus process
   stim_proc: process
   begin		
      -- insert stimulus here 
		read_file <= '1';
		write_file <= '0';
		ADRESS <= (X"0000");
		DATA <= (X"0000");
      WE <= '0';
      clk <= '0', '1' after 500 ns;
      wait;
   end process;

END;
