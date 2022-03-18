library ieee;
use ieee.std_logic_1164.all;

entity wb_hexTo7segOne is

	port
	(
		-- Input ports
		hexin	: in  std_logic_vector(3 downto 0);

		-- Output ports
		segout	: out std_logic_vector(6 downto 0)
	);
end wb_hexTo7segOne;


architecture behavior of wb_hexTo7segOne is

begin


segout(0) <= (not(hexin(3)) and not(hexin(2)) and not(hexin(1)) and (hexin(0))) or
         (not(hexin(3)) and (hexin(2)) and not(hexin(1)) and not(hexin(0))) or
         ((hexin(3)) and not(hexin(2)) and (hexin(1)) and (hexin(0))) or
         ((hexin(3)) and (hexin(2)) and not(hexin(1)) and (hexin(0)));

segout(1) <= (not(hexin(3)) and (hexin(2)) and not(hexin(1)) and (hexin(0))) or
         ((hexin(3)) and (hexin(2)) and not(hexin(0))) or
         ((hexin(2)) and (hexin(1)) and not(hexin(0))) or
         ((hexin(3)) and (hexin(1)) and (hexin(0)));

segout(2) <= (not(hexin(3)) and not(hexin(2)) and (hexin(1)) and not(hexin(0))) or
         ((hexin(3)) and (hexin(2)) and not(hexin(0))) or
         ((hexin(3)) and (hexin(2)) and (hexin(1)));

segout(3) <= (not(hexin(3)) and (hexin(2)) and not(hexin(1)) and not(hexin(0))) or
         (not(hexin(2)) and not(hexin(1)) and (hexin(0))) or
         ((hexin(2)) and (hexin(1)) and (hexin(0))) or
         ((hexin(3)) and not(hexin(2)) and (hexin(1)) and not(hexin(0)));

segout(4) <= (not(hexin(3)) and (hexin(2)) and not(hexin(1))) or
         (not(hexin(2)) and not(hexin(1)) and (hexin(0))) or
         (not(hexin(3)) and (hexin(0)));

segout(5) <= (not(hexin(3)) and not(hexin(2)) and (hexin(0))) or
         (not(hexin(3)) and not(hexin(2)) and (hexin(1))) or
         (not(hexin(3)) and (hexin(1)) and (hexin(0))) or
         ((hexin(3)) and (hexin(2)) and not(hexin(1)) and (hexin(0)));

segout(6) <= (not(hexin(3)) and not(hexin(2)) and not(hexin(1))) or
         (not(hexin(3)) and (hexin(2)) and (hexin(1)) and (hexin(0))) or
         ((hexin(3)) and (hexin(2)) and not(hexin(1)) and not(hexin(0)));



end behavior;

