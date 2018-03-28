library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
--use ieee.std_logic_unsigned.all;
-- library xil_defaultlib;
-- use xil_defaultlib.conf.all;
use std.env.finish;
library ieee;
use ieee.fixed_pkg.all;
use ieee.math_real.all;
use work.conf.all;
use work.tb_conf.all;

entity neuron_tb is
end neuron_tb;

architecture behavioral of neuron_tb is

	component neuron is
    generic ( 
      IN_SIZE : integer := 16);
	  port (
	  	clk    : in std_logic;
	  	reset  : in std_logic;
	  	clear  : in std_logic;
	  	enable : in std_logic;
      activ  : in std_logic;
	  	x      : in input_array(0 to IN_SIZE - 1);
	  	w      : in input_array(0 to IN_SIZE - 1);
	  	b      : in std_logic_vector(BIT_WIDTH-1 downto 0);
	    y      : out std_logic_vector(BIT_WIDTH-1 downto 0)
	  );
	end component;
		
  constant PERIOD  : time      := 10 ns;
  constant IN_SIZE : integer   := PARALLEL_RATE;
	signal clk       : std_logic := '0';
	signal reset     : std_logic := '1';
	signal clear     : std_logic := '1';
	signal enable    : std_logic := '0';
	signal activ     : std_logic := '0';

	signal x : input_array(0 to IN_SIZE-1) := (others => (others => '0'));
	signal w : input_array(0 to IN_SIZE-1) := (others => (others => '0'));
	signal b : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');
  signal y : std_logic_vector(BIT_WIDTH-1 downto 0);

  type real_array is array (integer range <>) of real;

begin

  clk <= not(clk) after PERIOD / 2;
  reset <= '0' after 2 * PERIOD + PERIOD / 2;
  
  dut: neuron
  generic map (
    IN_SIZE => IN_SIZE)
  port map (
    clk     => clk,
    reset   => reset,
    clear   => clear,
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
    constant v_x: in real_array(0 to IN_SIZE-1); 
    constant v_w: in real_array(0 to IN_SIZE-1);
    constant v_b: in real)
  is
    variable v_y: real;
    variable sum: real;
  begin
    clear <= '1';
    wait until rising_edge(clk);
    clear <= '0';
    enable <= '1';

    b <= real_to_stdlv(v_b, BIT_WIDTH, FRACTION);
    sum := 0.0;
    for i in 0 to IN_SIZE-1 loop
      x(i) <= real_to_stdlv(v_x(i), BIT_WIDTH, FRACTION);
      w(i) <= real_to_stdlv(v_w(i), BIT_WIDTH, FRACTION);
      sum := v_x(i) * v_w(i) + sum;
    end loop;
    v_y := sigmoid_funct(sum + v_b);

    wait until rising_edge(clk);
    enable <= '0';
    activ <= '1';
    wait until rising_edge(clk);
    activ <= '0';
    wait for period / 8;

    print("At " & time'image(now) & ", expected vs actual: ");
    print(real'image(v_y) & " "
        & real'image(stdlv_to_real(y, FRACTION)));
    print(" ");

  end procedure test_case;

    variable test_num      : integer := 20;
    constant rand_num      : integer := IN_SIZE * 2 + 1;
    variable seed1, seed2  : positive;
    variable rand          : real_array(0 to rand_num - 1);
  begin
    wait until reset = '0';

    for i in 0 to test_num - 1 loop
      print("* Test case (" & integer'image(i+1) & "):");
        for j in 0 to rand_num - 1 loop
          uniform(seed1, seed2, rand(j));  -- random value in range 0.0 to 1.0
          rand(j) := (rand(j) * 2.0 - 1.0);  -- convert -1.0 to 1.0
        end loop;

        test_case(rand(0 to IN_SIZE-1),
                  rand(IN_SIZE to 2*IN_SIZE-1),
                  rand(2*IN_SIZE)
        );
     end loop;

    print("* Test special (1) (maximum):");
    for i in 0 to IN_SIZE - 1 loop
      rand(i) := 7.0;  -- convert -1.0 to 1.0
    end loop;
    for i in IN_SIZE to 2*IN_SIZE loop
      rand(i) := -7.0;  -- convert -1.0 to 1.0
    end loop;
    test_case(rand(0 to IN_SIZE-1),
              rand(IN_SIZE to 2*IN_SIZE-1),
              rand(2*IN_SIZE)
    );

    print("* Test special (2) (maximum):");
    for i in 0 to rand_num - 1 loop
      rand(i) := 7.8;  -- convert -1.0 to 1.0
    end loop;
    test_case(rand(0 to IN_SIZE-1),
              rand(IN_SIZE to 2*IN_SIZE-1),
              rand(2*IN_SIZE)
    );

    finish(1);
  end process;
end behavioral;

