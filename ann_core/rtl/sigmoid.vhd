---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : sigmoid.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : May 04 2018 10:21
-- @Project         : Artificial Neural Network
-- @Module          : sigmoid
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

entity sigmoid is
  port (
    clk    : in std_logic;
    reset  : in std_logic;
    enable : in std_logic;
    input  : in std_logic_vector(BIT_WIDTH-1 downto 0);
    output : out std_logic_vector(BIT_WIDTH-1 downto 0)
  );
end sigmoid;

architecture LUT_funct of sigmoid is
  function sigmoid_funct(input: real) return real is
  begin
      return 1.0 / (1.0 + exp(-input));
  end function;

  function real_to_stdlv (
    constant real_val : real;
    constant size     : integer;
    constant fract    : integer
  )
  return std_logic_vector is
    variable max_val : real;
  begin
    max_val := real(2**FRACT);
    return std_logic_vector(to_signed(integer(real_val*max_val), size));
  end function real_to_stdlv;

  -- IF tanh(): output.range=fraction bit + 1 (sign bit)
  constant DEPTH : integer := 2**BIT_WIDTH;
  type mem_type is array(-DEPTH/2 to DEPTH/2 - 1)
    of std_logic_vector(FRACTION downto 0);

  function init_mem return mem_type is
    variable temp_mem : mem_type;
    variable input_real : real := 0.0;
    variable counter  : integer := 1;
  begin
    for i in -DEPTH/2 to DEPTH/2 - 1 loop
      input_real := real(i) / 2.0**(FRACTION);

      temp_mem(i) :=
        real_to_stdlv(sigmoid_funct(input_real), FRACTION+1, FRACTION);
      end loop;
      return temp_mem;
  end function;

    signal mem: mem_type := init_mem;
begin
  process (reset, clk) is
    variable output_tmp : std_logic_vector(FRACTION downto 0);
  begin
    if reset = '1' then
      output <= (others => '0');
    elsif rising_edge(clk) then
      if (enable = '1') then
        output_tmp := mem(to_integer(signed(input)));
        output <= (BIT_WIDTH - FRACTION - 2 downto 0 => '0' )
                 & output_tmp;
      else
        output <= (others => '0');
        end if;
    end if;
  end process;
end LUT_funct;
