library ieee;
use ieee.std_logic_1164.all;

entity counter_upto is
    generic (
        SIZE_BITS : integer := 4
    );
    port (
        CLK : in STD_LOGIC;
        RESET_N : in STD_LOGIC;

        COUNTER_START : in STD_LOGIC;
        COUNTER_TARGET : in STD_LOGIC_VECTOR(SIZE_BITS-1 downto 0);

        COUNTER_DONE : out STD_LOGIC
    );
end entity counter_upto;

architecture rtl of counter_upto is
    signal count_state : std_logic_vector(SIZE_BITS-1 downto 0);
    signal next_state  : std_logic_vector(SIZE_BITS-1 downto 0);
    signal up_vector   : std_logic_vector(SIZE_BITS-1 downto 0);
    signal and_vector  : std_logic_vector(SIZE_BITS-1 downto 0);
    signal xor_vector  : std_logic_vector(SIZE_BITS-1 downto 0);

    signal is_zero         : std_logic := '0';
    signal is_eq_to_target : std_logic;
begin
    
    P_COUNTER_REGS: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            count_state <= (others => '0');
        elsif rising_edge(CLK) then
            count_state <= next_state;
        end if;
    end process P_COUNTER_REGS;

    P_NEXT: process(count_state, up_vector, is_zero, is_eq_to_target, COUNTER_START)
    begin
        if COUNTER_START = '1' then
            next_state <= (others => '0');
            next_state(0) <= '1';
        elsif is_zero = '0' and is_eq_to_target = '0' then
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

    P_XOR_VECTOR: process(count_state, COUNTER_TARGET)
    begin
        for I in xor_vector'range loop
            xor_vector(I) <= count_state(I) xor COUNTER_TARGET(I);
        end loop;
    end process P_XOR_VECTOR;

    P_ZERO: process(count_state) is
        variable temp : std_logic_vector(SIZE_BITS-1 downto 0);
    begin
        temp(0) := count_state(0);
        for I in 1 to count_state'high loop
            temp(I) := temp(I-1) or count_state(I);
        end loop;
        is_zero <= not temp(temp'high);
    end process P_ZERO;

    P_EQ: process(xor_vector) is
        variable temp : std_logic_vector(SIZE_BITS-1 downto 0);
    begin
        temp(0) := xor_vector(0);
        for I in 1 to xor_vector'high loop
            temp(I) := temp(I-1) or xor_vector(I);
        end loop;
        is_eq_to_target <= not temp(temp'high);
    end process P_EQ;

    -- OUTPUTS

    COUNTER_DONE <= is_eq_to_target;
    
end architecture rtl;