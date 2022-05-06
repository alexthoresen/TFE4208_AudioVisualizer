library ieee;
use ieee.std_logic_1164.all;

entity filter is
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
        DVI : in STD_LOGIC;
        A : in STD_LOGIC_VECTOR(15 downto 0);
        
        CLK : in STD_LOGIC;
        RESET_N : in STD_LOGIC;

        FORCE_NEW : in STD_LOGIC;

        RESULT : out STD_LOGIC_VECTOR(7 downto 0);
        DVO : out STD_LOGIC
    );
end entity filter;

architecture rtl of filter is
    signal filter_internal_out : std_logic_vector(31 downto 0);
    signal filter_internal_dvo : std_logic;

    signal dvi_edge : std_logic;

    signal abs_out : std_logic_vector(31 downto 0);

    signal keep_max_out : std_logic_vector(31 downto 0);
    signal keep_max_dvo : std_logic;
begin
    
    C_FILTER_I : entity work.filter_internal(rtl)
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
        CLK => CLK,
        RESET_N => RESET_N,
        DVI => DVI,
        FILTER_IN => A,

        DVO => filter_internal_dvo,
        FILTER_OUT => filter_internal_out
    );

    C_EDGE : entity work.edge_detector(rtl)
    port map (
        CLK => CLK,
        RESET_N => RESET_N,
        DVI => filter_internal_dvo,
        DVI_EDGE => dvi_edge
    );

    C_ABS : entity work.absval(rtl)
    generic map (
        SIZE_BITS => 32
    )
    port map (
        A => filter_internal_out,
        O => abs_out
    );

    C_MAX : entity work.keep_max(rtl)
    generic map (
        SIZE_BITS => 32
    )
    port map (
        CLK => CLK,
        RESET_N => RESET_N,
        A => abs_out,
        DVI => filter_internal_dvo,
        STORE => dvi_edge,
        FORCE_NEW => FORCE_NEW,

        O => keep_max_out,
        DVO => keep_max_dvo
    );

    C_MAP : entity work.map_converter(rtl)
    port map (
        IN_32_BIT => keep_max_out,
        DVI => keep_max_dvo,

        OUT_8_BIT => RESULT,
        DVO => DVO
    );
    
end architecture rtl;