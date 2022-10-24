library ieee;
use ieee.std_logic_1164.all;

entity beeper is
    port (
        clock: in std_logic;
        frequency_r: in natural range 0 to 48000000;
        enabled_s: in std_logic;
        beep_s: out std_logic
    );
end entity;

architecture beeper_a of beeper is
    signal frequency_counter: natural range 0 to 48000000 := 0;
    signal beep_clk_r: std_logic := '0';
begin
    frequency_count : process(clock, enabled_s, beep_clk_r)
    begin
        if enabled_s = '1' then
            if (rising_edge(clock)) then
                if (frequency_counter = frequency_r) then
                    frequency_counter <= 0;
                    beep_clk_r <= not beep_clk_r;
                else
                    frequency_counter <= frequency_counter + 1;
                end if;

		        beep_s <= beep_clk_r;
            end if;
        else
            beep_s <= 'Z';
        end if;
    end process;
end architecture;
