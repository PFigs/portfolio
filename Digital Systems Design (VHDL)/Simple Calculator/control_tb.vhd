--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:11:18 03/08/2011
-- Design Name:   
-- Module Name:   /home/silva/Documents/Dropbox/IST/5 Ano/2 Semestre/PSD/Laboratorios/Lab 1/Codigo/Calculadora/control_tb.vhd
-- Project Name:  Calculadora
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: control
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
 
ENTITY control_tb IS
END control_tb;
 
ARCHITECTURE behavior OF control_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT control
    PORT(
         clk : IN  std_logic;
         oper : IN  std_logic_vector(3 downto 0);
         leds : OUT  std_logic_vector(5 downto 0);
         rst : OUT  std_logic;
         cbits : OUT  std_logic_vector(4 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal oper : std_logic_vector(3 downto 0) := (others => '0');

 	--Outputs
   signal leds : std_logic_vector(5 downto 0);
   signal rst : std_logic;
   signal cbits : std_logic_vector(4 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: control PORT MAP (
          clk => clk,
          oper => oper,
          leds => leds,
          rst => rst,
          cbits => cbits
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

      wait for clk_period*10;
      -- insert stimulus here
      oper <= "1111", "0100" after 100 ns, "0100" after 150 ns, "0000" after 200 ns, "0101" after 250 ns, "0010" after 350 ns, "0000" after 400 ns; -- +=-= 

      wait;
   end process;

END;
