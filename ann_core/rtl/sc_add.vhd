---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : sc_add.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 30 2018       @Modified Date : Mar 30 2018 22:32
-- @Project         : Artificial Neural Network
-- @Module          : sc_add
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

---------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------- 
entity sc_add is
  port (
    clk   : in std_logic;
    reset : in std_logic;
    x1    : in std_logic;
    x2    : in std_logic;
    sel   : in std_logic;
    y     : out std_logic
  );
end entity; 

---------------------------------------------------------------------------------
-- Architecture description
---------------------------------------------------------------------------------
architecture behavior of sc_add is
  signal ctrl    : std_logic;
  signal q, q_in : std_logic;
begin
  ctrl <= x1 XOR x2;

  tff: process (clk, reset) is
  begin
    if reset = '1' then
        q <= '0';
    elsif rising_edge(clk) then         -- rising clock edge
        q <= ctrl XOR q_in;
    end if;
  end process tff;
  q_in <= q; 

  y <= q when ctrl = '1' else x1;
end behavior;
