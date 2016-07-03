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
use WORK.PSDLIB.ALL;

entity control is
    Port (	clk : in  std_logic;
			oper : in  STD_LOGIC_VECTOR (3 downto 0);  -- Ask professor how to keep it generic
			leds   : out std_logic_vector(7 downto 0);
			rst   : out std_logic;
			cbits : out  STD_LOGIC_VECTOR (4 downto 0));  -- en2 en1 resul op op
end control;

architecture Behavioral of control is
	type   fsm_states is (s_init, s_equ,s_op2, s_end);
	type   fsm_opstates is (s_sub, s_add, s_inv, s_mul, s_nop);
	signal currstate, nextstate : fsm_states;
	signal opstate, currop : fsm_opstates;
begin

	
	-- States
	state_reg : process (clk, oper)
	begin
		if oper(3) = '1' then
			rst <='1';
			currstate <= s_init;
			currop <= s_nop;
		elsif clk'event and clk = '1' then
			rst <='0';
			currstate <= nextstate;
			currop <= opstate;
		end if;
	end process;

	state_comb : process (currstate, oper, currop)
		begin  --  process
			nextstate <= currstate;
			opstate <= currop;
			-- by default, does not change the state.
		case currstate is
			when s_init =>
				if oper(3) = '0' then
					cbits <= "01000"; -- enable(0) <= '1';
					if oper = "0011" and (currop = s_nop or currop = s_mul) then
						opstate <= s_mul;
						leds <= ( 4 => '1', others => '0');
					elsif oper = "0101" and (currop = s_nop or currop = s_sub) then
						opstate <= s_sub;
						leds <= ( 3 => '1', others => '0');
					elsif oper = "0100" and (currop = s_nop or currop = s_add) then
						opstate <= s_add;
						leds <= ( 2 => '1', others => '0');
					elsif oper = "0010" and (currop = s_nop or currop = s_inv) then
						opstate <= s_inv;
						leds <= ( 5 => '1', others => '0');
					elsif oper = "0000" and currop /= s_nop then
						nextstate <= s_op2;
						leds <= (others => '0');  -- atencao manter led
					else
						leds <= (1 => '1', others => '0');  -- atencao manter led
					end if;
				else
					cbits <= "01000";
					leds <= ( leds'low => '1', others => '0');
				end if;
			
		
			when s_op2 =>
				if currop = s_add then
					if oper = "0010" then -- when equal
						leds <= ( leds'high => '1', others => '0');
						cbits <= "01100";
						nextstate <= s_equ;
					else -- while not equal
						cbits <= "10000"; -- enable(1) <= '1';
						leds <= ( 2 => '1', others => '0');
					end if;
					
				elsif currop  = s_sub then
					if oper = "0010" then
						leds <= ( leds'high => '1', others => '0');
						cbits <= "01101"; -- enable(1) <= '1';
						nextstate <= s_equ;
					else
						cbits <= "10001"; -- enable(1) <= '1';
						leds <= ( 3 => '1', others => '0');
					end if;
					
				elsif currop  = s_mul then
					if oper = "0010" then
						leds <= ( leds'high => '1', others => '0');
						cbits <= "01111"; -- enable(1) <= '1';
						nextstate <= s_equ;
					else
						cbits <= "10011"; -- enable(1) <= '1';
						leds <= ( 4 => '1', others => '0');
					end if;
				else
					if oper = "0000" then
						leds <= ( 5 => '1', others => '0');
						cbits <= "01110";
						nextstate <= s_equ;
					else
						cbits <= "00010";
						leds <= ( 5 => '1', others => '0'); 
					end if;
				end if;
		
			when s_equ =>
				if oper = "0000" then -- waits for button release
					nextstate <= s_end;
					leds <= ( others => '0');
					if currop  = s_add then
						cbits <= "00100";
						opstate <= s_add;
					elsif currop  = s_sub then
						cbits <= "00101";
						opstate <= s_sub;
					elsif currop  = s_mul then
						cbits <= "00111";
						opstate <= s_mul;
					else -- s_inv
						cbits <= "00110";
						opstate <= s_inv;
					end if;
				else
					if currop  = s_add then
						cbits <= "00000";
						leds <= ( 2 => '1', others => '0');
						opstate <= s_add;
					elsif currop  = s_sub then
						cbits <= "00001";
						leds <= ( 3 => '1', others => '0');
						opstate <= s_sub;
					elsif currop  = s_mul then
						cbits <= "00011";
						leds <= ( 4 => '1', others => '0');
						opstate <= s_mul;
					else
						cbits <= "00010";
						leds <= ( 5 => '1', others => '0'); 
						opstate <= s_inv;
					end if;
				end if;
				
			when s_end =>
				leds <= ( leds'high => '1', others => '0');
				cbits <= "00100";
				opstate <= s_nop;
				if oper = "0011" then
					nextstate <= s_op2;
					opstate <= s_mul;
				elsif oper = "0101" then
					nextstate <= s_op2;
					opstate <= s_sub;
				elsif oper = "0100" then
					nextstate <= s_op2;
					opstate <= s_add;
				elsif oper = "0010" then -- oper = "0010"
					nextstate <= s_op2;
					opstate <= s_inv;
				else
					-- nop
				end if;
		end case;
	end process;


end Behavioral;

