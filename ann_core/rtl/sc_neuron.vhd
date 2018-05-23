---------------------------------------------------------------------------------
--
-- Copyright (c) 2017 by SISLAB Team, LSI Design Contest 2018.
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
--
-- @File            : sc_neuron.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Jan 20 2018       @Modified Date : Feb 05 2018 12:00
-- @Project         : Artificial Neural Network
-- @Module          : sc_neuron
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conf.all;
--pragma synthesis_off
use work.tb_conf.all;
use ieee.math_real.all;
--pragma synthesis_on

entity sc_neuron is
  generic (
    IN_SIZE  : integer := 16;
    NUM_CAL  : integer := 10
  );
  port(
  	clk      : in std_logic;
  	reset    : in std_logic;
    set_seed : in std_logic;
  	enable   : in std_logic;
    activ    : in std_logic;
  	x        : in input_array(0 to IN_SIZE - 1);
  	w        : in input_array(0 to IN_SIZE - 1);
  	b        : in std_logic_vector(BIT_WIDTH-1 downto 0);
    y        : out std_logic_vector(BIT_WIDTH-1 downto 0)
  );
end sc_neuron;

architecture rtl of sc_neuron is

  signal sc_x    : std_logic_vector(0 to IN_SIZE - 1);
  signal sc_w    : std_logic_vector(0 to IN_SIZE - 1);
  signal sc_b    : std_logic;
  signal sc_sum  : std_logic;
  signal sc_sop  : std_logic;
  signal sc_mult : std_logic_vector(0 to IN_SIZE - 1);
  signal sc_tmp  : std_logic_vector(0 to 13);

  signal sop     : unsigned(SUM_WIDTH-1 downto 0);
  signal counter : unsigned(SUM_WIDTH-1 downto 0);
  signal b_tmp   : unsigned(SUM_WIDTH-1 downto 0);
  signal sum_tmp : unsigned(SUM_WIDTH-1 downto 0);
  signal sum     : unsigned(SC_WIDTH-1 downto 0);

  constant VAL_1  : unsigned(SUM_WIDTH-1 downto 0)
    := to_unsigned(1*2**SC_WIDTH, SUM_WIDTH);
  constant VAL_MINUS : unsigned(SUM_WIDTH-1 downto 0)
    := to_unsigned(NUM_CAL*2**(SC_WIDTH-1), SUM_WIDTH);

begin

  b_tmp   <= (SUM_WIDTH-BIT_WIDTH-1 downto 0 => '0')
           & unsigned(b);
  sum_tmp <= ((sop + b_tmp) - VAL_MINUS);

  sum     <= (others => '0') when sum_tmp(SUM_WIDTH-1) = '1' else
             (others => '1') when sum_tmp(SC_WIDTH)    = '1' else
             sum_tmp(SC_WIDTH-1 downto 0);

  sop_count: process (clk, reset)
    variable test_count : real := 1.0;
  begin
    if reset = '1' then
      sop     <= (others => '0');
      counter <= (others => '0');
    elsif rising_edge(clk) then
      if set_seed = '1' then
        sop <= (others => '0');
      elsif enable = '1' then
        counter <= counter + 1;

        if sc_sop = '1' then
          sop <= sop + 1;
        end if;
      else
          counter <= (others => '0');
      end if;

      --pragma synthesis_off
      if counter = 2**SC_WIDTH-1 then
        -- print("sop_sc       = "
              -- & real'image(16.0 *
                -- (real(to_integer(sop)) / 2.0**(SC_WIDTH-1) - test_count)));
        -- print("    sum_actual   = "
              -- & real'image(16.0 *
                -- (real(to_integer(sum_tmp)) / 2.0**(SC_WIDTH-1) - 1.0)));
        test_count := test_count + 1.0;
      end if;
      --pragma synthesis_on

    end if;
  end process;

  mult_i: for i in 0 to IN_SIZE - 1 generate
      sc_mult(i) <= sc_x(i) xnor sc_w(i);
  end generate;

  adder0: entity work.sc_add
    port map(clk, reset, sc_mult(0), sc_mult(1), sc_tmp(0));
  adder1: entity work.sc_add
    port map(clk, reset, sc_mult(2), sc_mult(3), sc_tmp(1));
  adder2: entity work.sc_add
    port map(clk, reset, sc_mult(4), sc_mult(5), sc_tmp(2));
  adder3: entity work.sc_add
    port map(clk, reset, sc_mult(6), sc_mult(7), sc_tmp(3));
  adder4: entity work.sc_add
    port map(clk, reset, sc_mult(8), sc_mult(9), sc_tmp(4));
  adder5: entity work.sc_add
    port map(clk, reset, sc_mult(10), sc_mult(11), sc_tmp(5));
  adder6: entity work.sc_add
    port map(clk, reset, sc_mult(12), sc_mult(13), sc_tmp(6));
  adder7: entity work.sc_add
    port map(clk, reset, sc_mult(14), sc_mult(15), sc_tmp(7));
  adder8: entity work.sc_add
    port map(clk, reset, sc_tmp(0), sc_tmp(1), sc_tmp(8));
  adder9: entity work.sc_add
    port map(clk, reset, sc_tmp(2), sc_tmp(3), sc_tmp(9));
  adder10: entity work.sc_add
    port map(clk, reset, sc_tmp(4), sc_tmp(5), sc_tmp(10));
  adder11: entity work.sc_add
    port map(clk, reset, sc_tmp(6), sc_tmp(7), sc_tmp(11));
  adder12: entity work.sc_add
    port map(clk, reset, sc_tmp(8), sc_tmp(9), sc_tmp(12));
  adder13: entity work.sc_add
    port map(clk, reset, sc_tmp(10), sc_tmp(11), sc_tmp(13));
  adder14: entity work.sc_add
    port map(clk, reset, sc_tmp(12), sc_tmp(13), sc_sop);
  adder15: entity work.sc_add
    port map(clk, reset, sc_sop, sc_b, sc_sum);

  bin2sc_i: entity work.bin2sc
    generic map(
      IN_SIZE => IN_SIZE
    )
    port map (
      clk         => clk,
      reset       => reset,
      set_seed    => set_seed,
      enable_in   => enable,
      x           => x,
      b           => std_logic_vector(b_tmp(SC_WIDTH-1 downto 0)),
      w           => w,
      sc_x        => sc_x,
      sc_b        => sc_b,
      sc_w        => sc_w
    );

  activation_function: entity work.sc_relu
    port map(
      clk    => clk,
      reset  => reset,
      enable => activ,
      input  => std_logic_vector(sum),
      output => y);

end architecture rtl;
