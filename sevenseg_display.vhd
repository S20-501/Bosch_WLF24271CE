library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sevenseg_pkg.all;

entity sevenseg_display is
    port (
    clock: in std_logic;
    sevenseg_value_r: in charset_vector_t(3 downto 0);
    sevenseg_points_s:in std_logic_vector(2 downto 0);
    sevenseg_colon_s: in std_logic;
    sevenseg_enabled_digit_s: out std_logic_vector(3 downto 0);
    sevenseg_bus_s:out std_logic_vector(6 downto 0);
    sevenseg_point_s: out std_logic
    );
end entity;

architecture sevenseg_display_a of sevenseg_display is
    signal current_digit_counter: natural range 0 to 3 := 0;
    signal clock_divider_counter: natural range 0 to 10000 := 0;
    signal current_digit_r: sevenseg_charset_t;
begin
    current_digit_r <= sevenseg_value_r(current_digit_counter);

	 convert_digit : entity work.sevenseg_digit
		port map (
			sevenseg_in_s  => current_digit_r,
			sevenseg_out_s => sevenseg_bus_s
		);

    sevenseg_update : process(clock)
    begin
        if rising_edge(clock) then
            clock_divider_counter <= clock_divider_counter + 1;

            if (clock_divider_counter = 0) then
                current_digit_counter <= current_digit_counter + 1;
            end if;
        end if;
    end process;

	 with current_digit_counter select sevenseg_enabled_digit_s <=
        "0111" when 0,
        "1011" when 1,
        "1101" when 2,
        "1110" when 3;

    with current_digit_counter select sevenseg_point_s <=
       sevenseg_points_s(0) when 0,
       sevenseg_points_s(1) when 1,
    sevenseg_colon_s    when 2,
        sevenseg_points_s(2) when 3;
end architecture;
