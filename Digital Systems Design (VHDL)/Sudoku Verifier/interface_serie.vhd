-- Time-stamp: "2011-04-22 12:56:26    interface_serie.vhd    pff@inesc-id.pt"
-------------------------------------------------------------------------------
-- Title      : 3o Laboratorio: Projecto de um Sistema Digital
-- Project    : Projecto de Sistemas Digitais 2010/2011 (2o Sem.)
-------------------------------------------------------------------------------
-- File       : interface_serie.vhd
-- Author     : Paulo Flores  <pff@inesc-id.pt>
-- Company    : INESC-ID, ECE Dept. IST, TU Lisbon
-- Created    : 2011-04-15
-- Last update: 2011-04-22
-- Platform   : Digilent Xilinix Spartan-3 Starter Board (XC3S1000)
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Circuit to read/write data from/to the UART that communicates
-- with serial port of the PC. Each byte received/sent encode 4bits that are
-- written/read in the input/output memories.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 Instituto Superior Tecnico
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2007-05-30  1.5      hcn     Created (as uart2mem)
-- 2011-04-15  2.0      pff     Change name e separate some functions
-------------------------------------------------------------------------------
--
-- Este circuito tarta da recepcao/envio de dados de/para o PC para/de a
-- FPGA. Os dados são recebidos/enviados através da porta serie, byte a byte,
-- através do componente UART. A máquina de estados neste componente controla
-- o recebimento dos dados, nos estados stRCVstart, stRCV0 e stRCV1. Os dados
-- recebidos são escritos na memória de entrada através do porto A. O envio
-- de dados é controlado pelos estados stSNDstart, stSND0, stSND1, stEND. Os
-- dados enviados são lidos da memória de saída através do seu porto A.
--
-- Formato: os dados são enviados/recebidos como uma sequência de caracteres
-- hexadecimais, usando por exemplo o HyperTerminal ou programas de comunicacao
-- com a porta serie, terminando como o caracter 'L'.
-----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity interface_serie is
  port (TXD         : out std_logic := '1';
        RXD         : in  std_logic := '1';
        CLK         : in  std_logic;
        RST         : in  std_logic;
        RDaddr      : in  std_logic_vector(8 downto 0);   -- READ mem Address
        RDdata      : out std_logic_vector(31 downto 0);  -- READ mem Data
        WRaddr      : in  std_logic_vector(8 downto 0);   -- WRITE mem Address
        WRdata      : in  std_logic_vector(31 downto 0);  -- WRITE mem Data
        WRenable    : in  std_logic;    -- WRITE mem Enable
        WRdataRDbck : out std_logic_vector(31 downto 0);  -- readbeack WRITE mem
        canSTART    : out std_logic;  -- all data read from PC, can start computation
        execDONE    : in  std_logic;  -- computation done, data on mem, can send to PC
        SENDtoPC    : in  std_logic;    -- send data to PC via serial RS232
        CNTbyte2    : out std_logic_vector(11 downto 0);  -- numb. of char read
                                        -- (4bits in READ mem)
        canDEBUG    : out std_logic     -- for mem debug
        );
end interface_serie;

architecture Behavioral of interface_serie is
------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
  component UARTcomponent
    port (
      TXD   : out   std_logic := '1';
      RXD   : in    std_logic;
      CLK   : in    std_logic;                      --Master Clock
      DBIN  : in    std_logic_vector (7 downto 0);  --Data Bus in
      DBOUT : out   std_logic_vector (7 downto 0);  --Data Bus out
      RDA   : inout std_logic;                      --Read Data Available
      TBE   : inout std_logic := '1';               --Transfer Bus Empty
      RD    : in    std_logic;                      --Read Strobe
      WR    : in    std_logic;                      --Write Strobe
      PE    : out   std_logic;                      --Parity Error Flag
      FE    : out   std_logic;                      --Frame Error Flag
      OE    : out   std_logic;                      --Overwrite Error Flag
      RST   : in    std_logic := '0');              --Master Reset

  end component;

  component decode_hexa_chars
    port(
      din    : in  std_logic_vector(7 downto 0);
      dout   : out std_logic_vector(3 downto 0);
      isEnd  : out std_logic
      );
  end component;

  component encode_hexa_chars
    port(
      din  : in  std_logic_vector(3 downto 0);
      dout : out std_logic_vector(7 downto 0)
      );
  end component;

