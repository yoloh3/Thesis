-------------------------------------------------------------------------------
-- Title      : Stochastic Number Generator
-- Project    : 
-------------------------------------------------------------------------------
-- File       : sng.vhd
-- Author     : Hieu D. Bui  <Hieu D. Bui@>
-- Company    : SISLAB, VNU-UET
-- Created    : 2017-12-15
-- Last update: 2017-12-15
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Generate a Stochastic number by using a linear feedback register
-------------------------------------------------------------------------------
-- Copyright (c) 2017 SISLAB, VNU-UET
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2017-12-15  1.0      Hieu D. Bui     Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sng is
  generic (
    data_width : integer := 8);
  port (
    clk         : in  std_logic;
    rst_n       : in  std_logic;
    set_seed_in : in  std_logic;
    enable_in   : in  std_logic;
    seed_in     : in  std_logic_vector(data_width-1 downto 0);
    px_in       : in  std_logic_vector(data_width-1 downto 0);
    sc_out      : out std_logic);
end entity sng;

architecture beh of sng is
  component lfsr is
    generic (
      data_width : integer);
    port (
      clk         : in  std_logic;
      rst_n       : in  std_logic;
      seed_in     : in  std_logic_vector(data_width-1 downto 0);
      set_seed_in : in  std_logic;
      enable_in   : in  std_logic;
      lfsr_out    : out std_logic_vector(data_width-1 downto 0));
  end component lfsr;

  -- random number generator output
  signal rng_var : std_logic_vector(data_width-1 downto 0);

begin  -- architecture beh

  rng_1 : entity work.lfsr
    generic map (
      data_width => data_width)
    port map (
      clk         => clk,
      rst_n       => rst_n,
      seed_in     => seed_in,
      set_seed_in => set_seed_in,
      enable_in   => enable_in,
      lfsr_out    => rng_var);

  -- number of bit '1' devided by data_width in sc_out
  -- represents the probability px_in
  -- for example, the following series represent 1/4
  -- 01010000
  sc_out <= '1' when unsigned(rng_var) < unsigned(px_in) else '0';
end architecture beh;
