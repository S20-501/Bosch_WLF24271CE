LIBRARY ieee  ;
LIBRARY work  ;
USE ieee.NUMERIC_STD.all  ;
USE ieee.std_logic_1164.all  ;
USE ieee.STD_LOGIC_UNSIGNED.all  ;
USE work.sevenseg_pkg.all  ;
ENTITY fsm_states_tb  IS
END ;

ARCHITECTURE fsm_states_tb_arch OF fsm_states_tb IS
  SIGNAL temperature_s   :  temperature_enum_t := t30C  ;
  SIGNAL engine_acceleration_s   :  INTEGER := 10  ;
  SIGNAL sinking_led_s   :  STD_LOGIC  := '0';
  SIGNAL sink_button_s   :  STD_LOGIC  := '0' ;
  SIGNAL temperature_button_s   :  STD_LOGIC  := '0' ;
  SIGNAL speed_s   :  speed_enum_t := speed_200  ;
  SIGNAL clock   :  STD_LOGIC  := '0' ;
  SIGNAL end_led_s   :  STD_LOGIC  := '0' ;
  SIGNAL washing_led_s   :  STD_LOGIC  := '0' ;
  SIGNAL sink_s   :  STD_LOGIC := '0'  ;
  SIGNAL time_divider_s   :  STD_LOGIC  := '0' ;
  SIGNAL start_s   :  STD_LOGIC := '0'  ;
  SIGNAL engine_acceleration_neg_sign_s   :  STD_LOGIC := '1'  ;
  SIGNAL sink_led_s   :  STD_LOGIC  := '0' ;
  SIGNAL start_button_s   :  STD_LOGIC  := '0' ;
  SIGNAL start_led_s   :  STD_LOGIC  := '0' ;
  SIGNAL speed_button_s   :  STD_LOGIC := '0' ;
  SIGNAL fsm_prg_sink_enabled_s   :  STD_LOGIC := '0'  ;
  SIGNAL sevenseg_value_s   :  charset_vector_t(3 downto 0)  ;
  COMPONENT fsm_states
    PORT (
      temperature_s  : out temperature_enum_t ;
      engine_acceleration_s  : out INTEGER := 0;
      sinking_led_s  : out STD_LOGIC := '0';
      sink_button_s  : in STD_LOGIC := '0';
      temperature_button_s  : in STD_LOGIC := '0';
      speed_s  : out speed_enum_t;
      clock  : in STD_LOGIC := '0';
      end_led_s  : out STD_LOGIC := '0';
      washing_led_s  : out STD_LOGIC := '0';
      sink_s  : out STD_LOGIC := '0';
      time_divider_s  : out STD_LOGIC := '0';
      start_s  : out STD_LOGIC := '0';
      engine_acceleration_neg_sign_s  : out STD_LOGIC := '0';
      sink_led_s  : out STD_LOGIC := '0';
      start_button_s  : in STD_LOGIC:= '0' ;
      start_led_s  : out STD_LOGIC:= '0' ;
      speed_button_s  : in STD_LOGIC := '0';
      fsm_prg_sink_enabled_s  : out STD_LOGIC := '0';
      sevenseg_value_s  : out charset_vector_t(3 downto 0) );
  END COMPONENT ;

    component fsm_states_tester
    port (
      clock                : out std_logic;
      speed_button_s       : out std_logic;
      temperature_button_s : out std_logic;
      start_button_s       : out std_logic
    );
    end component fsm_states_tester;

BEGIN
  DUT  : fsm_states
    PORT MAP (
      temperature_s   => temperature_s  ,
      engine_acceleration_s   => engine_acceleration_s  ,
      sinking_led_s   => sinking_led_s  ,
      sink_button_s   => sink_button_s  ,
      temperature_button_s   => temperature_button_s  ,
      speed_s   => speed_s  ,
      clock   => clock  ,
      end_led_s   => end_led_s  ,
      washing_led_s   => washing_led_s  ,
      sink_s   => sink_s  ,
      time_divider_s   => time_divider_s  ,
      start_s   => start_s  ,
      engine_acceleration_neg_sign_s   => engine_acceleration_neg_sign_s  ,
      sink_led_s   => sink_led_s  ,
      start_button_s   => start_button_s  ,
      start_led_s   => start_led_s  ,
      speed_button_s   => speed_button_s  ,
      fsm_prg_sink_enabled_s   => fsm_prg_sink_enabled_s  ,
      sevenseg_value_s   => sevenseg_value_s   ) ;

      fsm_states_tester_i : fsm_states_tester
      port map (
        clock                => clock,
        speed_button_s       => speed_button_s,
        temperature_button_s => temperature_button_s,
        start_button_s       => start_button_s
      );

END ;
