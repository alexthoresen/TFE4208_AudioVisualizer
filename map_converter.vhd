library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Converts a 32 bit number to 8 bit
entity map_converter is

    port (
		IN_32_BIT : in STD_LOGIC_VECTOR (31 DOWNTO 0);
		DVI		  : in STD_LOGIC;

        OUT_8_BIT : out STD_LOGIC_VECTOR (7 DOWNTO 0);
		DVO		  : out STD_LOGIC
    );

end map_converter;

architecture rtl of map_converter is

	signal input_8_bit  : STD_LOGIC_VECTOR (8 DOWNTO 0);
	signal or_vector : STD_LOGIC_VECTOR (8 DOWNTO 0);
	
begin

	input_8_bit <= IN_32_BIT(31 DOWNTO 23);

	p_or: process(input_8_bit, or_vector) is
	begin
		or_vector(8) <= input_8_bit(8);
		for i in 7 downto 0 loop
			or_vector(i) <= input_8_bit(i) or or_vector(i+1);
		end loop;
	end process p_or;

	-- OUTPUTS

	DVO <= DVI;

	OUT_8_BIT <= or_vector(7 downto 0);

end rtl;