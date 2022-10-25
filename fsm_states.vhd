library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- package sevenseg_pkg11 is
--     subtype sevenseg_t is std_logic_vector(6 downto 0);
--     type sevenseg_charset_t is
--       ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
--       'C', 'o', 'l', 'd', 'E', 'n', 'h', '-', ' ', 'P', 'A', 'U', 'S');
--
--     type charset_vector_t is array (natural range <>) of sevenseg_charset_t;
--
--     -- subtype display_value_vector_t is charset_vector_t(3 downto 0);
--
--     type speed_enum_t is
--          (speed_200, speed_400, speed_600, speed_800, speed_1000, speed_1200);
--     type temperature_enum_t is
--         (tColdC, t30C, t40C, t50C, t60C, t70C, t80C, t90C);
-- end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- use work.sevenseg_pkg11.all;
use work.sevenseg_pkg.all;

entity fsm_states is
    port (
        clock: in std_logic;
        start_button_s: in std_logic;
        sink_button_s: in std_logic;
        temperature_button_s: in std_logic;
        speed_button_s: in std_logic;

        fsm_prg_sink_enabled_s:out std_logic := '0';
        sink_s:out std_logic := '0';

        sevenseg_value_s: out charset_vector_t(3 downto 0);

        start_s: out std_logic := '0'; -- 0 pause, 1 start
        speed_s: out speed_enum_t := speed_200;
        temperature_s: out temperature_enum_t := t30C;


        time_divider_s: out std_logic;

        washing_led_s: out std_logic;
        sinking_led_s: out std_logic;
        end_led_s: out std_logic;

        start_led_s: out std_logic;
        sink_led_s: out std_logic;
        engine_acceleration_s: out natural range 0 to 1200 := 10;
        engine_acceleration_neg_sign_s: out std_logic := '1' -- 0 positive, 1 negative
    );
end entity;

architecture fsm_states_a of fsm_states is
    type speed_disp_map_t is array(speed_enum_t)
        of charset_vector_t(3 downto 0);

    constant speed_disp_map : speed_disp_map_t := (
        speed_200 =>  " 200",
        speed_400 =>  " 400",
        speed_600 =>  " 600",
        speed_800 =>  " 800",
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
            SPEED_CONFIG_STATE, TEMPERATURE_CONFIG_STATE, -- TIME_CONFIG_STATE,
            START_STATE, TIME_DISPLAY_STATE, PAUSE_STATE, FINAL_STATE,
            SPEED_UPDATE_STATE, TEMPERATURE_UPDATE_STATE,
            DOOR_ERROR_STATE, DRAIN_ERROR_STATE, ENGINE_ERROR_STATE, FILL_ERROR_STATE
        );

    signal fsm_state: fsm_state_t := POWER_ON_STATE;
    signal fsm_state_next: fsm_state_t := POWER_ON_STATE;

    signal timer_counter: natural range 0 to 1000 := 0;

    signal config_changed_r: std_logic := '0';

    signal start_r: std_logic := '0'; -- 0 pause, 1 start
    signal sink_r: std_logic := '0';

    signal speed_r: speed_enum_t := speed_200;
    signal temperature_r: temperature_enum_t := t30C;

    signal washing_led_r: std_logic := '0';
    signal end_led_r: std_logic := '0';

    signal start_led_r: std_logic := '0';


    signal rtc_enable: std_logic := '0';
    signal rtc_counter: natural range 0 to 1000 := 0;
    signal time_divider_r: std_logic := '0';

    signal minute_units_r: natural range 0 to 9 := 0;
    signal minute_tens_r: natural range 0 to 9 := 0;
    signal hour_units_r: natural range 0 to 9 := 0;



