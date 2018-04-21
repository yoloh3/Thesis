---------------------------------------------------------------------------------
--
-- The University of Engineering and Technology, Vietnam National University.
-- All right resevered.
--
-- Copyright notification
-- No part may be reproduced except as authorized by written permission.
-- 
-- @File            : sigmoid.vhd
-- @Author          : Huy-Hung Ho       @Modifier      : Huy-Hung Ho
-- @Created Date    : Mar 28 2018       @Modified Date : Mar 28 2018 13:38
-- @Project         : Artificial Neural Network
-- @Module          : sigmoid
-- @Description     :
-- @Version         :
-- @ID              :
--
---------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;
use work.conf.all;
use ieee.math_real.all;
--pragma synthesis_off
use work.tb_conf.all;
--pragma synthesis_on
-- library xil_defaultlib;
-- use xil_defaultlib.conf.all;

entity sigmoid is
  port (
    clk    : in std_logic;
    reset  : in std_logic;
    enable : in std_logic;
    input  : in std_logic_vector(BIT_WIDTH-1 downto 0);
    output : out std_logic_vector(BIT_WIDTH-1 downto 0)
  );
end sigmoid;

architecture LUT_funct of sigmoid is
  function sigmoid_funct(input: real) return real is
  begin
      return 1.0 / (1.0 + exp(-input));
  end function;

  function real_to_stdlv (
    constant real_val : real;
    constant size     : integer;
    constant fract    : integer 
  )
  return std_logic_vector is
    variable max_val : real;
  begin
    max_val := real(2**FRACT);
    return std_logic_vector(to_signed(integer(real_val*max_val), size));
  end function real_to_stdlv;

  -- IF tanh(): output.range=fraction bit + 1 (sign bit)
  constant DEPTH : integer := 2**BIT_WIDTH;
  type mem_type is array(0 to DEPTH - 1)
    of std_logic_vector(FRACTION - 1 downto 0);

  function init_mem return mem_type is
    variable temp_mem : mem_type;
    variable input_real : real := 0.0;
    variable counter  : integer := 1;
  begin
    for i in 0 to DEPTH - 1 loop
      input_real := (real(i) / 2.0**(FRACTION) - 1.0);

      temp_mem(i) :=
        real_to_stdlv(sigmoid_funct(input_real), FRACTION, FRACTION);
      end loop;
      return temp_mem;
  end function;

    signal mem: mem_type := init_mem;
begin
  process (reset, clk) is
    variable output_tmp : std_logic_vector(FRACTION - 1 downto 0);
  begin
    if reset = '1' then
      output <= (others => '0');
    elsif rising_edge(clk) then
      if (enable = '1') then
        output_tmp := mem(to_integer(unsigned(input)));
        output <= (BIT_WIDTH - FRACTION - 1 downto 0 => '0' )
                 & output_tmp;
        end if;
    end if;
  end process;
end LUT_funct;

-- architecture behav of sigmoid is
  -- function sigmoid_funct(input: real) return real is
  -- begin
      -- return 1.0 / (1.0 + exp(-input));
  -- end function;

