library ieee;
use ieee.std_logic_1164.all;

use work.sevenseg_pkg.all;

entity Bosch_WLF24271CE is
	port(CLK: in std_logic;
	 reset : in std_logic;
	--sevenseg leds
	DS_G, DS_F, DS_E, DS_D, DS_C, DS_B, DS_A: out std_logic;
	-- digit enable leds
	DS_EN1, DS_EN2, DS_EN3, DS_EN4: out std_logic;
	--input keys
 	KEY1,--start
	KEY2,--sink
	KEY3,-- speed
	KEY4 -- temper
	: in std_logic;
	V_R: out std_logic_vector(4 downto 0);
	-- beeper
	BP1: out std_logic;

	door_lock_s:in std_logic;
	door_locked_s:out std_logic;
	drain_pressure_ok_s: in std_logic;
	water_pressure_ok_s: in std_logic;
	engine_ok_s: in std_logic
	);
end entity Bosch_WLF24271CE;

architecture A_Bosch_WLF24271CE of Bosch_WLF24271CE is
	signal sevenseg_value_r: charset_vector_t(3 downto 0) := "Cold";
	signal clock_divider_counter: natural range 0 to 10000 := 0;

	signal frequency_beep_r: natural range 0 to 48000000 := 1000000; -- in ms
	signal frequency_counter: natural range 0 to 4800000 := 0;

	signal sink_s: std_logic;
	signal end_s: std_logic;
	signal fsm_prg_sink_enabled_s: std_logic;
	signal clock_2hz: std_logic;

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
	component fsm_states
		port (
		  clock                : in  std_logic;
		  start_button_s       : in  std_logic;
		  sink_button_s        : in  std_logic;
		  temperature_button_s : in  std_logic;
		  speed_button_s       : in  std_logic;
		  fsm_prg_sink_enabled_s    : out std_logic;
		  sink_s               : out std_logic
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
	V_R(0) <= '1';

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
		enabled_s => '0'
	);

	fsm_states_i : fsm_states
	port map (
	  clock                => clock_2hz,
	  start_button_s       => KEY1,
	  sink_button_s        => KEY2,
	  temperature_button_s => KEY3,
	  speed_button_s       => KEY4,
	  fsm_prg_sink_enabled_s    => fsm_prg_sink_enabled_s,
	  sink_s               => sink_s
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


	frequency_up : process(CLK)
	begin
	  if (rising_edge(CLK)) then
			frequency_counter <= frequency_counter + 1;

			if (frequency_counter = 0) then
				 frequency_beep_r <= frequency_beep_r - 1;
			end if;
	  end if;
	end process;


end architecture A_Bosch_WLF24271CE;
