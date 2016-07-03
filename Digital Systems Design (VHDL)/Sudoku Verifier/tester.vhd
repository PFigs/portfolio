library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;




entity tester is
  port (
    m    : out std_logic_vector(2 downto 0);
    n    : out std_logic_vector(2 downto 0);
    mn   : out std_logic_vector(5 downto 0);
    clk  : in std_logic;
    rst  : in std_logic;
    en   : in std_logic;
    rdata: in std_logic_vector(31 downto 0)
    );
end tester;




architecture Behavioral of tester is

	component clkdiv is
	port( clk:in std_logic;
		  clkout:out std_logic);
	end component;

	signal cnt, clkd : std_logic;
	
begin

	process (clkd)
	begin
		if clkd'event and clkd='1' then  
			if rst='1' then   
				m <= (others => '0');
				n <= (others => '0');
				mn <= (others => '0');
			elsif en ='1' then
				m <= rdata(2 downto 0);
				n <= rdata(10 downto 8);
				mn <= rdata(21 downto 16);
			end if;
		end if;
	end process;


	clk1: clkdiv
	port map (
		clk => clk,
		clkout => clkd
		);
	

end Behavioral;

