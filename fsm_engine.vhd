library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- package sevenseg_pkg111 is
--     type speed_enum_t is
--          (speed_200, speed_400, speed_600, speed_800, speed_1000, speed_1200);
-- end package;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_unsigned.all;

-- use work.sevenseg_pkg111.all;
use work.sevenseg_pkg.all;

entity fsm_engine is
    port (
        clock: in std_logic;

        engine_frequency_s: out natural range 0 to 48000000;
        engine_enabled_s: out std_logic;

        engine_max_speed_s: in speed_enum_t;
        engine_acceleration_s: in natural range 0 to 1200;
        engine_acceleration_neg_sign_s: in std_logic -- 0 positive, 1 negative
    );
end entity;

architecture fsm_engine_a of fsm_engine is
    type speed_num_map_t is array(speed_enum_t)
        of natural range 0 to 1200;

    constant speed_disp_map : speed_num_map_t := (
        speed_200 =>  200,
        speed_400 => 400,
        speed_600 =>  600,
        speed_800 =>  800,
        speed_1000 =>  1000,
        speed_1200 =>  1200
    );

    type fsm_state_t is
        (IDLE_STATE, SPEED_UP_STATE, SPEED_DOWN_STATE
        );

    signal fsm_state: fsm_state_t := IDLE_STATE;
    signal fsm_state_next: fsm_state_t := IDLE_STATE;

    signal timer_counter: natural range 0 to 1000 := 0;

    signal engine_speed: natural range 0 to 1200 := 0;
begin
    fsm_state_p : process(clock, fsm_state, timer_counter,
			engine_acceleration_s, engine_speed, engine_max_speed_s, engine_acceleration_neg_sign_s)
    begin
		fsm_state_next <= fsm_state;

        case(fsm_state) is
            when IDLE_STATE =>
                if (engine_acceleration_s /= 0) then
                    if (engine_speed < speed_disp_map(engine_max_speed_s) and
                        engine_acceleration_neg_sign_s = '0') then
                        fsm_state_next <= SPEED_UP_STATE;
                    elsif (engine_speed > 0 and
                        engine_acceleration_neg_sign_s = '1') then
                        fsm_state_next <= SPEED_DOWN_STATE;
                    elsif (engine_speed > speed_disp_map(engine_max_speed_s)) then
                        fsm_state_next <= SPEED_DOWN_STATE;
                    end if;
                end if;

            when SPEED_UP_STATE =>
                if (engine_speed >= speed_disp_map(engine_max_speed_s)) then
                    fsm_state_next <= IDLE_STATE;
                end if;

            when SPEED_DOWN_STATE =>
                if (engine_speed <= 0) then
                    fsm_state_next <= IDLE_STATE;
                end if;
        end case;

    end process;

    fsm_reg_p : process(clock, timer_counter, fsm_state_next)
    begin
        if (rising_edge(clock)) then
            fsm_state <= fsm_state_next;
        end if;
    end process;

    fsm_logic_p : process(clock, fsm_state, timer_counter)
    begin
	 if rising_edge(clock) then
         if (timer_counter > 0) then
             timer_counter <= timer_counter - 1;
         end if;

         if (engine_speed = 0) then
             engine_enabled_s <= '0';
         else
            engine_enabled_s <= '1';
            engine_frequency_s <= 512 + engine_speed * 512; -- srl 10
         end if;

        case(fsm_state) is
            when IDLE_STATE =>
                -- NO LOGIC(

            when SPEED_UP_STATE =>
                if (timer_counter = 0) then
                    engine_speed <= engine_speed + engine_acceleration_s;

                    timer_counter <= 1;
                end if;

            when SPEED_DOWN_STATE =>
                if (timer_counter = 0) then
                    engine_speed <= engine_speed - engine_acceleration_s;

                    timer_counter <= 1;
                end if;

        end case;
		end if;
    end process;
end architecture;
