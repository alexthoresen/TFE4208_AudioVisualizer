--==============================================================================================================================================--
-- Title       : wb_audioCFGautoUpdateSM
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
-- Description : State machine for the wb_audioCFGautoUpdate module
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

entity wb_audioCFG_autoUpdateSM is
--	generic (
--		);
		
	port (
		async_nreset	    :  in std_logic;
		clk	                :  in std_logic; 
		I2C_busy            :  in std_logic;

		volumeNeedUpdate    :  in std_logic;
		lineMICneedUpdate   :  in std_logic;
		
		readLineMICvalue    : out std_logic;
		readVolumeValue     : out std_logic;
		internal_nUpdate    : out std_logic;
		internal_nDataLatch : out std_logic;
		inMuxSel            : out std_logic_vector(2 downto 0)
	);
	
end wb_audioCFG_autoUpdateSM;

architecture behavior of wb_audioCFG_autoUpdateSM is


--==============================================================================================================================================--
-- Constants
--==============================================================================================================================================--
	constant reset_assert          : std_logic :='0'; 

	-- these are the _MUX_ addresses for the different addresses and data to be written into the config register
	constant muxAdr_direct            : std_logic_vector :="000"; -- letting data directly though
	constant muxAdr_updateLInVol      : std_logic_vector :="001"; --\
	constant muxAdr_updateRInVol      : std_logic_vector :="010"; --|
	constant muxAdr_updateAudioPath   : std_logic_vector :="011"; --|
	constant muxAdr_updateLOutVol     : std_logic_vector :="100"; --\
	constant muxAdr_updateROutVol     : std_logic_vector :="101"; -- Indirect address for the address to the different registers
--	constant muxAdr_         : std_logic_vector :="000";     -- unused address
--	constant muxAdr_         : std_logic_vector :="000";     -- unused address



--==============================================================================================================================================--
-- Signals
--==============================================================================================================================================--




	signal next_readLineMICvalue    : std_logic:='0';
	signal next_readVolumeValue     : std_logic:='0';
	signal next_internal_nUpdate    : std_logic:='0';
	signal next_internal_nDataLatch : std_logic:='0';
	signal next_inMuxSel            : std_logic_vector(2 downto 0):=(others => '0');
	  
	  type states_audioAutoCFG is (state_idle, state_readOutVolume,state_readLineMIC, state_updatedLInVol, state_updatedRInVol, state_updatedLOutVol, state_waitForI2C);								
	signal sm_audioCFG_current    : states_audioAutoCFG;
	signal sm_audioCFG_next       : states_audioAutoCFG;

--attribute ENUM_ENCODING: STRING; 
--attribute ENUM_ENCODING of states_timeingStateMachine:type is "000 001 010 011 100 101 110 111";
--attribute ENUM_ENCODING of states_bitSequenceStateMachine:type is "0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011";


--==============================================================================================================================================--
-- Processes
--==============================================================================================================================================--


begin

-- registering all output signal to remove any hazzards.
proc_next_readLineMICvalue    : readLineMICvalue <= next_readLineMICvalue when rising_edge(clk);
proc_next_readVolumeValue     : readVolumeValue <= next_readVolumeValue when rising_edge(clk);
proc_next_internal_nUpdate    : internal_nUpdate <= next_internal_nUpdate when rising_edge(clk);
proc_next_internal_nDataLatch : internal_nDataLatch <= next_internal_nDataLatch when rising_edge(clk);
proc_next_inMuxSel            : inMuxSel <=  next_inMuxSel when rising_edge(clk);



SM_logic:
--==============================================================================================================================================--
-- The logic for the state machine
--==============================================================================================================================================--
Process(sm_audioCFG_current,volumeNeedUpdate,lineMICneedUpdate,I2C_busy)
Begin
		
	-- Default values
	next_readLineMICvalue <= '0';
	next_readVolumeValue <='0';
	next_internal_nUpdate <='1'; -- active low
	next_internal_nDataLatch <= '1'; -- active low
	next_inMuxSel <= "001"; -- keep at address 001 so that the busy condition is set.

	-- Then the conditional values
	case (sm_audioCFG_current) is
		when state_idle =>
			if volumeNeedUpdate = '1' then
				sm_audioCFG_next <= state_readOutVolume;
				-- Read new data
				next_readVolumeValue <= '1';
			elsif lineMICneedUpdate = '1' then
				sm_audioCFG_next <= state_readLineMIC;
				-- Read new data
				next_readLineMICvalue <= '1';
			else
				sm_audioCFG_next <= state_idle;
			end if; 
			next_inMuxSel <= (others => '0'); -- release the system to allow throughput
		-- The volume update	
		when state_readOutVolume =>
			-- update the left output volume
			sm_audioCFG_next <= state_updatedLOutVol;
			next_inMuxSel <= muxAdr_updateLOutVol;
			next_internal_nDataLatch <= '0';
			
		when state_updatedLOutVol =>
			-- update the right output volume
			sm_audioCFG_next <= state_waitForI2C;
			next_inMuxSel <= muxAdr_updateROutVol;
			next_internal_nDataLatch <= '0';
			
		when state_waitForI2C =>
			-- transmitt new data to codec
			if I2C_busy = '1' then
				sm_audioCFG_next <= state_waitForI2C;
			else
				sm_audioCFG_next <= state_idle;
				next_internal_nUpdate <= '0';
			end if;		

-- NOT NEEDED		
--		when state_codecUpdateing =>
--			if I2C_busy = '1' then
--				sm_audioCFG_next <= state_codecUpdateing;
--			else
--				sm_audioCFG_next <= state_idle;
--			end if;	
		
		-- Update the input and preamp volume
		when state_readLineMIC =>
			-- update the L preAmp volume
			sm_audioCFG_next <= state_updatedLInVol;
			next_inMuxSel <= muxAdr_updateLInVol;
			next_internal_nDataLatch <= '0';
		when state_updatedLInVol =>
			-- update the R preAmp volume
			sm_audioCFG_next <= state_updatedRInVol;
			next_inMuxSel <= muxAdr_updateRInVol;
			next_internal_nDataLatch <= '0';
		when state_updatedRInVol =>
			-- upadte the audio path
			sm_audioCFG_next <= state_waitForI2C;
			next_inMuxSel <= muxAdr_updateAudioPath;
			next_internal_nDataLatch <= '0';
		when others => 
			sm_audioCFG_next <= state_idle;
		
	end case;

end process;


SM_register:
--==============================================================================================================================================--
-- Audio auto config state machine.
--==============================================================================================================================================--
process(clk,async_nreset)
begin
	if async_nreset = reset_assert then
		sm_audioCFG_current <= state_idle; -- set to idle state on reset
	elsif rising_edge(clk) then
		sm_audioCFG_current <= sm_audioCFG_next; -- set to next state on rising flank
	end if;
end process;



end architecture;

