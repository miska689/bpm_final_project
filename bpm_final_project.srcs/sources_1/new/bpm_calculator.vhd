library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity bpm_calculator is
    Port (
        clk          : in  std_logic;
        reset        : in  std_logic;
        enable       : in  std_logic;
        duration_ms  : in  unsigned(15 downto 0);
        bpm_out      : out unsigned(13 downto 0);  -- până la 9999
        done         : out std_logic
    );
end bpm_calculator;

architecture Behavioral of bpm_calculator is
    constant MAX_TIME    : unsigned(15 downto 0) := to_unsigned(60000, 16);

    signal countdown     : unsigned(15 downto 0) := (others => '0');
    signal bpm_counter   : unsigned(13 downto 0) := (others => '0');
    signal total_elapsed : unsigned(15 downto 0) := (others => '0');
    signal working       : std_logic := '0';
begin

    process(clk, reset)
    begin
        if reset = '1' then
            countdown     <= (others => '0');
            bpm_counter   <= (others => '0');
            total_elapsed <= (others => '0');
            done          <= '0';
            working       <= '0';

        elsif rising_edge(clk) then
            if enable = '1' then
                countdown     <= duration_ms;
                bpm_counter   <= (others => '0');
                total_elapsed <= (others => '0');
                working       <= '1';
                done          <= '0';

            elsif working = '1' then
                if countdown > 0 then
                    countdown <= countdown - 1;
                    total_elapsed <= total_elapsed + 1;
                else
                    bpm_counter <= bpm_counter + 1;
                    countdown <= duration_ms;
                end if;

                if total_elapsed >= MAX_TIME then
                    done <= '1';
                    working <= '0';
                end if;
            end if;
        end if;
    end process;

    bpm_out <= bpm_counter;

end Behavioral;
