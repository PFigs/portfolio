--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:22:39 06/07/2010
-- Design Name:   
-- Module Name:   /home/silva/Documents/Dropbox/workspace/Xilinx/tadam/teste_fdu.vhd
-- Project Name:  tadam
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: FDU
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
 
ENTITY teste_fdu IS
END teste_fdu;
 
ARCHITECTURE behavior OF teste_fdu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FDU
    PORT(
         FWD_WB : IN  std_logic_vector(15 downto 0);
         ID_OPA : IN  std_logic_vector(15 downto 0);
         ID_OPB : IN  std_logic_vector(15 downto 0);
         WB_INST : IN  std_logic_vector(15 downto 0);
         ID_INST : IN  std_logic_vector(15 downto 0);
         OPA : OUT  std_logic_vector(15 downto 0);
         OPB : OUT  std_logic_vector(15 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal FWD_WB : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_OPA : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_OPB : std_logic_vector(15 downto 0) := (others => '0');
   signal WB_INST : std_logic_vector(15 downto 0) := (others => '0');
   signal ID_INST : std_logic_vector(15 downto 0) := (others => '0');

 	--Outputs
   signal OPA : std_logic_vector(15 downto 0);
   signal OPB : std_logic_vector(15 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FDU PORT MAP (
          FWD_WB => FWD_WB,
          ID_OPA => ID_OPA,
          ID_OPB => ID_OPB,
          WB_INST => WB_INST,
          ID_INST => ID_INST,
          OPA => OPA,
          OPB => OPB
        );
 
   -- Stimulus process
   stim_proc: process
   begin		
      -- insert stimulus here 
		FWD_WB <= x"000f";
		ID_OPA <= x"0001";
		ID_OPB <= x"0002";
		WB_INST <= x"aa98", x"a969" after 200 ns;
		ID_INST <= x"a969", x"aa98" after 200 ns;
      wait;
   end process;

END;
