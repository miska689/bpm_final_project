library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity counter_ms is
    Port (
        clk           : in  std_logic;
        reset         : in  std_logic;
        counting      : in  std_logic;
        duration_ms   : out unsigned(15 downto 0)  -- maxim 65535 ms
    );
end counter_ms;

architecture Behavioral of counter_ms is
    signal internal_counter : unsigned(15 downto 0) := (others => '0');
    
    -- Prescaler pentru generarea unui puls la 1ms (presupunem clk = 50 MHz)
    constant CLK_FREQ       : integer := 50_000_000;
    constant PRESCALER_MAX  : integer := CLK_FREQ / 1_000;  -- 1ms = 50000 cicluri

    signal prescaler        : integer := 0;
    signal tick_1ms         : std_logic := '0';
begin
    process(clk)
    begin
        if falling_edge(clk) then
            if prescaler = PRESCALER_MAX - 1 then
                prescaler <= 0;
                tick_1ms <= '1';
            else
                prescaler <= prescaler + 1;
                tick_1ms <= '0';
            end if;
        end if;
    end process;

    process(clk, reset, counting)
    begin
        if reset = '1' then
            internal_counter <= (others => '0');
        elsif rising_edge(clk) then
            if counting = '1' and tick_1ms = '1' then
                internal_counter <= internal_counter + 1;
            end if;
        end if;
    end process;

    duration_ms <= internal_counter;

end Behavioral;
