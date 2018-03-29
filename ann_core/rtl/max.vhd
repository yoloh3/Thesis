library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.conf.all;
-- library xil_defaultlib;
-- use xil_defaultlib.conf.all;

entity max is
    port (
        clk       : in std_logic;
        ena       : in std_logic;
        res       : in std_logic;
        x         : in std_logic_vector(BIT_WIDTH-1 downto 0);
        index     : in std_logic_vector(3 downto 0);
        y         : out std_logic_vector(BIT_WIDTH-1 downto 0);
        max_index : out std_logic_vector(3 downto 0)
    );
end max;

architecture behavioral of max is
signal max           : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');
signal max_in        : std_logic_vector(BIT_WIDTH-1 downto 0) := (others => '0');
signal max_index_in  : std_logic_vector(3 downto 0) := (others => '0');
signal max_index_out : std_logic_vector(3 downto 0) := (others => '0');
begin
    reg_proc: process (clk, res) is
    begin
        if (res = '1') then
            max <= (others => '0');
            max_index_out <= (others => '0');
        elsif (rising_edge(clk)) then
            max_index_out <= max_index_in;
            max <= max_in;
        end if;
    end process;

    process (x, ena, index, max_index_out, max) is
    begin
        max_in <= max;
        max_index_in <= max_index_out;
        if (ena = '1') then
            if (signed(max) < signed(x)) then
                max_in <= x;
                max_index_in <= index;
            end if;
        end if;
    end process;

    y <= max;
    max_index <= max_index_out;
end behavioral;
