---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : template.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Mar 28 2018 12:06
-- @Project         : Artificial Neural Network
-- @Module          : template
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.numeric_bit.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all;

package conf is
  -- constants
  constant PARALLEL_RATE : integer := 16;
  constant INPUTS_N      : integer := 224;
  constant BIAS_N        : integer := 224;
  constant WEIGHTS_N     : integer := 10640;
  constant NEURONS_N     : integer := 40;
  constant LAYERS_N      : integer := 2;

  -- bit widths for blockrams
  constant MEM_I_N : integer := 8;
  constant MEM_W_N : integer := 14;
  constant MEM_R_N : integer := 7;

  constant BIT_WIDTH : integer := 16;
  constant FRACTION  : integer := 10;

  type input_array is array (integer range <>)
    of std_logic_vector (BIT_WIDTH-1 downto 0);

  function vectorize(s: std_logic) return std_logic_vector;
  function vectorize(v: std_logic_vector) return std_logic_vector;
  function to_bcd(bin: std_logic_vector(3 downto 0) ) return std_logic_vector;
end conf;

package body conf is
  function vectorize(s: std_logic) return std_logic_vector is
  variable v: std_logic_vector(0 downto 0);
  begin
      v(0) := s;
  return v;
  end;

  function vectorize(v: std_logic_vector) return std_logic_vector is
  begin
      return v;
  end;
  
  -- bcd converter
  function to_bcd ( bin : std_logic_vector(3 downto 0) ) return std_logic_vector is
    variable i : integer:=0;
    variable bcd : std_logic_vector(7 downto 0) := (others => '0');
    variable bint : std_logic_vector(3 downto 0) := bin;
    
  begin
    for i in 0 to 3 loop  -- repeating 8 times.
    bcd(7 downto 1) := bcd(6 downto 0);  --shifting the bits.
    bcd(0) := bint(3);
    bint(3 downto 1) := bint(2 downto 0);
    bint(0) :='0';
    
    
    if(i < 7 and bcd(3 downto 0) > "0100") then --add 3 if BCD digit is greater than 4.
    bcd(3 downto 0) := bcd(3 downto 0) + "0011";
    end if;
    
    if(i < 7 and bcd(7 downto 4) > "0100") then --add 3 if BCD digit is greater than 4.
    bcd(7 downto 4) := bcd(7 downto 4) + "0011";
    end if;
    
  end loop;
  return bcd;
  end to_bcd;
end conf;
