library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sevenseg_pkg11 is
    subtype sevenseg_t is std_logic_vector(6 downto 0);
    type sevenseg_charset_t is
      ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      'C', 'o', 'l', 'd', 'E', 'n', 'h', '-', ' ');

    type charset_vector_t is array (natural range <>) of sevenseg_charset_t;

    subtype display_value_vector_t is charset_vector_t(3 downto 0);

    type speed_enum_t is
         (speed_200, speed_400, speed_600, speed_800, speed_1000, speed_1200);
    type temperature_enum_t is
        (tColdC, t30C, t40C, t50C, t60C, t70C, t80C, t90C);




    function TO_SEVENSEG (signal speed_s: speed_enum_t)
        return charset_vector_t;

    function TO_SEVENSEG (signal temperature_s: temperature_enum_t)
        return charset_vector_t;
end package;

package body sevenseg_pkg11 is
    function TO_SEVENSEG (signal speed_s: speed_enum_t)
        return charset_vector_t is
            variable DISP_VALUE: charset_vector_t(3 downto 0);
        begin
            case speed_s is
                when speed_200 => DISP_VALUE := "200 ";
                when speed_400 => DISP_VALUE := "400 ";
                when speed_600 => DISP_VALUE := "600 ";
                when speed_800 => DISP_VALUE := "800 ";
                when speed_1000 => DISP_VALUE := "1000";
                when speed_1200 => DISP_VALUE := "1200";
            end case;

            return DISP_VALUE;
      end TO_SEVENSEG;

      function TO_SEVENSEG (signal temperature_s: temperature_enum_t)
          return charset_vector_t is
              variable DISP_VALUE: charset_vector_t(3 downto 0);
          begin
              case temperature_s is
                  when tColdC => DISP_VALUE := "Cold";
                  when t30C => DISP_VALUE := "30 C";
                  when t40C => DISP_VALUE := "40 C";
                  when t50C => DISP_VALUE := "50 C";
                  when t60C => DISP_VALUE := "60 C";
                  when t70C => DISP_VALUE := "70 C";
                  when t80C => DISP_VALUE := "80 C";
                  when t90C => DISP_VALUE := "90 C";
              end case;

              return DISP_VALUE;
        end TO_SEVENSEG;
end package body;

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
        sink_s:out std_logic := '0'
    );
end entity;

architecture fsm_states_a of fsm_states is
    type speed_range_t is range 200 to 1200;

    --subtype speed_t is

    -- constant speed_sevenseg_conv : array(natural range <>)
    --     of charset_vector_t(3 downto 0) := (
    --         200 => "200 ",
    --         400 => "400 ",
    --         600 => "600 ",
    --         800 => "400 ",
    --         1000 => "1000"
    --     );

	 type lookup_t is array(speed_enum_t) of charset_vector_t(3 downto 0) ;

    constant lookup : lookup_t := (
		speed_200 =>  "200 ",
     speed_400 => "400 ",
     speed_600 =>  "600 ",
     speed_800 =>  "800 ",
     speed_1000 =>  "1000",
     speed_1200 =>  "1200"
     );



    type fsm_state_t is
      (INIT_STATE, POWER_ON_STATE, CONFIG_STATE,
      SPEED_CONFIG_STATE, TEMPERATURE_CONFIG_STATE,
      START_STATE
      );

    signal fsm_state: fsm_state_t := INIT_STATE;
    signal fsm_state_next: fsm_state_t := INIT_STATE;

    signal timer_counter: natural range 0 to 10 := 0;

    signal config_changed_r: std_logic := '0';

    signal start_r: std_logic := '0';
    signal sink_r: std_logic := '0';

    -- must be enums!!!
    signal speed_r: natural range 200 to 1200 := 200; -- how to convert?
    signal temperature_r: natural range 30 to 90 := 30;
begin
    fsm_state_p : process(clock, fsm_state, timer_counter, start_r,
        config_changed_r, start_button_s, speed_button_s)
    begin
		fsm_state_next <= fsm_state;

        case(fsm_state) is
            when INIT_STATE =>
                fsm_state_next <= POWER_ON_STATE;

            when POWER_ON_STATE =>
                if (timer_counter = 0) then
                    fsm_state_next <= CONFIG_STATE;
                end if;

            when CONFIG_STATE =>
                if (timer_counter = 0) then
                    if (start_r = '1') then
                        fsm_state_next <= START_STATE;
                    else
                        fsm_state_next <= SPEED_CONFIG_STATE;
                    end if;
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
            when INIT_STATE =>  -- should remove?

            when POWER_ON_STATE =>
                timer_counter <= 2;

            when CONFIG_STATE =>
                timer_counter <= 2;

            when SPEED_CONFIG_STATE =>
                -- sevenseg_value_r <= "1200"; -- TODO: display current speed setting! speed_r

                if (speed_button_s = '1') then
                    speed_r <=+ 200;
                    config_changed_r <= '1';
                end if;

                if (timer_counter = 0) then
                    if (config_changed_r = '1') then
                        config_changed_r <= '0';
                    end if;

                    timer_counter <= 2;
                end if;


            when TEMPERATURE_CONFIG_STATE =>
                -- TEMPERATURE_CONFIG_STATE sevenseg_value_r <= "1200"; -- TODO: display current speed setting! speed_r

                -- if (temperature_button_s = '1') then
                --     speed_r <=+ 200;
                --     config_changed_r <= '1';
                -- end if;
                --
                if (timer_counter = 0) then
                    if (config_changed_r = '1') then
                        config_changed_r <= '0';
                    end if;

                    timer_counter <= 2;
                end if;

            when START_STATE =>
                fsm_prg_sink_enabled_s <= '1';

        end case;
		end if;
    end process;
end architecture;
