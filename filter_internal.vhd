library ieee;
use ieee.std_logic_1164.all;

entity filter_internal is
    generic (
        A1 : STD_LOGIC_VECTOR(31 downto 0) := x"3fc9543f";
        A2 : STD_LOGIC_VECTOR(31 downto 0) := x"bfd6c831";
        A3 : STD_LOGIC_VECTOR(31 downto 0) := x"3f6a7f96";
        A4 : STD_LOGIC_VECTOR(31 downto 0) := x"bebbc988";

        B0 : STD_LOGIC_VECTOR(31 downto 0) := x"3dab2249";
        B1 : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
        B2 : STD_LOGIC_VECTOR(31 downto 0) := x"be2b2249";
        B3 : STD_LOGIC_VECTOR(31 downto 0) := x"00000000";
        B4 : STD_LOGIC_VECTOR(31 downto 0) := x"3dab2249"
    );
    port (
        CLK : in STD_LOGIC;
        RESET_N : in STD_LOGIC;

        DVI : in STD_LOGIC;
        FILTER_IN : STD_LOGIC_VECTOR(15 downto 0);

        DVO : out STD_LOGIC;
        FILTER_OUT : out STD_LOGIC_VECTOR(31 downto 0)
    );
end entity filter_internal;

architecture rtl of filter_internal is
    signal dvi_edge : std_logic;
    signal input_stored : std_logic_vector(15 downto 0);
    signal output_stored : std_logic_vector(31 downto 0);
    
    signal counter_done : std_logic;
    signal clk_en : std_logic;
    signal store_in : std_logic;
    signal store_filter : std_logic;
    signal store_out : std_logic;
    signal counter_start : std_logic;
    signal counter_target : std_logic_vector(7 downto 0);

    signal datapath_output : std_logic_vector(31 downto 0);
    
begin
    
    -- REGS

    P_REG_IN: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            input_stored <= (others => '0');
        elsif rising_edge(CLK) and store_in = '1' then
            input_stored <= FILTER_IN;
        end if;
    end process P_REG_IN;

    P_REG_OUT: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            output_stored <= (others => '0');
        elsif rising_edge(CLK) and store_out = '1' then
            output_stored <= datapath_output;
        end if;
    end process P_REG_OUT;

    -- CONTROL MODULE

    C_CTRL : entity work.filter_internal_control(rtl)
    port map (
        CLK => CLK,
        RESET_N => RESET_N,
        DVI_EDGE => dvi_edge,
        COUNTER_DONE => counter_done,
        CLK_EN => clk_en,
        STORE_IN => store_in,
        STORE_FILTER => store_filter,
        STORE_OUT => store_out,
        COUNTER_START => counter_start,
        DVO => DVO,
        COUNTER_TARGET => counter_target
    );

    -- DATAPATH MODULE

    C_DTP : entity work.filter_internal_datapath(rtl)
    generic map (
        A1 => A1,
        A2 => A2,
        A3 => A3,
        A4 => A4,
        B0 => B0,
        B1 => B1,
        B2 => B2,
        B3 => B3,
        B4 => B4
    )
    port map (
        FILTER_IN => input_stored,
        CLK => CLK,
        CLK_EN => clk_en,
        STORE => store_filter,
        RESET_N => RESET_N,
        FILTER_OUT => datapath_output
    );

    -- EDGE DETECTOR

    C_EDGE : entity work.edge_detector(rtl)
    port map (
        CLK => CLK,
        RESET_N => RESET_N,
        DVI => DVI,
        DVI_EDGE => dvi_edge
    );

    -- COUNTER

    C_COUNTER : entity work.counter_upto(rtl)
    generic map (
        SIZE_BITS => 8
    )
    port map (
        CLK => CLK,
        RESET_N => RESET_N,
        COUNTER_START => counter_start,
        COUNTER_TARGET => counter_target,
        COUNTER_DONE => counter_done
    );

    -- OUTPUTS

    -- DVO straight from control module

    FILTER_OUT <= output_stored;
    
end architecture rtl;