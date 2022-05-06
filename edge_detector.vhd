library ieee;
use ieee.std_logic_1164.all;

entity edge_detector is
    port (
        CLK      : in STD_LOGIC;
        RESET_N  : in STD_LOGIC;
        DVI      : in STD_LOGIC;
        DVI_EDGE : out STD_LOGIC
    );
end entity edge_detector;

architecture rtl of edge_detector is
    signal reg1 : STD_LOGIC;
    signal reg2 : STD_LOGIC;
begin
    
    P_REG1: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            reg1 <= '0';
        elsif rising_edge(CLK) then
            reg1 <= DVI;
        end if;
    end process P_REG1;

    P_REG2: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            reg2 <= '0';
        elsif rising_edge(CLK) then
            reg2 <= reg1;
        end if;
    end process P_REG2;

    DVI_EDGE <= reg1 and (not reg2);
    
end architecture rtl;