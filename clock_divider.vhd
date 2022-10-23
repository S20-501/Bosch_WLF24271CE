library ieee;
use ieee.std_logic_1164.all;

entity clock_divider is
    port (
        enabled_s: in std_logic;
        clock: in std_logic;
        clock_2hz: out std_logic
    );
end entity;

architecture A_clock_divider of clock_divider is
    constant clock_max: integer := 48_000_000 / 64;

    signal clock_counter: natural range 0 to clock_max := clock_max;
    signal clock_2hz_r: std_logic := '0';
begin
    clock_div_p : process(enabled_s, clock, clock_counter)
    begin
        if (enabled_s = '1') then
            if rising_edge(clock) then
                if (clock_counter = 0) then
                    clock_counter <= clock_max;
                    clock_2hz_r <= not clock_2hz_r;
                else
                     clock_counter <= clock_counter - 1;
                end if;

                clock_2hz <= clock_2hz_r;
            end if;
        end if;
    end process;
end architecture;
