library IEEE;
use IEEE.std_logic_1164.all;
use ieee.numeric_std.all;

entity filter_internal_datapath is
    -- Generic coefficients
    generic (
             A1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
             A2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
             A3 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
             A4 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');

             B0 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
             B1 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
             B2 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
             B3 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
             B4 : STD_LOGIC_VECTOR(31 downto 0) := (others => '0')
    );

    port (
          FILTER_IN : in STD_LOGIC_VECTOR(15 DOWNTO 0);
          CLK       : in STD_LOGIC;
          CLK_EN    : in STD_LOGIC;
          STORE     : in STD_LOGIC;
          RESET_N   : in STD_LOGIC;

          FILTER_OUT : out STD_LOGIC_VECTOR(31 DOWNTO 0)
    );

end filter_internal_datapath;


architecture rtl of filter_internal_datapath is

signal filter_in_sign_ext : STD_LOGIC_VECTOR(31 downto 0);

signal x0 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal x1 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal x2 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal x3 : STD_LOGIC_VECTOR(31 DOWNTO 0);
signal x4 : STD_LOGIC_VECTOR(31 DOWNTO 0);

signal y0 : STD_LOGIC_VECTOR(31 downto 0);
signal y1 : STD_LOGIC_VECTOR(31 downto 0);
signal y2 : STD_LOGIC_VECTOR(31 downto 0);
signal y3 : STD_LOGIC_VECTOR(31 downto 0);
signal y4 : STD_LOGIC_VECTOR(31 downto 0);

signal mult_res_y1 : STD_LOGIC_VECTOR(31 downto 0);
signal mult_res_y2 : STD_LOGIC_VECTOR(31 downto 0);
signal mult_res_y3 : STD_LOGIC_VECTOR(31 downto 0);
signal mult_res_y4 : STD_LOGIC_VECTOR(31 downto 0);
signal mult_res_x0 : STD_LOGIC_VECTOR(31 downto 0);
signal mult_res_x1 : STD_LOGIC_VECTOR(31 downto 0);
signal mult_res_x2 : STD_LOGIC_VECTOR(31 downto 0);
signal mult_res_x3 : STD_LOGIC_VECTOR(31 downto 0);
signal mult_res_x4 : STD_LOGIC_VECTOR(31 downto 0);

signal add_res_y0 : STD_LOGIC_VECTOR(31 downto 0);
signal add_res_y1 : STD_LOGIC_VECTOR(31 downto 0);
signal add_res_y2 : STD_LOGIC_VECTOR(31 downto 0);
signal add_res_y3 : STD_LOGIC_VECTOR(31 downto 0);
signal add_res_x0 : STD_LOGIC_VECTOR(31 downto 0);
signal add_res_x1 : STD_LOGIC_VECTOR(31 downto 0);
signal add_res_x2 : STD_LOGIC_VECTOR(31 downto 0);
signal add_res_x3 : STD_LOGIC_VECTOR(31 downto 0);

-- COMPONENTS

COMPONENT altfp_convert_int_to_float
	PORT (
			clk_en	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT altfp_convert_float_to_int
	PORT (
			clk_en	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT altfp_multi
	PORT (
			clk_en	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT altfp_add
	PORT (
			clk_en	: IN STD_LOGIC ;
			clock	: IN STD_LOGIC ;
			dataa	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			datab	: IN STD_LOGIC_VECTOR (31 DOWNTO 0);
			result	: OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
	);
END COMPONENT;

begin

    -- INPUT CONVERSION

	filter_in_sign_ext <= STD_LOGIC_VECTOR(resize(signed(FILTER_IN), filter_in_sign_ext'length));

    C_I2F : altfp_convert_int_to_float port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => filter_in_sign_ext,
        result => x0
    );

    -- REGISTERS

    P_X1_REG: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            x1 <= (others => '0');
        elsif rising_edge(CLK) and STORE = '1' then
            x1 <= x0;
        end if;
    end process P_X1_REG;

    P_X2_REG: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            x2 <= (others => '0');
        elsif rising_edge(CLK) and STORE = '1' then
            x2 <= x1;
        end if;
    end process P_X2_REG;

    P_X3_REG: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            x3 <= (others => '0');
        elsif rising_edge(CLK) and STORE = '1' then
            x3 <= x2;
        end if;
    end process P_X3_REG;

    P_X4_REG: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            x4 <= (others => '0');
        elsif rising_edge(CLK) and STORE = '1' then
            x4 <= x3;
        end if;
    end process P_X4_REG;

    P_Y1_REG: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            y1 <= (others => '0');
        elsif rising_edge(CLK) and STORE = '1' then
            y1 <= y0;
        end if;
    end process P_Y1_REG;

    P_Y2_REG: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            y2 <= (others => '0');
        elsif rising_edge(CLK) and STORE = '1' then
            y2 <= y1;
        end if;
    end process P_Y2_REG;

    P_Y3_REG: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            y3 <= (others => '0');
        elsif rising_edge(CLK) and STORE = '1' then
            y3 <= y2;
        end if;
    end process P_Y3_REG;

    P_Y4_REG: process(CLK, RESET_N)
    begin
        if RESET_N = '0' then
            y4 <= (others => '0');
        elsif rising_edge(CLK) and STORE = '1' then
            y4 <= y3;
        end if;
    end process P_Y4_REG;

    -- MULTIPLIERS

    C_MX0 : altfp_multi port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => x0,
        datab => B0,
        result => mult_res_x0
    );

    C_MX1 : altfp_multi port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => x1,
        datab => B1,
        result => mult_res_x1
    );

    C_MX2 : altfp_multi port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => x2,
        datab => B2,
        result => mult_res_x2
    );

    C_MX3 : altfp_multi port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => x3,
        datab => B3,
        result => mult_res_x3
    );

    C_MX4 : altfp_multi port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => x4,
        datab => B4,
        result => mult_res_x4
    );

    C_MY1 : altfp_multi port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => y1,
        datab => A1,
        result => mult_res_y1
    );

	C_MY2 : altfp_multi port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => y2,
        datab => A2,
        result => mult_res_y2
    );

    C_MY3 : altfp_multi port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => y3,
        datab => A3,
        result => mult_res_y3
    );

    C_MY4 : altfp_multi port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => y4,
        datab => A4,
        result => mult_res_y4
    );

    -- ADDERS

    C_AX0 : altfp_add port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => mult_res_x0,
        datab => add_res_x1,
        result => add_res_x0
    );

    C_AX1 : altfp_add port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => mult_res_x1,
        datab => add_res_x2,
        result => add_res_x1
    );
    
    C_AX2 : altfp_add port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => mult_res_x2,
        datab => add_res_x3,
        result => add_res_x2
    );

    C_AX3 : altfp_add port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => mult_res_x3,
        datab => mult_res_x4,
        result => add_res_x3
    );

    C_AY0 : altfp_add port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => add_res_x0,
        datab => add_res_y1,
        result => add_res_y0
    );

    C_AY1 : altfp_add port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => mult_res_y1,
        datab => add_res_y2,
        result => add_res_y1
    );

    C_AY2 : altfp_add port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => mult_res_y2,
        datab => add_res_y3,
        result => add_res_y2
    );

    C_AY3 : altfp_add port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => mult_res_y3,
        datab => mult_res_y4,
        result => add_res_y3
    );

    -- Y0

    y0 <= add_res_y0;

    -- OUTPUT CONVERSION

    C_F2I : altfp_convert_float_to_int port map (
        clk_en => CLK_EN,
        clock => CLK,
        dataa => y0,
        result => FILTER_OUT
    );

end rtl;