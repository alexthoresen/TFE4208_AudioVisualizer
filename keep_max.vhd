library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

entity keep_max is
  Generic (
    SIZE_BITS : integer := 8
  );
  Port (
    CLK : in std_logic;
    RESET_N : in std_logic;

    A : in std_logic_vector(SIZE_BITS-1 downto 0);
    
    STORE : in std_logic;
    FORCE_NEW : in std_logic;
	 DVI : in std_logic;
    
    O : out std_logic_vector(SIZE_BITS-1 downto 0);
	 DVO : out std_logic
  );
end keep_max;

architecture rtl of keep_max is
    signal is_larger : std_logic;
    signal reg : std_logic_vector(SIZE_BITS-1 downto 0);
begin

    P_CMP: process(A, reg)
    begin
        if unsigned(A) > unsigned(reg) then
            is_larger <= '1';
        else
            is_larger <= '0';
        end if;
    end process P_CMP;

    P_REG: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            reg <= (others => '0');
        elsif rising_edge(CLK) then
            if FORCE_NEW = '1' or (STORE = '1' and is_larger = '1') then
                reg <= A;
            end if;
        end if;
    end process P_REG;
	 
	 P_DVO: process(CLK, RESET_N)
	 begin
		if RESET_N = '0' then
			DVO <= '0';
		elsif rising_edge(CLK) then
			if FORCE_NEW = '1' or STORE = '1' then
				DVO <= DVI;
			elsif DVI = '0' then
				DVO <= '0';
			end if;
		end if;
	 end process P_DVO;

    -- OUTPUTS

    O <= reg;

end rtl;