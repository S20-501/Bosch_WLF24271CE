library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fsm_types_pkg is
    type fsm_state_t is
      (POWER_ON_STATE, CONFIG_STATE,
      SPEED_CONFIG_STATE, TEMPERATURE_CONFIG_STATE,
      START_STATE, STOP_STATE,
      LOCK_DOOR_STATE, PRE_DRAIN_STATE, WATER_FILL_STATE, WASHING_STATE,
      AFTER_DRAIN_STATE, SPIN_STATE, UNLOCK_DOOR, DOOR_ERROR_STATE
      );
end package;

library ieee;
use ieee.std_logic_1164.all;

use work.fsm_types_pkg.all;

entity fsm_states is
    port (
        clock: in std_logic;
        start_button_s: in std_logic;
        sink_button_s: in std_logic;
        temperature_button_s: in std_logic;
        speed_button_s: in std_logic
    );
end entity;

architecture fsm_states_a of fsm_states is
    signal fsm_state: fsm_state_t := POWER_ON_STATE;
    signal fsm_state_next: fsm_state_t := START_STATE;

    signal timer_counter: natural range 0 to 48_000_000 := 48_000_000;
    signal timer_enabled: std_logic := '1';
begin
    fsm_state_p : process(clock)
    begin
        case(fsm_state) is
            when POWER_ON_STATE =>
                if (timer_counter = 0) then
                    timer_enabled <= '0';
                    fsm_state_next <= CONFIG_STATE;
                end if;

            when CONFIG_STATE =>
                if (timer_counter = 0) then
                    if (start_button_s = '1') then
                        timer_enabled <= '0';
                        fsm_state_next <= START_STATE;
                    else
                        timer_enabled <= '1';
                        timer_counter <= 48_000_000;
                        fsm_state_next <= SPEED_CONFIG_STATE;
                    end if;
                end if;

            when SPEED_CONFIG_STATE =>
                if (timer_counter = 0) then
                    timer_counter <= 48_000_000;

                    if (speed_button_s = '0') then
                        fsm_state_next <= TEMPERATURE_CONFIG_STATE;
                    end if;
                end if;

            when TEMPERATURE_CONFIG_STATE =>
                if (timer_counter = 0) then
                    timer_counter <= 48_000_000;

                    if (speed_button_s = '0') then
                        fsm_state_next <= CONFIG_STATE;
                    end if;
                end if;

            when START_STATE =>
                -- if ()


            when STOP_STATE =>


            -- when others =>

        end case;


        if rising_edge(clock) then
            fsm_state <= fsm_state_next;

            if timer_enabled = '1' then
                timer_counter <= timer_counter - 1;
            end if;
        end if;
    end process;
end architecture;
