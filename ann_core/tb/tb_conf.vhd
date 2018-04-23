---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : tb_conf.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Mar 28 2018 13:12
-- @Project         : Artificial Neural Network
-- @Module          : tb_conf
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use std.textio.all;

package tb_conf is

  function real_to_stdlv (
    constant real_val : real;
    constant size     : integer;
    constant fract    : integer 
  )
    return std_logic_vector;

  function stdlv_to_real (
    constant stdlv : std_logic_vector;
    constant fract : integer
  )
    return real;

  function real_to_sc (
    constant real_val : real;
    constant size     : integer)
    return std_logic_vector;

  function sc_to_real (
    constant stdlv : std_logic_vector)
    return real;

  procedure print (
    constant str : in string);

  function mse(expected, actual: real) return real;

  function sigmoid_funct(input: real) return real;

  function relu_funct(input: real) return real;

end package tb_conf;



package body tb_conf is

  function real_to_stdlv (
    constant real_val : real;
    constant size     : integer;
    constant fract    : integer 
  )
  return std_logic_vector is
    variable max_val : real;
  begin
    max_val := real(2**fract);
    return std_logic_vector(to_signed(integer(real_val*max_val), size));
  end function real_to_stdlv;

  function stdlv_to_real(
    constant stdlv : std_logic_vector;
    constant fract : integer
  )
    return real
  is
  begin
    return real(to_integer(signed(stdlv))) / real(2**fract);
  end function stdlv_to_real;

  function real_to_sc (
    constant real_val : real;
    constant size     : integer
  )
    return std_logic_vector
  is
    variable max_val : real;
    variable actual_val: integer;
  begin
    max_val := real(2**size);
    actual_val := integer((real_val+1.0)/2.0*max_val);
    if actual_val < 0 then
        return std_logic_vector(to_unsigned(0, size));
    elsif actual_val >= 2**size then
        return std_logic_vector(to_unsigned(2**size - 1, size));
    else
        return std_logic_vector(to_unsigned(integer((real_val+1.0)/2.0*max_val), size));
    end if;
  end function real_to_sc;

  function sc_to_real (
    constant stdlv : std_logic_vector
  )
    return real
  is begin
    return real(to_integer(unsigned(stdlv))) / real(2**stdlv'length) * 2.0 - 1.0;
  end function sc_to_real;

  procedure print (
    constant str : in string)
  is
    variable msg : line;
  begin
    write(msg, str);
    writeline(output, msg);
  end procedure;

  function mse(expected, actual: real) return real is
  begin
      if expected = actual or abs(expected - actual) < 1.0e-8 then
          return 0.0;
      else
          return (expected - actual)**2;
      end if;
  end mse;

  function sigmoid_funct(input: real) return real is
  begin
      return 1.0 / (1.0 + exp(-input));
  end function;

  function relu_funct(input: real) return real is
    variable tmp: real;
  begin
    if input > 0.0 then
      tmp := input;
    else
      tmp := 0.0;
    end if;
    return tmp;
  end function;
eND PACKAGE BODY tb_conf;
