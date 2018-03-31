---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : top_clk.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 30 2018       @Modified Date : Mar 30 2018 15:49
-- @Project         : Artificial Neural Network
-- @Module          : top_clk
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
-- library xil_defaultlib;
-- use xil_defaultlib.conf.all;

---------------------------------------------------------------------------------
-- Entity declaration
--------------------------------------------------------------------------------- 
entity top_clk is
  port (
    reset       : in std_logic;
    clk_in1_p   : in std_logic;
    clk_in1_n   : in std_logic;
    push_button : in std_logic_vector(1 downto 0);
    max_index   : out std_logic_vector(3 downto 0)
  );
end entity; 

---------------------------------------------------------------------------------
-- Architecture description
---------------------------------------------------------------------------------
architecture behavior of top_clk is
  component clk_gen is
  port  (
    clk_in1_p : in std_logic;
    clk_in1_n : in std_logic;
    clk_out1  : out std_logic;
    clk_out2  : out std_logic;
    reset     : in std_logic
   );
end component;

  component top_module is
    port (
      clk         : in std_logic;
      reset       : in std_logic;
      push_button : in std_logic_vector(1 downto 0);
      max_index   : out std_logic_vector(3 downto 0);
      finish      : out std_logic
    );
  end component;

  signal clk        : std_logic;
  signal clk_100mhz : std_logic;
  signal clk_50mhz  : std_logic;
  signal finish     : std_logic;
begin

  clk <= clk_50mhz;

  clk_gen_i: clk_gen
    port map (
      clk_in1_p => clk_in1_p,
      clk_in1_n => clk_in1_n,
      clk_out1  => clk_100mhz,
      clk_out2  => clk_50mhz,
      reset     => reset
    );

  top: top_module
    port map (
      clk         => clk,
      reset       => reset,
      push_button => push_button,
      max_index   => max_index,
      finish      => finish
    );

end behavior;

