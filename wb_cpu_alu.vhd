-------------------------------------------------------------------------------
-- Title      : ALU
-- Project    : Lab5, DigDat
-------------------------------------------------------------------------------
-- File       : alu.vhd
-- Author     : Asbjørn Djupdal  <asbjoern@djupdal.org>
-- Company    : 
-- Last update: 2008-06-17
-- Platform   : BenERA, Virtex 1000E
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003/08/07  1.0      djupdal	Created
-- 2008/09/26  1.1      grannas Adapted to DigDat lab
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.wb_cpu_package.all;

entity wb_cpu_alu is

  port (
    alu_funct : in std_logic_vector(FUNCT_BUS - 1 downto 0);
    alu_in_a  : in std_logic_vector(DDATA_BUS - 1 downto 0);
    alu_in_b  : in std_logic_vector(DDATA_BUS - 1 downto 0);

	
    alu_out    : out std_logic_vector(DDATA_BUS - 1 downto 0);
    alu_status : out std_logic_vector(STATUS_BUS - 1 downto 0));

end wb_cpu_alu;    

-------------------------------------------------------------------------------

architecture alu_arch of wb_cpu_alu is

  -- These are one bit more than the inputs and outputs. This lets us
  -- check for carry

  signal alu_out_i        : std_logic_vector(DDATA_BUS downto 0);
  signal alu_in_a_i       : std_logic_vector(DDATA_BUS downto 0);
  signal alu_in_b_i       : std_logic_vector(DDATA_BUS downto 0);

begin

  process (alu_in_a, alu_in_b)
  begin 

    alu_in_a_i <= '0'&alu_in_a;
    alu_in_b_i <= '0'&alu_in_b;
  
  end process;

  -- alu
  process (alu_funct, alu_in_a, alu_in_b)
  begin
    case alu_funct is
      -- move
      when "0000" =>
        alu_out_i(DDATA_BUS - 1 downto 0) <= alu_in_a;

      -- and
      when "0001" =>
        alu_out_i(DDATA_BUS - 1 downto 0) <= alu_in_a and alu_in_b;

      -- or
      when "0010" =>
        alu_out_i(DDATA_BUS - 1 downto 0) <= alu_in_a or alu_in_b;

      -- xor
      when "0011" =>
        alu_out_i(DDATA_BUS - 1 downto 0) <= alu_in_a xor alu_in_b;

      -- not
      when "0100" =>
        alu_out_i(DDATA_BUS - 1 downto 0) <= not alu_in_a;

      -- logical shift left
      when "0101" =>
        alu_out_i(DDATA_BUS - 1 downto 1) <= alu_in_a(DDATA_BUS - 2 downto 0);
        alu_out_i(0) <= '0';

      -- logical shift right
      when "0110" =>
        alu_out_i(DDATA_BUS - 1) <= '0';
        alu_out_i(DDATA_BUS - 2 downto 0) <= alu_in_a(DDATA_BUS - 1 downto 1);

      -- add
      when "0111" =>
        alu_out_i(DDATA_BUS downto 0) <= std_logic_vector (unsigned (alu_in_a_i) +
                                                           unsigned (alu_in_b_i));

      -- sub
      when "1000" =>
        alu_out_i(DDATA_BUS - 1 downto 0) <=
          std_logic_vector (unsigned (alu_in_a) - unsigned (alu_in_b));

      when others =>
        alu_out_i <= (others => '0');

    end case;
  end process;

  process (alu_out_i)
    begin
      alu_out <= alu_out_i(DDATA_BUS - 1 downto 0);

      -- set zero flag
      if alu_out_i(DDATA_BUS -1 downto 0) = "00000000" then
        alu_status(0) <= '1'; 
      else 
        alu_status(0) <= '0';
      end if;
   
      -- set carry flag
      alu_status(1) <= alu_out_i(DDATA_BUS);
      -- set negative flag
      alu_status(2) <= alu_out_i(DDATA_BUS - 1);
   end process;

  -----------------------------------------------------------------------------

end alu_arch;
