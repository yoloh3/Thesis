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
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

entity sc_neuron is
  generic (
    IN_SIZE : integer := 16);
  port(
  	clk     : in std_logic;
  	reset   : in std_logic;
    clear   : in std_logic;
  	enable  : in std_logic;
    activ   : in std_logic;
  	x       : in input_array(0 to IN_SIZE - 1);
  	w       : in input_array(0 to IN_SIZE - 1);
  	b       : in std_logic_vector(BIT_WIDTH-1 downto 0);
    y       : out std_logic_vector(BIT_WIDTH-1 downto 0)
  );
end sc_neuron;

architecture rtl of sc_neuron is

  component lfsr is
    generic (
      data_width : integer := 8);
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      seed_in     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      set_seed_in : in  std_logic;
      enable_in   : in  std_logic;
      lfsr_out    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

entity sc_mul is
  port (
    x1 : in std_logic;
    x2 : in std_logic;
    y  : out std_logic
  );
end entity; 



  signal sc_x : std_logic_vector(0 to IN_SIZE - 1); 
  signal sc_w : std_logic_vector(0 to IN_SIZE - 1); 
  signal sc_b : std_logic; 
  signal sc_y : std_logic; 

  constant DATA_WIDTH : integer := 8;

  type seed_in_t is array(integer range <>)
    of std_logic_vector(DATA_WIDTH-1 downto 0);

  procedure init_seed_in (
    type real_array is array (integer range <>) of real;
    v_seed_in_x : out seed_in_t(0 to IN_SIZE - 1); 
    v_seed_in_w : out seed_in_t(0 to IN_SIZE - 1); 
    v_seed_in_y : out std_logic_vector(DATA_WIDTH-1 downto 0));
  is
    constant rand_num     : integer := IN_SIZE * 2 + 1;
    variable seed1, seed2 : positive;
    variable rand_x       : real_array(0 to IN_SIZE - 1);
    variable rand_w       : real_array(0 to IN_SIZE - 1);
    variable rand_b       : real;
  begin
    for i in 0 to IN_SIZE - 1 loop
      uniform(seed1, seed2, rand_x(i));  -- random value in range 0.0 to 1.0
      uniform(seed1, seed2, rand_w(i));  -- random value in range 0.0 to 1.0
      rand_x(i) := (rand_x(i) * 2.0 - 1.0);  -- convert -1.0 to 1.0
      rand_w(i) := (rand_w(i) * 2.0 - 1.0);  -- convert -1.0 to 1.0
      v_seed_in_x(i) <=
       std_logic_vector(to_signed(integer(rand_x(i)*2.0**DATA_WIDTH, DATA_WIDTH)))
      v_seed_in_w(i) <=
       std_logic_vector(to_signed(integer(rand_w(i)*2.0**DATA_WIDTH, DATA_WIDTH)))
    end loop;

    uniform(seed1, seed2, rand_b);  -- random value in range 0.0 to 1.0
    rand_b := (rand_b * 2.0 - 1.0);  -- convert -1.0 to 1.0
    v_seed_in_b <=
     std_logic_vector(to_signed(integer(rand_b*2.0**DATA_WIDTH, DATA_WIDTH)))
  end procedure;

  signal seed_in_x : seed_in_t(0 to IN_SIZE - 1);
  signal seed_in_w : seed_in_t(0 to IN_SIZE - 1);
  signal seed_in_b : std_logic_vector(DATA_WIDTH-1 downto 0);

  signal sc_counter    : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
  signal sc_counter_in : std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');

  signal sum_tmp : std_logic;
  signal sum
begin  -- architecture beh

  for i in 0 to IN_SIZE - 1 generate
    sng_x: lfsr
    generic map (
      DATA_WIDTH => DATA_WIDTH)
    port map (
      clk         => clk,
      reset       => reset,
      set_seed_in => set_seed_in,
      seed_in     => seed_in_x(i),
      enable_in   => enable_in,
      lfsr_out    => sc_x(i)
    );
    sng_w: lfsr
    generic map (
      DATA_WIDTH => DATA_WIDTH)
    port map (
      clk         => clk,
      reset       => reset,
      set_seed_in => set_seed_in,
      seed_in     => seed_in_w(i),
      enable_in   => enable_in,
      lfsr_out    => sc_w(i)
    );
  end generate;

  sng_b: lfsr
  generic map (
    DATA_WIDTH => DATA_WIDTH)
  port map (
    clk         => clk,
    reset       => reset,
    set_seed_in => set_seed_in,
    seed_in     => seed_in_b,
    enable_in   => enable_in,
    lfsr_out    => sc_b
  );

  reg: process (clk, reset) is
  begin
    if reset = '1' then        
      sc_counter <= (others => '0'); 
      init_seed_in(seed_in_x, seed_in_w, seed_in_b);
    elsif rising_edge(clk) then
      sc_counter <= sc_counter_in;
    end if;
  end reg;

  sc_counter_in <= sc_counter;


  in  -- stochastic multiplication in bipolar domain
  sc_mul1 <= sc_input1 xnor sc_weight1;
  sc_mul2 <= sc_input2 xnor sc_weight2;

  sc_ctrl1 <= sc_mul1 xor sc_mul2;
  sc_ctrl2 <= sc_ctrl1;
  sc_ctrl3 <= sc_add1 xor sc_add2;

  tff: process (clk, rst_n) is
  begin  -- process sc_counter_proc
    if rst_n = '0' then                 -- asynchronous reset (active low)
        q_tff1 <= '0';
        q_tff2 <= '0';
        q_tff3 <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
        q_tff1 <= sc_ctrl1 xor q_tff1;
        q_tff2 <= sc_ctrl2 xor q_tff2;
        q_tff3 <= sc_ctrl3 xor q_tff3;
    end if;
  end process tff;

  sc_add1 <= q_tff1 when sc_ctrl1 = '1' else sc_mul1;
  sc_add2 <= q_tff2 when sc_ctrl2 = '1' else sc_bias;
  result   <= q_tff3 when sc_ctrl3 = '1' else sc_add2;
  result_out <= std_logic_vector(result_counter);

  count: process (clk, rst_n) is
  begin  -- process convert_proc
    if rst_n = '0'then
        counter <= (others => (others => '0'));
        count_out <= (others => (others => '0'));
    elsif rising_edge(clk) then         -- rising clock edge
        if enable = '1' then
            if sc_input1 = '1' then
                counter(0) <= counter(0) + 1;
            end if;
            if sc_input2 = '1' then
                counter(1) <= counter(1) + 1;
            end if;
            if sc_weight1 = '1' then
                counter(2) <= counter(2) + 1;
            end if;
            if sc_weight2 = '1' then
                counter(3) <= counter(3) + 1;
            end if;
            if sc_bias = '1' then
                counter(4) <= counter(4) + 1;
            end if;

            if sc_mul1 = '1' then
                count_out(0) <= count_out(0) + 1;
            end if;
            if sc_mul2 = '1' then
                count_out(1) <= count_out(1) + 1;
            end if;
            if sc_add1 = '1' then
                count_out(2) <= count_out(2) + 1;
            end if;
            if sc_add2 = '1' then
                count_out(3) <= count_out(3) + 1;
            end if;
        else
            counter <= (others => (others => '0'));
            count_out <= (others => (others => '0'));
        end if;
    end if;
  end process count;
end architecture rtl;
