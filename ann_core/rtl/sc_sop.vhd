---------------------------------------------------------------------------------
--
-- Copyright (c) 2017 by SISLAB Team, LSI Design Contest 2018.
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
--
-- @File            : sc_sop.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Jan 20 2018       @Modified Date : Feb 05 2018 12:00
-- @Project         : Artificial Neural Network
-- @Module          : sc_sop
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.conf.all;
use work.tb_conf.all;

entity sc_sop is
  generic (
    IN_SIZE  : integer := 16);
  port(
  	clk      : in std_logic;
  	reset    : in std_logic;
    set_seed : in std_logic;
  	enable   : in std_logic;
    activ    : in std_logic;
  	x        : in input_array(0 to IN_SIZE - 1);
  	w        : in input_array(0 to IN_SIZE - 1);
    y        : out std_logic_vector(SUM_WIDTH-1 downto 0)
  );
end sc_sop;

architecture rtl of sc_sop is

  component bin2sc is
    generic ( IN_SIZE : integer := 8);
    port (
      clk             : in std_logic;
      reset           : in std_logic;
      set_seed        : in std_logic;
      enable_in       : in std_logic;
      x               : in input_array(0 to IN_SIZE - 1);
      w               : in input_array(0 to IN_SIZE - 1);
      sc_x            : out std_logic_vector(0 to IN_SIZE - 1);
      sc_0_5          : out std_logic_vector(0 to 16);
      sc_w            : out std_logic_vector(0 to IN_SIZE - 1)
    );
  end component; 

  component sc_mul is
    port (
      x1 : in std_logic;
      x2 : in std_logic;
      y  : out std_logic
    );
  end component;

  component sc_add is
    port (
      clk   : in std_logic;
      reset : in std_logic;
      x1    : in std_logic;
      x2    : in std_logic;
      sel   : in std_logic;
      y     : out std_logic
    );
  end component;

  component lfsr is
    generic (
      DATA_WIDTH : integer := 8);
    port (
      clk       : in  std_logic;
      reset     : in  std_logic;
      set_seed  : in  std_logic;
      seed_in   : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      enable_in : in  std_logic;
      lfsr_out  : out std_logic_vector(DATA_WIDTH-1 downto 0));
  end component lfsr;

  signal sc_x    : std_logic_vector(0 to IN_SIZE - 1);
  signal sc_w    : std_logic_vector(0 to IN_SIZE - 1);
  signal sc_mult : std_logic_vector(0 to IN_SIZE - 1);
  signal sc_tmp  : std_logic_vector(0 to 13);
  signal sc_sum  : std_logic;
  signal sc_0_5  : std_logic_vector(0 to 16);

  signal ctrl    : std_logic_vector(CTRL_WIDTH-1 downto 0);
  signal sum     : unsigned(SUM_WIDTH-1 downto 0);

begin

  sum_count: process (clk, reset)
  begin
    if reset = '1' then
      sum     <= (others => '0');
    elsif rising_edge(clk) then
      if set_seed = '1' then
        sum <= (others => '0');
      elsif enable = '1' then
        if sc_sum = '1' then
          sum <= sum + 1;
        end if;
      end if;
    end if;
  end process;

  bin2sc_i: bin2sc
    generic map(
      IN_SIZE => IN_SIZE
    )
    port map (
      clk         => clk,
      reset       => reset,
      set_seed    => set_seed,
      enable_in   => enable,
      x           => x,
      w           => w,
      sc_x        => sc_x,
      sc_0_5      => sc_0_5,
      sc_w        => sc_w
    );

  mult_i: for i in 0 to IN_SIZE - 1 generate
      sc_mult(i) <= sc_x(i) xnor sc_w(i);
  end generate;

  -- sc_sum <= sc_mult(to_integer(unsigned(ctrl(3 downto 0))));
  -- lfsr_ctrl: lfsr
    -- generic map (
      -- DATA_WIDTH  => CTRL_WIDTH
    -- )
    -- port map (
      -- clk         => clk,
      -- reset       => reset,
      -- set_seed    => set_seed,
      -- seed_in     => std_logic_vector(to_unsigned(11, CTRL_WIDTH)),
      -- enable_in   => enable,
      -- lfsr_out    => ctrl);

  -- binary adder tree
  adder0: sc_add
    port map(clk, reset, sc_mult(0), sc_mult(1), sc_0_5(0), sc_tmp(0));
  adder1: sc_add
    port map(clk, reset, sc_mult(2), sc_mult(3), sc_0_5(1), sc_tmp(1));
  adder2: sc_add
    port map(clk, reset, sc_mult(4), sc_mult(5), sc_0_5(2), sc_tmp(2));
  adder3: sc_add
    port map(clk, reset, sc_mult(6), sc_mult(7), sc_0_5(3), sc_tmp(3));
  adder4: sc_add
    port map(clk, reset, sc_mult(8), sc_mult(9), sc_0_5(4), sc_tmp(4));
  adder5: sc_add
    port map(clk, reset, sc_mult(10), sc_mult(11), sc_0_5(5), sc_tmp(5));
  adder6: sc_add
    port map(clk, reset, sc_mult(12), sc_mult(13), sc_0_5(6), sc_tmp(6));
  adder7: sc_add
    port map(clk, reset, sc_mult(14), sc_mult(15), sc_0_5(7), sc_tmp(7));
  adder8: sc_add
    port map(clk, reset, sc_tmp(0), sc_tmp(1), sc_0_5(8), sc_tmp(8));
  adder9: sc_add
    port map(clk, reset, sc_tmp(2), sc_tmp(3), sc_0_5(9), sc_tmp(9));
  adder10: sc_add
    port map(clk, reset, sc_tmp(4), sc_tmp(5), sc_0_5(10), sc_tmp(10));
  adder11: sc_add
    port map(clk, reset, sc_tmp(6), sc_tmp(7), sc_0_5(11), sc_tmp(11));
  adder12: sc_add
    port map(clk, reset, sc_tmp(8), sc_tmp(9), sc_0_5(12), sc_tmp(12));
  adder13: sc_add
    port map(clk, reset, sc_tmp(10), sc_tmp(11), sc_0_5(13), sc_tmp(13));
  adder14: sc_add
    port map(clk, reset, sc_tmp(12), sc_tmp(13), sc_0_5(14), sc_sum);

  y <= std_logic_vector(sum);
end architecture rtl;
