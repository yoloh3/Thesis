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

---------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------- 
entity sc_counter is
  port (
    clk   : in std_logic;
    reset : in std_logic;
    enable: in std_logic;
    x     : in std_logic;
    y     : out integer
  );
end entity; 

---------------------------------------------------------------------------------
-- Architecture description
---------------------------------------------------------------------------------
architecture behavior of sc_counter is
  signal count: integer;
begin

  process (clk, reset) is
  begin
    if reset = '1' then
      count <= 0;
    elsif rising_edge(clk) then
      if enable = '1' then
        if x = '1' then
          count <= count + 1;
        end if;
      else
        count <= 0;
      end if;
    end if;
  end process;

  y <= count;
end behavior;

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
    IN_SIZE  : integer := 16);
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

  component bin2sc is
    generic ( IN_SIZE : integer := 16);
    port (
      clk             : in std_logic;
      reset           : in std_logic;
      set_seed        : in std_logic;
      enable_in       : in std_logic;
      x               : in input_array(0 to IN_SIZE - 1);
      w               : in input_array(0 to IN_SIZE - 1);
      b               : in std_logic_vector(SC_WIDTH-1 downto 0);
      sc_x            : out std_logic_vector(0 to IN_SIZE - 1);
      sc_b            : out std_logic;
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
      y     : out std_logic
    );
  end component;

  component sc_sigmoid is
    port (
      clk    : in std_logic;
      reset  : in std_logic;
      enable : in std_logic;
      input  : in std_logic_vector(SUM_WIDTH-1 downto 0);
      output : out std_logic_vector(SC_WIDTH-1 downto 0)
    );
  end component;

  component sc_relu is
    port (
      clk    : in std_logic;
      reset  : in std_logic;
      enable : in std_logic;
      input  : in std_logic_vector(SUM_WIDTH-1 downto 0);
      bias   : in std_logic_vector(SC_WIDTH-1 downto 0);
      output : out std_logic_vector(SC_WIDTH-1 downto 0)
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
  signal sc_b    : std_logic;
  signal sc_sum  : std_logic;
  signal sc_sop  : std_logic;
  signal sc_mult : std_logic_vector(0 to IN_SIZE - 1);
  signal sc_tmp  : std_logic_vector(0 to 13);

  signal ctrl     : std_logic_vector(CTRL_WIDTH-1 downto 0);
  signal sop      : unsigned(SUM_WIDTH-1 downto 0);
  signal counter  : unsigned(SC_WIDTH-1 downto 0);
  signal sum      : unsigned(SUM_WIDTH-1 downto 0);

  --pragma synthesis_off
  signal v_x    : integer := 0;
  signal v_w    : integer := 0;
  signal v_mul  : integer := 0;
  signal v_sum  : integer := 0;
--pragma synthesis_on
begin

  --pragma synthesis_off
  -- For simulation
  count1: entity work.sc_counter
    port map (clk, reset, enable, sc_x(0), v_x);
  count2: entity work.sc_counter
    port map (clk, reset, enable, sc_w(0), v_w);
  count3: entity work.sc_counter
    port map (clk, reset, enable, sc_mult(0), v_mul);
  count4: entity work.sc_counter
    port map (clk, reset, enable, sc_sum, v_sum);
  --pragma synthesis_on

  sop_count: process (clk, reset)
    variable test_count : real := 1.0;
  begin
    if reset = '1' then
      sop     <= (others => '0');
      sum     <= (others => '0');
      counter <= (others => '0');
    elsif rising_edge(clk) then
      if set_seed = '1' then
        sop <= (others => '0');
        sum <= (others => '0');
        -- sop <= (SUM_WIDTH - SC_WIDTH - 1 downto 0 => '0')
               -- & unsigned(b);
        -- sum <= (SUM_WIDTH - SC_WIDTH - 1 downto 0 => '0')
               -- & unsigned(b);
      elsif enable = '1' then
        if sc_sop = '1' then
          sop <= sop + 1;
        end if;

        if sc_sum = '1' then
          sum <= sum + 1;
        end if;

        counter <= counter + 1;

      else
          -- sop <= (others => '0');
          -- sum <= (others => '0');
          counter <= (others => '0');
      end if;


      --pragma synthesis_off
      if counter = 2**SC_WIDTH-1 then

        print("sop_sc     = "
             & real'image(16.0*(real(to_integer(sop))/2.0**(SC_WIDTH-1)-test_count)));
        print("sum_sc     = " &
        real'image(32.0*(real(v_sum)/2.0**(SC_WIDTH-1) - test_count + 1.0)));

        test_count := test_count + 1.0;
      end if;
      --pragma synthesis_on

    end if;
  end process;

  mult_i: for i in 0 to IN_SIZE - 1 generate
      sc_mult(i) <= sc_x(i) xnor sc_w(i);
  end generate;

  -- sc_sum <= sc_mult(to_integer(unsigned(ctrl(3 downto 0))));

  -- binary adder tree
  adder0: sc_add
    port map(clk, reset, sc_mult(0), sc_mult(1), sc_tmp(0));
  adder1: sc_add
    port map(clk, reset, sc_mult(2), sc_mult(3), sc_tmp(1));
  adder2: sc_add
    port map(clk, reset, sc_mult(4), sc_mult(5), sc_tmp(2));
  adder3: sc_add
    port map(clk, reset, sc_mult(6), sc_mult(7), sc_tmp(3));
  adder4: sc_add
    port map(clk, reset, sc_mult(8), sc_mult(9), sc_tmp(4));
  adder5: sc_add
    port map(clk, reset, sc_mult(10), sc_mult(11), sc_tmp(5));
  adder6: sc_add
    port map(clk, reset, sc_mult(12), sc_mult(13), sc_tmp(6));
  adder7: sc_add
    port map(clk, reset, sc_mult(14), sc_mult(15), sc_tmp(7));
  adder8: sc_add
    port map(clk, reset, sc_tmp(0), sc_tmp(1), sc_tmp(8));
  adder9: sc_add
    port map(clk, reset, sc_tmp(2), sc_tmp(3), sc_tmp(9));
  adder10: sc_add
    port map(clk, reset, sc_tmp(4), sc_tmp(5), sc_tmp(10));
  adder11: sc_add
    port map(clk, reset, sc_tmp(6), sc_tmp(7), sc_tmp(11));
  adder12: sc_add
    port map(clk, reset, sc_tmp(8), sc_tmp(9), sc_tmp(12));
  adder13: sc_add
    port map(clk, reset, sc_tmp(10), sc_tmp(11), sc_tmp(13));
  adder14: sc_add
    port map(clk, reset, sc_tmp(12), sc_tmp(13), sc_sop);
  adder15: sc_add
    port map(clk, reset, sc_sop, sc_b, sc_sum);



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
      b           => b,
      w           => w,
      sc_x        => sc_x,
      sc_b        => sc_b,
      sc_w        => sc_w
    );

  lfsr_ctrl: lfsr
    generic map (
      DATA_WIDTH  => CTRL_WIDTH
    )
    port map (
      clk         => clk,
      reset       => reset,
      set_seed    => set_seed,
      seed_in     => std_logic_vector(to_unsigned(314, CTRL_WIDTH)),
      enable_in   => enable,
      lfsr_out    => ctrl);

  activation_function: sc_relu
    port map(
      clk    => clk,
      reset  => reset,
      enable => activ,
      bias   => b,
      input  => std_logic_vector(sum),
      output => y);

end architecture rtl;