------------------------------------------------------------------------
--  Local Type Declarations
------------------------------------------------------------------------

  type mainState is (stRCVstart, stRCV0, stRCV1, stExecute, stSNDstart, stSND0, stSND1, stEND);

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
  signal dataToPC, dataFromPC         : std_logic_vector(7 downto 0);
  signal rdaSig, tbeSig, rdSig, wrSig : std_logic;

  signal stCur  : mainState := stRCVstart;
  signal stNext : mainState;

  signal reset_delay_cnt, endSending, isRDEnd  : std_logic;
  signal enableWRmemIN, enableWRmemOUT         : std_logic;
  signal uartRDcount, uartWRlastAddress, count : std_logic_vector(11 downto 0);
  signal enableCount, rstCount                 : std_logic;
  signal addressWRmemIN, addressRDmemOUT       : std_logic_vector(11 downto 0);
  signal addressRDmemIN, addressWRmemOUT       : std_logic_vector(8 downto 0);
  signal dataTOmemIN, dataFROMmemOUT           : std_logic_vector(3 downto 0);
  signal dataTOmemOUT, dataFROMmemIN, d_portoB : std_logic_vector(31 downto 0);
  signal delay                                 : std_logic_vector(20 downto 0);
  signal setRDcount, endExecution, doDebug     : std_logic;


------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------

