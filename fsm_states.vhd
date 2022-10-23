library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sevenseg_pkg11 is
    subtype sevenseg_t is std_logic_vector(6 downto 0);
    type sevenseg_charset_t is
      ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      'C', 'o', 'l', 'd', 'E', 'n', 'h', '-', ' ');

    type charset_vector_t is array (natural range <>) of sevenseg_charset_t;

    -- subtype display_value_vector_t is charset_vector_t(3 downto 0);

    type speed_enum_t is
         (speed_200, speed_400, speed_600, speed_800, speed_1000, speed_1200);
    type temperature_enum_t is
        (tColdC, t30C, t40C, t50C, t60C, t70C, t80C, t90C);
end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

use work.sevenseg_pkg11.all;

entity fsm_states is
    port (
        clock: in std_logic;
        start_button_s: in std_logic;
        sink_button_s: in std_logic;
        temperature_button_s: in std_logic;
        speed_button_s: in std_logic;

        fsm_prg_sink_enabled_s:out std_logic := '0';
        sink_s:out std_logic := '0';

        sevenseg_value_s: out charset_vector_t(3 downto 0)
    );
end entity;

architecture fsm_states_a of fsm_states is
    type speed_disp_map_t is array(speed_enum_t)
        of charset_vector_t(3 downto 0);

    constant speed_disp_map : speed_disp_map_t := (
        speed_200 =>  "200 ",
        speed_400 => "400 ",
        speed_600 =>  "600 ",
        speed_800 =>  "800 ",
        speed_1000 =>  "1000",
        speed_1200 =>  "1200"
    );


    type temperature_disp_map_t is array(temperature_enum_t)
        of charset_vector_t(3 downto 0);

    constant temperature_disp_map : temperature_disp_map_t := (
        tColdC =>  "Cold",
        t30C => "30 C",
        t40C => "40 C",
        t50C => "50 C",
        t60C => "60 C",
        t70C => "70 C",
        t80C => "80 C",
        t90C => "90 C"
    );


    type fsm_state_t is
      (POWER_ON_STATE, CONFIG_STATE,
      SPEED_CONFIG_STATE, TEMPERATURE_CONFIG_STATE,
      START_STATE
      );

    signal fsm_state: fsm_state_t := POWER_ON_STATE;
    signal fsm_state_next: fsm_state_t := POWER_ON_STATE;

    signal timer_counter: natural range 0 to 1000 := 0;

    signal config_changed_r: std_logic := '0';

    signal start_r: std_logic := '0';
    signal sink_r: std_logic := '0';

    -- must be enums!!!
    signal speed_r: speed_enum_t := speed_200; -- how to convert?
    signal temperature_r: temperature_enum_t := t30C;
begin
    fsm_state_p : process(clock, fsm_state, timer_counter, start_r,
        config_changed_r, start_button_s, speed_button_s)
    begin
		fsm_state_next <= fsm_state;

        case(fsm_state) is
            when POWER_ON_STATE =>
                if (timer_counter = 0) then
                    fsm_state_next <= CONFIG_STATE;
                end if;

            when CONFIG_STATE =>
                -- if (timer_counter = 0) then
                    if (start_r = '1') then
                        fsm_state_next <= START_STATE;
                    else
                        fsm_state_next <= SPEED_CONFIG_STATE;
                    end if;
                -- end if;

            when SPEED_CONFIG_STATE =>
                if (timer_counter = 0) then
                    if (config_changed_r = '0') then
                        fsm_state_next <= TEMPERATURE_CONFIG_STATE;
                    end if;
                end if;

            when TEMPERATURE_CONFIG_STATE =>
                if (timer_counter = 0) then
                    if (config_changed_r = '0') then
                        fsm_state_next <= CONFIG_STATE;
                    end if;
                end if;

            when START_STATE => -- final state, enable program
        end case;

    end process;

    fsm_reg_p : process(clock, timer_counter, fsm_state_next,
        config_changed_r,
        start_button_s, speed_button_s)
    begin
        if (rising_edge(clock)) then
            fsm_state <= fsm_state_next;
        end if;
    end process;

    fsm_logic_p : process(clock, fsm_state, timer_counter,
        config_changed_r, start_button_s, speed_button_s)
    begin
	 if rising_edge(clock) then
         if (timer_counter /= 0) then
             timer_counter <= timer_counter - 1;
         end if;

        case(fsm_state) is
            when POWER_ON_STATE =>
                if (timer_counter = 0) then
                    timer_counter <= 64;
                end if;

            when CONFIG_STATE =>
--                if (timer_counter = 0) then
--                    timer_counter <= 2;
--                end if;

            when SPEED_CONFIG_STATE =>
                sevenseg_value_s <= speed_disp_map(speed_r);

                if (config_changed_r = '0') then
                    if (speed_button_s = '1') then
                        if (speed_r = speed_enum_t'high) then
                            speed_r <= speed_enum_t'low;
                        else
                            speed_r <= speed_enum_t'succ(speed_r);
                        end if;

                        timer_counter <= 16;
                        config_changed_r <= '1';
                    end if;
                end if;

                if (timer_counter = 0) then
                    if (config_changed_r = '1') then
                        config_changed_r <= '0';
                    end if;

                    timer_counter <= 64;
                end if;


            when TEMPERATURE_CONFIG_STATE =>
                sevenseg_value_s <= temperature_disp_map(temperature_r);

                if (config_changed_r = '0') then
                    if (temperature_button_s = '1') then
                        if (temperature_r = temperature_enum_t'high) then
                            temperature_r <= temperature_enum_t'low;
                        else
                            temperature_r <= temperature_enum_t'succ(temperature_r);
                        end if;

                        timer_counter <= 16;
                        config_changed_r <= '1';
                    end if;
                end if;

                if (timer_counter = 0) then
                    if (config_changed_r = '1') then
                        config_changed_r <= '0';
                    end if;

                    timer_counter <= 64;
                end if;

            when START_STATE =>
                fsm_prg_sink_enabled_s <= '1';

        end case;
		end if;
    end process;
end architecture;
