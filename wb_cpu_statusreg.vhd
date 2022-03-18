-------------------------------------------------------------------------------
-- Title      : Status register
-- Project    : Lab5, DigDat
-------------------------------------------------------------------------------
-- File       : wb_cpu_statusreg.vhd
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
use work.wb_cpu_package.all;

entity wb_cpu_statusreg is

  port (
    -- input status
    input_status : in std_logic_vector(STATUS_BUS - 1 downto 0);
    -- output status
    output_status : out std_logic_vector(STATUS_BUS - 1 downto 0);
    -- enable signal
    status_update_enable : in std_logic;
    --
    core_rst : in std_logic;
    core_clk : in std_logic);

end wb_cpu_statusreg;

architecture statusreg_arch of wb_cpu_statusreg is

begin    
    
  process (core_rst, core_clk)
  begin
    if core_rst = '0' then
       output_status <= (others => '0');
    elsif rising_edge (core_clk) then
      if status_update_enable = '1' then
         output_status <= input_status;
      end if;
    end if;
  end process;

end statusreg_arch;