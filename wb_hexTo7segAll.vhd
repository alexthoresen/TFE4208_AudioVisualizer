library ieee;
use ieee.std_logic_1164.all;

entity wb_hexTo7segAll is

	port
	(
		-- Input ports
		hex	: in  std_logic_vector(15 downto 0);

		-- Output ports
		seg3	: out std_logic_vector(6 downto 0);
	    seg2	: out std_logic_vector(6 downto 0);
	    seg1	: out std_logic_vector(6 downto 0);
	    seg0	: out std_logic_vector(6 downto 0)
	);
end wb_hexTo7segAll;


architecture behavior of wb_hexTo7segAll is

begin

U7seg3: entity work.wb_hexTo7segOne(behavior)
	port map 
	(
		hexin(3) => hex(15),
		hexin(2) => hex(14),
		hexin(1) => hex(13),
		hexin(0) => hex(12),
		segout(6) => seg3(6),
		segout(5) => seg3(5),
		segout(4) => seg3(4),
		segout(3) => seg3(3),
		segout(2) => seg3(2),
		segout(1) => seg3(1),
		segout(0) => seg3(0)
	);
	
U7seg2: entity work.wb_hexTo7segOne(behavior)
	port map 
	(
		hexin(3) => hex(11),
		hexin(2) => hex(10),
		hexin(1) => hex(9),
		hexin(0) => hex(8),
		segout(6) => seg2(6),
		segout(5) => seg2(5),
		segout(4) => seg2(4),
		segout(3) => seg2(3),
		segout(2) => seg2(2),
		segout(1) => seg2(1),
		segout(0) => seg2(0)
	);	

U7seg1: entity work.wb_hexTo7segOne(behavior)
	port map 
	(
		hexin(3) => hex(7),
		hexin(2) => hex(6),
		hexin(1) => hex(5),
		hexin(0) => hex(4),
		segout(6) => seg1(6),
		segout(5) => seg1(5),
		segout(4) => seg1(4),
		segout(3) => seg1(3),
		segout(2) => seg1(2),
		segout(1) => seg1(1),
		segout(0) => seg1(0)
	);	

U7seg0: entity work.wb_hexTo7segOne(behavior)
	port map 
	(
		hexin(3) => hex(3),
		hexin(2) => hex(2),
		hexin(1) => hex(1),
		hexin(0) => hex(0),
		segout(6) => seg0(6),
		segout(5) => seg0(5),
		segout(4) => seg0(4),
		segout(3) => seg0(3),
		segout(2) => seg0(2),
		segout(1) => seg0(1),
		segout(0) => seg0(0)
	);	




end behavior;

