----------------------------------------------------------------------------------
-- Instituto Superior Técnico 
-- 
-- Projecto Sistemas Digitais
-- 
-- Martim Camacho (56755)
-- Pedro Silva, pedro.silva@ist.utl.pt (58035)
-- 
----------------------------------------------------------------------------------

library IEEE;
library UNISIM;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use UNISIM.Vcomponents.all;

package psdlib is
	constant cbits_size : integer := 2; -- bits de controlo
				 	  -- (1 downto 0) -- 00 => E1
									  -- 01 => E2
									  -- 11 => E3
									  
	constant idx_size : integer := 5; --endereco memorias
	constant addr_size : integer := 9; --endereco memorias

component memsdata is
  port ( 
         addrA : in  std_logic_vector(8 downto 0);
         addrB : in  std_logic_vector(8 downto 0);
         addrC : in  std_logic_vector(8 downto 0);
         addrD : in  std_logic_vector(8 downto 0);
         addrE : in  std_logic_vector(8 downto 0);
         addrF : in  std_logic_vector(8 downto 0);
         doA   : out std_logic_vector(31 downto 0);
         doB   : out std_logic_vector(31 downto 0);
         doC   : out std_logic_vector(31 downto 0);
         doD   : out std_logic_vector(31 downto 0);
         doE   : out std_logic_vector(31 downto 0);
         doF   : out std_logic_vector(31 downto 0);
         clk  : in  std_logic
       );
end component;



component disp7 is
    port(
      disp4   : in  std_logic_vector(3 downto 0);
      disp3   : in  std_logic_vector(3 downto 0);
      disp2   : in  std_logic_vector(3 downto 0);
      disp1   : in  std_logic_vector(3 downto 0);
      clk     : in  std_logic;
      en_disp : out std_logic_vector(4 downto 1);
      segm    : out std_logic_vector(7 downto 0)
      );
end component;



component clkdiv is
  port (
    clk                       : in  std_logic;
    clk50M, clk10Hz, clk_disp : out std_logic
    );
end component;




component regp is
	 generic (N: integer:=32);
    Port ( clk : in  STD_LOGIC;
	 		  clear: in std_logic;
           p : in  STD_LOGIC_VECTOR (N-1 downto 0);
           q : out  STD_LOGIC_VECTOR (N-1 downto 0)
			);
end component;


component adder is
	generic (N : integer := 32);
    Port ( a : in  STD_LOGIC_VECTOR (N-1 downto 0);
           b : in  STD_LOGIC_VECTOR (N-1 downto 0);
           sel : in  STD_LOGIC;
           z : out  STD_LOGIC_VECTOR (N-1 downto 0)
	);
end component;


component datapath is
	Port (	clk		: in	STD_LOGIC;
			clear	: in	STD_LOGIC;
			idx		: in	STD_LOGIC_VECTOR(addr_size-1 downto 0);
			cbits	: in	std_logic_vector (cbits_size-1 downto 0); -- bits controlo
			outi	: out	STD_LOGIC_VECTOR (31 downto 0)
			);
end component;


component control is
	Port(	clk		: in	STD_LOGIC;
			rst		: in	STD_LOGIC;
			cbits	: out	STD_LOGIC_VECTOR(cbits_size-1 downto 0);
			clear	: out	STD_LOGIC;
			idx		: out	STD_LOGIC_VECTOR(addr_size-1 downto 0)
			);
end component;


component counterup is 
  port (clk, clr, count : in std_logic; 
        q : out std_logic_vector (idx_size-1 downto 0)); 
end component;


--component  is
--port ();
--end component;


end package psdlib;

