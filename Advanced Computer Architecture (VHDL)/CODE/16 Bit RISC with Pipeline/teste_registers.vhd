--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   22:54:11 05/14/2010
-- Design Name:   
-- Module Name:   C:/Xilinx/AAC/10.Maio/tadam/teste_registers.vhd
-- Project Name:  tadam
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Registers
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
 
ENTITY teste_registers IS
END teste_registers;
 
ARCHITECTURE behavior OF teste_registers IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT Registers
    PORT(
         WPort : IN  std_logic_vector(15 downto 0);
         OPCODE : IN  std_logic_vector(15 downto 0);
         SELA : IN  std_logic_vector(2 downto 0);
         SELB : IN  std_logic_vector(2 downto 0);
         SelWB : IN  std_logic_vector(2 downto 0);
         RegA : OUT  std_logic_vector(15 downto 0);
         RegB : OUT  std_logic_vector(15 downto 0);
         Clock : IN  std_logic;
         Reset : IN  std_logic;
         WEnable : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal WPort : std_logic_vector(15 downto 0) := (others => '0');
   signal OPCODE : std_logic_vector(15 downto 0) := (others => '0');
   signal SELA : std_logic_vector(2 downto 0) := (others => '0');
   signal SELB : std_logic_vector(2 downto 0) := (others => '0');
   signal SelWB : std_logic_vector(2 downto 0) := (others => '0');
   signal Clock : std_logic := '0';
   signal Reset : std_logic := '0';
   signal WEnable : std_logic := '0';

 	--Outputs
   signal RegA : std_logic_vector(15 downto 0);
   signal RegB : std_logic_vector(15 downto 0);
 	constant period : time := 100ns;
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: Registers PORT MAP (
          WPort => WPort,
          OPCODE => OPCODE,
          SELA => SELA,
          SELB => SELB,
          SelWB => SelWB,
          RegA => RegA,
          RegB => RegB,
          Clock => Clock,
          Reset => Reset,
          WEnable => WEnable
        );
 
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
   clocks :process
   begin
		Clock <= '0';
		wait for period/2;
		Clock <= '1';
		wait for period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin
		 WPort <= X"0007";
       OPCODE <= "1100000001010101", "1100010101010101" after 400 ns;
       SELA <= "000";
       SELB <= "010";
       SelWB <= "000";
       Reset <= '1', '0' after 200 ns;
       WEnable <= '1';
      wait;
   end process;

END;
