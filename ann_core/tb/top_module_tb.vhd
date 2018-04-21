---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : top_module_tb.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Mar 28 2018 17:49
-- @Project         : Artificial Neural Network
-- @Module          : top_module_tb
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
use std.textio.all;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
library std;
use std.env.finish;
-- library xil_defaultlib;
-- use xil_defaultlib.conf.all;

entity top_module_tb is
end top_module_tb;

architecture testbench of top_module_tb is
  component top_module is
	  port (
      clk         : in std_logic;
      reset       : in std_logic;
      push_button : in std_logic_vector(1 downto 0);
      max_index   : out std_logic_vector(3 downto 0);
      finish      : out std_logic
    );
  end component;

  constant period    : time      := 10 ns;
  signal clk         : std_logic := '0';
  signal reset       : std_logic := '1';
  signal fnish       : std_logic;
	signal push_button : std_logic_vector(1 downto 0) := "00";
  signal max_index   : std_logic_vector(3 downto 0);
begin

	  clk <= not clk after period / 2;
    reset <= '0' after 2 * period + period / 2;

		uut: top_module
      port map (clk          => clk,
                reset        => reset,
                push_button  => push_button,
                max_index    => max_index,
                finish       => fnish);

		stim_proc: process
      variable oline   : line;
      file myfile      : text;
		begin

      -- main running
			wait for period;
			push_button(0) <= '1';
			wait for period;
			push_button(0) <= '0';
			wait until fnish = '1';

      file_open(myfile, "../tb/output_ann.bin", APPEND_MODE);
      write(oline, integer'image(to_integer(unsigned((max_index))) - 1));
      writeline(myfile, oline);

      finish(1);
		end process;
end testbench;
