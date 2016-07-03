-- Time-stamp: "2011-04-22 18:09:41    fpga3.vhd    pff@inesc-id.pt"
-------------------------------------------------------------------------------
-- Title      : 3o Laboratorio: Projecto de um Sistema Digital
-- Project    : Projecto de Sistemas Digitais 2010/2011 (2o Sem.)
-------------------------------------------------------------------------------
-- File       : fpga3.vhd
-- Author     : Paulo Flores  <pff@inesc-id.pt>
-- Company    : INESC-ID, ECE Dept. IST, TU Lisbon
-- Created    : 2011-04-15
-- Last update: 2011-04-22
-- Platform   : Digilent Xilinix Spartan-3 Starter Board (XC3S1000)
-- Standard   : VHDL'93
-------------------------------------------------------------------------------
-- Description: Top level circuit that interfaces the user circuit with
-- communication circuit that handle the data transfer to serial port of the
-- PC.
-------------------------------------------------------------------------------
-- Copyright (c) 2011 Instituto Superior Tecnico
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2011-04-15  1.0      pff     Created
-------------------------------------------------------------------------------
--
-- O botão 0, da placa, reinicializa a máquina de estados.
-- O botão 1 da placa, inicia a sequência de envio de dados para o PC.
-- Para efeitos de debug é possível, no estado final, visualizar os dados em
-- ambas as memórias nos displays de 7 segmentos, usando os switches da placa
-- para introduzir o endereço das posições a visualizar.
-- Aqui os botões 2 e 3 tem o seguinte significado:
-- btn(2) permitem seleccionar os 2 bytes mais significativos na mem de escrita
-- btn(3) permitem seleccionar os 2 bytes menos significativos na mem de leitura
-- btn(2)+btn(3) permitem seleccionar os 2 bytes mais significativos na mem de
-- leitura
-----------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.STD_LOGIC_ARITH.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

--  Uncomment the following lines to use the declarations that are
--  provided for instantiating Xilinx primitive components.
library UNISIM;
use UNISIM.VComponents.all;

entity fpga3 is
	port (TXD  : out std_logic := '1';
		RXD  : in  std_logic := '1';
		CLKB : in  std_logic;
		btn  : in  std_logic_vector(3 downto 0);
		swt  : in  std_logic_vector(7 downto 0);
		led  : out std_logic_vector(7 downto 0);
		an   : out std_logic_vector(3 downto 0);
		ssg  : out std_logic_vector(7 downto 0)
		);
end fpga3;


architecture beahvioral of fpga3 is

	component interface_serie
	port(
		RXD         : in  std_logic;
		CLK         : in  std_logic;
		RST         : in  std_logic;
		RDaddr      : in  std_logic_vector(8 downto 0);
		WRaddr      : in  std_logic_vector(8 downto 0);
		WRdata      : in  std_logic_vector(31 downto 0);
		WRenable    : in  std_logic;
		execDONE    : in  std_logic;
		TXD         : out std_logic;
		RDdata      : out std_logic_vector(31 downto 0);
		WRdataRDbck : out std_logic_vector(31 downto 0);
		canSTART    : out std_logic;
		CNTbyte2    : out std_logic_vector(11 downto 0);
		SENDtoPC    : in  std_logic;
		canDEBUG    : out std_logic
		);
	end component;

	component interface_placa
	port (
		clk50M                 : in  std_logic;
		led                    : out std_logic_vector(7 downto 0);
		an                     : out std_logic_vector(3 downto 0);
		ssg                    : out std_logic_vector(7 downto 0);
		D7S3, D7S2, D7S1, D7S0 : in  std_logic_vector(3 downto 0);
		dataleds               : in  std_logic_vector(7 downto 0)
		);
	end component;

	component circuito3
	port(
		CLK       : in  std_logic;
		RST       : in  std_logic;
		RDaddrCIR : out std_logic_vector(8 downto 0);
		RDdata    : in  std_logic_vector(31 downto 0);
		WRaddrCIR : out std_logic_vector(8 downto 0);
		WRdata    : out std_logic_vector(31 downto 0);
		WRenable  : out std_logic;
		canSTART  : in  std_logic;
		execDONE  : out std_logic;
		CNTbyte2  : in  std_logic_vector(11 downto 0)
		);
	end component;


	component clkdiv is
		port(
			clk		:	in std_logic;
			clkout	:	out std_logic
		);
	end component;


	signal clk,clkd, rst    : std_logic;
	signal RDaddr      : std_logic_vector(8 downto 0);
	signal WRaddr      : std_logic_vector(8 downto 0);
	signal WRdata      : std_logic_vector(31 downto 0);
	signal WRenable    : std_logic;
	signal execDONE    : std_logic;
	signal RDdata      : std_logic_vector(31 downto 0);
	signal WRdataRDbck : std_logic_vector(31 downto 0);
	signal canSTART    : std_logic;
	signal CNTbyte2    : std_logic_vector(11 downto 0);
	signal SENDtoPC    : std_logic;
	signal canDEBUG    : std_logic;
	signal RDaddrCIR   : std_logic_vector(8 downto 0);
	signal WRaddrCIR   : std_logic_vector(8 downto 0);
	signal dleds       : std_logic_vector(7 downto 0);
	signal ddisplay    : std_logic_vector(15 downto 0);
  

