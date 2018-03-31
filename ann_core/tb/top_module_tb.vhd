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
library std;
use std.textio.all;
use std.env.finish;
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.numeric_std.all;
use work.conf.all;
use work.tb_conf.all;
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

		stim_proc : process
      type int_array is array (integer range <>) of integer;

      impure function init_expected return int_array is
        variable out_tmp : int_array(0 to NUM_OF_TESTS - 1);
        variable iline   : line;
        file myfile      : text;
      begin
        file_open(myfile, "../tb/output_labers.bin", read_mode);
        for i in 0 to NUM_OF_TESTS - 1 loop 
          readline(myfile, iline);
          read(iline, out_tmp(i));
        end loop;
        return out_tmp;
      end function;

      variable expected_out : int_array(0 to NUM_OF_TESTS - 1) := init_expected;
      variable actual_out   : int_array(0 to NUM_OF_TESTS - 1) := (others => 0);
      variable correct_num  : integer := 0;
		begin
      -- file_open(myfile, "../tb/output_ann.bin", APPEND_MODE);
      -- write(oline, integer'image(to_integer(unsigned(max_index)) - 1));
      -- writeline(myfile, oline);

      print("Run test:");
			wait for period;
			push_button(0) <= '1';
      wait until fnish = '1';

      actual_out(0) := to_integer(unsigned(max_index) - 1);
      if actual_out(0) = expected_out(0) then
        correct_num := correct_num + 1;
      end if;
      print("1");

      for i in 1 to NUM_OF_TESTS - 1 loop
        print(integer'image(i+1) & " ");
        push_button(0) <= '0';
        push_button(1) <= '1';
        wait for period;
        push_button(0) <= '1';
        wait until fnish = '1';
        actual_out(i) := to_integer(unsigned(max_index) - 1);
        if actual_out(i) = expected_out(i) then
          correct_num := correct_num + 1;
        end if;
      end loop;

      print("Classification: "
           & integer'image(correct_num)
           & "/" & integer'image(NUM_OF_TESTS));

      finish(1);
		end process;
end testbench;
