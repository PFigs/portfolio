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

entity flag_en_logic is
    Port ( b15 : in  STD_LOGIC;
			  b14 : in  STD_LOGIC;
			  b10 : in  STD_LOGIC;
           b9 : in  STD_LOGIC;
           b8 : in  STD_LOGIC;
           b7 : in  STD_LOGIC;
           b6 : in  STD_LOGIC;
           es : out  STD_LOGIC;
           ec : out  STD_LOGIC;
           ez : out  STD_LOGIC;
           eo : out  STD_LOGIC);
end flag_en_logic;

architecture Behavioral of flag_en_logic is

signal notb15, notb14, notb10, notb9, notb8, notb7, notb6 : STD_LOGIC;
signal alu_mem,  eo_temp,  ec_temp, ezs_temp, ezs_final : STD_LOGIC;
signal no_2_3out, no_2_4out, no_2_5out, no_3_1out, no_2_6out, no_3_2out, no_3_3out, no_3_4out: STD_LOGIC;
signal s_1, s_2, s_3 : STD_LOGIC;

begin

-----------------------------------------------------------------------------
-----------------------------------------------------------------------------
--	BITS NEGADOS
not_b6 : not1 port map
		(
       A => b6,
       Z => notb6
       );
not_b7 : not1 port map
		(
       A => b7,
       Z => notb7
       );
not_b8 : not1 port map
		(
       A => b8,
       Z => notb8
       );
not_b9 : not1 port map
		(
       A => b9,
       Z => notb9
       );
		 
not_b10 : not1 port map
		(
       A => b10,
       Z => notb10
       );

not_b14 : not1 port map
		(
       A => b14,
       Z => notb14
       );
not_b15 : not1 port map
		(
       A => b15,
       Z => notb15
       );

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
--OPERACAO DE ALU OU MEM
no_2_1 : no2 port map
		(
        A => notb15,
        B => b14,
        Z => alu_mem
		);

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
--ENABLE OVERFLOW TEMPORARIO

no_2_2 : no2 port map
		(
        A => b10,
        B => b9,
        Z => eo_temp
		);
------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------
--ENABLE CARRY TEMPORARIO

no_2_3 : no2 port map
		(
        A => b10,
        B => b7,
        Z => no_2_3out
		);

		
or_2_1 : o2 port map
		(
        A => eo_temp,
        B => no_2_3out,
        Z => ec_temp
		);

------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------------------------------------

no_2_4 : no2 port map
		(
        A => notb9,
        B => b7,
        Z => no_2_4out
		);

no_2_5 : no2 port map
		(
        A => notb8,
        B => b9,
        Z => no_2_5out
		);
		
no_3_1 :	no3 port map
		(
        A => notb8,
        B => notb7,
        D => b6,
        Z => no_3_1out
      );

no_2_6 : no2 port map
		(
        A => notb8,
        B => b10,
        Z => no_2_6out
		);

no_3_2 :	no3 port map
		(
        A => notb10,
        B => notb9,
        D => b8,
        Z => no_3_2out
      );

no_3_3 :	no3 port map
		(
        A => b9,
        B => notb7,
        D => b6,
        Z => no_3_3out
      );
		
no_3_4 :	no3 port map
		(
        A => b8,
        B => b7,
        D => notb6,
        Z => no_3_4out
      );




or_3_1: o3 port map
		(
        A => eo_temp,
        B => no_2_4out,
        D => no_2_5out,
        Z => s_1
		);

or_3_2 : o3 port map
		(
        A => no_3_1out,
        B => no_2_6out,
        D => no_3_2out,
        Z => s_2
		);
		
o2_1 : o2 port map
		(
        A => no_3_3out,
        B => no_3_4out,
        Z => s_3
		);
	 
or_3_3: o3 port map
		(
        A => s_1,
        B => s_2,
        D => s_3,
        Z => ezs_temp
		);

----------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

a2_1 : a2 port map
		(
        A => alu_mem,
        B => ec_temp,
        Z => ec
		);
a2_2 : a2 port map
		(
        A => alu_mem,
        B => eo_temp,
        Z => eo
		);
a2_3 : a2 port map
		(
        A => alu_mem,
        B => ezs_temp,
        Z => ezs_final
		);

ez <= ezs_final;
es <= ezs_final;

---------------------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------

end Behavioral;

