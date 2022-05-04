library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Counter for filter bank
entity counter is

    port (INCREMENT : in STD_LOGIC;
          CLK       : in STD_LOGIC;
          RESET_N   : in STD_LOGIC;

          COUNTER_DONE : out STD_LOGIC
    );

end counter;


architecture fsm_arch of counter is

-- constant IDLE    : STD_LOGIC := '0';
-- constant OPERATE : STD_LOGIC := '1';

-- signal state: STD_LOGIC;

signal counter : UNSIGNED (15 DOWNTO 0);

begin


    process (CLK) is begin

        if (CLK'event and CLK = '1') then
        -- Blank
        end if;

    end process;

end fsm_arch;