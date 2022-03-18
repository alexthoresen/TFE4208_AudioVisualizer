-------------------------------------------------------------------------------
-- Title      : Program Counter
-- Project    : Lab5, DigDat
-------------------------------------------------------------------------------
-- File       : wb_cpu_sprogramcounter.vhd
-- Author     : Marius Grannaes <grannas@idi.ntnu.no>
-- Company    : 
-- Last update: 2009-09-26
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2008/09/26  1.0      grannas Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use work.wb_cpu_package.all;

entity wb_cpu_programcounter is

  port (
    -- input status
    set_counter : in std_logic_vector(IADDR_BUS - 1 downto 0);
    -- output status
    program_counter : out std_logic_vector(IADDR_BUS - 1 downto 0);
    -- enable signal
    control_PS : in std_logic; 
    -- Selects incrementation or setting immidiate (set_counter) value
    control_PL : in std_logic;
    --
    core_rst_n : in std_logic;
    core_clk : in std_logic);

end wb_cpu_programcounter;

architecture programcounter_arch of wb_cpu_programcounter is
  
  signal pc : std_logic_vector(IADDR_BUS - 1 downto 0);

begin    
    
-- update program counter
  process (core_rst_n, core_clk,pc)
  begin
      program_counter <= pc;
    if core_rst_n = '0' then
      pc <= (others => '0');

    elsif rising_edge (core_clk) then
      if control_PL = '1' then

        if control_PS = '0' then
          pc <= std_logic_vector (unsigned (pc) + 1);
        else
          pc <= set_counter;
        end if;

      end if;
    end if;
  end process;


end programcounter_arch;