-- ////////////////////////////////////////////////////
-- //			     (0)
-- //		    --------
-- //		    |       |
-- //		(5) |  (6)	|(1)
-- //		    --------
-- //		    |		   |
-- //		(4)|		   |(2)
-- //		   --------
-- //			  (3)
-- ///////////////////////////////////////////////////

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sevenseg_pkg.all;

entity sevenseg_digit is
    port (
        -- clock: in std_logic;
        sevenseg_in_s : in sevenseg_charset_t;
        sevenseg_out_s : out sevenseg_t
    );
end entity;

architecture sevenseg_digit_a of sevenseg_digit is
    type sevenseg_digits_map_t is array (0 to 9) of sevenseg_t;
    constant SEVENSEG_DIGIT_MAP : sevenseg_digits_map_t := (
      "0111111",
      "0000110",
      "1011011",
      "1001111",
      "1100110",
      "1101101",
      "1111101",
      "0000111",
      "1111111",
      "1101111"
    );

    constant SEVENSEG_CHARACTER_C     : sevenseg_t := "0111001";
    constant SEVENSEG_CHARACTER_o     : sevenseg_t := "1011100";
    constant SEVENSEG_CHARACTER_l     : sevenseg_t := "0000110";
    constant SEVENSEG_CHARACTER_d     : sevenseg_t := "1011110";
    constant SEVENSEG_CHARACTER_E     : sevenseg_t := "1111001";
    constant SEVENSEG_CHARACTER_n     : sevenseg_t := "1010100";
    constant SEVENSEG_CHARACTER_h     : sevenseg_t := "1110100";
    constant SEVENSEG_CHARACTER_minus : sevenseg_t := "1000000";
    constant SEVENSEG_CHARACTER_space : sevenseg_t := "0000000";
begin
    with sevenseg_in_s select sevenseg_out_s <=
        SEVENSEG_DIGIT_MAP(0) when '0',
        SEVENSEG_DIGIT_MAP(1) when '1',
        SEVENSEG_DIGIT_MAP(2) when '2',
        SEVENSEG_DIGIT_MAP(3) when '3',
        SEVENSEG_DIGIT_MAP(4) when '4',
        SEVENSEG_DIGIT_MAP(5) when '5',
        SEVENSEG_DIGIT_MAP(6) when '6',
        SEVENSEG_DIGIT_MAP(7) when '7',
        SEVENSEG_DIGIT_MAP(8) when '8',
        SEVENSEG_DIGIT_MAP(9) when '9',
        SEVENSEG_CHARACTER_C when 'C',
        SEVENSEG_CHARACTER_o when 'o',
        SEVENSEG_CHARACTER_l when 'l',
        SEVENSEG_CHARACTER_d when 'd',
        SEVENSEG_CHARACTER_E when 'E',
        SEVENSEG_CHARACTER_n when 'n',
        SEVENSEG_CHARACTER_h when 'h',
        SEVENSEG_CHARACTER_minus when '-',
        SEVENSEG_CHARACTER_space when ' '
        ;

end architecture;
