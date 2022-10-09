library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity LED is
	port(leds : out std_logic_vector(3 downto 0);
		blinking: in std_logic_vector(3 downto 0);
		clk: in std_logic);
end entity LED;

architecture A_LED of LED is 
  signal led_state: std_logic_vector(3 downto 0):= (others => '0');
begin

  clock : process(clk) 
    variable tick : integer := 48_000_000 / 2;
    variable count_clk : integer range 0 to tick; 
    begin 
		leds_all : for i in 3 downto 0 loop
			if (rising_edge(clk) and (blinking(i) = '0')) then 
			  if (count_clk = tick) then 
				 count_clk := 0; 
				 led_state(i) <= not led_state(i); 
			  else 
				 count_clk := count_clk + 1; 
			  end if; 
			end if;
			
			leds(i) <= led_state(i); 
		 end loop; 
  end process clock; 

  --
end architecture;