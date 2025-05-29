library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all;

entity bpm_fsm is
    Port (
        clk         : in  std_logic;
        reset       : in  std_logic;
        pulse_in    : in  std_logic;
        bpm_result  : out unsigned(13 downto 0);
        duration_result : out unsigned(15 downto 0);
        enable_bpm  : out std_logic;
        done_bpm    : out std_logic;
        state       : out state_type;
        counter_state: out std_logic;
        pulse_in_d_tb : out std_logic;
        pulse_fall_tb: out std_logic;
        pulse_rise_tb : out std_logic
    );
end bpm_fsm;

architecture Behavioral of bpm_fsm is
    component counter_ms is
        Port (
            clk           : in  std_logic;
            reset         : in  std_logic;
            counting      : in  std_logic;
            duration_ms   : out unsigned(15 downto 0)  -- maxim 65535 ms
        );
    end component counter_ms;
    
    component bpm_calculator is
        Port (
            clk          : in  std_logic;
            reset        : in  std_logic;
            enable       : in  std_logic;
            duration_ms  : in  unsigned(15 downto 0);
            bpm_out      : out unsigned(13 downto 0);  -- până la 9999
            done         : out std_logic
        );
    end component bpm_calculator;
    
    component driver7seg is
        Port ( clk : in STD_LOGIC; --100MHz board clock input
               Din : in STD_LOGIC_VECTOR (15 downto 0); --16 bit binary data for 4 displays
               an : out STD_LOGIC_VECTOR (3 downto 0); --anode outputs selecting individual displays 3 to 0
               seg : out STD_LOGIC_VECTOR (0 to 6); -- cathode outputs for selecting LED-s in each display
               dp_in : in STD_LOGIC_VECTOR (3 downto 0); --decimal point input values
               dp_out : out STD_LOGIC; --selected decimal point sent to cathodes
               rst : in STD_LOGIC
        );
    end component driver7seg; 
    
    component debounce is
        Port (
            clk       : in  std_logic;
            rst       : in  std_logic;
            btn_raw   : in  std_logic;
            btn_clean : out std_logic
        );
    end component debounce;
    
    signal current_state, next_state : state_type;
    
    signal counting    : std_logic := '0';
    signal duration_ms : unsigned(15 downto 0);
    signal enable      : std_logic := '0';
    signal bpm_out     : unsigned(13 downto 0);
    signal done        : std_logic;
    
    signal pulse_signal : std_logic;
    signal pulse_in_d, pulse_fall, pulse_rise : std_logic;
    
    signal score : std_logic_vector(15 downto 0);
    signal an : std_logic_vector(3 downto 0);
    signal seg : std_logic_vector(0 to 6);
    signal dp_out : std_logic;
begin
    UUT1: counter_ms port map(
        clk         => clk,
        reset       => reset,
        counting    => counting,
        duration_ms => duration_ms
    );
    
    UUT2: bpm_calculator port map(
        clk => clk,
        reset => reset,
        enable => enable,
        duration_ms => duration_ms,
        bpm_out => bpm_out,
        done => done
    );
    
    UUT3: driver7seg port map (
        clk => clk,
        Din => score,
        an => an,
        seg => seg,
        dp_in => (others => '0'),
        dp_out => dp_out,
        rst => reset
    );
    
    UUT4_pulse_button: debounce port map(
        clk => clk,
        rst => reset,
        btn_raw => pulse_in,
        btn_clean => pulse_signal
    ); 

    process(clk, reset)
    begin
       if reset = '1' then
            pulse_in_d  <= '0';
            pulse_rise  <= '0';
            pulse_fall  <= '0';
       elsif rising_edge(clk) then
            pulse_rise  <= pulse_signal and not pulse_in_d;
            pulse_fall  <= not pulse_signal and pulse_in_d;
            pulse_in_d  <= pulse_signal;
       end if;
    end process;
    
    process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
        elsif rising_edge(clk) then
            current_state <= next_state;
        end if;
    end process;
    
    process(clk)
    begin
        if rising_edge(clk) then
            pulse_in_d <= pulse_signal;
        end if;
    end process;
    
    

    -- FSM next state logic
    process(current_state, pulse_rise, pulse_fall, done)
    begin
        case current_state is
            when IDLE =>
                if pulse_fall = '1' then
                    next_state <= MEASURE;
                else
                    next_state <= IDLE;
                end if;
            
            when MEASURE =>
                if pulse_rise = '1' then
                    next_state <= CALCULATE;
                else
                    next_state <= MEASURE;
                end if;

            when CALCULATE =>
                if done = '1' then
                    next_state <= DISPLAY;
                else
                    next_state <= CALCULATE;
                end if;
                
            when DISPLAY =>
                next_state <= WAIT_RESET;

            when WAIT_RESET =>
                null;
                    
            when others =>
                next_state <= IDLE;
        end case;
    end process;

    -- FSM outputs
    process(current_state)
    begin
        case current_state is
            when IDLE =>
                report "Am ajuns în starea IDLE!" severity note;
                null;

            when MEASURE =>
                report "Am ajuns în starea MEASURE!" severity note;
                counting <= '1';

            when CALCULATE =>
                report "Am ajuns în starea CALCULATE!" severity note;
                counting <= '0';
                enable <= '1', '0' after 40ns;

            when DISPLAY =>
                score <= std_logic_vector(TO_UNSIGNED(0, 2)) &
                         std_logic_vector(bpm_out);
                
            when WAIT_RESET =>
                null;
        end case;
    end process;
    
    bpm_result <= bpm_out;
    duration_result <= duration_ms;
    state <= current_state;
    enable_bpm <= enable;
    done_bpm <= done;
    counter_state <= counting;
    pulse_in_d_tb <= pulse_in_d;
    pulse_fall_tb <= pulse_fall;
    pulse_rise_tb <= pulse_rise;
    
end Behavioral;
