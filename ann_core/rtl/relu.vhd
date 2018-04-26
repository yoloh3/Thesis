---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : relu.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Mar 28 2018 13:38
-- @Project         : Artificial Neural Network
-- @Module          : relu
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

entity relu is
  port (
    clk    : in std_logic;
    reset  : in std_logic;
    enable : in std_logic;
    input  : in std_logic_vector(BIT_WIDTH-1 downto 0);
    output : out std_logic_vector(BIT_WIDTH-1 downto 0)
  );
end relu;

architecture behav of relu is
begin

  process (reset, clk) is
    variable out_real : real;
    variable counter  : integer := 1;
  begin
    if reset = '1' then
      output <= (others => '0');
    elsif rising_edge(clk) then
      if (enable = '1') then
        if input(BIT_WIDTH-1) = '0' then
          output <= input;
        else
          output <= (others => '0');
        end if;

        if input(BIT_WIDTH-1) = '0' then
          out_real := real(to_integer(signed(input))) / 2.0**FRACTION;
        else
          out_real := 0.0;
        end if;

        --pragma synthesis_off
        -- print("Relu out(" & integer'image(counter mod (NEURONS_N) ) & ") = "
             -- & real'image(out_real) & "  =>  "
             -- & integer'image((integer(out_real*2.0**FRACTION))));
        -- --pragma synthesis_on
        -- counter := counter + 1;
      end if;
     end if;
   end process;

end behav;
