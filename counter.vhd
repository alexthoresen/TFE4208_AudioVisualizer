library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

-- Counter for filter bank
entity counter is
    generic (
        SIZE_BITS : integer
    );
    port (INCREMENT : in STD_LOGIC;
          CLK       : in STD_LOGIC;
          RESET_N   : in STD_LOGIC;

          COUNTER_DONE : out STD_LOGIC
    );

end counter;


architecture rtl of counter is

    signal count_state : std_logic_vector(SIZE_BITS-1 downto 0);
    signal next_state : std_logic_vector(SIZE_BITS-1 downto 0);
    signal up_vector : std_logic_vector(SIZE_BITS-1 downto 0);
    signal and_vector : std_logic_vector(SIZE_BITS-1 downto 0);

    signal overflow_reg : std_logic;
begin
    
    P_COUNTER_REGS: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            count_state <= (others => '0');
        elsif rising_edge(CLK) then
            count_state <= next_state;
        end if;
    end process P_COUNTER_REGS;

    P_NEXT: process(count_state, up_vector, INCREMENT)
    begin
        if INCREMENT = '1' then
            next_state <= up_vector;
        else
            next_state <= count_state;
        end if;
    end process P_NEXT;

    P_UP_VECTOR: process(count_state, and_vector)
    begin
        up_vector(0) <= not count_state(0);
        for I in 1 to up_vector'high loop
            up_vector(I) <= count_state(I) xor and_vector(I-1);
        end loop;
    end process P_UP_VECTOR;

    P_AND_VECTOR: process(and_vector, count_state)
    begin
        and_vector(0) <= count_state(0);
        for I in 1 to and_vector'high loop
            and_vector(I) <= count_state(I) and and_vector(I-1);
        end loop;
    end process P_AND_VECTOR;

    P_OVERFLOW_REG: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            overflow_reg <= '0';
        elsif rising_edge(CLK) then
            overflow_reg <= INCREMENT and and_vector(and_vector'high);
        end if;
    end process P_OVERFLOW_REG;

    -- OUTPUTS

    COUNTER_DONE <= overflow_reg;
    
end architecture rtl;