begin

  UART : Uartcomponent
    port map (
      TXD   => TXD,
      RXD   => RXD,
      CLK   => CLK,                     --Master Clock
      DBIN  => dataToPC,                --Data Bus in
      DBOUT => dataFromPC,              --Data Bus out
      RDA   => rdaSig,                  --Read Data Available
      TBE   => tbeSig,                  --Transfer Bus Empty
      RD    => rdSig,                   --Read Strobe
      WR    => wrSig,                   --Write Strobe
      PE    => open,                    --Parity Error Flag
      FE    => open,                    --Frame Error Flag
      OE    => open,                    --Overwrite Error Flag
      RST   => RST);                    --Master Reset

  memoria_entrada_na_fpga : RAMB16_S4_S36
    port map (
      DOA   => open,                    -- Port A 4-bit Data Output
      DOB   => dataFROMmemIN,           -- Port B 32-bit Data Output
      DOPB  => open,                    -- Port B 4-bit Parity Output
      ADDRA => addressWRmemIN,          -- Port A 12-bit Address Input
      ADDRB => addressRDmemIN,          -- Port B 9-bit Address Input
      CLKA  => CLK,                     -- Port A Clock
      CLKB  => CLK,                     -- Port B Clock
      DIA   => dataTOmemIN,             -- Port A 4-bit Data Input
      DIB   => X"00000000",             -- Port B 32-bit Data Input
      DIPB  => "0000",                  -- Port-B 4-bit parity Input
      ENA   => '1',                     -- Port A RAM Enable Input
      ENB   => '1',                     -- Port B RAM Enable Input
      SSRA  => '0',                     -- Port A Synchronous Set/Reset Input
      SSRB  => '0',                     -- Port B Synchronous Set/Reset Input
      WEA   => enableWRmemIN,           -- Port A Write Enable Input
      WEB   => '0'                      -- Port B Write Enable Input
      );

  memoria_saida_na_fpga : RAMB16_S4_S36
    port map (
      DOA   => dataFROMmemOUT,          -- Port A 4-bit Data Output
      DOB   => d_portoB,                -- Port B 32-bit Data Output
      DOPB  => open,                    -- Port B 4-bit Parity Output
      ADDRA => addressRDmemOUT,         -- Port A 12-bit Address Input
      ADDRB => addressWRmemOUT,         -- Port B 9-bit Address Input
      CLKA  => CLK,                     -- Port A Clock
      CLKB  => CLK,                     -- Port B Clock
      DIA   => "0000",                  -- Port A 4-bit Data Input
      DIB   => dataTOmemOUT,            -- Port B 32-bit Data Input
      DIPB  => "0000",                  -- Port-B 4-bit parity Input
      ENA   => '1',                     -- Port A RAM Enable Input
      ENB   => '1',                     -- Port B RAM Enable Input
      SSRA  => '0',                     -- Port A Synchronous Set/Reset Input
      SSRB  => '0',                     -- Port B Synchronous Set/Reset Input
      WEA   => '0',                     -- Port A Write Enable Input
      WEB   => enableWRmemOUT           -- Port B Write Enable Input
      );

  Inst_encode_hexa_chars : encode_hexa_chars
    port map (
      din  => dataFROMmemOUT,
      dout => dataToPC
      );

  Inst_decode_hexa_chars : decode_hexa_chars
    port map (
      din    => dataFromPC,
      dout   => dataTOmemIN,
      isEnd  => isRDEnd
      );

  addressWRmemIN  <= count;
  addressRDmemOUT <= count;
  endSending      <= '1' when count = uartWRlastAddress else '0';

  -- Read Memory
  addressRDmemIN <= RDaddr;
  RDdata         <= dataFROMmemIN;

  -- Write Memory
  addressWRmemOUT <= WRaddr;
  dataTOmemOUT    <= WRdata;
  enableWRmemOUT  <= WRenable;

  -- status and debug signals
  endExecution <= execDONE;
  WRdataRDbck  <= d_portoB;
  CNTbyte2     <= uartRDcount;
  canDEBUG     <= doDebug;



  process (CLK, RST)
  begin
    if (CLK = '1' and CLK'event) then
      if rst = '1' or rstCount = '1' then
        count <= (others => '0');
      elsif enableCount = '1' then
        count <= count + 1;
      end if;
    end if;
  end process;

  process (CLK)
  begin
    if (CLK = '1' and CLK'event) then
      if reset_delay_cnt = '1' then
        delay <= (others => '0');
      else
        delay <= delay + 1;
      end if;
    end if;
  end process;

  process (CLK)
  begin
    if (CLK = '1' and CLK'event) then
      if rst = '1' then
        uartRDcount <= (others => '0');
      elsif setRDcount = '1' and isRDend = '0' then
        uartRDcount <= count;
      end if;
    end if;
  end process;
  uartWRlastAddress <= uartRDcount - 1;

  process (CLK, RST)
  begin
    if (CLK = '1' and CLK'event) then
      if RST = '1' then
        stCur <= stRCVstart;
      else
        stCur <= stNext;
      end if;
    end if;
  end process;

  process (stCur, rdaSig, isRDend, SENDtoPC, tbeSig, endSending, delay, endExecution)
  begin
    enableCount     <= '0';
    rstCount        <= '0';
    stNext          <= stCur;
    enableWRmemIN   <= '0';
    reset_delay_cnt <= '0';
    setRDcount      <= '0';
    rdSig           <= '0';
    wrSig           <= '0';
    doDebug         <= '0';
    canSTART        <= '0';
    case stCur is
      when stRCVstart =>
        if rdaSig = '1' then
          stNext <= stRCV0;
        end if;

      when stRCV0 =>
        enableCount   <= '1';
        enableWRmemIN <= '1';
        stNext        <= stRCV1;

      when stRCV1 =>
        rdSig      <= '1';
        setRDcount <= '1';
        if rdaSig = '1' then
          stNext <= stRCV1;
        elsif isRDend = '0' then
          stNext <= stRCVstart;
        else
          stNext   <= stExecute;
          rstCount <= '1';
        end if;

      when stExecute =>
        canSTART <= '1';
        if endExecution = '1' then
          stNext <= stSNDstart;
        end if;

      when stSNDstart =>
        rstCount <= '1';
        if SENDtoPC = '1' then
          stNext <= stSND0;
        end if;

      when stSND0 =>
        wrSig           <= '1';
        reset_delay_cnt <= '1';
        if tbeSig = '0' then
          stNext <= stSND1;
        end if;

      when stSND1 =>
        if endSending = '1' then
          stNext <= stEND;
        elsif delay(20) = '1' then
          stNext      <= stSND0;
          enableCount <= '1';
        end if;

      when stEND =>
        stNext  <= stEND;
        doDebug <= '1';
    end case;
  end process;

end Behavioral;
