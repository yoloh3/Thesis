-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : sc_neuron_tb.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Apr 09 2018       @Modified Date : Apr 09 2018 18:07
-- @Project         : Artificial Neural Network
-- @Module          : sc_neuron_tb
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
use std.env.finish;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use work.conf.all;
use work.tb_conf.all;

entity sc_neuron_tb is
end sc_neuron_tb;

architecture behavioral of sc_neuron_tb is

  constant PERIOD  : time      := 10 ns;
  constant IN_SIZE : integer   := PARALLEL_RATE;
	signal clk       : std_logic := '0';
	signal reset     : std_logic := '1';
	signal set_seed  : std_logic := '0';
	signal enable    : std_logic := '0';
	signal activ     : std_logic := '0';

	signal x : input_array(0 to IN_SIZE-1) := (others => (others => '0'));
	signal w : input_array(0 to IN_SIZE-1) := (others => (others => '0'));
	signal b : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');
  signal y : std_logic_vector(BIT_WIDTH-1 downto 0);

  type real_array is array (integer range <>) of real;
  signal sum_old    : real := 0.0;
  signal mse_error  : real := 0.0;
  signal max_error  : real := 0.0;
  signal test_count : integer := 0;
  constant NUM_CAL  : integer := 1;

begin

  clk <= not(clk) after PERIOD / 2;
  reset <= '0' after 2 * PERIOD + PERIOD / 2;
  
  dut: entity work.sc_neuron
  generic map (
    IN_SIZE => IN_SIZE,
    NUM_CAL => NUM_CAL)
  port map (
    clk     => clk,
    reset   => reset,
    set_seed => set_seed,
    enable  => enable,
    activ   => activ,
    x       => x,
    w       => w,
    b       => b,
    y       => y
  );

  -- waveform generation
  WaveGen_proc: process
  procedure test_case (
    constant v_x : in real_array(0 to IN_SIZE-1);
    constant v_w : in real_array(0 to IN_SIZE-1);
    constant v_b : in real)
    -- constant v_s: in real)
  is
    variable v_y   : real;
    variable v_mse : real;
    variable a_y   : real;
    variable sum   : real;
  begin

    b <= real_to_sc(v_b / 16.0, SC_WIDTH);
    sum := sum_old;

    for i in 0 to IN_SIZE-1 loop
      x(i) <= real_to_sc(v_x(i), SC_WIDTH);
      w(i) <= real_to_sc(v_w(i), SC_WIDTH);
      sum := v_x(i) * v_w(i) + sum;
    end loop;
    v_y := relu_funct(sum + v_b);
    sum_old <= sum;

    if test_count = 1 then
      set_seed <= '1';
      wait until rising_edge(clk);
      set_seed <= '0';
    end if;

    enable <= '1';

    wait for (2**SC_WIDTH-1) * period;
    enable <= '0';
    activ <= '1';
    wait until rising_edge(clk);
    activ <= '0';
    wait until rising_edge(clk);
    wait for period / 8;

    -- print("sop_expect   = " & real'image(sum));
    -- print("    sum_expect   = " & real'image(sum+v_b));

    if test_count = NUM_CAL then
      a_y := 16.0 * (real(to_integer(unsigned(y)))
                  / 2.0**(SC_WIDTH-1) - 1.0);
      print("Expected vs actual:  "
          & real'image(sum + v_b) & " "
          & real'image(a_y));

      mse_error <= mse_error + mse(v_y, a_y);
      if (abs(v_y - a_y) > max_error) then
        max_error <= abs(v_y - a_y);
      end if;

      assert (abs(v_y - a_y) < 1.5 OR a_y > 15.5 OR a_y < -15.5)
        report "Far of wrong." severity failure;
    end if;

  end procedure test_case;

    variable test_num      : integer := 1000;
    variable input_num     : integer := NUM_CAL;
    constant rand_num      : integer := IN_SIZE * 2 + 1;
    variable seed1, seed2  : positive := 4;
    variable rand          : real_array(0 to rand_num - 1);
  begin
    mse_error <= 0.0;    
    max_error <= 0.0;    
    wait until reset = '0';


    for train in  0 to test_num - 1 loop
      test_count <= 0;
      sum_old  <= 0.0;

      uniform(seed1, seed2, rand(2*IN_SIZE));
      rand(2*IN_SIZE) := rand(2*IN_SIZE) * 2.0 - 1.0;

      for i in 0 to input_num - 1 loop
        wait for period;
        test_count <= test_count + 1;
        wait for period;

        for j in 0 to rand_num - 1 loop
          uniform(seed1, seed2, rand(j));
          rand(j) := (rand(j) * 2.0 - 1.0);
        end loop;

        test_case(rand(0 to IN_SIZE-1),
                  rand(IN_SIZE to 2*IN_SIZE-1),
                  rand(2*IN_SIZE));
      end loop;
    end loop;

    wait for period;
    print("Mse = "
      & real'image(mse_error / real(test_num)));
    print("Max error = " & real'image(max_error));


    print("");
    print("Test special 1:");
    for j in 0 to rand_num - 1 loop
      rand(j) := 1.0;
    end loop;
    test_case(rand(0 to IN_SIZE-1),
              rand(IN_SIZE to 2*IN_SIZE-1),
              rand(2*IN_SIZE));

    print("Test special 2:");
    for j in 0 to (rand_num-1)/2 - 1 loop
      rand(j) := 1.0;
    end loop;
    for j in (rand_num-1)/2 to rand_num-1 loop
      rand(j) := -1.0;
    end loop;
    test_case(rand(0 to IN_SIZE-1),
              rand(IN_SIZE to 2*IN_SIZE-1),
              rand(2*IN_SIZE));

    finish(1);
  end process;
end behavioral;

