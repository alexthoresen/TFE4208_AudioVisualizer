library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity absval is
  generic (
        SIZE_BITS : integer := 4
  );
  port (
    A : in std_logic_vector(SIZE_BITS-1 downto 0);
    O : out std_logic_vector(SIZE_BITS-1 downto 0)
  );
end absval;

architecture rtl of absval is
    signal A_msb : std_logic;
    signal xor_res : std_logic_vector(SIZE_BITS-1 downto 0);
    signal carry_vector : std_logic_vector(SIZE_BITS-1 downto 0);
    signal sum_vector : std_logic_vector(SIZE_BITS-1 downto 0);
begin

A_msb <= A(A'high);

p_xor: process(A_msb, A)
begin
    for I in xor_res'range loop
        xor_res(I) <= A_msb xor A(I);
    end loop;
end process p_xor;

g_ha: for I in carry_vector'range generate
    g_ha1: if I = 0 generate
        ha1: entity work.half_adder(rtl) port map (
            A => xor_res(0),
            B => A_msb,
            C => carry_vector(0),
            S => sum_vector(0)
        );
    end generate g_ha1;

    g_ha2: if I > 0 generate
        ha2: entity work.half_adder(rtl) port map (
            A => xor_res(I),
            B => carry_vector(I-1),
            C => carry_vector(I),
            S => sum_vector(I)
        );
    end generate g_ha2;
end generate g_ha;

O <= sum_vector;

end rtl;
