library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Bosch_WLF24271CE is
	port(CLK: in std_logic;
	--leds
		DS_C,DS_D,DS_G,DS_DP: out std_logic;
		--
		DS_F,DS_E,DS_A,DS_B: out std_logic;
		--input key
	 	KEY1,KEY2,KEY3,KEY4: in std_logic
		);
end entity Bosch_WLF24271CE;

architecture A_Bosch_WLF24271CE of Bosch_WLF24271CE is
component LED is
	port(leds : out std_logic_vector(3 downto 0);
	blinking: in std_logic_vector(3 downto 0);
		clk: in std_logic);
end component LED;
begin
	LED_P: LED port map(
			clk => CLK,
			leds(0) => DS_C,
			leds(1) => DS_G,
			leds(2) => DS_D,
			leds(3) => DS_DP,
--			leds(0) => DS_F,
--			leds(1) => DS_E,
--			leds(2) => DS_A,
--			leds(3) => DS_B,
			blinking(0) => KEY1,
			blinking(1) => KEY2,
			blinking(2) => KEY3,
			blinking(3) => KEY4
			);
end architecture A_Bosch_WLF24271CE;


