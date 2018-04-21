---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : controller.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Mar 28 2018 17:15
-- @Project         : Artificial Neural Network
-- @Module          : controller
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
library IEEE;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use work.conf.all;
-- library xil_defaultlib;
-- use xil_defaultlib.conf.all;

entity controller is
  port (
    clk          : in std_logic;
    start        : in std_logic;  -- push_button(0)
    restart      : in std_logic;  -- push_button(1)
    finish       : out std_logic := '0';
    read_ena     : out std_logic; 
    wb_ena       : out std_logic; -- bram_r_wea
    mux_i_sel    : out std_logic;
    reset_sum    : out std_logic; -- neuron_res
    max_ena      : out std_logic; 
    calculate    : out std_logic;
    activate     : out std_logic; 
    reinit       : out std_logic; -- max_res
    neuron_index : out std_logic_vector(3 downto 0);
    mem_i_adr    : out std_logic_vector(MEM_I_N-1 downto 0); -- bram_i_adr 
    mem_w_adr    : out std_logic_vector(MEM_W_N-1 downto 0); -- bram_w_adr
    mem_b_adr    : out std_logic_vector(MEM_B_N-1 downto 0); -- bram_b_adr
    mem_r_adr    : out std_logic_vector(MEM_R_N-1 downto 0)  -- bram_r_adr
  );
end controller;

architecture behavioral of controller is
  type state is (idle_state, read_state, wb_state, res_state, init_state, count_state,
      evaluate_state, calc_state, nlayer_state, display_state, reinit_state);
  signal current_state, next_state : state := idle_state;

  signal next_neuron, nlayer, validate, idle, done, ready      : std_logic := '0';
  signal input_counter, neuron_counter, layer_counter          : integer := 0;
  signal input_counter_in, neuron_counter_in, layer_counter_in : integer := 0;

  -- input address starts from 0, so it would skip first input and use bias 1 instead
  signal input_address  : std_logic_vector(MEM_I_N-1 downto 0) := (others => '0');
  signal weight_address : std_logic_vector(MEM_W_N-1 downto 0) := (others => '0');
  signal bias_address   : std_logic_vector(MEM_B_N-1 downto 0) := (others => '0');
  signal result_address : std_logic_vector(MEM_R_N-1 downto 0) := (others => '0');

  signal input_address_in  : std_logic_vector(MEM_I_N-1 downto 0) := (others => '0');
  signal weight_address_in : std_logic_vector(MEM_W_N-1 downto 0) := (others => '0');
  signal bias_address_in   : std_logic_vector(MEM_B_N-1 downto 0) := (others => '0');
  signal result_address_in : std_logic_vector(MEM_R_N-1 downto 0) := (others => '0');

  signal wb_address    : std_logic_vector(MEM_R_N-1 downto 0) := (others => '0');
  signal wb_address_in : std_logic_vector(MEM_R_N-1 downto 0) := (others => '0');

  signal num_of_inputs  : integer := INPUTS_N / PARALLEL_RATE - 1; -- number of inputs go in
  signal num_of_neurons : integer := NEURONS_N - 1;                -- number of neuron in current layer
  signal calc_count     : integer := 0;
  signal calc_count_in  : integer := 0;
  constant max_count    : integer := 1;
  signal input_addr_init  : std_logic_vector(MEM_I_N-1 downto 0) := (others => '0');
  signal input_addr_init_in : std_logic_vector(MEM_I_N-1 downto 0) := (others => '0');

