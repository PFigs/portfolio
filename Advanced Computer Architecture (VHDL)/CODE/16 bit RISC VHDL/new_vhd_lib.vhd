----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:37:44 04/17/2010 
-- Design Name: 
-- Module Name:    new_vhd_lib - Behavioral 
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




package new_vhd_lib is

component full_add_1bit is
    port ( x : in  STD_LOGIC;
           y : in  STD_LOGIC;
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           sum : out  STD_LOGIC);
end component;

component full_add_16 is
    port ( x : in  STD_LOGIC_VECTOR (15 downto 0);
           y : in  STD_LOGIC_VECTOR (15 downto 0);
           cin : in  STD_LOGIC;
           cout : out  STD_LOGIC;
           overflow : out  STD_LOGIC;
           sum : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component Reg16 is
    Port ( CLK : in  STD_LOGIC;
           E : in  STD_LOGIC;
           R : in  STD_LOGIC;
           D : in  STD_LOGIC_VECTOR (15 downto 0);
           Q : out  STD_LOGIC_VECTOR (15 downto 0));
end component;

component Mux16 is
    Port ( I0 : in  STD_LOGIC_VECTOR (15 downto 0);
           I1 : in  STD_LOGIC_VECTOR (15 downto 0);
           O : out  STD_LOGIC_VECTOR (15 downto 0);
           S : in  STD_LOGIC);
end component;

component Mux8x1 is
    Port ( M0 : in  STD_LOGIC_VECTOR (15 downto 0);
           M1 : in  STD_LOGIC_VECTOR (15 downto 0);
           M2 : in  STD_LOGIC_VECTOR (15 downto 0);
           M3 : in  STD_LOGIC_VECTOR (15 downto 0);
           M4 : in  STD_LOGIC_VECTOR (15 downto 0);
           M5 : in  STD_LOGIC_VECTOR (15 downto 0);
           M6 : in  STD_LOGIC_VECTOR (15 downto 0);
           M7 : in  STD_LOGIC_VECTOR (15 downto 0);
           Z : out  STD_LOGIC_VECTOR (15 downto 0);
			  SEL : in  STD_LOGIC_VECTOR (2 downto 0));
end component;

component Decoder3x8 is
    Port ( D : in  STD_LOGIC_VECTOR (2 downto 0);
           Z : out  STD_LOGIC_VECTOR (7 downto 0));
end component;

--component  is
--port ();
--end component;

--component  is
--port ();
--end component;

--component  is
--port ();
--end component;

--component  is
--port ();
--end component;

--component  is
--port ();
--end component;

--component  is
--port ();
--end component;




end package new_vhd_lib;

