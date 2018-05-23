---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : sc_relu.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Apr 18 2018 09:28
-- @Project         : Artificial Neural Network
-- @Module          : sc_relu
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conf.all;
--pragma synthesis_off
use work.tb_conf.all;
--pragma synthesis_on

entity sc_relu is
  port (
    clk    : in std_logic;
    reset  : in std_logic;
    enable : in std_logic;
    input  : in std_logic_vector(SC_WIDTH-1 downto 0);
    output : out std_logic_vector(SC_WIDTH-1 downto 0)
  );
end sc_relu;

architecture behav of sc_relu is
  constant VAL_0_5: unsigned(SC_WIDTH-1 downto 0)
    := to_unsigned(2**(SC_WIDTH-1), SC_WIDTH);
begin

  process (reset, clk) is
  begin
    if reset = '1' then
      output <= (others => '0');
    elsif rising_edge(clk) then
      if (enable = '1') then
        if (unsigned(input) > VAL_0_5) then
          output <= input;
        else
          output <= std_logic_vector(VAL_0_5);
        end if;
      end if;
    end if;
  end process;
end behav;
