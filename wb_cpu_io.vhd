-------------------------------------------------------------------------------
-- Title      : I/O Module
-- Project    : Lab5, DigDat
-------------------------------------------------------------------------------
-- File       : wb_cpu_statusreg.vhd
-- Author     : Marius Grannaes <grannas@idi.ntnu.no>
-- Company    : 
-- Last update: 2009-10-24
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2008/10/24  1.0      grannas Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use work.wb_cpu_package.all;

entity wb_cpu_io is

  port (

    -- Interface
    io_port : in std_logic_vector(DDATA_BUS - 1 downto 0);
    io_in   : in std_logic_vector(DDATA_BUS - 1 downto 0);
    
    io_out  : out std_logic_vector(DDATA_BUS - 1 downto 0);

    -- keys
    key1 : in std_logic;
    key2 : in std_logic;
    
    -- Audio Codec
    codec_data : out std_logic_vector(8 downto 0);
    codec_addr : out std_logic_vector(3 downto 0);
    
    codec_latch_n : out std_logic;
    codec_update_n : out std_logic;
     
    -- General
    control_IOW : in std_logic;
    reset_n     : in std_logic;
    clk         : in std_logic);

end wb_cpu_io;

architecture io_arch of wb_cpu_io is

  type states is (idle, data, strobe, waitstate, update);
  
  signal state : states;
  
  
begin    

  -- This process sets up the configuration
  -- on the audio codec
  -- state machine, clocked part
  process (clk, reset_n, control_IOW)
  begin
    if reset_n = '0' then
      state <= idle;
  
    elsif rising_edge (clk) then
      case state is

        when idle =>
          if control_IOW = '1' then
            state <= data;
            codec_data <= '1'&io_in;
            codec_addr <= X"3";           
          else
            state <= idle;
          end if;

        when data =>
          state <= strobe;
          
        when strobe =>
          state <= waitstate;
         
        when waitstate =>
          state <= update;
          
          
        when update =>
          state <= idle;

        when others =>
          state <= idle;

      end case;
    end if;
end process;   
  
-- State machine, comb. part
process (state)
  begin
  codec_latch_n <= '1';
  codec_update_n <= '1';
  
  case state is
    when strobe =>
      codec_latch_n <= '0';
    
    when update =>
      codec_update_n <= '0';
    
    when others =>
       null;
    
    end case;
 end process;

    
  process (io_port, clk)
  begin
   
         io_out <= (others => '0');

         case io_port is
			
			when X"01" =>
			  -- Key 1
			  io_out(0) <= key1;
			  io_out(DDATA_BUS - 1 downto 1) <= (others => '0');
			   
			when X"02" =>
			  -- Key 2
			  io_out(0) <= key2;
			  io_out(DDATA_BUS - 1 downto 1) <= (others => '0');

            when X"03" =>
              -- Volume
              null;
              			
			when others =>
		      -- Not defined
		      null;

        end case;

  end process;

end io_arch;