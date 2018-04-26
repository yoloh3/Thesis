---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : bin2sc.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Apr 03 2018       @Modified Date : Apr 03 2018 13:19
-- @Project         : Artificial Neural Network
-- @Module          : bin2sc
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Library declaration
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.math_real.all;
use ieee.numeric_std.all;
use work.conf.all;

---------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------- 
entity bin2sc is
  generic ( IN_SIZE : integer := 16);
  port (
    clk             : in std_logic;
    reset           : in std_logic;
    set_seed        : in std_logic;
    enable_in       : in std_logic;
  	x               : in input_array(0 to IN_SIZE - 1);
  	b               : in std_logic_vector(BIT_WIDTH-1 downto 0);
  	w               : in input_array(0 to IN_SIZE - 1);
    sc_x            : out std_logic_vector(0 to IN_SIZE - 1);
    sc_b            : out std_logic;
    sc_w            : out std_logic_vector(0 to IN_SIZE - 1)
  );
end entity; 

---------------------------------------------------------------------------------
-- Architecture description
---------------------------------------------------------------------------------
architecture behavior of bin2sc is

  component lfsr is
    generic (
      DATA_WIDTH : integer := 8);
    port (
      clk         : in  std_logic;
      reset       : in  std_logic;
      seed_in     : in  std_logic_vector(DATA_WIDTH-1 downto 0);
      set_seed    : in  std_logic;
      enable_in   : in  std_logic;
      lfsr_out    : out std_logic_vector(DATA_WIDTH-1 downto 0)
    );
  end component;

  type real_array is array (integer range <>) of real;
  type seed_array is array (integer range <>)
    of std_logic_vector(15 downto 0);
  type lfsr_array is array (integer range <>)
    of std_logic_vector(SC_WIDTH-1 downto 0);

  function init_seed
    return std_logic_vector
  is
    variable seed1, seed2 : positive;
    variable rand         : real;
  begin
    uniform(seed1, seed2, rand);
    rand := (rand * 2.0 - 1.0);
    return std_logic_vector(
      to_signed(integer(rand*2.0**SC_WIDTH), SC_WIDTH));
  end function;

  signal lfsr_x : lfsr_array(0 to IN_SIZE - 1);
  signal lfsr_w : lfsr_array(0 to IN_SIZE - 1);
  signal lfsr_b : std_logic_vector(SC_WIDTH-1 downto 0);

  signal seed_x : seed_array(0 to IN_SIZE - 1)
    := (x"fa23", x"faf2", x"1fa0", x"a2fa",
        x"b322", x"293b", x"1012", x"0a93",
        x"50e2", x"9a9a", x"10d3", x"3c9a",
        x"cd12", x"52a0", x"f192", x"ad9d");

  signal seed_w : seed_array(0 to IN_SIZE - 1)
    := (x"a2ca", x"0a2f", x"c1a0", x"5f29",
        x"9aca", x"c9a3", x"09af", x"91a9",
        x"9fc1", x"8a3f", x"59d0", x"952b",
        x"2a15", x"8d28", x"09ae", x"e652");

  signal seed_b   :
    std_logic_vector(15 downto 0) := x"384a";

begin
  lfsr_sng_x: for i in 0 to IN_SIZE - 1 generate
    lfsr_sng_x_i: lfsr
    generic map (
      DATA_WIDTH => SC_WIDTH)
    port map (
      clk         => clk,
      reset       => reset,
      set_seed    => set_seed,
      seed_in     => seed_x(i)(SC_WIDTH-1 downto 0),
      enable_in   => enable_in,
      lfsr_out    => lfsr_x(i)
    );

    lfsr_sng_w_i: lfsr
    generic map (
      DATA_WIDTH => SC_WIDTH)
    port map (
      clk         => clk,
      reset       => reset,
      set_seed    => set_seed,
      seed_in     => seed_w(i)(SC_WIDTH-1 downto 0),
      enable_in   => enable_in,
      lfsr_out    => lfsr_w(i)
    );
  end generate;

  lfsr_sng_b: lfsr
  generic map (
    DATA_WIDTH => SC_WIDTH)
  port map (
    clk         => clk,
    reset       => reset,
    set_seed    => set_seed,
    seed_in     => seed_b(SC_WIDTH-1 downto 0),
    enable_in   => enable_in,
    lfsr_out    => lfsr_b
  );

  sng: process (clk, reset)
  begin
    if reset = '1' then
      sc_x   <= (others => '0');
      sc_w   <= (others => '0');
      sc_b <= '0';
    elsif rising_edge(clk) then
      for i in 0 to IN_SIZE - 1 loop
        if unsigned(lfsr_x(i)) < unsigned(x(i)) then
          sc_x(i) <= '1';
        else 
          sc_x(i) <= '0';
        end if;

        if unsigned(lfsr_w(i)) < unsigned(w(i)) then
          sc_w(i) <= '1';
        else 
          sc_w(i) <= '0';
        end if;
      end loop;

      if unsigned(lfsr_b) < unsigned(b) then
        sc_b <= '1';
      else 
        sc_b <= '0';
      end if;

    end if;
  end process;

end behavior;
