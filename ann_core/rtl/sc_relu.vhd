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
    input  : in std_logic_vector(SUM_WIDTH-1 downto 0);
    bias   : in std_logic_vector(SC_WIDTH-1 downto 0);
    output : out std_logic_vector(SC_WIDTH-1 downto 0)
  );
end sc_relu;

architecture behav of sc_relu is
  constant VAL_0_5: unsigned(SUM_WIDTH-1 downto 0)
    := (SUM_WIDTH-1 downto SC_WIDTH/2 => '0')
     & (SC_WIDTH/2-1 downto 0 => '1');
  signal out_tmp: unsigned(SC_WIDTH-1 downto 0);
begin

  process (reset, clk) is
    variable out_int : integer; 
  begin
    if reset = '1' then
      out_tmp <= VAL_0_5(SC_WIDTH-1 downto 0);
    elsif rising_edge(clk) then
      if (enable = '1') then
        -- out_int := 16 * ((to_integer(unsigned(input))) * 2 - 2*2**SC_WIDTH);

        -- print("out_tmp = " & real'image(real(out_int)/2.0**SC_WIDTH));

        -- out_tmp <= to_unsigned(integer(out_int), SC_WIDTH);
      end if;
    end if;
  end process;

  output <= std_logic_vector(out_tmp);
end behav;
