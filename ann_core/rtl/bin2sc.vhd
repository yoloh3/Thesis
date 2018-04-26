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
  	w               : in input_array(0 to IN_SIZE - 1);
    sc_x            : out std_logic_vector(0 to IN_SIZE - 1);
    sc_0_5          : out std_logic;
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
    of std_logic_vector(SC_WIDTH - 1 downto 0);

  function init_seed_array (
    constant SIZE: integer
  )
    return seed_array
  is
    variable seed1, seed2 : positive;
    variable rand         : real_array(0 to SIZE-1);
    variable output_tmp   : seed_array(0 to SIZE-1);
  begin
    for i in 0 to SIZE-1 loop
      uniform(seed1, seed2, rand(i));
      rand(i) := (rand(i) * 2.0 - 1.0);
      output_tmp(i) := std_logic_vector(
        to_signed(integer(rand(i)*2.0**SC_WIDTH), SC_WIDTH));
    end loop;
      return output_tmp;
    end function;

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

  signal lfsr_x      : seed_array(0 to IN_SIZE - 1);
  signal lfsr_w      : seed_array(0 to IN_SIZE - 1);
  signal lfsr_0_5    : std_logic_vector(SC_WIDTH-1 downto 0);

  signal seed_x : seed_array(0 to IN_SIZE - 1)
    -- := (x"23", x"f2", x"10", x"a2",
        -- x"b2", x"2b", x"12", x"0a",
        -- x"52", x"9a", x"13", x"3c",
        -- x"c2", x"50", x"f2", x"ad");
    := ("10" & x"23", "11" & x"e2", "11" & x"10", "10" & x"a2",
        "01" & x"b5", "11" & x"fb", "11" & x"12", "10" & x"0f",
        "00" & x"f2", "11" & x"9a", "00" & x"a3", "00" & x"3c",
        "10" & x"c2", "00" & x"5e", "10" & x"f2", "00" & x"ad");
  signal seed_w : seed_array(0 to IN_SIZE - 1)
    -- := (x"ca", x"0f", x"c0", x"59",
        -- x"ca", x"c3", x"0f", x"99",
        -- x"c1", x"8f", x"50", x"2b",
        -- x"25", x"88", x"0e", x"e2");
    := ("10" & x"1a", "00" & x"0f", "10" & x"c0", "10" & x"59",
        "10" & x"cf", "10" & x"c3", "00" & x"0f", "01" & x"99",
        "11" & x"ef", "10" & x"8f", "10" & x"50", "11" & x"2b",
        "10" & x"25", "11" & x"85", "11" & x"0e", "10" & x"e2");

  signal seed_b   :
    std_logic_vector(SC_WIDTH-1 downto 0) := "01" & x"4a";
  signal seed_0_5 :
    std_logic_vector(SC_WIDTH-1 downto 0) := "11" & x"d3";

  constant val_0_5 : std_logic_vector(SC_WIDTH-1 downto 0)
    := std_logic_vector(to_signed(integer(0.5*2.0**SC_WIDTH), SC_WIDTH));
  
begin
  lfsr_sng_x: for i in 0 to IN_SIZE - 1 generate
    lfsr_sng_x_i: lfsr
    generic map (
      DATA_WIDTH => SC_WIDTH)
    port map (
      clk         => clk,
      reset       => reset,
      set_seed    => set_seed,
      seed_in     => seed_x(i),
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
      seed_in     => seed_w(i),
      enable_in   => enable_in,
      lfsr_out    => lfsr_w(i)
    );
  end generate;

  lfsr_sng_0_5: lfsr
  generic map (
    DATA_WIDTH => SC_WIDTH)
  port map (
    clk         => clk,
    reset       => reset,
    set_seed    => set_seed,
    seed_in     => seed_0_5,
    enable_in   => enable_in,
    lfsr_out    => lfsr_0_5 
  );

  sng: process (clk, reset)
  begin
    if reset = '1' then
      sc_x   <= (others => '0');
      sc_w   <= (others => '0');
      sc_0_5 <= '0';
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

      if unsigned(lfsr_0_5) < unsigned(val_0_5) then
        sc_0_5 <= '1';
      else 
        sc_0_5 <= '0';
      end if;

    end if;
  end process;

end behavior;