-- begin
  -- process (reset, clk) is
    -- variable out_real : real;
    -- variable counter  : integer := 1;
  -- begin

    -- if reset = '1' then
        -- output <= (others => '0');
    -- elsif rising_edge(clk) then
      -- if (enable = '1') then
        -- out_real := sigmoid_funct(real(to_integer(signed(input))) / 2.0**FRACTION);
        -- output <= std_logic_vector(to_signed(integer(out_real * 2.0**FRACTION), BIT_WIDTH));

        -- --pragma synthesis_off
        -- -- print("Sigmoid out(" & integer'image(counter mod (NEURONS_N) ) & ") = "
             -- -- & real'image(out_real) & "  =>  "
             -- -- & integer'image((integer(out_real*2.0**FRACTION))));
        -- --pragma synthesis_on

        -- counter := counter + 1;
      -- end if;
    -- end if;
  -- end process;

-- end behav;


-- architecture LUT of sigmoid is
-- begin
    -- process(enable) is
    -- begin
        -- if (enable = '1') then
            -- case input is
            -- when "00000000" => output <= "00001000";
            -- when "00000001" => output <= "00001000";
            -- when "00000010" => output <= "00001000";
            -- when "00000011" => output <= "00001001";
            -- when "00000100" => output <= "00001001";
            -- when "00000101" => output <= "00001001";
            -- when "00000110" => output <= "00001001";
            -- when "00000111" => output <= "00001010";
            -- when "00001000" => output <= "00001010";
            -- when "00001001" => output <= "00001010";
            -- when "00001010" => output <= "00001010";
            -- when "00001011" => output <= "00001011";
            -- when "00001100" => output <= "00001011";
            -- when "00001101" => output <= "00001011";
            -- when "00001110" => output <= "00001011";
            -- when "00001111" => output <= "00001011";
            -- when "00010000" => output <= "00001100";
            -- when "00010001" => output <= "00001100";
            -- when "00010010" => output <= "00001100";
            -- when "00010011" => output <= "00001100";
            -- when "00010100" => output <= "00001100";
            -- when "00010101" => output <= "00001101";
            -- when "00010110" => output <= "00001101";
            -- when "00010111" => output <= "00001101";
            -- when "00011000" => output <= "00001101";
            -- when "00011001" => output <= "00001101";
            -- when "00011010" => output <= "00001101";
            -- when "00011011" => output <= "00001110";
            -- when "00011100" => output <= "00001110";
            -- when "00011101" => output <= "00001110";
            -- when "00011110" => output <= "00001110";
            -- when "00011111" => output <= "00001110";
            -- when "00100000" => output <= "00001110";
            -- when "00100001" => output <= "00001110";
            -- when "00100010" => output <= "00001110";
            -- when "00100011" => output <= "00001110";
            -- when "00100100" => output <= "00001110";
            -- when "00100101" => output <= "00001111";
            -- when "00100110" => output <= "00001111";
            -- when "00100111" => output <= "00001111";
            -- when "00101000" => output <= "00001111";
            -- when "00101001" => output <= "00001111";
            -- when "00101010" => output <= "00001111";
            -- when "00101011" => output <= "00001111";
            -- when "00101100" => output <= "00001111";
            -- when "00101101" => output <= "00001111";
            -- when "00101110" => output <= "00001111";
            -- when "00101111" => output <= "00001111";
            -- when "00110000" => output <= "00001111";
            -- when "00110001" => output <= "00001111";
            -- when "00110010" => output <= "00001111";
            -- when "00110011" => output <= "00001111";
            -- when "00110100" => output <= "00001111";
            -- when "00110101" => output <= "00001111";
            -- when "00110110" => output <= "00001111";
            -- when "00110111" => output <= "00010000";
            -- when "00111000" => output <= "00010000";
            -- when "00111001" => output <= "00010000";
            -- when "00111010" => output <= "00010000";
            -- when "00111011" => output <= "00010000";
            -- when "00111100" => output <= "00010000";
            -- when "00111101" => output <= "00010000";
            -- when "00111110" => output <= "00010000";
            -- when "00111111" => output <= "00010000";
            -- when "01000000" => output <= "00010000";
            -- when "01000001" => output <= "00010000";
            -- when "01000010" => output <= "00010000";
            -- when "01000011" => output <= "00010000";
            -- when "01000100" => output <= "00010000";
            -- when "01000101" => output <= "00010000";
            -- when "01000110" => output <= "00010000";
            -- when "01000111" => output <= "00010000";
            -- when "01001000" => output <= "00010000";
            -- when "01001001" => output <= "00010000";
            -- when "01001010" => output <= "00010000";
            -- when "01001011" => output <= "00010000";
            -- when "01001100" => output <= "00010000";
            -- when "01001101" => output <= "00010000";
            -- when "01001110" => output <= "00010000";
            -- when "01001111" => output <= "00010000";
            -- when "01010000" => output <= "00010000";
            -- when "01010001" => output <= "00010000";
            -- when "01010010" => output <= "00010000";
            -- when "01010011" => output <= "00010000";
            -- when "01010100" => output <= "00010000";
            -- when "01010101" => output <= "00010000";
            -- when "01010110" => output <= "00010000";
            -- when "01010111" => output <= "00010000";
            -- when "01011000" => output <= "00010000";
            -- when "01011001" => output <= "00010000";
            -- when "01011010" => output <= "00010000";
            -- when "01011011" => output <= "00010000";
            -- when "01011100" => output <= "00010000";
            -- when "01011101" => output <= "00010000";
            -- when "01011110" => output <= "00010000";
            -- when "01011111" => output <= "00010000";
            -- when "01100000" => output <= "00010000";
            -- when "01100001" => output <= "00010000";
            -- when "01100010" => output <= "00010000";
            -- when "01100011" => output <= "00010000";
            -- when "01100100" => output <= "00010000";
            -- when "01100101" => output <= "00010000";
            -- when "01100110" => output <= "00010000";
            -- when "01100111" => output <= "00010000";
            -- when "01101000" => output <= "00010000";
            -- when "01101001" => output <= "00010000";
            -- when "01101010" => output <= "00010000";
            -- when "01101011" => output <= "00010000";
            -- when "01101100" => output <= "00010000";
            -- when "01101101" => output <= "00010000";
            -- when "01101110" => output <= "00010000";
            -- when "01101111" => output <= "00010000";
            -- when "01110000" => output <= "00010000";
            -- when "01110001" => output <= "00010000";
            -- when "01110010" => output <= "00010000";
            -- when "01110011" => output <= "00010000";
            -- when "01110100" => output <= "00010000";
            -- when "01110101" => output <= "00010000";
            -- when "01110110" => output <= "00010000";
            -- when "01110111" => output <= "00010000";
            -- when "01111000" => output <= "00010000";
            -- when "01111001" => output <= "00010000";
            -- when "01111010" => output <= "00010000";
            -- when "01111011" => output <= "00010000";
            -- when "01111100" => output <= "00010000";
            -- when "01111101" => output <= "00010000";
            -- when "01111110" => output <= "00010000";
            -- when "01111111" => output <= "00010000";
            -- when "10000000" => output <= "00000000";
            -- when "10000001" => output <= "00000000";
            -- when "10000010" => output <= "00000000";
            -- when "10000011" => output <= "00000000";
            -- when "10000100" => output <= "00000000";
            -- when "10000101" => output <= "00000000";
            -- when "10000110" => output <= "00000000";
            -- when "10000111" => output <= "00000000";
            -- when "10001000" => output <= "00000000";
            -- when "10001001" => output <= "00000000";
            -- when "10001010" => output <= "00000000";
            -- when "10001011" => output <= "00000000";
            -- when "10001100" => output <= "00000000";
            -- when "10001101" => output <= "00000000";
            -- when "10001110" => output <= "00000000";
            -- when "10001111" => output <= "00000000";
            -- when "10010000" => output <= "00000000";
            -- when "10010001" => output <= "00000000";
            -- when "10010010" => output <= "00000000";
            -- when "10010011" => output <= "00000000";
            -- when "10010100" => output <= "00000000";
            -- when "10010101" => output <= "00000000";
            -- when "10010110" => output <= "00000000";
            -- when "10010111" => output <= "00000000";
            -- when "10011000" => output <= "00000000";
            -- when "10011001" => output <= "00000000";
            -- when "10011010" => output <= "00000000";
            -- when "10011011" => output <= "00000000";
            -- when "10011100" => output <= "00000000";
            -- when "10011101" => output <= "00000000";
            -- when "10011110" => output <= "00000000";
            -- when "10011111" => output <= "00000000";
            -- when "10100000" => output <= "00000000";
            -- when "10100001" => output <= "00000000";
            -- when "10100010" => output <= "00000000";
            -- when "10100011" => output <= "00000000";
            -- when "10100100" => output <= "00000000";
            -- when "10100101" => output <= "00000000";
            -- when "10100110" => output <= "00000000";
            -- when "10100111" => output <= "00000000";
            -- when "10101000" => output <= "00000000";
            -- when "10101001" => output <= "00000000";
            -- when "10101010" => output <= "00000000";
            -- when "10101011" => output <= "00000000";
            -- when "10101100" => output <= "00000000";
            -- when "10101101" => output <= "00000000";
            -- when "10101110" => output <= "00000000";
            -- when "10101111" => output <= "00000000";
            -- when "10110000" => output <= "00000000";
            -- when "10110001" => output <= "00000000";
            -- when "10110010" => output <= "00000000";
            -- when "10110011" => output <= "00000000";
            -- when "10110100" => output <= "00000000";
            -- when "10110101" => output <= "00000000";
            -- when "10110110" => output <= "00000000";
            -- when "10110111" => output <= "00000000";
            -- when "10111000" => output <= "00000000";
            -- when "10111001" => output <= "00000000";
            -- when "10111010" => output <= "00000000";
            -- when "10111011" => output <= "00000000";
            -- when "10111100" => output <= "00000000";
            -- when "10111101" => output <= "00000000";
            -- when "10111110" => output <= "00000000";
            -- when "10111111" => output <= "00000000";
            -- when "11000000" => output <= "00000000";
            -- when "11000001" => output <= "00000000";
            -- when "11000010" => output <= "00000000";
            -- when "11000011" => output <= "00000000";
            -- when "11000100" => output <= "00000000";
            -- when "11000101" => output <= "00000000";
            -- when "11000110" => output <= "00000000";
            -- when "11000111" => output <= "00000000";
            -- when "11001000" => output <= "00000000";
            -- when "11001001" => output <= "00000000";
            -- when "11001010" => output <= "00000001";
            -- when "11001011" => output <= "00000001";
            -- when "11001100" => output <= "00000001";
            -- when "11001101" => output <= "00000001";
            -- when "11001110" => output <= "00000001";
            -- when "11001111" => output <= "00000001";
            -- when "11010000" => output <= "00000001";
            -- when "11010001" => output <= "00000001";
            -- when "11010010" => output <= "00000001";
            -- when "11010011" => output <= "00000001";
            -- when "11010100" => output <= "00000001";
            -- when "11010101" => output <= "00000001";
            -- when "11010110" => output <= "00000001";
            -- when "11010111" => output <= "00000001";
            -- when "11011000" => output <= "00000001";
            -- when "11011001" => output <= "00000001";
            -- when "11011010" => output <= "00000001";
            -- when "11011011" => output <= "00000001";
            -- when "11011100" => output <= "00000010";
            -- when "11011101" => output <= "00000010";
            -- when "11011110" => output <= "00000010";
            -- when "11011111" => output <= "00000010";
            -- when "11100000" => output <= "00000010";
            -- when "11100001" => output <= "00000010";
            -- when "11100010" => output <= "00000010";
            -- when "11100011" => output <= "00000010";
            -- when "11100100" => output <= "00000010";
            -- when "11100101" => output <= "00000010";
            -- when "11100110" => output <= "00000011";
            -- when "11100111" => output <= "00000011";
            -- when "11101000" => output <= "00000011";
            -- when "11101001" => output <= "00000011";
            -- when "11101010" => output <= "00000011";
            -- when "11101011" => output <= "00000011";
            -- when "11101100" => output <= "00000100";
            -- when "11101101" => output <= "00000100";
            -- when "11101110" => output <= "00000100";
            -- when "11101111" => output <= "00000100";
            -- when "11110000" => output <= "00000100";
            -- when "11110001" => output <= "00000101";
            -- when "11110010" => output <= "00000101";
            -- when "11110011" => output <= "00000101";
            -- when "11110100" => output <= "00000101";
            -- when "11110101" => output <= "00000101";
            -- when "11110110" => output <= "00000110";
            -- when "11110111" => output <= "00000110";
            -- when "11111000" => output <= "00000110";
            -- when "11111001" => output <= "00000110";
            -- when "11111010" => output <= "00000111";
            -- when "11111011" => output <= "00000111";
            -- when "11111100" => output <= "00000111";
            -- when "11111101" => output <= "00000111";
            -- when "11111110" => output <= "00001000";
            -- when "11111111" => output <= "00001000";
            -- when others => output <= "XXXXXXXX";
            -- end case;
        -- else
            -- output <= (others => '0');
        -- end if;
    -- end process;
-- end LUT;