begin
    fsm_state_p : process(clock, fsm_state, timer_counter, start_r,
        config_changed_r, start_button_s, speed_button_s, temperature_button_s,
        minute_tens_r, minute_units_r, hour_units_r, rtc_enable)
    begin
		fsm_state_next <= fsm_state;

        case(fsm_state) is
            when POWER_ON_STATE =>
                if (timer_counter = 0) then
                    fsm_state_next <= CONFIG_STATE;
                end if;

            when CONFIG_STATE =>
                if (start_button_s = '1') then
                    fsm_state_next <= START_STATE;
                else
                    fsm_state_next <= SPEED_CONFIG_STATE;
                end if;

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

            when START_STATE => -- ininitialize washing
                fsm_state_next <= TIME_DISPLAY_STATE;

            -- when RESUME_STATE => -- set start bits

            when TIME_DISPLAY_STATE => --
                if (timer_counter = 0) then
                    if (speed_button_s = '1') then
                        fsm_state_next <= SPEED_UPDATE_STATE;
                    elsif (temperature_button_s = '1') then
                        fsm_state_next <= TEMPERATURE_UPDATE_STATE;
                    elsif (start_button_s = '1') then
                        fsm_state_next <= PAUSE_STATE;
                    elsif (minute_tens_r = 0 and minute_units_r = 0 and hour_units_r = 0) then
                        fsm_state_next <= FINAL_STATE;
                    end if;
                end if;

            when PAUSE_STATE => -- NEED TEST
                if (timer_counter = 0) then
                    if (speed_button_s = '1') then
                        fsm_state_next <= SPEED_UPDATE_STATE;
                    elsif (temperature_button_s = '1') then
                        fsm_state_next <= TEMPERATURE_UPDATE_STATE;
                    elsif (start_button_s = '1') then
                        fsm_state_next <= TIME_DISPLAY_STATE; --RESUME_STATE
                    end if;
                end if;
            when FINAL_STATE => --NEED TEST, or just finalize
                -- if () then
                --     if (speed_button_s = '1') then
                --         fsm_state_next <= SPEED_UPDATE_STATE;
                --     elsif (temperature_button_s = '1') then
                --         fsm_state_next <= TEMPERATURE_UPDATE_STATE;
                --     end if;
                -- else
                --     fsm_state_next <= START_STATE;
                -- end if;

            when SPEED_UPDATE_STATE =>
                if (timer_counter = 0) then
                    if (config_changed_r = '0') then
                        if (minute_tens_r = 0 and minute_units_r = 0 and hour_units_r = 0) then
                            fsm_state_next <= FINAL_STATE;
                        elsif (rtc_enable = '1') then
                            fsm_state_next <= TIME_DISPLAY_STATE;
                        else
                            fsm_state_next <= PAUSE_STATE;
                        end if;
                    end if;
                end if;

            when TEMPERATURE_UPDATE_STATE =>
                if (timer_counter = 0) then
                    if (config_changed_r = '0') then
                        if (minute_tens_r = 0 and minute_units_r = 0 and hour_units_r = 0) then
                            fsm_state_next <= FINAL_STATE;
                        elsif (rtc_enable = '1') then
                            fsm_state_next <= TIME_DISPLAY_STATE;
                        else
                            fsm_state_next <= PAUSE_STATE;
                        end if;
                    end if;
                end if;


            -- final states
            when DOOR_ERROR_STATE =>
            when DRAIN_ERROR_STATE =>
            when ENGINE_ERROR_STATE =>
            when FILL_ERROR_STATE =>
        end case;

    end process;

    fsm_reg_p : process(clock, timer_counter, fsm_state_next,
        config_changed_r,
        start_button_s, speed_button_s)
    begin
        if (rising_edge(clock)) then
            fsm_state <= fsm_state_next;

            sink_s <= sink_r;
            start_s <= start_r;
            speed_s <= speed_r;
            temperature_s <= temperature_r;
        end if;
    end process;

    fsm_logic_p : process(clock, fsm_state, timer_counter,
        config_changed_r, start_button_s, speed_button_s)
    begin
	 if rising_edge(clock) then
         if (timer_counter /= 0) then
             timer_counter <= timer_counter - 1;
         end if;

        if (rtc_enable = '1') then
            if (rtc_counter > 0) then
                rtc_counter <= rtc_counter - 1;
            else
                rtc_counter <= 32;  -- should be timed to 1min or 1sec

                if (minute_tens_r = 0 and minute_units_r = 0 and hour_units_r = 0) then
                    rtc_enable <= '0';
                else
                    if minute_units_r > 0 then
                        minute_units_r <= minute_units_r - 1;
                    else
    					minute_units_r <= 9;

    					if minute_tens_r > 0 then
                            minute_tens_r <= minute_tens_r - 1;
                        else
    						minute_tens_r <= 5;

                            if hour_units_r > 0 then
                                hour_units_r <= hour_units_r - 1;
                            end if;
                        end if;

                    end if;
                end if;
            end if;
        end if;

        case(fsm_state) is
            when POWER_ON_STATE =>
                sink_led_s <= '0';
                start_led_s <= '0';
                end_led_s <= '0';
                washing_led_s <= '0';
                sinking_led_s <= '0';
                time_divider_s <= '0';

                if (timer_counter = 0) then
                    timer_counter <= 64; --1s
                end if;

            when CONFIG_STATE =>
                if (timer_counter = 0) then
                    start_led_r <= not start_led_r;

                    timer_counter <= 32; -- 0.5 s

                    if (start_button_s = '1') then
                        start_r <= '1';
                    end if;
                end if;

                start_led_s <= start_led_r;

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
                hour_units_r <= 2;
                minute_tens_r <= 0;
                minute_units_r <= 0;
                -- rtc_enable <= '1';

                -- start_led_s <= '1';
                fsm_prg_sink_enabled_s <= '1';

                -- engine_acceleration_neg_sign_s <= '0';

                if (start_button_s = '1') then
                    start_r <= '0';
                end if;


            when TIME_DISPLAY_STATE =>
                if (timer_counter = 0) then
                    time_divider_r <= not time_divider_r;

                    timer_counter <= 16; -- 0.5 s
                end if;

                start_led_s <= '1';
                rtc_enable <= '1';
                engine_acceleration_neg_sign_s <= '0';

                time_divider_s <= time_divider_r;

                sevenseg_value_s(3) <= ' ';
                sevenseg_value_s(2) <= sevenseg_charset_t'VAL(hour_units_r);
                sevenseg_value_s(1) <= sevenseg_charset_t'VAL(minute_tens_r);
                sevenseg_value_s(0) <= sevenseg_charset_t'VAL(minute_units_r);

            when PAUSE_STATE =>
                sevenseg_value_s <= "PAUS";
                time_divider_s <= '0';

                start_led_s <= start_led_r;
                rtc_enable <= '0';

                engine_acceleration_neg_sign_s <= '1';

                if (timer_counter = 0) then
                    start_led_r <= not start_led_r;

                    if (start_button_s = '1') then
                        start_r <= '1';
                    end if;

                    timer_counter <= 16;
                end if;

            when FINAL_STATE =>
                sevenseg_value_s <= " End";
                time_divider_s <= '0';

                end_led_s <= end_led_r;
                engine_acceleration_neg_sign_s <= '1';

                start_led_s <= '0';

                if (timer_counter = 0) then
                    end_led_r <= not end_led_r;

                    timer_counter <= 16;
                end if;


            when SPEED_UPDATE_STATE =>
                time_divider_s <= '0';

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

            when TEMPERATURE_UPDATE_STATE =>
                time_divider_s <= '0';

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



            -- final states
            when DOOR_ERROR_STATE =>
                sevenseg_value_s <= " E0 ";
            when DRAIN_ERROR_STATE =>
                sevenseg_value_s <= " E0 ";
            when ENGINE_ERROR_STATE =>
                sevenseg_value_s <= " E0 ";
            when FILL_ERROR_STATE =>
                sevenseg_value_s <= " E0 ";

        end case;
		end if;
    end process;
end architecture;
