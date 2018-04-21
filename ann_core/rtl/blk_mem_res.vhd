---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : blk_mem_res.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Mar 28 2018 17:45
-- @Project         : Artificial Neural Network
-- @Module          : blk_mem_res
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
entity blk_mem_res is
  port (
    clka  : in std_logic;
    ena   : in std_logic;
    wea   : in std_logic_vector(0 downto 0);
    addra : in std_logic_vector(MEM_R_N-1 downto 0);
    dina  : in std_logic_vector(BIT_WIDTH-1 downto 0);
    douta : out input_array(0 to PARALLEL_RATE - 1)
  );
end entity; 

---------------------------------------------------------------------------------
-- Architecture description
---------------------------------------------------------------------------------
architecture behavior of blk_mem_res is
  constant DEPTH : integer := BIAS_N + PARALLEL_RATE;

  signal ram : input_array(0 to DEPTH - 1)
    := (others => (others => '0'));
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

