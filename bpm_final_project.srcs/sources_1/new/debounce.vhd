library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    Port (
        clk       : in  std_logic;
        rst       : in  std_logic;
        btn_raw   : in  std_logic;
        btn_clean : out std_logic
    );
end debounce;

architecture Behavioral of debounce is
    constant DEBOUNCE_TIME : integer := 500000; -- 10ms @ 50MHz
    signal counter         : integer range 0 to DEBOUNCE_TIME := 0;
    signal btn_sync_0      : std_logic := '0';
    signal btn_sync_1      : std_logic := '0';
    signal btn_state       : std_logic := '0';
begin

    -- Sincronizare pe două registre (pentru evitarea metastabilității)
    process(clk)
    begin
        if rising_edge(clk) then
            btn_sync_0 <= btn_raw;
            btn_sync_1 <= btn_sync_0;
        end if;
    end process;

    -- Debounce logic
    process(clk, rst)
    begin
        if rst = '1' then
            counter   <= 0;
            btn_state <= '0';
        elsif rising_edge(clk) then
            if btn_sync_1 /= btn_state then
                counter <= counter + 1;
                if counter >= DEBOUNCE_TIME then
                    btn_state <= btn_sync_1;
                    counter   <= 0;
                end if;
            else
                counter <= 0;
            end if;
        end if;
    end process;

    btn_clean <= btn_state;

end Behavioral;
