---------------------------------------------------------------------------------
--
-- Copyright (c) 2017 by SISLAB Team, LSI Design Contest 2018.
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : sc_rtl_pkg.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Feb 06 2018       @Modified Date : Feb 06 2018 15:00
-- @Project         : Artificial Neural Network
-- @Module          : sc_rtl_pkg
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE ieee.math_real.ALL;

package sc_rtl_pkg is
  constant sc_data_width     : integer := 10;
  constant layer_input_size  : integer := 2;
  constant layer_hidden_size : integer := 3;
  constant layer_output_size : integer := 2;

  subtype sc_float_t
    is std_logic_vector(sc_data_width - 1 downto 0);
  type sc_array_t
    is array (integer range <>) of sc_float_t;
  type sc_array2_input2hidden_t
    is array (0 to layer_hidden_size - 1)
        of sc_array_t(0 to layer_input_size - 1);
  type sc_array2_hidden2output_t
    is array (0 to layer_output_size - 1)
        of sc_array_t(0 to layer_hidden_size - 1);

  type real_array_t is array (integer range <>) of real;
  type real_array21_t is array (0 to 2) of real_array_t(0 to 1);
  type real_array22_t is array (0 to 1) of real_array_t(0 to 2);

  function sigmoid_funct(input: real) return real;

end sc_rtl_pkg;


package body sc_rtl_pkg is

  function sigmoid_funct(input: real) return real is
  begin
      return 1.0 / (1.0 + exp(-input));
  end function;

end package body sc_rtl_pkg;
