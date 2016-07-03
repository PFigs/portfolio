----------------------------------------------------------------------------------
-- Instituto Superior Técnico 
-- 
-- Projecto Sistemas Digitais
-- 
-- Martim Camacho, martim.camacho@ist.utl.pt (56755)
-- Pedro Silva, pedro.silva@ist.utl.pt (58035)
-- 
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_SIGNED.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.PSDLIB.ALL;

entity counterup is 
  port (clk, clr, count : in std_logic; 
        q : out std_logic_vector (idx_size-1 downto 0)); 
end counterup; 
 
architecture archi of counterup is 
  signal tmp: std_logic_vector (idx_size-1 downto 0); 
begin 
  process (clk, clr) 
  begin 
    if (clr ='1') then 
      tmp <= (others => '0'); 
    elsif (clk'event and clk = '1') and count='1' then 
      tmp <= tmp + 1; 
    end if; 
  end process; 
  q <= tmp; 
end archi; 

