---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : top_module.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : May 04 2018 10:19
-- @Project         : Artificial Neural Network
-- @Module          : top_module
-- @Description     : Top module of Neural Network architecture, apply on
-- handwritten-digit recognization. Output 'max_index' signal is the digit
-- output will approach when finish assert.
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use work.conf.all;
-- library xil_defaultlib;
-- use xil_defaultlib.conf.all;

entity top_module is
	port (
    clk         : in std_logic;
    reset       : in std_logic;
    push_button : in std_logic_vector(1 downto 0);
    max_index   : out std_logic_vector(3 downto 0);
    finish      : out std_logic
  );
end top_module;

architecture behavioral of top_module is

  ------------- wires ----------------------
  -- controller
  signal read_ena      : std_logic := '0';
  signal readwrite_ena : std_logic := '0';
  signal mux_i_sel     : std_logic := '0';
  signal calculate     : std_logic := '0';
  signal activate      : std_logic := '0';

  -- neuron
  signal neuron_res : std_logic;
  signal neuron_y   : std_logic_vector(BIT_WIDTH-1 downto 0);

  -- Block rams
  -- image BRAM
  signal bram_i_ena : std_logic := '0';
  signal bram_i_adr : std_logic_vector(MEM_I_N-1 downto 0);
  signal bram_i_in  : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');
  signal bram_i_wea : std_logic_vector(0 to 0) := (others => '0');
  signal bram_i_out : input_array(0 to PARALLEL_RATE - 1);

  -- weight BRAM
  signal bram_w_ena : std_logic := '0';
  signal bram_w_adr : std_logic_vector(MEM_W_N-1 downto 0);
  signal bram_w_in  : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');
  signal bram_w_wea : std_logic_vector(0 to 0) := (others => '0');
  signal bram_w_out : input_array(0 to PARALLEL_RATE - 1);

  -- bias BRAM
  signal bram_b_ena : std_logic := '0';
  signal bram_b_adr : std_logic_vector(MEM_B_N-1 downto 0);
  signal bram_b_in  : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');
  signal bram_b_wea : std_logic_vector(0 to 0) := (others => '0');
  signal bram_b_out : std_logic_vector(BIT_WIDTH-1 downto 0);

  -- result BRAM
  signal bram_r_ena : std_logic := '0';
  signal bram_r_adr : std_logic_vector(MEM_R_N-1 downto 0);
  signal bram_r_in  : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');
  signal bram_r_wea : std_logic_vector(0 to 0) := (others => '0');
  signal bram_r_out : input_array(0 to PARALLEL_RATE - 1);

  -- mux -> neuron
  signal mux_out   : input_array(0 to PARALLEL_RATE - 1);

  -- max finder
  signal max_ena : std_logic;
  signal max_res : std_logic;

  -- display
  signal max_output   : std_logic_vector(BIT_WIDTH-1 downto 0);
  signal neuron_index : std_logic_vector(3 downto 0);

  signal sum_counter    : integer := 0;
  signal neuron_counter : integer := 0;
  signal layer_counter  : integer := 0;
begin

  ram_i: entity work.blk_mem_img
    port map (clka  => clk,
               ena   => read_ena,
               wea   => bram_i_wea,
               addra => bram_i_adr,
               dina  => bram_i_in,
               douta => bram_i_out);

  ram_w: entity work.blk_mem_weight
     port map (clka  => clk,
               ena   => read_ena,
               wea   => bram_w_wea,
               addra => bram_w_adr,
               dina  => bram_w_in,
               douta => bram_w_out);

  ram_b: entity work.blk_mem_bias
    port map (clka  => clk,
               ena   => read_ena,
               wea   => bram_b_wea,
               addra => bram_b_adr,
               dina  => bram_b_in,
               douta => bram_b_out);

  ram_r: entity work.blk_mem_res
     port map (clka  => clk,
               ena   => readwrite_ena,
               wea   => bram_r_wea,
               addra => bram_r_adr,
               dina  => neuron_y,
               douta => bram_r_out);

  ctrl: entity work.controller
    port map (clk          => clk,
              start        => push_button(0),
              restart      => push_button(1),
              finish       => finish,
              read_ena     => read_ena,
              wb_ena       => bram_r_wea(0),
              mux_i_sel    => mux_i_sel,
              reset_sum    => neuron_res,
              max_ena      => max_ena,
              calculate    => calculate,
              activate     => activate,
              reinit       => max_res,
              neuron_index => neuron_index,
              mem_i_adr    => bram_i_adr,
              mem_w_adr    => bram_w_adr,
              mem_b_adr    => bram_b_adr,
              mem_r_adr    => bram_r_adr);

   -- select data to neuron and ram enable signals
   readwrite_ena <= read_ena OR bram_r_wea(0);
   mux_out       <= bram_i_out when mux_i_sel = '0'
                    else bram_r_out;

  neuron_0: entity work.neuron
     port map(clk    => clk,
              reset  => reset,
              clear  => neuron_res,
              enable => calculate,
              activ  => activate,
              x      => mux_out,
              w      => bram_w_out,
              b      => bram_b_out,
              y      => neuron_y);

  max_0: entity work.max
    port map(clk,
             max_ena,
             max_res,
             neuron_y,
             neuron_index,
             max_output,
             max_index);

  --pragma synthesis_off
  count: process (reset,clk)
  begin
    if reset = '1' then
      sum_counter <= 0;
      neuron_counter <= 0;
      layer_counter <= 0;
    elsif rising_edge(clk) then
      if calculate = '1' then
        sum_counter <= sum_counter + 1;
      end if;
      if activate = '1' then
        neuron_counter <= neuron_counter + 1;
      sum_counter <= 0;
      end if;
      if bram_r_wea(0) = '1' then
        layer_counter <= layer_counter + 1;
      end if;
    end if;
  end process;
  --pragma synthesis_on
end behavioral;
