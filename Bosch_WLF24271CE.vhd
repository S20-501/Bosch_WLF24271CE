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
	 	KEY1,KEY2,KEY3,KEY4: in std_logic
		);
end entity Bosch_WLF24271CE;

architecture A_Bosch_WLF24271CE of Bosch_WLF24271CE is
		signal sevenseg_value_r: charset_vector_t(3 downto 0) := "Cold";
		signal clock_divider_counter: natural range 0 to 10000 := 0;
component sevenseg_display is
    port (
    clock: in std_logic;
    sevenseg_value_r: in charset_vector_t(3 downto 0);
    sevenseg_enabled_digit_s: out std_logic_vector(3 downto 0);
    sevenseg_bus_s:out std_logic_vector(6 downto 0)
    );
end component;
begin
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

end architecture A_Bosch_WLF24271CE;
