library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package sevenseg_pkg is
    subtype sevenseg_t is std_logic_vector(6 downto 0);
    type sevenseg_charset_t is
      ('0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
      'C', 'o', 'l', 'd', 'E', 'n', 'h', '-', ' ');

    type charset_vector_t is array (natural range <>) of sevenseg_charset_t;
end package;
