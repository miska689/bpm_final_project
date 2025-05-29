library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity heart_rate_monitor is
    Port (
        clk        : in  std_logic;             -- ceas sistem
        reset      : in  std_logic;
        pulse_in   : in  std_logic;             -- intrare de la buton/pin JA
        seg        : out std_logic_vector(6 downto 0); -- segmente 7-seg
        an         : out std_logic_vector(3 downto 0)  -- digit select (active low)
    );
end heart_rate_monitor;

architecture Behavioral of heart_rate_monitor is

    -- Durata măsurată între două impulsuri
    signal duration_ms  : unsigned(15 downto 0) := (others => '0');
    signal bpm_value    : unsigned(13 downto 0) := (others => '0');
    signal start_bpm    : std_logic := '0';
    signal bpm_done     : std_logic := '0';

    signal pulse_prev   : std_logic := '0';
    signal counting     : std_logic := '0';
    signal ms_counter   : unsigned(15 downto 0) := (others => '0');

    -- Ceas pentru 1 ms
    constant clk_freq     : integer := 50000000; -- exemplu: 50 MHz
    constant ticks_1ms    : integer := clk_freq / 1000;
    signal tick_count     : integer range 0 to ticks_1ms := 0;
    signal tick_1ms       : std_logic := '0';

begin

    -- DIVIZOR DE CEAS: generează 1 ms tick
    process(clk)
    begin
        if rising_edge(clk) then
            if tick_count = ticks_1ms - 1 then
                tick_1ms <= '1';
                tick_count <= 0;
            else
                tick_count <= tick_count + 1;
                tick_1ms <= '0';
            end if;
        end if;
    end process;

    -- DETECȚIE IMPULS: flanc crescător
    process(clk)
    begin
        if rising_edge(clk) then
            pulse_prev <= pulse_in;

            if pulse_prev = '0' and pulse_in = '1' then
                if counting = '0' then
                    -- Începem măsurătoarea
                    counting <= '1';
                    ms_counter <= (others => '0');
                else
                    -- Al doilea impuls: salvează durata
                    counting <= '0';
                    duration_ms <= ms_counter;
                    start_bpm <= '1';
                end if;
            elsif counting = '1' and tick_1ms = '1' then
                ms_counter <= ms_counter + 1;
            end if;
        end if;
    end process;

    -- MODUL DE CALCUL BPM
    bpm_calc: entity work.bpm_calculator
        port map (
            clk         => clk,
            reset       => reset,
            enable      => start_bpm,
            duration_ms => duration_ms,
            bpm_out     => bpm_value,
            done        => bpm_done
        );

    -- Semnal de control start
    process(clk)
    begin
        if rising_edge(clk) then
            if start_bpm = '1' then
                start_bpm <= '0';  -- declanșează doar o dată
            end if;
        end if;
    end process;

    -- MODUL Afișaj 7 segmente
    display: entity work.display_driver
        port map (
            clk        => clk,
            reset      => reset,
            bpm_value  => bpm_value,
            seg        => seg,
            an         => an
        );

end Behavioral;
