library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;


entity disp7 is
  port (
    disp4, disp3, disp2, disp1 : in  std_logic_vector(3 downto 0);
    clk                        : in  std_logic;
    en_disp                    : out std_logic_vector(4 downto 1);
    segm                       : out std_logic_vector(7 downto 0)
    );
end disp7;

architecture mixed of disp7 is

  signal hex_disp : std_logic_vector(3 downto 0);
  signal dig7s_L  : std_logic_vector(7 downto 1);
  signal count    : std_logic_vector(1 downto 0);
  signal dot      : std_logic;

begin

  -- 2 bit counter, one value for each display
  process (clk)
  begin
    if rising_edge(clk) then
      count <= count + 1;
    end if;
  end process;

  -- the values of each display are multiplexed in time
  -- acording to the count value, control signals are also generated
  multiplex_display : process (count, disp4, disp3, disp2, disp1)
  begin
    case count is
      when "00" =>
        en_disp  <= "0111";
        hex_disp <= disp1;
        dot      <= '1';
      when "01" =>
        en_disp  <= "1011";
        hex_disp <= disp2;
        dot      <= '1';
      when "10" =>
        en_disp  <= "1101";
        hex_disp <= disp3;
        dot      <= '1';
      when others =>
        en_disp  <= "1110";
        hex_disp <= disp4;
        dot      <= '1';
    end case;
  end process multiplex_display;

  -- converts 4-bit number to 7-segment hexadecimal display (active-low)
  dig7s_L <= "1000000" when hex_disp = X"0" else
             "1111001" when hex_disp = X"1" else
             "0100100" when hex_disp = X"2" else
             "0110000" when hex_disp = X"3" else
             "0011001" when hex_disp = X"4" else
             "0010010" when hex_disp = X"5" else
             "0000010" when hex_disp = X"6" else
             "1111000" when hex_disp = X"7" else
             "0000000" when hex_disp = X"8" else
             "0010000" when hex_disp = X"9" else
             "0001000" when hex_disp = X"A" else
             "0000011" when hex_disp = X"b" else
             "1000110" when hex_disp = X"C" else
             "0100001" when hex_disp = X"d" else
             "0000110" when hex_disp = X"E" else
             "0001110";                 -- "F"

  segm <= (dot & dig7s_L);



end mixed;
