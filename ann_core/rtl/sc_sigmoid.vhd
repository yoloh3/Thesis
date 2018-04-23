---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : sc_sigmoid.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Mar 28 2018 13:38
-- @Project         : Artificial Neural Network
-- @Module          : sc_sigmoid
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conf.all;
use ieee.math_real.all;
--pragma synthesis_off
use work.tb_conf.all;
--pragma synthesis_on

entity sc_sigmoid is
  port (
    clk    : in std_logic;
    reset  : in std_logic;
    enable : in std_logic;
    input  : in std_logic_vector(SUM_WIDTH-1 downto 0);
    output : out std_logic_vector(SC_WIDTH-1 downto 0)
  );
end sc_sigmoid;

architecture LUT_funct of sc_sigmoid is
  function sigmoid_funct(input: real) return real is
  begin
      return 1.0 / (1.0 + exp(-input));
  end function;

  function real_to_sc (
    constant real_val : real;
    constant SIZE     : integer)
    return std_logic_vector
  is
    variable max_val : real;
    variable actual_val: integer;
  begin
    max_val := real(2**SIZE);
    actual_val := integer((real_val+1.0)/2.0*max_val);
    if actual_val < 0 then
        return std_logic_vector(to_unsigned(0, SIZE));
    elsif actual_val >= 2**SIZE then
        return std_logic_vector(to_unsigned(2**SIZE - 1, SIZE));
    else
        return std_logic_vector(to_unsigned(integer((real_val+1.0)/2.0*max_val), SIZE));
    end if;
  end function real_to_sc;

  -- IF tanh(): output.range=fraction bit + 1 (sign bit)
  constant DEPTH : integer := 2**SC_WIDTH;
  type mem_type is array(0 to DEPTH - 1)
    of std_logic_vector(SC_WIDTH-1 downto 0);

  function init_mem return mem_type is
    variable temp_mem   : mem_type;
    variable input_real : real := 0.0;
  begin
    for i in 0 to DEPTH - 1 loop
      input_real := 64.0 * (real(i)/2.0**(SC_WIDTH-1) - 1.0);

      temp_mem(i) := real_to_sc(sigmoid_funct(input_real), SC_WIDTH);
    end loop;
    return temp_mem;
  end function;

    signal mem: mem_type := init_mem;
begin
  process (reset, clk) is
    variable i : integer := 0;
  begin
    if reset = '1' then
      output <= (others => '0');
    elsif rising_edge(clk) then
      if (enable = '1') then
        output <= mem(to_integer(unsigned(input)));
        print("Sigmoid (" & integer'image(i) & "):"
            & real'image(sc_to_real(mem(to_integer(unsigned(input))))));
        i := i + 1;
        end if;
    end if;
  end process;
end LUT_funct;
