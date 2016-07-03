----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:     
-- Design Name: 
-- Module Name:    cla_lib - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;

package cla_lib is



component A_block is
    Port ( a : in  STD_LOGIC;
           b : in  STD_LOGIC;
           c : in  STD_LOGIC;
           g : out  STD_LOGIC;
           p : out  STD_LOGIC;
           s : out  STD_LOGIC);
end component;



component B_block is
    Port ( Gij : in  STD_LOGIC;
           Pij : in  STD_LOGIC;
           Gj_i_k : in  STD_LOGIC;
           Pj_i_k : in  STD_LOGIC;
           Gik : out  STD_LOGIC;
           Pik : out  STD_LOGIC;
           Cin : in  STD_LOGIC;
           Cj1 : out  STD_LOGIC);
end component;




component Carry_Look_ahead is
    Port ( IN_A : in  STD_LOGIC_VECTOR (15 downto 0);
           IN_B : in  STD_LOGIC_VECTOR (15 downto 0);
           IN_C : in  STD_LOGIC;
           OUT_Q : out  STD_LOGIC_VECTOR (15 downto 0);
           OUT_C : out  STD_LOGIC;
			  OUT_C15:out  STD_LOGIC 
			  );
end component;


end package cla_lib;

