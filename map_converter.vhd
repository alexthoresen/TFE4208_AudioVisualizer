library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Converts a 32 bit number to 8 bit
entity map_converter is

    port (IN_32_BIT : in STD_LOGIC_VECTOR (31 DOWNTO 0);
			 DVI		  : in STD_LOGIC;
          CLK       : in STD_LOGIC;
          RESET_N   : in STD_LOGIC;

          OUT_8_BIT : out STD_LOGIC_VECTOR (7 DOWNTO 0);
			 DVO		  : out STD_LOGIC
    );

end map_converter;


architecture fsm_arch of map_converter is

	signal temp_output_8_bit : STD_LOGIC_VECTOR (7 DOWNTO 0);
	signal temp_input_8_bit  : STD_LOGIC_VECTOR (7 DOWNTO 0);
	
begin

	temp_input_8_bit <= IN_32_BIT(31 DOWNTO 24);
	
	process (CLK, RESET_N) is begin
		if (!RESET_N) then
			DVO		  			<= '0';
			OUT_8_BIT  			<= '0';
			temp_output_8_bit <= '0';
		
		elsif (CLK'event and CLK = '1') then
			if (DVI) then
				temp_output_8_bit[7] <= temp_input_8_bit[7];
				
				for (i in 6 downto 0) loop
					temp_output_8_bit[i] <= temp_input_8_bit[i] or temp_output_8_bit[i + 1];
				end loop
				
				OUT_8_BIT <= temp_output_8_bit;
				
			else
				DVO 					<= '0';
				OUT_8_BIT  			<= '0';
				temp_output_8_bit <= '0';
				
			end if
      end if;
    end process;

end fsm_arch;