begin

  mem_i_adr    <= input_address;
  mem_w_adr    <= weight_address;
  mem_b_adr    <= bias_address;
  mem_r_adr    <= result_address;
  neuron_index <= std_logic_vector(to_unsigned(neuron_counter + 1, neuron_index'length));

  state_change : process(clk)
  begin
    if rising_edge(clk) then
      current_state  <= next_state;

      input_counter       <= input_counter_in;
      neuron_counter      <= neuron_counter_in;
      layer_counter       <= layer_counter_in;
      input_address       <= input_address_in;
      input_addr_init  <= input_addr_init_in;
      weight_address      <= weight_address_in;
      bias_address        <= bias_address_in;
      result_address      <= result_address_in;
      wb_address          <= wb_address_in;
      calc_count          <= calc_count_in;
      finish              <= done;
    end if;
  end process;

  nsf : process (current_state, start, nlayer, next_neuron, done, restart,
    ready, calc_count) 
  begin
    case current_state is
      when idle_state =>
        if (start = '1') then
            next_state <= init_state;
        elsif (restart = '1') then
            next_state <= reinit_state;
        else
            next_state <= idle_state;
        end if;

      when reinit_state =>
        next_state <= idle_state;

      when init_state =>
        if (ready = '1') then
          next_state <= read_state;
        else
          next_state <= count_state;
        end if;

      when count_state =>
        next_state <= init_state;

      when read_state =>
          next_state <= calc_state;

      when calc_state =>
        if calc_count = max_count then
          if (next_neuron = '1') then
            next_state <= wb_state;
          else
            next_state <= read_state;
          end if;
        else
          next_state <= calc_state;
        end if;

      when wb_state =>
        next_state <= res_state;

      when res_state =>
        if (nlayer = '1') then
          next_state <= nlayer_state;
        else
          next_state <= read_state;
        end if;

      when nlayer_state =>
        if (done = '1') then
          next_state <= idle_state; -- todo: evaluate
        else
          next_state <= read_state;
        end if;

      when others =>
        next_state <= idle_state;
    end case;
  end process;

  control : process (current_state, neuron_counter, input_counter, calc_count, 
                      layer_counter, input_address, weight_address, bias_address,
                      result_address, wb_address, num_of_inputs, num_of_neurons,
                    input_addr_init)
  begin

      read_ena    <= '0';
      wb_ena      <= '0';
      reset_sum   <= '0';
      max_ena     <= '0';
      calculate   <= '0';
      activate    <= '0';
      reinit      <= '0';
      nlayer      <= '0';
      next_neuron <= '0';
      done        <= '0';

      neuron_counter_in      <= neuron_counter;
      input_counter_in       <= input_counter;
      layer_counter_in       <= layer_counter;
      input_address_in       <= input_address;
      input_addr_init_in  <= input_addr_init;
      weight_address_in      <= weight_address;
      result_address_in      <= result_address;
      wb_address_in          <= wb_address;


      case current_state is
        when idle_state =>
          neuron_counter_in <= 0;
          input_counter_in  <= 0;
          next_neuron       <= '0';
          done              <= '0';
          read_ena          <= '0';
          wb_ena            <= '0';
          max_ena           <= '0';
          calculate         <= '0';
          activate          <= '0';

        when reinit_state =>
          num_of_inputs     <= INPUTS_N / PARALLEL_RATE - 1;
          num_of_neurons    <= NEURONS_N - 1;
          neuron_counter_in <= 0;
          input_counter_in  <= 0;
          layer_counter_in  <= 0;
          input_address_in  <= input_addr_init + INPUTS_N;
          input_addr_init_in <= input_addr_init + INPUTS_N;
          weight_address_in <= (others => '0');
          bias_address_in   <= (others => '0');
          result_address_in <= (others => '0');
          reinit            <= '1';
          mux_i_sel         <= '0';

        when init_state =>
          read_ena  <= '1'; -- enable to brams and neuron
          calc_count_in <= 0;

        when count_state =>
          input_counter_in <= input_counter + 1;
          if (input_counter = 1) then
            input_counter_in <= 0;
            ready <= '1';
          end if;

        when read_state =>
          read_ena  <= '1'; -- enable to brams and neuron
          reset_sum <= '0';
          wb_ena    <= '0';
          max_ena   <= '0';
          calculate <= '0';
          activate  <= '0';
          wb_ena    <= '0';

          calc_count_in     <= calc_count + 1;
          input_counter_in  <= input_counter + 1;

          -- increase memory addresses
          input_address_in  <= input_address + PARALLEL_RATE;
          weight_address_in <= weight_address + PARALLEL_RATE;

          if layer_counter > 0 then
            mux_i_sel <= '1';
            result_address_in <= result_address + PARALLEL_RATE;
          else
            mux_i_sel <= '0';
            result_address_in <= wb_address;
          end if;
          
          if input_counter = num_of_inputs then
            next_neuron <= '1';
            bias_address_in  <= bias_address + 1;
          else
            next_neuron <= '0';
          end if;

        when calc_state =>
          calculate <= '1';
          if calc_count = max_count then
            calc_count_in <= 0;
          else
            calc_count_in <= calc_count + 1;
          end if;

          -- if all the inputs have been read, move to next neuron
          if input_counter = num_of_inputs + 1 then
            next_neuron <= '1';
          else
            next_neuron <= '0';
          end if;

        when wb_state =>
          calculate <= '1';
          wb_ena <= '0';
          activate <= '1'; -- enable activation function
          wb_address_in <= wb_address + 1;  -- for remembering where to save the answer

          -- if it's the last layer, find out maximum result also

        when res_state =>
          wb_ena     <= '1';
          reset_sum  <= '1';
          calc_count_in <= 0;

          -- if all neurons have been calculated, move to next state
          if neuron_counter = num_of_neurons then
            nlayer    <= '1';
          end if;

          next_neuron <= '0';
          -- increment neuron counter, reset input counter and image address
          neuron_counter_in <= neuron_counter + 1;
          input_counter_in <= 0;
          input_address_in <= input_addr_init;
          if layer_counter > 0 then
              result_address_in <= (others => '0');
          end if;
          -- if it's not an input layer then the input is coming from results RAM
          if layer_counter = LAYERS_N-1 then
            max_ena <= '1';
          end if;

        when nlayer_state =>
          wb_ena            <= '0';
          nlayer            <= '0';
          neuron_counter_in <= 0;
          -- inner control signals
          -- for next layer the num of inputs is equal to number of neurons
          -- in the last layer
          num_of_inputs <= NEURONS_N/PARALLEL_RATE - 1;
          num_of_neurons <= NEURONS_O - 1;

          layer_counter_in <= layer_counter + 1;
          result_address_in <= (others => '0');
          wb_address_in <= (others => '0');  -- for remembering where to save the answer

          if layer_counter = LAYERS_N-1 then
            done <= '1';
          end if;

        when others =>
          read_ena  <= '0';
          wb_ena    <= '0';
          reset_sum <= '0';
          max_ena   <= '0';
          calculate <= '0';
          activate  <= '0';
          reinit    <= '0';
      end case;
  end process;
end behavioral;
