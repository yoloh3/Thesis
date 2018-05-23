---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : conf.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : May 04 2018 08:54
-- @Project         : Artificial Neural Network
-- @Module          : template
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package conf is
  -- constants
  constant SYNTHESIS    : integer := 0;

  constant NUM_OF_TESTS : integer := 1000;
  constant BIT_WIDTH    : integer := 10;
  constant FRACTION     : integer := 4;

  constant SC_WIDTH     : integer := BIT_WIDTH;
  -- constant SC_DELAY     : integer := 2**SC_WIDTH-1;
  constant SC_DELAY      : integer := 1;

  constant PARALLEL_RATE : integer := 16;
  constant SUM_WIDTH     : integer := SC_WIDTH + 10;

  constant INPUTS_N      : integer := 784;
  constant NEURONS_N     : integer := 64;
  constant NEURONS_O     : integer := 10;
  constant LAYERS_N      : integer := 2;
  constant WEIGHTS_N     : integer := INPUTS_N*NEURONS_N + NEURONS_N*NEURONS_O;
  constant BIAS_N        : integer := NEURONS_N + NEURONS_O;

  -- bit widths for blockrams
  -- NOTE: Check if addr not enought
  constant MEM_I_N : integer := 23; --6; --23;
  constant MEM_W_N : integer := 16; --12; --16;
  constant MEM_B_N : integer := 6;
  constant MEM_R_N : integer := 7; --6; --7;

  type input_array is array (integer range <>)
    of std_logic_vector (BIT_WIDTH-1 downto 0);

end conf;

package body conf is
end conf;
