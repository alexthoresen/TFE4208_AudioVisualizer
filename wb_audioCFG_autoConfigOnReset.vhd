--==============================================================================================================================================--
-- Title       : workbench audio config auto config on reset
-- Project     : TFE4105 Digital Design and Computer Fundamentals @ NTNU
-- ==============================================================================================================
-- Author      : UTA Ingulf Helland <helland@netpower.no>
-- Company     : Department of Electronics and Telecommunications <www.iet.ntnu.no>
-- Company     : Norwegian University of Science and Technology <www.ntnu.no>
-- Copyright   : 2008
-- License     : Copyright IET - NTNU
-- ==========================================================
-- Created date: 28. Aug  2008
-- Last update : 
-- Project ver.: 1.00
-- File ver.   : 0.01 
-- Last Rev by : Ingulf Helland <helland@netpower.no>
-- ==========================================================
-- Description : State machine for automiticly soft-resetting the codec and downloading the default configuration on after reset.
--               
--==============================================================================================================================================--
-- Revisions:
--
-- v0.01 - 28. Aug  2008
-- initial test version.
--==============================================================================================================================================--
--==============================================================================================================================================--
-- Libraries: 
--==============================================================================================================================================--



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity wb_audioCFG_autoConfigOnReset is
--	generic (
--		);
		
	port (
		async_nreset	    :  in std_logic;
		clk	                :  in std_logic; 
		I2C_busy            :  in std_logic;

		nResetCodec         : out std_logic;
		nUpdateCodec        : out std_logic
	);
	
end wb_audioCFG_autoConfigOnReset;

architecture behavior of wb_audioCFG_autoConfigOnReset is


--==============================================================================================================================================--
-- Constants
--==============================================================================================================================================--
	constant reset_assert: std_logic :='0'; -- reset polarity


--==============================================================================================================================================--
-- Signals
--==============================================================================================================================================--
	signal next_nResetCodec      : std_logic:='0';
	signal next_nUpdateCodec     : std_logic:='0';
	signal I2CBusIsBusy          : std_logic:='1';
	signal Lev1LastI2CBusy       : std_logic:='1';
	signal Lev2LastI2CBusy       : std_logic:='1';
	signal Lev3LastI2CBusy       : std_logic:='1';
  
	  type states_audioReset is (state_waitI2CpreReset,state_signalReset, state_waitI2CpreConfig, state_signalConfig, state_end);								
	signal sm_audioReset_current    : states_audioReset;
	signal sm_audioReset_next       : states_audioReset;



--==============================================================================================================================================--
-- Processes
--==============================================================================================================================================--
begin

-- registering all output signal to remove any hazzards.
proc_next_nResetCodec    : nResetCodec <= next_nResetCodec when rising_edge(clk);
proc_next_nUpdateCodec   : nUpdateCodec <= next_nUpdateCodec when rising_edge(clk);


proc_I2CBusIsBusy: I2CBusIsBusy <= Lev3LastI2CBusy or Lev2LastI2CBusy or Lev1LastI2CBusy or I2C_busy; -- busy goes low if it's been low for 4 clocks


proc_LastI2CBusy:
--==============================================================================================================================================--
-- History of the 3 last I2CBusy
--==============================================================================================================================================--
process(async_nreset,clk)
begin
	if async_nreset = reset_assert then
		Lev1LastI2CBusy <= '1'; -- assume busy when reset
		Lev2LastI2CBusy <= '1';
		Lev3LastI2CBusy <= '1';
	elsif rising_edge(clk) then
		Lev3LastI2CBusy <= Lev2LastI2CBusy; -- make a history of the 3 last I2CBusy
		Lev2LastI2CBusy <= Lev1LastI2CBusy;
		Lev1LastI2CBusy <= I2C_busy;
	end if;
end process;



SM_logic:
--==============================================================================================================================================--
-- The logic for the state machine
--==============================================================================================================================================--
Process(I2CBusIsBusy,sm_audioReset_current)
Begin
		
	-- Default values
	next_nResetCodec <= '1';
	next_nUpdateCodec <= '1';
	
	-- Then the conditional values
	case (sm_audioReset_current) is
		when state_waitI2CpreReset =>
			if I2CBusIsBusy = '1' then
				sm_audioReset_next <= state_waitI2CpreReset;
			else
				sm_audioReset_next <= state_signalReset;
				next_nResetCodec <= '0';
			end if;
			
		when state_signalReset =>
			if I2CBusIsBusy = '0' then -- keep signaling a reset until the I2C bus goes busy sending the reset.
				sm_audioReset_next <= state_signalReset;
				next_nResetCodec <= '0';
			else
				sm_audioReset_next <= state_waitI2CpreConfig;
			end if;
			
		when state_waitI2CpreConfig =>
			if I2CBusIsBusy = '1' then -- wait until the I2C bus is free again
				sm_audioReset_next <= state_waitI2CpreConfig;
			else
				sm_audioReset_next <= state_signalConfig; -- then signal a update
				next_nUpdateCodec <= '0';
			end if;
			
		when state_signalConfig =>
			if I2CBusIsBusy = '0' then -- keep signaling a update until the I2C bus goes busy sending the update.
				sm_audioReset_next <= state_signalConfig;
				next_nUpdateCodec <= '0';
			else
				sm_audioReset_next <= state_end;
			end if;
			
		when state_end =>
			sm_audioReset_next <= state_end; -- stop at the end until the unit is reset again.
			
		when others => 
			sm_audioReset_next <= state_waitI2CpreReset;
		
	end case;

end process;


SM_register:
--==============================================================================================================================================--
-- Audio auto config state machine.
--==============================================================================================================================================--
process(clk,async_nreset)
begin
	if async_nreset = reset_assert then
		sm_audioReset_current <= state_waitI2CpreReset; -- set to idle state on reset
	elsif rising_edge(clk) then
		sm_audioReset_current <= sm_audioReset_next; -- set to next state on rising flank
	end if;
end process;



end architecture;
