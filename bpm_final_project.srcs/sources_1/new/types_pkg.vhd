library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

package types_pkg is
    type state_type is (IDLE, MEASURE, CALCULATE, DISPLAY, WAIT_RESET);
end package types_pkg;
