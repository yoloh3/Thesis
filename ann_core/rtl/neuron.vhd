---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : neuron.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Mar 28 2018 17:16
-- @Project         : Artificial Neural Network
-- @Module          : neuron
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
-- library xil_defaultlib;
-- use xil_defaultlib.conf.all;
library ieee;
use ieee.fixed_pkg.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_signed.all;
use work.conf.all;
use work.tb_conf.all;

entity neuron is
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
end neuron;

architecture behavioral of neuron is
  signal sum         : signed(BIT_WIDTH*2-1 downto 0) := (others => '0');
  signal sum_in      : signed(BIT_WIDTH*2-1 downto 0) := (others => '0');
  signal sum_tmp     : signed(BIT_WIDTH*2-1 downto 0) := (others => '0');
  signal sum_of_mult : signed(BIT_WIDTH*2-1 downto 0) := (others => '0');
  signal trunc_sum   : signed(BIT_WIDTH - 1 downto 0) := (others => '0');
  signal b_tmp       : std_logic_vector(BIT_WIDTH*2-1 downto 0) := (others => '0');
  signal overflow    : std_logic := '0';

  type mult_array is array (integer range <>)
    of signed(BIT_WIDTH * 2 - 1 downto 0);
  signal mult     : mult_array(0 to IN_SIZE-1) := (others => (others => '0'));
  signal mult_tmp : mult_array(0 to 14) := (others => (others => '0'));

component sigmoid is
  port (
    clk    : in std_logic;
    reset  : in std_logic;
    enable : in std_logic;
    input  : in std_logic_vector(BIT_WIDTH-1 downto 0);
    output : out std_logic_vector(BIT_WIDTH-1 downto 0)
  );
end component;

begin

  b_tmp <= (BIT_WIDTH-FRACTION-1 downto 0 => b(BIT_WIDTH - 1))
         & b
         & (FRACTION-1 downto 0 => '0');

  mult_i: for i in 0 to IN_SIZE - 1 generate
    mult(i) <= signed(x(i)) * signed(w(i));
  end generate;

  mult_tmp(0)  <= mult(0) + mult(1);
  mult_tmp(1)  <= mult(2) + mult(3);
  mult_tmp(2)  <= mult(4) + mult(5);
  mult_tmp(3)  <= mult(6) + mult(7);
  mult_tmp(4)  <= mult(8) + mult(9);
  mult_tmp(5)  <= mult(10) + mult(11);
  mult_tmp(6)  <= mult(12) + mult(13);
  mult_tmp(7)  <= mult(14) + mult(15);
  mult_tmp(8)  <= mult_tmp(0) + mult_tmp(1);
  mult_tmp(9)  <= mult_tmp(2) + mult_tmp(3);
  mult_tmp(10) <= mult_tmp(4) + mult_tmp(5);
  mult_tmp(11) <= mult_tmp(6) + mult_tmp(7);
  mult_tmp(12) <= mult_tmp(8) + mult_tmp(9);
  mult_tmp(13) <= mult_tmp(10) + mult_tmp(11);
  mult_tmp(14) <= mult_tmp(12) + mult_tmp(13);
  sum_of_mult  <= mult_tmp(14);

  sum_in <= sum_tmp;
  add_and_multiply: process (clk) is
  begin
    if reset = '1' then
      sum_tmp <= (others => '0');
    elsif (rising_edge(clk)) then
      if (clear = '1') then
        sum_tmp <= (others => '0');
      elsif (enable = '1') then
        sum_tmp <= sum_in + sum_of_mult;
      end if;
    end if;
  end process;
  sum <= sum_tmp + signed(b_tmp);

  truncation: process (sum) is
    variable mult_t : sfixed(2*(BIT_WIDTH-FRACTION)-1 downto -2*FRACTION);
    variable out_t  : sfixed(BIT_WIDTH-FRACTION-1 downto -FRACTION);
  begin
    -- detect overflow when truncating
    if sum >= signed(to_sfixed(MEM_I_N-1, mult_t)) then
      overflow <= '1';
      trunc_sum <= signed(to_sfixed(MEM_I_N-1, out_t));
    elsif sum < signed(to_sfixed(-MEM_I_N, mult_t)) then
      overflow <= '1';
      trunc_sum <= signed(to_sfixed(-MEM_I_N, out_t));
    else
      overflow <= '0';
      trunc_sum <= sum(BIT_WIDTH+FRACTION-1 downto FRACTION);
    end if;
  end process;

  activation_function: sigmoid
    port map(clk    => clk,
             reset  => reset,
             enable => activ,
             input  => std_logic_vector(trunc_sum),
             output => y);

end behavioral;
