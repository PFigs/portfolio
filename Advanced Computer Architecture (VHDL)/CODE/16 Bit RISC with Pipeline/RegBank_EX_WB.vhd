----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    01:31:08 05/04/2010 
-- Design Name: 
-- Module Name:    RegBank_EX_WB - Behavioral 
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
use work.gates.all;
use work.new_vhd_lib.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegBank_EX_WB is
    Port ( MEM : in  STD_LOGIC_VECTOR (15 downto 0);
           ALU : in  STD_LOGIC_VECTOR (15 downto 0);
           OPCODE : in  STD_LOGIC_VECTOR (15 downto 0);
			  WC : in   STD_LOGIC_VECTOR (2 downto 0);
           Z0 : out  STD_LOGIC_VECTOR (15 downto 0);
           Z1 : out  STD_LOGIC_VECTOR (15 downto 0);
           Z2 : out  STD_LOGIC_VECTOR (15 downto 0);
			  Z3 : out 	STD_LOGIC_VECTOR (2 downto 0);
           CLK : in  STD_LOGIC;
           E : in  STD_LOGIC;
           RST : in  STD_LOGIC);
end RegBank_EX_WB;

architecture Behavioral of RegBank_EX_WB is
signal wirebuffer : STD_LOGIC_VECTOR (15 downto 0);
begin

	KEEPER0: Reg16 port map(
		CLK => CLK,
      E   => E,
      R   => RST,
      D   => MEM,
      Q   => Z0
	);

	KEEPER1: Reg16 port map(
		CLK => CLK,
      E   => E,
      R   => RST,
      D   => ALU,
      Q   => Z1
	);

	KEEPER2: Reg16 port map(
		CLK => CLK,
      E   => E,
      R   => RST,
      D   => OPCODE,
      Q   => Z2
	);
	
	KEEPER3: Reg16 port map(
		CLK 				 => CLK,
      E   				 => E,
      R  				 => RST,
		D(15 downto 3)	 => "0000000000000",
      D( 2 downto 0)  => WC,
		Q 					 => wirebuffer
	);
	
	Z3 <= wirebuffer(2 downto 0);

end Behavioral;

