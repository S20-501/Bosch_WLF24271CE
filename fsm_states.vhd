library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

library ieee;
use ieee.std_logic_1164.all;

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
    type fsm_state_t is
      (POWER_ON_STATE, CONFIG_STATE,
      SPEED_CONFIG_STATE, TEMPERATURE_CONFIG_STATE,
      START_STATE
      );

    signal fsm_state: fsm_state_t := POWER_ON_STATE;
    signal fsm_state_next: fsm_state_t := POWER_ON_STATE;

    signal timer_counter: natural range 0 to 10 := 1;
    signal timer_enabled: std_logic := '1';

    signal start_r: std_logic := '0';
begin
    fsm_state_p : process(clock, fsm_state, timer_counter,
        start_button_s, speed_button_s)
    begin
		fsm_state_next <= fsm_state;

        case(fsm_state) is
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
                    if (speed_button_s = '0') then
                        fsm_state_next <= TEMPERATURE_CONFIG_STATE;
                    end if;
                end if;

            when TEMPERATURE_CONFIG_STATE =>
                if (timer_counter = 0) then
                    if (speed_button_s = '0') then
                        fsm_state_next <= CONFIG_STATE;
                    end if;
                end if;

            when START_STATE => -- final state
        end case;

    end process;

    fsm_reg_p : process(clock, timer_enabled, timer_counter, fsm_state_next, start_button_s, speed_button_s)
    begin
        if rising_edge(clock) then
            fsm_state <= fsm_state_next;

            if (timer_enabled = '1') and (timer_counter /= 0) then
                timer_counter <= timer_counter - 1;
				else
					 timer_counter <= 10;
            end if;
        end if;
    end process;

    fsm_logic_p : process(clock, fsm_state, timer_counter, start_button_s, speed_button_s)
    begin
	 if rising_edge(clock) then
        case(fsm_state) is
            when POWER_ON_STATE =>
                if (timer_counter = 0) then
                    timer_enabled <= '0';
                end if;

            when CONFIG_STATE =>
                if (timer_counter = 0) then
                    if (start_button_s = '1') then
                        timer_enabled <= '0';
                    else
                        timer_enabled <= '1';
--                        timer_counter <= 48_000_000;
                    end if;
                end if;

            when SPEED_CONFIG_STATE =>
                if (timer_counter = 0) then
--                    timer_counter <= 48_000_000;

                    if (speed_button_s = '0') then

                    end if;
                end if;

            when TEMPERATURE_CONFIG_STATE =>
                if (timer_counter = 0) then
--                    timer_counter <= 48_000_000;

                    if (speed_button_s = '0') then

                    end if;
                end if;

            when START_STATE =>

        end case;
		end if;
    end process;
end architecture;
