----------------------------------------------------------------------------------
-- Instituto Superior Técnico 
-- 
-- Projecto Sistemas Digitais
-- 
-- Martim Camacho ()
-- Pedro Silva, pedro.silva@ist.utl.pt (58035)
-- 
----------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;

package psdlib is

component alu is
	generic (N : integer := 8);
    Port ( a : in  STD_LOGIC_VECTOR (N-1 downto 0);
           b : in  STD_LOGIC_VECTOR (N-1 downto 0);
           sel : in  STD_LOGIC_VECTOR(1 downto 0);
           z : out  STD_LOGIC_VECTOR (2*N-1 downto 0));
end component;

component adder is
	generic (N : integer := 8);
    Port ( a : in  STD_LOGIC_VECTOR (N-1 downto 0);
           b : in  STD_LOGIC_VECTOR (N-1 downto 0);
           sel : in  STD_LOGIC;
           z : out  STD_LOGIC_VECTOR (N-1 downto 0));
end component;

component inverter is
	generic (N : integer := 8);
    Port ( a : in  STD_LOGIC_VECTOR (N-1 downto 0);
           z : out  STD_LOGIC_VECTOR (N-1 downto 0));
end component;


component multiplier is
	generic (N : integer := 8);
    Port ( a : in  STD_LOGIC_VECTOR (N-1 downto 0);
           b : in  STD_LOGIC_VECTOR (N-1 downto 0);
           z : out  STD_LOGIC_VECTOR ((N*2-1) downto 0));
end component;


component ffp is
    Port ( c : in  STD_LOGIC;
           d : in  STD_LOGIC;
           e : in  STD_LOGIC;
           q : out  STD_LOGIC);
end component;


component regp is
	 generic (N : integer := 8);
    Port ( c : in  STD_LOGIC;
           d : in  STD_LOGIC_VECTOR(N-1 downto 0);
           e : in  STD_LOGIC;
           q : out  STD_LOGIC_VECTOR(N-1 downto 0));
end component;


component control is
    Port (	clk : in  std_logic;
			oper : in  STD_LOGIC_VECTOR (3 downto 0);  -- Ask professor how to keep it generic
			leds   : out std_logic_vector(7 downto 0);
			rst   : out std_logic;
			cbits : out  STD_LOGIC_VECTOR (4 downto 0));
end component;

component datapath is
	generic (N : integer := 8);
    Port ( clk: in std_logic;
		     ent : in  STD_LOGIC_VECTOR (N-1 downto 0);
           res : in  STD_LOGIC;
           rst : in  STD_LOGIC;
           oper: in STD_LOGIC_VECTOR (1 downto 0);
           enable : in STD_LOGIC_VECTOR (1 downto 0);
           data : out  STD_LOGIC_VECTOR (2*N-1 downto 0));
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




--component  is
--port ();
--end component;


--component  is
--port ();
--end component;


--component  is
--port ();
--end component;




end package psdlib;

