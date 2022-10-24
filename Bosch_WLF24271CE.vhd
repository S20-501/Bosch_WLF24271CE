library ieee;
use ieee.std_logic_1164.all;

use work.sevenseg_pkg.all;

entity Bosch_WLF24271CE is
	port(CLK: in std_logic;
	--sevenseg leds
	DS_G, DS_F, DS_E, DS_D, DS_C, DS_B, DS_A: out std_logic;
	-- digit enable leds
	DS_EN1, DS_EN2, DS_EN3, DS_EN4: out std_logic;
	--input keys
 	KEY1,--temper
	KEY2,-- engine_acceleration_neg_sign_s
	KEY3,-- ?
	KEY4 -- speed
	: in std_logic := '0';
	V_R: out std_logic_vector(4 downto 0);
	-- beeper
	BP1: out std_logic
	);
end entity Bosch_WLF24271CE;

architecture A_Bosch_WLF24271CE of Bosch_WLF24271CE is

signal door_lock_s: std_logic;
	signal door_locked_s: std_logic;
	signal drain_pressure_ok_s:  std_logic;
	signal water_pressure_ok_s:  std_logic;
	signal engine_ok_s:  std_logic;


	signal sevenseg_value_r: charset_vector_t(3 downto 0) := "Cold";
	signal frequency_beep_r: natural range 0 to 48000000 := 0; -- in ms

	signal sink_s: std_logic;
	signal end_s: std_logic;
	signal fsm_prg_sink_enabled_s: std_logic;
	signal clock_2hz: std_logic;

	signal engine_enabled_r: std_logic;

	signal start_r: std_logic := '0'; -- 0 pause, 1 start
	signal speed_r: speed_enum_t := speed_200;
	signal temperature_r: temperature_enum_t := t30C;

	signal engine_acceleration_r: natural range 0 to 1200 := 10;

	component clock_divider is
	    port (
	        enabled_s: in std_logic;
	        clock: in std_logic;
	        clock_2hz: out std_logic
	    );
	end component;

	component sevenseg_display is
	    port (
	    clock: in std_logic;
	    sevenseg_value_r: in charset_vector_t(3 downto 0);
	    sevenseg_enabled_digit_s: out std_logic_vector(3 downto 0);
	    sevenseg_bus_s:out std_logic_vector(6 downto 0)
	    );
	end component;
	component beeper is
	      port (
			  clock: in std_logic;
			  frequency_r: natural range 0 to 48000000;
			  enabled_s: in std_logic;
			  beep_s: out std_logic
	      );
	end component;
	component fsm_engine
		port (
		  clock                          : in  std_logic;
		  engine_frequency_s             : out natural range 0 to 48000000;
		  engine_enabled_s               : out std_logic;
		  engine_max_speed_s             : in  speed_enum_t;
		  engine_acceleration_s          : in  natural range 0 to 1200;
		  engine_acceleration_neg_sign_s : in  std_logic
		);
	end component fsm_engine;

	component fsm_states
		port (
		  clock                : in  std_logic;
		  start_button_s       : in  std_logic;
		  sink_button_s        : in  std_logic;
		  temperature_button_s : in  std_logic;
		  speed_button_s       : in  std_logic;
		  fsm_prg_sink_enabled_s    : out std_logic;
		  sink_s               : out std_logic;
		  sevenseg_value_s: out charset_vector_t(3 downto 0);
		  start_s: out std_logic; -- 0 pause, 1 start
          speed_s: out speed_enum_t;
          temperature_s: out temperature_enum_t
		);
	end component fsm_states;
	-- component fsm_prg_sink
	-- 	port (
	-- 	  clock                : in  std_logic;
	-- 	  door_lock_s          : in  std_logic;
	-- 	  door_locked_s        : out std_logic;
	-- 	  start_button_s       : in  std_logic;
	-- 	  sink_button_s        : in  std_logic;
	-- 	  drain_pressure_ok_s  : in  std_logic;
	-- 	  water_pressure_ok_s  : in  std_logic;
	-- 	  sink_s               : in  std_logic;
	-- 	  engine_ok_s          : in  std_logic;
	-- 	  temperature_button_s : in  std_logic;
	-- 	  speed_button_s       : in  std_logic;
	-- 	  enable_s             : in  std_logic;
	-- 	  end_s                : out std_logic
	-- 	);
	-- end component fsm_prg_sink;
begin
	V_R(4) <= '1';
	V_R(3) <= '1';
	V_R(2) <= '1';
	V_R(1) <= '1';
	V_R(0) <= engine_enabled_r;

	clock_divider_i : clock_divider
	port map (
		enabled_s => '1',
		clock     => CLK,
		clock_2hz => clock_2hz
	);


	DISP_P: sevenseg_display port map(
		clock => CLK,
		sevenseg_value_r => sevenseg_value_r,
		sevenseg_enabled_digit_s(0) => DS_EN1,
		sevenseg_enabled_digit_s(1) => DS_EN2,
		sevenseg_enabled_digit_s(2) => DS_EN3,
		sevenseg_enabled_digit_s(3) => DS_EN4,
		sevenseg_bus_s(0) => DS_A,
		sevenseg_bus_s(1) => DS_B,
		sevenseg_bus_s(2) => DS_C,
		sevenseg_bus_s(3) => DS_D,
		sevenseg_bus_s(4) => DS_E,
		sevenseg_bus_s(5) => DS_F,
		sevenseg_bus_s(6) => DS_G
	);

	BEEP_P: beeper port map(
		clock => CLK,
		frequency_r => frequency_beep_r,
		beep_s => BP1,
		enabled_s => engine_enabled_r
	);

	fsm_engine_i : fsm_engine
	port map (
	  clock                          => clock_2hz,
	  engine_frequency_s             => frequency_beep_r,
	  engine_enabled_s               => engine_enabled_r,
	  engine_max_speed_s             => speed_r,
	  engine_acceleration_s          => engine_acceleration_r,
	  engine_acceleration_neg_sign_s => KEY2
	);


	fsm_states_i : fsm_states
	port map (
	  clock                => clock_2hz,
	  start_button_s       => "not"(KEY1),
	  sink_button_s        => "not"(KEY2),
	  temperature_button_s => "not"(KEY3),
	  speed_button_s       => "not"(KEY4),
	  fsm_prg_sink_enabled_s    => fsm_prg_sink_enabled_s,
	  sink_s               => sink_s,
	  sevenseg_value_s => sevenseg_value_r,
	  start_s => start_r,
	  speed_s => speed_r,
	  temperature_s => temperature_r
	);

	-- fsm_prg_sink_i : fsm_prg_sink
	-- port map (
	--   clock                => clock_2hz,
	--   start_button_s       => KEY1,
	--   sink_button_s        => KEY2,
	--   temperature_button_s => KEY3,
	--   speed_button_s       => KEY4,
	--
	--   door_lock_s          => door_lock_s,
	--   door_locked_s        => door_locked_s,
	--   drain_pressure_ok_s  => drain_pressure_ok_s,
	--   water_pressure_ok_s  => water_pressure_ok_s,
	--   sink_s               => sink_s,
	--   engine_ok_s          => engine_ok_s,
	--   enable_s             => fsm_prg_sink_enabled_s,
	--   end_s                => end_s
	-- );
end architecture A_Bosch_WLF24271CE;
