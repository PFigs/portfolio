--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   01:44:28 05/21/2011
-- Design Name:   
-- Module Name:   /home/silva/Documents/Dropbox/IST/5 Ano/2 Semestre/PSD/Laboratorios/Lab 3/debug/sudoku_mem/tb_controlo.vhd
-- Project Name:  sudoku_mem
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
 
ENTITY tb_controlo IS
END tb_controlo;
 
ARCHITECTURE behavior OF tb_controlo IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT control
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         RDaddrCIR : OUT  std_logic_vector(8 downto 0);
         RDdata : IN  std_logic_vector(31 downto 0);
         WRaddrCir : OUT  std_logic_vector(8 downto 0);
         WRenable : OUT  std_logic;
         canSTART : IN  std_logic;
         endd : IN  std_logic;
         error : IN  std_logic;
         cbits : OUT  std_logic_vector(5 downto 0);
         idx : OUT  std_logic_vector(4 downto 0);
         m : OUT  std_logic_vector(2 downto 0);
         n : OUT  std_logic_vector(2 downto 0);
         mn : OUT  std_logic_vector(4 downto 0);
         execDONE : OUT  std_logic;
         CNTbyte2 : IN  std_logic_vector(11 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal RDdata : std_logic_vector(31 downto 0) := (others => '0');
   signal canSTART : std_logic := '0';
   signal endd : std_logic := '0';
   signal error : std_logic := '0';
   signal CNTbyte2 : std_logic_vector(11 downto 0) := (others => '0');

 	--Outputs
   signal RDaddrCIR : std_logic_vector(8 downto 0);
   signal WRaddrCir : std_logic_vector(8 downto 0);
   signal WRenable : std_logic;
   signal cbits : std_logic_vector(5 downto 0);
   signal idx : std_logic_vector(4 downto 0);
   signal m : std_logic_vector(2 downto 0);
   signal n : std_logic_vector(2 downto 0);
   signal mn : std_logic_vector(4 downto 0);
   signal execDONE : std_logic;

   -- Clock period definitions
   constant clk_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: control PORT MAP (
          clk => clk,
          rst => rst,
          RDaddrCIR => RDaddrCIR,
          RDdata => RDdata,
          WRaddrCir => WRaddrCir,
          WRenable => WRenable,
          canSTART => canSTART,
          endd => endd,
          error => error,
          cbits => cbits,
          idx => idx,
          m => m,
          n => n,
          mn => mn,
          execDONE => execDONE,
          CNTbyte2 => CNTbyte2
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
		rst <= '1', '0' after 40 ns;
      -- insert stimulus here
		canstart <= '0','1' after 60 ns;

      wait;
   end process;

END;
