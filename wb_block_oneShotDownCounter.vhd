--==============================================================================================================================================--
-- Title       : Single shot down counter.
-- Project     : TFE4105 Digital Design and Computer Fundamentals @ NTNU
-- ==============================================================================================================
-- Author      : UTA Ingulf Helland <helland@netpower.no>
-- Company     : Department of Electronics and Telecommunications <www.iet.ntnu.no>
-- Company     : Norwegian University of Science and Technology <www.ntnu.no>
-- Copyright   : 2008
-- License     : Copyright IET - NTNU
-- ==========================================================
-- Created date: 4. July 2008
-- Last update : 
-- Project ver.: 1.00
-- File ver.   : 0.01 
-- Last Rev by : Ingulf Helland <helland@netpower.no>
-- ==========================================================
-- Description : A counter that counts down from the given input and stop at zero, with the assertsion of the "zero" output
--==============================================================================================================================================--
-- Revisions:
--
-- v0.01 - 4. July 2008
-- initial test version.
--==============================================================================================================================================--
--
-- component oneShotDownCounter is
-- 	generic (wordsize : natural);
--  port (clk, async_nreset, le, ce : in std_logic;
--        d    : in std_logic_vector(wordsize-1 downto 0);
--        zero : out std_logic);
-- end component oneShotDownCounter;
--
--


--==============================================================================================================================================--
-- Libraries: 
--==============================================================================================================================================--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned."-";
use ieee.std_logic_unsigned."=";



--==============================================================================================================================================--
-- Inputs and outputs decrlarations:
--==============================================================================================================================================--
entity wb_block_oneShotDownCounter is

  generic (
		wordsize         : natural := 8    -- Shiftregister size.
	 );
  
  port(	
      
		clk              :  in std_logic; -- clocksignal
		async_nreset     :  in std_logic; -- reset
		le               :  in std_logic; -- latch enable
		ce               :  in std_logic; -- count enable
		d                :  in std_logic_vector(wordsize-1 downto 0); -- parallel data in
		zero             : out std_logic
      );  
end entity wb_block_oneShotDownCounter;

architecture behavior of wb_block_oneShotDownCounter is

	signal counter : std_logic_vector(wordsize-1 downto 0):= (others => '0');
	signal counterIsZero : std_logic :='0';


begin

proc_zero:zero <= counterIsZero;

proc_counterIsZero:process(counter)
begin
	if counter = 0 then
		counterIsZero <= '1';
	else
		counterIsZero <= '0';
	end if;
end process;

proc_counter: process (async_nreset,clk,le,ce,counterIsZero)	
begin
	if async_nreset = '0' then
		counter <= (others => '0');
	else
		if rising_edge(clk) then
			if le='1' then
				counter <= d;
			else
				if ce='1' and counterIsZero = '0' then
					counter <= counter - 1;
				end if; -- count
			end if; -- latch enable
		end if; --clock
	end if; --reset
end process;
end architecture;