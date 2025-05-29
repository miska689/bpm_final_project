library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_driver is
    Port (
        clk        : in  std_logic;
        reset      : in  std_logic;
        bpm_value  : in  unsigned(13 downto 0);  -- 0-9999
        seg        : out std_logic_vector(6 downto 0);
        an         : out std_logic_vector(3 downto 0)  -- active low pentru fiecare digit
    );
end display_driver;

architecture Behavioral of display_driver is
    signal digit_counter : unsigned(1 downto 0) := "00";
    signal clk_div       : unsigned(15 downto 0) := (others => '0');

    signal s_thousands, s_hundreds, s_tens, s_units : unsigned(3 downto 0);
    signal current_digit                    : unsigned(3 downto 0);
begin

    -- Frecvență de multiplexare (prescaler)
    process(clk, reset)
    begin
        if reset = '1' then
            clk_div <= (others => '0');
            digit_counter <= "00";
        elsif rising_edge(clk) then
            clk_div <= clk_div + 1;
            if clk_div = X"FFFF" then
                digit_counter <= digit_counter + 1;
            end if;
        end if;
    end process;

    -- Extragem cifrele individuale din bpm_value
    process(bpm_value)
        variable value : integer;
    begin
        value := to_integer(bpm_value);
        s_thousands <= to_unsigned((value / 1000) mod 10, 4);
        s_hundreds  <= to_unsigned((value / 100) mod 10, 4);
        s_tens      <= to_unsigned((value / 10) mod 10, 4);
        s_units     <= to_unsigned(value mod 10, 4);
    end process;

    -- Selectăm digitul curent pentru afișaj
    process(digit_counter, s_thousands, s_hundreds, s_tens, s_units)
    begin
        case digit_counter is
            when "00" =>
                current_digit <= s_units;
                an <= "1110";  -- active low
            when "01" =>
                current_digit <= s_tens;
                an <= "1101";
            when "10" =>
                current_digit <= s_hundreds;
                an <= "1011";
            when others =>
                current_digit <= s_thousands;
                an <= "0111";
        end case;
    end process;

    -- Afișare cifră selectată
    decoder: entity work.digit_to_7seg
        port map (
            digit => current_digit,
            seg   => seg
        );

end Behavioral;
