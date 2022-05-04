library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;


entity filter_internal is
    -- Generic coefficients
    generic (A0 : INTEGER := 1;
             A1 : INTEGER := 2000;
             A2 : INTEGER := 2000;
             A3 : INTEGER := 2000;
             A4 : INTEGER := 2000;
             A5 : INTEGER := 2000;
             A6 : INTEGER := 2000;
             A7 : INTEGER := 2000;

             B0 : INTEGER := 2000;
             B1 : INTEGER := 2000;
             B2 : INTEGER := 2000;
             B3 : INTEGER := 2000;
             B4 : INTEGER := 2000;
             B5 : INTEGER := 2000;
             B6 : INTEGER := 2000;
             B7 : INTEGER := 2000
    );

    port (DVI       : in STD_LOGIC;
          FILTER_IN : in SIGNED (15 DOWNTO 0);
          CLK       : in STD_LOGIC;
          RESET_N   : in STD_LOGIC;

          FILTER_OUT : out SIGNED (31 DOWNTO 0);
          DVO        : out STD_LOGIC
    );

end filter_internal;


architecture filter_arch of filter_internal is

-- constant S0 : integer := '0';
-- constant S1 : integer := '1';
-- constant S2 : integer := '2';
-- constant S3 : integer := '3';
-- constant S4 : integer := '4';
-- constant S5 : integer := '5';
-- constant S6 : integer := '6';
-- constant S7 : integer := '7';

-- signal state: integer;

signal filter_in_sig : SIGNED (31 DOWNTO 0);


begin

	filter_in_sig <= resize(FILTER_IN, filter_in_sig'length);

	process (CLK) is begin

        if (CLK'event and CLK = '1') then
        -- use multipliers, adders
        end if;

    end process;

end filter_arch;