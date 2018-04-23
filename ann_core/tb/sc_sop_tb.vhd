---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : sc_sop_tb.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Apr 09 2018       @Modified Date : Apr 09 2018 18:07
-- @Project         : Artificial Neural Network
-- @Module          : sc_sop_tb
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

entity sc_sop_tb is
end sc_sop_tb;

architecture behavioral of sc_sop_tb is

	component sc_sop is
    generic ( 
      IN_SIZE  : integer := 16);
	  port (
	  	clk      : in std_logic;
	  	reset    : in std_logic;
	  	set_seed : in std_logic;
	  	enable   : in std_logic;
      activ    : in std_logic;
	  	x        : in input_array(0 to IN_SIZE - 1);
	  	w        : in input_array(0 to IN_SIZE - 1);
	    y        : out std_logic_vector(SUM_WIDTH-1 downto 0)
	  );
	end component;
		
  constant PERIOD  : time      := 10 ns;
  constant IN_SIZE : integer   := PARALLEL_RATE;
	signal clk       : std_logic := '0';
	signal reset     : std_logic := '1';
	signal set_seed  : std_logic := '0';
	signal enable    : std_logic := '0';
	signal activ     : std_logic := '0';

	signal x : input_array(0 to IN_SIZE-1) := (others => (others => '0'));
	signal w : input_array(0 to IN_SIZE-1) := (others => (others => '0'));
  signal y : std_logic_vector(SUM_WIDTH-1 downto 0);

  type real_array is array (integer range <>) of real;
  signal test_count : integer := 0;
  signal sum_tmp   : real := 0.0;
  signal mse_error : real := 0.0;
  signal max_error : real := 0.0;

begin

  clk <= not(clk) after PERIOD / 2;
  reset <= '0' after 2 * PERIOD + PERIOD / 2;
  
  dut: sc_sop
  generic map (
    IN_SIZE => IN_SIZE)
  port map (
    clk     => clk,
    reset   => reset,
    set_seed => set_seed,
    enable  => enable,
    activ   => activ,
    x       => x,
    w       => w,
    y       => y
  );

  -- waveform generation
  WaveGen_proc: process
  procedure test_case (
    constant v_x: in real_array(0 to IN_SIZE-1); 
    constant v_w: in real_array(0 to IN_SIZE-1);
    constant v_s: in real)
  is
    variable v_y: real;
    variable a_y: real;
    variable sum: real;
  begin
    sum := v_s;
    for i in 0 to IN_SIZE-1 loop
      x(i) <= real_to_sc(v_x(i), SC_WIDTH);
      w(i) <= real_to_sc(v_w(i), SC_WIDTH);
      sum := v_x(i) * v_w(i) + sum;
    end loop;
    v_y := sum;
    sum_tmp <= sum;

    if test_count = 0 then
      set_seed <= '1';
      wait until rising_edge(clk);
      set_seed <= '0';
    end if;
    test_count <= test_count + 1;

    enable   <= '1';
    wait for (2**SC_WIDTH-1) * period;
    enable   <= '0';
    activ    <= '1';
    wait until rising_edge(clk);
    activ    <= '0';
    wait for period / 8;

    a_y := 16.0 * (real(to_integer(unsigned(y))) / 2.0**(SC_WIDTH-1)
                   - real(test_count));
          

    print("Expected vs actual: "
        & real'image(v_y) & " "
        & real'image(a_y));
    print(" ");

    mse_error <= mse_error
         + mse(v_y, a_y);
    if (abs(v_y - a_y) > max_error) then
      max_error <= abs(v_y - a_y);
    end if;

  end procedure test_case;

    variable test_num      : integer := 49;
    constant rand_num      : integer := IN_SIZE * 2;
    variable seed1, seed2  : positive := 30;
    variable rand          : real_array(0 to rand_num - 1);
  begin
    mse_error <= 0.0;    
    max_error <= 0.0;    
    sum_tmp   <= 0.0;
    test_count <= 0;
    wait until reset = '0';


    for i in 0 to test_num - 1 loop
      print("* Test case (" & integer'image(i+1) & "):");
      for j in 0 to rand_num - 1 loop
        uniform(seed1, seed2, rand(j));  -- random value in range 0.0 to 1.0
        rand(j) := (rand(j) * 2.0 - 1.0);  -- convert -1.0 to 1.0
      end loop;

      test_case(rand(0 to IN_SIZE-1),
                rand(IN_SIZE to 2*IN_SIZE-1), sum_tmp);
    end loop;

    wait for period;
    print("Mse = "
      & real'image(mse_error / real(test_num)));
    print("Max error = " & real'image(max_error));

    finish(1);
  end process;
end behavioral;

