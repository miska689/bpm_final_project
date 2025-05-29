library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.types_pkg.all;

entity tb_bpm is
end tb_bpm;

architecture Behavioral of tb_bpm is
    component bpm_fsm is
        Port (
            clk         : in  std_logic;
            reset       : in  std_logic;
            pulse_in    : in  std_logic;
            bpm_result  : out unsigned(13 downto 0);
            duration_result : out unsigned(15 downto 0);
            enable_bpm      : out std_logic;
            state       : out state_type;
            done_bpm    : out std_logic;
            counter_state: out std_logic;
            pulse_in_d_tb : out std_logic;
            pulse_fall_tb: out std_logic;
            pulse_rise_tb : out std_logic      
        );
    end component     bpm_fsm;
    
    signal clk      : std_logic;
    signal reset    : std_logic := '0';
    signal pulse_in : std_logic;
    signal bpm_result : unsigned(13 downto 0);
    signal duration_result : unsigned(15 downto 0);
    signal enable_bpm : std_logic;
    signal done_bpm : std_logic;
    signal state    : state_type;
    signal counter_state : std_logic;
    signal pulse_in_d : std_logic;
    
    signal pulse_fall, pulse_rise : std_logic;
    
    constant CLK_PERIOD : time := 20ns;
begin
    UUT: bpm_fsm port map(
        clk => clk,
        reset => reset,
        pulse_in => pulse_in,
        bpm_result => bpm_result,
        duration_result => duration_result,
        enable_bpm => enable_bpm,
        state => state,
        done_bpm => done_bpm,
        counter_state => counter_state,
        pulse_in_d_tb => pulse_in_d,
        pulse_fall_tb => pulse_fall,
        pulse_rise_tb => pulse_rise
    );
    
    initial_process: process
    begin
      reset <= '1';
      wait for 2*CLK_PERIOD;
      reset <= '0';
      wait for 650ms;
      reset <= '1';
      wait for 10ms;
      reset <= '0';
      wait;
    end process;

    clk_process: process
    begin
        clk <= '0';
        wait for CLK_PERIOD / 2;
        clk <= '1';
        wait for CLK_PERIOD / 2;
    end process; 
    
    pulse_process: process
    begin
      wait for 100 ms;
      -- primul click
      pulse_in <= '1'; wait for CLK_PERIOD;
      pulse_in <= '0'; wait for CLK_PERIOD;
      -- al doilea click după 500 ms
      wait for 500 ms;
      pulse_in <= '1'; wait for CLK_PERIOD;
      pulse_in <= '0'; wait for CLK_PERIOD;
      wait for 300ms;
      pulse_in <= '1'; wait for CLK_PERIOD;
      pulse_in <= '0'; wait for CLK_PERIOD;
      -- al doilea click după 500 ms
      wait for 750 ms;
      pulse_in <= '1'; wait for CLK_PERIOD;
      pulse_in <= '0'; wait for CLK_PERIOD;
      wait;
    end process; 
end Behavioral;
