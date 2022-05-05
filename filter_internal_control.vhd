library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter_internal_control is
    port (
          CLK           : in STD_LOGIC;
          RESET_N       : in STD_LOGIC;
          DVI_EDGE      : in STD_LOGIC;
          COUNTER_DONE  : in STD_LOGIC;

          CLK_EN        : out STD_LOGIC;
          STORE_IN      : out STD_LOGIC;
          STORE_FILTER  : out STD_LOGIC;
          STORE_OUT     : out STD_LOGIC;
          COUNTER_START : out STD_LOGIC;
          DVO           : out STD_LOGIC;

          COUNTER_TARGET : out STD_LOGIC_VECTOR(7 downto 0)
    );

end filter_internal_control;

architecture rtl of filter_internal_control is
    constant CALC_CYCLES : integer := 82;

    type t_state is (IDLE, INIT, CALC, FINISH);

    signal curr_state : t_state;
    signal next_state : t_state;

    signal set_dvo   : STD_LOGIC;
    signal reset_dvo : STD_LOGIC;
begin

    COUNTER_TARGET <= STD_LOGIC_VECTOR( TO_UNSIGNED(CALC_CYCLES, 8) );
    
    P_STATE: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            curr_state <= IDLE;
        elsif rising_edge(CLK) then
            curr_state <= next_state;
        end if;
    end process P_STATE;

    P_NEXT: process(curr_state, DVI_EDGE, COUNTER_DONE)
    begin
        case curr_state is
            when IDLE =>
                if DVI_EDGE = '1' then
                    next_state <= INIT;
                else
                    next_state <= IDLE;
                end if;

            when INIT =>
                next_state <= CALC;

            when CALC =>
                if COUNTER_DONE = '1' then
                    next_state <= FINISH;
                else
                    next_state <= CALC;
                end if;

            when FINISH =>
                next_state <= IDLE;
        
            when others =>
                next_state <= IDLE;
        
        end case;
    end process P_NEXT;
    
    P_OUT: process(curr_state)
    begin
        case curr_state is
            when IDLE =>
                CLK_EN        <= '0';
                STORE_IN      <= '0';
                STORE_FILTER  <= '0';
                STORE_OUT     <= '0';
                COUNTER_START <= '0';

                set_dvo   <= '0';
                reset_dvo <= '0';

            when INIT =>
                CLK_EN        <= '0';
                STORE_IN      <= '1';
                STORE_FILTER  <= '0';
                STORE_OUT     <= '0';
                COUNTER_START <= '1';

                set_dvo   <= '0';
                reset_dvo <= '1';

            when CALC =>
                CLK_EN        <= '1';
                STORE_IN      <= '0';
                STORE_FILTER  <= '0';
                STORE_OUT     <= '0';
                COUNTER_START <= '0';

                set_dvo   <= '0';
                reset_dvo <= '0';

            when FINISH =>
                CLK_EN        <= '0';
                STORE_IN      <= '0';
                STORE_FILTER  <= '1';
                STORE_OUT     <= '1';
                COUNTER_START <= '0';

                set_dvo   <= '1';
                reset_dvo <= '0';
        
            when others =>
                CLK_EN        <= '0';
                STORE_IN      <= '0';
                STORE_FILTER  <= '0';
                STORE_OUT     <= '0';
                COUNTER_START <= '0';
                
                set_dvo   <= '0';
                reset_dvo <= '0';
        
        end case;
    end process P_OUT;

    P_DVO: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            DVO <= '0';
        elsif rising_edge(CLK) then
            if reset_dvo = '1' then
                DVO <= '0';
            elsif set_dvo = '1' then
                DVO <= '1';
            end if;
        end if;
    end process P_DVO;
    
end architecture rtl;