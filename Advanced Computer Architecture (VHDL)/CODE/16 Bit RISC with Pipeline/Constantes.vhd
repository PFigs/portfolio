----------------------------------------------------------------------------------
-- Projecto Arquitecturas Avanadas de Computadores
-- 			2 Semestre 2009/2010
-- 
-- Realizado por:
-- Pedro Silva (58035)
-- Oleksandr Yefimochkin (58958)
--
-- Responsvel:
-- Leonel Sousa
----------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use work.gates.all;
use work.new_vhd_lib.all;

entity Constants is
    Port ( opcode : in  STD_LOGIC_VECTOR (15 downto 0);
           rc : in  STD_LOGIC_VECTOR (15 downto 0);
           res : out  STD_LOGIC_VECTOR (15 downto 0));
end Constants;

architecture Behavioral of Constants is
signal loadlit,lcl,lch,lcl_h : STD_LOGIC_VECTOR (15 downto 0);
begin

loadlit(15) <= opcode(10);
loadlit(14) <= opcode(10);
loadlit(13) <= opcode(10);
loadlit(12) <= opcode(10);
loadlit(11) <= opcode(10);
loadlit(10) <= opcode(10);
loadlit(9)  <= opcode(9);
loadlit(8)  <= opcode(8);
loadlit(7)  <= opcode(7);
loadlit(6)  <= opcode(6);
loadlit(5)  <= opcode(5);
loadlit(4)  <= opcode(4);
loadlit(3)  <= opcode(3);
loadlit(2)  <= opcode(2);
loadlit(1)  <= opcode(1);
loadlit(0)  <= opcode(0);


lcl(15) <= rc(15);
lcl(14) <= rc(14);
lcl(13) <= rc(13);
lcl(12) <= rc(12);
lcl(11) <= rc(11);
lcl(10) <= rc(10);
lcl(9)  <= rc(9);
lcl(8)  <= rc(8);
lcl(7)  <= opcode(7);
lcl(6)  <= opcode(6);
lcl(5)  <= opcode(5);
lcl(4)  <= opcode(4);
lcl(3)  <= opcode(3);
lcl(2)  <= opcode(2);
lcl(1)  <= opcode(1);
lcl(0)  <= opcode(0);


lch(15) <= opcode(7);
lch(14) <= opcode(6);
lch(13) <= opcode(5);
lch(12) <= opcode(4);
lch(11) <= opcode(3);
lch(10) <= opcode(2);
lch(9)  <= opcode(1);
lch(8)  <= opcode(0);
lch(7)  <= rc(7);
lch(6)  <= rc(6);
lch(5)  <= rc(5);
lch(4)  <= rc(4);
lch(3)  <= rc(3);
lch(2)  <= rc(2);
lch(1)  <= rc(1);
lch(0)  <= rc(0);


M1 : Mux16 Port map
			( I0 => lcl,
           I1 => lch,
           O  => lcl_h,
           S  => opcode(10)
			);
			
M2 : Mux16 Port map
			( I0 => loadlit,
           I1 => lcl_h,
           O  => res,
           S  => opcode(15)
			);			

end Behavioral;

