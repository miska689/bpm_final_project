-- Simulation for ms counter

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

entity tb_counter_ms is
end tb_counter_ms;

architecture Behavioral of tb_counter_ms is

    component counter_ms is
    Port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        counting      : in  std_logic;
        duration_ms   : out unsigned(15 downto 0)  -- maxim 65535 ms
    );
    end component counter_ms;

    signal clk           : std_logic := '0';
    signal reset         : std_logic := '0';
    signal counting      : std_logic := '0';
    signal duration_ms   : unsigned(15 downto 0);
    
    constant CLK_PERIOD : time := 20ns;
begin
    UUT1: counter_ms
        port map(
            clk         => clk,
            reset       => reset,
            counting    => counting,
            duration_ms => duration_ms
        );
    
    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process; 
    
    counter_sim: process
    begin
        counting <= '0';
        wait for 10ms;
        
        counting <= '1';
        wait for 10ms;
    end process;

end Behavioral;
