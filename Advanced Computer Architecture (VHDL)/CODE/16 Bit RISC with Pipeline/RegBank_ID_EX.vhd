----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:43:37 05/03/2010 
-- Design Name: 
-- Module Name:    RegBank_ID_EX - Behavioral 
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

entity RegBank_ID_EX is
    Port ( PC     : in  STD_LOGIC_VECTOR (15 downto 0);
           OPA    : in  STD_LOGIC_VECTOR (15 downto 0);
           OPB    : in  STD_LOGIC_VECTOR (15 downto 0);
           SIGE   : in  STD_LOGIC_VECTOR (15 downto 0);
           OPCODE : in  STD_LOGIC_VECTOR (15 downto 0);
           Z0 		: out  STD_LOGIC_VECTOR (15 downto 0);
           Z1 		: out  STD_LOGIC_VECTOR (15 downto 0);
           Z2 		: out  STD_LOGIC_VECTOR (15 downto 0);
           Z3 		: out  STD_LOGIC_VECTOR (15 downto 0);
			  Z4 		: out  STD_LOGIC_VECTOR (15 downto 0);
			  CLK 	: in STD_LOGIC;
			  E		: in STD_LOGIC;
			  RST		: in STD_LOGIC);
end RegBank_ID_EX;

architecture Behavioral of RegBank_ID_EX is

begin

	-- Stores PC
	KEEPER0 : Reg16 port map(
		CLK => CLK,
      E   => E,
      R   => RST,
      D   => PC,
      Q   => Z0
	);
	
	-- Stores Operand A
	KEEPER1 : Reg16 port map(
		CLK => CLK,
      E   => E,
      R   => RST,
      D   => OPA,
      Q   => Z1
	);
	
	-- Stores Operand B
	KEEPER2 : Reg16 port map(
		CLK => CLK,
      E   => E,
      R   => RST,
      D   => OPB,
      Q   => Z2
	);
	
	-- Stores Signal Extend
	KEEPER3 : Reg16 port map(
		CLK => CLK,
      E   => E,
      R   => RST,
      D   => SIGE,
      Q   => Z3
	);
	
	-- Stores Destination Register
	KEEPER4 : Reg16 port map(
		CLK => CLK,
      E   => E,
      R   => RST,
      D   => OPCODE,
      Q   => Z4
	);

end Behavioral;

