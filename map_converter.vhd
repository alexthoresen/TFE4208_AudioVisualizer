library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Counter for filter bank
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

-- constant IDLE    : STD_LOGIC := '0';
-- constant OPERATE : STD_LOGIC := '1';

-- signal state: STD_LOGIC;

-- signal counter : UNSIGNED (15 DOWNTO 0);

begin


    process (CLK) is begin

        if (CLK'event and CLK = '1') then
        -- Blank
        end if;

    end process;

end fsm_arch;