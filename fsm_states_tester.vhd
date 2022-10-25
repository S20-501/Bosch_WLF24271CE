LIBRARY ieee  ;
LIBRARY work  ;
USE ieee.NUMERIC_STD.all  ;
USE ieee.std_logic_1164.all  ;
USE ieee.STD_LOGIC_UNSIGNED.all  ;

ENTITY fsm_states_tester  IS
    port(
        clock: out std_logic := '0';
        speed_button_s: out std_logic := '0';
        temperature_button_s: out std_logic := '0';
        start_button_s: out std_logic := '0'
    );
END ;

ARCHITECTURE fsm_states_tester_arch OF fsm_states_tester IS
    signal clock_r:std_logic := '0';
BEGIN
      clock_r <= not clock_r after 10 ps;

      clock <= clock_r;

      speed_button_s <= '1' after 50 ps, '0' after 1 ns,
        '1' after 21 ns, '0' after 22 ns;

      temperature_button_s <= '1' after 3 ns, '0' after 4 ns,
        '1' after 24 ns, '0' after 25 ns;


      start_button_s <= '1' after 7 ns, '0' after 9 ns, '1' after 14 ns, '0' after 14300 ps,
                '1' after 18 ns, '0' after 18200 ps;
END ;
