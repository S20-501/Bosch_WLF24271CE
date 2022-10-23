library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library ieee;
use ieee.std_logic_1164.all;

entity fsm_prg_sink is
    port (
        clock: in std_logic;

        start_button_s: in std_logic;
        sink_button_s: in std_logic;
        temperature_button_s: in std_logic;
        speed_button_s: in std_logic;

        door_lock_s:in std_logic;
        door_locked_s:out std_logic := '0';
        drain_pressure_ok_s: in std_logic;
        water_pressure_ok_s: in std_logic;
        sink_s: in std_logic;
        engine_ok_s: in std_logic;
        enable_s: in std_logic;
        end_s:out std_logic := '0'
    );
end entity;

architecture fsm_prg_sink_a of fsm_prg_sink is
    type fsm_prg_sink_state_t is
      (LOCK_DOOR_STATE, PRE_DRAIN_STATE, WATER_FILL_STATE, WASHING_STATE,
      AFTER_DRAIN_STATE, DOOR_UNLOCK_STATE, SINK_CHECK_STATE, FINAL_STATE,
       DOOR_ERROR_STATE, DRAIN_ERROR_STATE, ENGINE_ERROR_STATE, FILL_ERROR_STATE
       );

    signal fsm_state: fsm_prg_sink_state_t := LOCK_DOOR_STATE;
    signal fsm_state_next: fsm_prg_sink_state_t := LOCK_DOOR_STATE;

    signal timer_counter: natural range 0 to 48_000_000 := 48_000_000;
    signal timer_enabled: std_logic := '1';

    signal sink_r: std_logic;
begin
    fsm_state_p : process(clock, timer_enabled, fsm_state,
		 timer_counter, door_lock_s, sink_r,
		 water_pressure_ok_s, engine_ok_s , drain_pressure_ok_s, sink_s)
    begin
        fsm_state_next <= fsm_state;
	 
        case(fsm_state) is
            when LOCK_DOOR_STATE =>
                if (door_lock_s = '1') then
                    fsm_state_next <= PRE_DRAIN_STATE;
                elsif (timer_counter = 0) then
                    fsm_state_next <= DOOR_ERROR_STATE;
                end if;

            when PRE_DRAIN_STATE => -- should be changed to waterlevel signal for drain press
                if (drain_pressure_ok_s = '0') then
                    fsm_state_next <= DRAIN_ERROR_STATE;
                elsif (timer_counter = 0) then
                    fsm_state_next <= PRE_DRAIN_STATE;
                end if;

            when WATER_FILL_STATE =>  -- should be changed to waterlevel signal for water press
                if (water_pressure_ok_s = '0') then
                    fsm_state_next <= FILL_ERROR_STATE;
                elsif (timer_counter = 0) then
                    fsm_state_next <= WASHING_STATE;
                end if;

            when WASHING_STATE =>
                if (engine_ok_s = '0') then
                    fsm_state_next <= ENGINE_ERROR_STATE;
                elsif (timer_counter = 0) then
                    fsm_state_next <= AFTER_DRAIN_STATE;
                end if;

            when AFTER_DRAIN_STATE =>
                if (drain_pressure_ok_s = '0') then
                    fsm_state_next <= DRAIN_ERROR_STATE;
                elsif (timer_counter = 0) then
                    fsm_state_next <= SINK_CHECK_STATE;
                end if;

            when SINK_CHECK_STATE =>
                if (sink_s = '1') and (sink_r = '0') then
                    fsm_state_next <= WATER_FILL_STATE;
                else
                    fsm_state_next <= DOOR_UNLOCK_STATE;
                end if;

            when DOOR_UNLOCK_STATE =>
                if timer_counter = 0 then
                    fsm_state_next <= FINAL_STATE;
                end if;

            when DOOR_ERROR_STATE =>
            when DRAIN_ERROR_STATE =>
            when FILL_ERROR_STATE =>
            when ENGINE_ERROR_STATE =>
            when FINAL_STATE =>

        end case;
    end process;

    fsm_reg_p : process(clock)
    begin
        if rising_edge(clock) then
            fsm_state <= fsm_state_next;

            if (timer_enabled = '1') and (timer_counter /= 0) then
                timer_counter <= timer_counter - 1;
				else
					 timer_counter <= 48_000_000;
            end if;
        end if;
    end process;

    fsm_logic_p : process(clock, fsm_state,
		 timer_counter, door_lock_s, sink_r,
		 water_pressure_ok_s, engine_ok_s , drain_pressure_ok_s, sink_s
		 )
    begin
	 if rising_edge(clock) then	 
        case(fsm_state) is
            when LOCK_DOOR_STATE =>
                if (door_lock_s = '1') then
                    timer_enabled <= '1';
--                    timer_counter <= 48_000_000 ; --5s drain
                elsif (timer_counter = 0) then
                    timer_enabled <= '0';
                end if;

            when PRE_DRAIN_STATE => -- should be changed to waterlevel signal for drain press
                if (drain_pressure_ok_s = '0') then
                    timer_enabled <= '0';
                elsif (timer_counter = 0) then
                    timer_enabled <= '1';
--                    timer_counter <= 48_000_000 ; --5s drain
                end if;

            when WATER_FILL_STATE =>  -- should be changed to waterlevel signal for water press
                if (water_pressure_ok_s = '0') then
                    timer_enabled <= '0';
                elsif (timer_counter = 0) then
                    timer_enabled <= '1';
--                    timer_counter <= 48_000_000; --5s drain
                end if;

            when WASHING_STATE =>
                if (engine_ok_s = '0') then
                    timer_enabled <= '0';
                elsif (timer_counter = 0) then
                    timer_enabled <= '1';
--                    timer_counter <= 48_000_000; --5s drain
                end if;

            when AFTER_DRAIN_STATE =>
                if (drain_pressure_ok_s = '0') then
                    timer_enabled <= '0';
                elsif (timer_counter = 0) then
                    timer_enabled <= '1';
--                    timer_counter <= 48_000_000 ; --5s drain
                end if;

            when SINK_CHECK_STATE =>
                if (sink_s = '1') and (sink_r = '0') then
                    sink_r <= '1'; -- NEED to be in other porcess
                end if;

            when DOOR_UNLOCK_STATE =>
                if timer_counter = 0 then

                end if;

            when DOOR_ERROR_STATE =>

            when DRAIN_ERROR_STATE =>

            when FILL_ERROR_STATE =>

            when ENGINE_ERROR_STATE =>

            when FINAL_STATE =>

            -- when others =>

        end case;
		  
		end if;
    end process;
end architecture;
