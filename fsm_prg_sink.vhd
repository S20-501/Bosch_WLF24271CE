library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package fsm_types_pkg is
    type fsm_prg_sink_state_t is
      (LOCK_DOOR_STATE, PRE_DRAIN_STATE, WATER_FILL_STATE, WASHING_STATE,
      AFTER_DRAIN_STATE, SPIN_STATE, UNLOCK_DOOR, DOOR_ERROR_STATE);
end package;

library ieee;
use ieee.std_logic_1164.all;

use work.fsm_types_pkg.all;

entity fsm_prg_sink is
    port (
        clock: in std_logic;
        door_lock_s:in std_logic;
        door_locked_s:out std_logic;
        start_button_s: in std_logic;
        sink_button_s: in std_logic;
        temperature_button_s: in std_logic;
        speed_button_s: in std_logic;
        enable_s: in std_logic;
        end_s:out std_logic
    );
end entity;

architecture fsm_prg_sink_a of fsm_prg_sink is
    signal fsm_state: fsm_prg_sink_state_t := LOCK_DOOR_STATE;
    signal fsm_state_next: fsm_prg_sink_state_t := LOCK_DOOR_STATE;

    signal timer_counter: natural range 0 to 48_000_000 := 48_000_000;
    signal timer_enabled: std_logic := '1';
begin
    fsm_state_p : process(clock)
    begin
        case(fsm_state) is
            when LOCK_DOOR_STATE =>
                if (door_lock_s = '1') then
                    timer_enabled <= '1';
                    timer_counter <= 48_000_000 * 5; --5s drain
                    fsm_state_next <= PRE_DRAIN_STATE;
                elsif (timer_counter = 0) then
                    timer_enabled <= '0';
                    fsm_state_next <= DOOR_ERROR_STATE;
                end if;

            when PRE_DRAIN_STATE =>
                if (drain_pressure_ok = '0') then
                    timer_enabled <= '0';
                    fsm_state_next <= DRAIN_ERROR_STATE;
                elsif (timer_counter = 0) then
                    timer_enabled <= '1';
                    timer_counter <= 48_000_000 * 5; --5s drain
                    fsm_state_next <= PRE_DRAIN_STATE;
                end if;

            when WATER_FILL_STATE =>  -- <<<<<<<<
                if (timer_counter = 0) then
                    timer_counter <= 48_000_000;

                    if (speed_button_s = '0') then
                        fsm_state_next <= TEMPERATURE_CONFIG_STATE;
                    end if;
                end if;

            when WASHING_STATE =>
                if (timer_counter = 0) then
                    timer_counter <= 48_000_000;

                    if (speed_button_s = '0') then
                        fsm_state_next <= CONFIG_STATE;
                    end if;
                end if;

            when SPIN_STATE =>
                -- if ()


            when UNLOCK_DOOR =>


            when DOOR_ERROR_STATE =>



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
