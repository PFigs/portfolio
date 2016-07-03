--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   23:54:26 03/08/2011
-- Design Name:   
-- Module Name:   /home/silva/Documents/Dropbox/IST/5 Ano/2 Semestre/PSD/Laboratorios/Lab 1/Codigo/Calculadora/datapath_tb.vhd
-- Project Name:  Calculadora
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: datapath
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
 
ENTITY datapath_tb IS
END datapath_tb;
 
ARCHITECTURE behavior OF datapath_tb IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT datapath
    PORT(
         clk : IN  std_logic;
         ent : IN  std_logic_vector(7 downto 0);
         res : IN  std_logic;
         rst : IN  std_logic;
         oper : IN  std_logic_vector(1 downto 0);
         enable : IN  std_logic_vector(1 downto 0);
         lcout : OUT  std_logic;
         lneg : OUT  std_logic;
         data : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal ent : std_logic_vector(7 downto 0) := (others => '0');
   signal res : std_logic := '0';
   signal rst : std_logic := '0';
   signal oper : std_logic_vector(1 downto 0) := (others => '0');
   signal enable : std_logic_vector(1 downto 0) := (others => '0');

 	--Outputs
   signal lcout : std_logic;
   signal lneg : std_logic;
   signal data : std_logic_vector(15 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: datapath PORT MAP (
          clk => clk,
          ent => ent,
          res => res,
          rst => rst,
          oper => oper,
          enable => enable,
          lcout => lcout,
          lneg => lneg,
          data => data
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
      rst <= '1', '0' after 25 ns;
      ent <= "00000001", "00000001" after 300 ns;
      enable <= "01", "10" after 300 ns, "01" after 400 ns, "00" after 410 ns;
      oper <= "00", "01" after 500 ns;
      res <= '1' after 400 ns;

      wait;
   end process;

END;
