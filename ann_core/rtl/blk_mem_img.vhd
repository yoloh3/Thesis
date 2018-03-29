---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : blk_mem_img.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Mar 28 2018 17:16
-- @Project         : Artificial Neural Network
-- @Module          : blk_mem_img
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------

---------------------------------------------------------------------------------
-- Library declaration
---------------------------------------------------------------------------------
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;
use work.conf.all;

---------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------- 
entity blk_mem_img is
  port (
    clka  : in std_logic;
    ena   : in std_logic;
    wea   : in std_logic_vector(0 downto 0);
    addra : in std_logic_vector(MEM_I_N-1 downto 0);
    dina  : in std_logic_vector(BIT_WIDTH-1 downto 0);
    douta : out input_array(0 to PARALLEL_RATE - 1)
  );
end entity; 

---------------------------------------------------------------------------------
-- Architecture description
---------------------------------------------------------------------------------
architecture behavior of blk_mem_img is
  constant DEPTH     : integer := INPUTS_N;
  constant file_name : string := "../tb/input.bin";

  impure function init_ram return input_array is
    variable ram_tmp : input_array(0 to DEPTH - 1);
    variable iline   : line;
    variable value   : real;
    file myfile      : text;
  begin
    file_open(myfile, file_name, read_mode);
    for i in 0 to DEPTH - 1 loop 
      readline(myfile, iline);
      read(iline, value);

      ram_tmp(i) :=
        std_logic_vector(to_signed(integer(value*2.0**FRACTION), BIT_WIDTH));
    end loop;
      return ram_tmp;
    file_close(myfile);
  end function;   

  signal ram : input_array(0 to DEPTH - 1) := init_ram;
begin
  process(clka)
    variable addr_int: integer;
  begin
    if rising_edge(clka) then
      if ena = '1' then
        addr_int := to_integer(unsigned(addra));
        if wea(0) = '1' then
          ram(addr_int) <= dina;
        else
          douta <= ram(addr_int to addr_int+PARALLEL_RATE-1);
        end if;
      end if;
    end if;
  end process;
end behavior;

