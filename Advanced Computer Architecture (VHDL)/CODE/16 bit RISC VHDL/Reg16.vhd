----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    16:17:13 04/15/2010 
-- Design Name: 
-- Module Name:    Reg16 - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use work.gates.all;

---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Reg16 is
    Port ( CLK : in  STD_LOGIC;
           E : in  STD_LOGIC;
           R : in  STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (15 downto 0);
           Q : out  STD_LOGIC_VECTOR (15 downto 0));
end Reg16;

architecture Reg16 of Reg16 is

begin
	FF_Out0 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(0),
		Q => Q(0)
	);

	FF_Out1 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(1),
		Q => Q(1)
	);

	FF_Out2 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(2),
		Q => Q(2)
	);

	FF_Out3 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(3),
		Q => Q(3)
	);

	FF_Out4 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(4),
		Q => Q(4)
	);
	
	FF_Out5 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(5),
		Q => Q(5)
	);
	
	FF_Out6 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(6),
		Q => Q(6)
	);

	FF_Out7 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(7),
		Q => Q(7)
	);

	FF_Out8 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(8),
		Q => Q(8)
	);
	
	FF_Out9 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(9),
		Q => Q(9)
	);
	
	FF_Out10 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(10),
		Q => Q(10)
	);
	
	FF_Out11 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(11),
		Q => Q(11)
	);

	FF_Out12 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(12),
		Q => Q(12)
	);
	
	FF_Out13 : ffe port map (
		CLK => CLK,
		Reset => R  ,
		Enable => E,
		D => D(13),
		Q => Q(13)
	);

	FF_Out14 : ffe port map (
		CLK => CLK,
		Reset => R ,
		Enable => E,
		D => D(14),
		Q => Q(14)
	);

	FF_Out15 : ffe port map (
		CLK => CLK,
		Reset => R ,
		Enable => E,
		D => D(15),
		Q => Q(15)
	);

end Reg16;

