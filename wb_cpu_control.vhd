-------------------------------------------------------------------------------
-- Title      : Control Unit
-- Project    : Lab5, DigDat
-------------------------------------------------------------------------------
-- File       : wb_cpu_control.vhd
-- Author     : Asbj�rn Djupdal  <asbjoern@djupdal.org>
-- Company    : 
-- Last update: 2008-06-12
-- Platform   : BenERA, Virtex 1000E
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003/08/07  1.0      djupdal	Created
-- 2008/09/26  1.1      grannas Adapted to DigDat
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.wb_cpu_package.all;

entity wb_cpu_control is

  port (
    control_PS                : out std_logic;
    control_PL          : out std_logic;
    control_MD2 : out std_logic;
    control_RW                  : out std_logic;
    control_IOW                 : out std_logic;
    control_MD1                 : out std_logic;

    sr     : in std_logic_vector(STATUS_BUS - 1 downto 0);
    opcode : in std_logic_vector(3 downto 0);

    rst      : in std_logic;
    core_clk : in std_logic);

end wb_cpu_control;

-------------------------------------------------------------------------------

architecture control_arch of wb_cpu_control is

  type state_type is (fetch, execute);

  signal state : state_type;
  
  signal status_register : std_logic_vector(STATUS_BUS - 1 downto 0);
  
  signal control_SR : std_logic;

begin

  -----------------------------------------------------------------------------
  -- state machine, clocked part
  -----------------------------------------------------------------------------

  process (rst, core_clk)
  begin
    if rst = '0' then
      state <= fetch;

    elsif rising_edge (core_clk) then
      case state is

        when fetch =>
          state <= execute;

        when execute =>
          state <= fetch;

        when others =>
          state <= fetch;

      end case;
    end if;
  end process;

  -----------------------------------------------------------------------------
  -- state machine, comb. part
  -----------------------------------------------------------------------------

  process (state, opcode, sr)
  begin

    control_PS <= '0';
    control_PL <= '0';
    control_RW <= '0';
    control_MD2 <= '0';
    control_IOW <= '0';
    control_MD1 <= '0';
    control_SR <= '0';

    case state is

      when fetch =>
        null;

      when execute =>
        control_PL <= '1';

        case opcode is
          when "0001" =>  
            -- ALU operation
            control_RW <= '1';
            control_SR <= '1';
            
          when "0010" =>
            -- BNZ Branch if not zero
            if status_register(0) = '0' then  -- zero flag from alu
              control_PS <= '1';
            end if;

          when "0011" => 
            -- LDI Load Immidiate
            control_RW <= '1';
            control_MD2 <= '1';
          
          when "0100" =>
			-- JMP Unconditional Branch (Jump)
			control_PS <= '1';
			
	      when "0101" =>
	        -- IN Read from IO port
	        control_RW <= '1';
	        control_MD1 <= '1';
	      
	      when "0110" =>
	        -- OUT Write to IO port
	        control_IOW <= '1';
	     
	        
          when others =>
            null;

        end case;

      when others =>
        null;

    end case;
  end process;

-- Status register
process (sr, rst, core_clk, control_SR)
begin
  if rst = '0' then
    status_register <= (others => '0');
  
  elsif rising_edge (core_clk) then
    if control_SR = '1' then
       status_register <= sr;
    end if;
  end if;
end process;



end control_arch;
