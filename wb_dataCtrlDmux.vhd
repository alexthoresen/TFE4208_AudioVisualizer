library ieee;
use ieee.std_logic_1164.all;

entity wb_dataCtrlDmux is

	port
	(
		-- Input ports
		result_A	: in  std_logic_vector(15 downto 0);
		DVI : in std_logic;
		sel : in std_logic;

		-- Output ports
		testResult_A	: out std_logic_vector(15 downto 0);
	    audioResult_A	: out std_logic_vector(15 downto 0);
	    testDVI	: out std_logic;
	    audioDVI	: out std_logic
	);
end wb_dataCtrlDmux;


architecture behavior of wb_dataCtrlDmux is

begin

	testResult_A <= result_A when sel = '0' else "0000000000000000";
	audioResult_A <= result_A when sel = '1' else "0000000000000000";
	testDVI <= DVI when sel = '0' else '0';
	audioDVI <= DVI when sel = '1' else '0';

end behavior;

