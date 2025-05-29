library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_heart_rate_monitor is
end tb_heart_rate_monitor;

architecture Behavioral of tb_heart_rate_monitor is

    signal clk       : std_logic := '0';
    signal reset     : std_logic := '0';
    signal pulse_in  : std_logic := '0';
    signal seg       : std_logic_vector(6 downto 0);
    signal an        : std_logic_vector(3 downto 0);

    constant CLK_PERIOD : time := 20 ns;  -- 50 MHz

begin

    -- Instanțiem modulul de testat
    uut: entity work.heart_rate_monitor
        port map (
            clk       => clk,
            reset     => reset,
            pulse_in  => pulse_in,
            seg       => seg,
            an        => an
        );

    -- Ceas de 50 MHz
    clk_process : process
    begin
        while now < 2 sec loop
            clk <= '0';
            wait for CLK_PERIOD / 2;
            clk <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
        wait;
    end process;

    -- Simulare impulsuri
    stim_proc : process
    begin
        wait for 100 ms;
        pulse_in <= '1';  -- primul impuls
        wait for 20 ns;
        pulse_in <= '0';

        wait for 1000 ms;  -- așteptăm 1 secundă

        pulse_in <= '1';  -- al doilea impuls
        wait for 20 ns;
        pulse_in <= '0';

        wait for 500 ms;
    end process;

end Behavioral;
