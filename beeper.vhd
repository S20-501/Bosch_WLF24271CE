library ieee;
use ieee.std_logic_1164.all;

entity beeper is
      port (
          clock: in std_logic;
          frequency_r: natural range 0 to 48000000;
          beep_s: inout std_logic
      );
end entity;

architecture beeper_a of beeper is

    signal frequency_counter: natural range 0 to 48000000 := 48000000;
    -- signal beep_clk: std_logic;

begin
    frequency_count : process(clock)
    begin
        if (rising_edge(clock)) then
            if (frequency_counter = frequency_r) then
                frequency_counter <= 48000000;
                beep_s <= not beep_s;
            else
                frequency_counter <= frequency_counter - 1;
            end if;
        end if;
    end process;

end architecture;