begin  -- beahvioral

  -- IBUFG: Global Clock Buffer (sourced by an external pin) Spartan-3
  -- Xilinx HDL Language Template, version 12.4
  BUFG_clk : IBUFG port map (I => CLKB, O => clk);

  Inst_interface_serie : interface_serie port map(
    TXD         => TXD,
    RXD         => RXD,
    CLK         => clk,
    RST         => rst,
    RDaddr      => RDaddr,              -- READ mem Address
    RDdata      => RDdata,              -- READ mem Data
    WRaddr      => WRaddr,              -- WRITE mem Address
    WRdata      => WRdata,              -- WRITE mem Data
    WRenable    => WRenable,            -- WRITE mem Enable
    WRdataRDbck => WRdataRDbck,         -- readbeack WRITE mem
    canSTART    => canSTART,  -- all data read from PC, can start computation
    execDONE    => execDONE,  -- compuation done, data on mem, can send to PC
    SENDtoPC    => sendtopc,            -- send data to PC via serial RS232
    CNTbyte2    => CNTbyte2,  -- numb. of char read (4bits in READ mem)
    canDEBUG    => canDEBUG             -- for mem debug
    );

  Inst_interface_placa : interface_placa
    port map (
      clk50M   => clk,
      led      => led,
      an       => an,
      ssg      => ssg,
      dataleds => dleds,
      D7S3     => ddisplay(15 downto 12),
      D7S2     => ddisplay(11 downto 8),
      D7S1     => ddisplay(7 downto 4),
      D7S0     => ddisplay(3 downto 0)
      );

	-- CLOCK_DIV
	clk1: clkdiv
	port map (
		clk => clk,
		clkout => clkd
	);


  Inst_circuito3 : circuito3 port map(
    CLK       => clkd,
    RST       => rst,
    RDaddrCIR => RDaddrCIR,
    RDdata    => RDdata,
    WRaddrCIR => WRaddrCIR,
    WRdata    => WRdata,
    WRenable  => WRenable,
    execDONE  => execDONE,
    canSTART  => canSTART,
    CNTbyte2  => CNTbyte2
    );

  rst      <= btn(0);                   -- o botao 0 e usado como reset
  sendtopc <= btn(1);                   -- o botao 1 envia os dados para o PC

  -- some debug capabilities
  dleds <= canDebug & execDONE & canSTART & CNTbyte2(7 downto 3);

  ddisplay <= WRdataRDbck(31 downto 16) when btn(2) = '1' and btn(3) = '1' else
              WRdataRDbck(15 downto 00) when btn(3) = '1' else
              RDData(31 downto 16)      when btn(2) = '1' else
              RDdata(15 downto 00);

  RDaddr <= RDaddrCIR when canDebug = '0' else ("0" & swt);

  WRaddr <= WRaddrCIR when canDebug = '0' else ("0" & swt);

end beahvioral;

