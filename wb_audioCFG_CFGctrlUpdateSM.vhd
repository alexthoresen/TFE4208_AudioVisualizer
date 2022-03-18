--==============================================================================================================================================--
-- Title       : audio config config control update statemachine
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
-- Description : This is the state machine controlling the sequence of bytes that are to be transmittet from the register bank in order to
--               Configure the audio codec.
--               
--==============================================================================================================================================--
-- Revisions:
--
-- v0.01 - 4. July 2008
-- initial test version.
--==============================================================================================================================================--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;

entity wb_audioCFG_CFGctrlUpdateSM is
	generic (
		reset_active_low             : boolean := true -- The reset signal polarity
	);
	
	port (
		async_nreset          :  in std_logic;
		clk		              :  in std_logic; 
		serDes_TransErr       :  in std_logic; 
		serDes_Idle           :  in std_logic; 
		serDes_ByteRead       :  in std_logic; 
		serDes_ContiuneStream : out std_logic; 
		mux_chipAddr          : out std_logic;
		mux_msbLSB            : out std_logic;
		regBank_I2C_addr      : out std_logic_vector(3 downto 0);
		ctrl_resetCoDec       :  in std_logic;
		ctrl_updateCoDec      :  in std_logic;
		ctrl_busy             : out std_logic;
		ctrl_transErr         : out std_logic
		
	);
end wb_audioCFG_CFGctrlUpdateSM;

architecture behavior of wb_audioCFG_CFGctrlUpdateSM is


	  type states_byteSequenceStateMachine is (state_idle, state_sendChipAddr, state_sendMSB, state_sendLSB,state_finnishWrite);

	signal sm_byteSequenceCurrentState  : states_byteSequenceStateMachine;
	signal sm_byteSequenceNextState     : states_byteSequenceStateMachine;
	signal sm_jumpToNextState           : std_logic := '0';
	
	signal addressCounter               : std_logic_vector(3 downto 0):= (others => '0');
	signal addrCntEnable                : std_logic:= '0';
	signal addrCntEnableLast            : std_logic:= '0';
	signal addrCntLoad                  : std_logic:= '0';
	signal addressDataIn                : std_logic_vector(3 downto 0):= (others => '0');
	
	signal latchCMDreg                  : std_logic:= '0';
	signal cmdReg_resetCoDec            : std_logic:= '0'; 
	signal transmissionError            : std_logic:= '0'; 
	signal transmissionErrorReset       : std_logic:= '0';
	
	signal serDes_ByteReadLast          : std_logic:= '0';   
	signal serDes_ByteReadFlank         : std_logic:= '0'; 
	signal serDes_TransErrLast          : std_logic:= '0';
	signal serDes_TransErrFlank         : std_logic:= '0';
	

begin

--==============================================================================================================================================--
-- Simple logical expressions.
--==============================================================================================================================================--
proc_addrCntEnableLast: addrCntEnableLast <= addrCntEnable when rising_edge(clk); -- simle data latch
proc_cmdReg_resetCoDec: cmdReg_resetCoDec <= ctrl_resetCoDec when (rising_edge(clk) and latchCMDreg = '1'); -- register to remember the reset cmd.

proc_serDes_ByteReadLast: serDes_ByteReadLast <= serDes_ByteRead when rising_edge(clk); -- simple datalatch for flank detector.
proc_serDes_ByteReadFlank: serDes_ByteReadFlank <= serDes_ByteRead and (not serDes_ByteReadLast);
proc_serDes_TransErrLast: serDes_TransErrLast <= serDes_TransErr  when rising_edge(clk);
proc_serDes_TransErrFlank: serDes_TransErrFlank <= serDes_TransErr and (not serDes_TransErrLast);
proc_ctrl_transErr: ctrl_transErr <= transmissionError;

proc_regBank_I2C_addr: regBank_I2C_addr <= addressCounter;


proc_transErrSRReg:
--==============================================================================================================================================--
-- A clocked SR-Register to hold the value of transErr from the serdes.
--==============================================================================================================================================--
process (async_nreset, clk)
begin
	if async_nreset = '0' then
		transmissionError <= '0';
	else
		if rising_edge(clk) then 
			if serDes_TransErrFlank = '1' then
				transmissionError <= '1';
			elsif transmissionErrorReset = '1' then
				transmissionError <= '0';
			else
				transmissionError <= transmissionError;
			end if;
		end if; -- clock
	end if;
end process;
			



proc_byteSequenceStateMachineLogic:
--==============================================================================================================================================--
-- State machine register
--==============================================================================================================================================--
process(sm_byteSequenceCurrentState,serDes_TransErr,serDes_Idle,serDes_ByteRead,ctrl_resetCoDec,
        ctrl_updateCoDec,serDes_ByteReadFlank,addressCounter,cmdReg_resetCoDec,transmissionError)
begin
	-- default values
	addrCntEnable <= '0';
	addrCntLoad <= '0';
	serDes_ContiuneStream <= '0';
	mux_chipAddr <= '0';
	mux_msbLSB <= '0';
	ctrl_busy <= '1';
	latchCMDreg <= '0';
	transmissionErrorReset <= '0';
	addressDataIn <= (others => '0'); -- reset by default
	
	
	case (sm_byteSequenceCurrentState) is
  	when state_idle =>
		--external signals
		ctrl_busy <= '0'; -- idleing so not busy.
		
		-- internal signals
		latchCMDreg <= '1'; -- remember the command that started teh state machine in case it should disapear.
		addrCntLoad <= '1'; -- reset the address counter
		transmissionErrorReset <= ctrl_resetCoDec or ctrl_updateCoDec; -- reset the error state when a new transmission is activated.
		
		-- conditions for the state machine
		sm_jumpToNextState <= ctrl_resetCoDec or ctrl_updateCoDec;
		sm_byteSequenceNextState <= state_sendChipAddr;
		
		
		
  	when state_sendChipAddr =>
  		--external signals
		mux_chipAddr <= '1';
		serDes_ContiuneStream <= '1'; -- keep streaming data to same address
		

		
		-- conditions for the state machine
		if transmissionError = '1' then
			sm_byteSequenceNextState <= state_finnishWrite;
			sm_jumpToNextState <= '1'; --imidiate jump
		else
			sm_byteSequenceNextState <= state_SendMSB;
			sm_jumpToNextState <= serDes_ByteReadFlank;
		end if;	
  	
  	
  	when state_SendMSB => 
	  	--external signals
		mux_chipAddr <= '0';
		mux_msbLSB <= '0';
		serDes_ContiuneStream <= '1'; -- keep streaming data to same address
		
		-- internal signals
		if cmdReg_resetCoDec = '1' then -- if the command is to reset the coDec we need to load address 1111 into the addresscounter
			addressDataIn <= (others => '1');
			addrCntLoad <= '1';
		else
			addressDataIn <= (others => '0');
			addrCntLoad <= '0';			
		end if;
		
		
		
		-- conditions for the state machine
		if transmissionError = '1' then
			sm_byteSequenceNextState <= state_finnishWrite;
			sm_jumpToNextState <= '1'; --imidiate jump
		else
			sm_byteSequenceNextState <= state_sendLSB;	
			sm_jumpToNextState <= serDes_ByteReadFlank;	
		end if;
  	
  	when state_sendLSB => 
  		--external signals
		mux_chipAddr <= '0';
		mux_msbLSB <= '1';
		serDes_ContiuneStream <= '1'; -- send stop at end of byte.
		
		-- internal signals
		
		-- conditions for the state machine
		if transmissionError = '1' then
			sm_byteSequenceNextState <= state_finnishWrite;
			sm_jumpToNextState <= '1'; --imidiate jump
		else
			sm_byteSequenceNextState <= state_finnishWrite;
			sm_jumpToNextState <= serDes_ByteReadFlank;
		end if;
		
	when state_finnishWrite => 
		addrCntEnable <= '1'; -- increment the address counter in preparation for the next byte.
		serDes_ContiuneStream <= '0';
		if transmissionError = '1' then
			sm_byteSequenceNextState <= state_idle;
			sm_jumpToNextState <= serDes_Idle;
		else
			if addressCounter = 10 or cmdReg_resetCoDec = '1' then -- if all adresses are sent, or it was a reset command that was sent, return to idle.
				sm_jumpToNextState <= serDes_Idle;
				sm_byteSequenceNextState <= state_idle;	
			else
				sm_jumpToNextState <= serDes_Idle; -- if not, send next address.
				sm_byteSequenceNextState <= state_sendChipAddr;		
			end if;
		end if;
	end case;




end process;


Proc_addressCounter:
--==============================================================================================================================================--
-- Simple coutner with parallel load
--==============================================================================================================================================--
process(async_nreset, clk)
begin
	if async_nreset = '0' then
		addressCounter <= (others => '0');
	else
		if rising_edge(clk) then
			if addrCntLoad = '1' then
				addressCounter <= addressDataIn;
			else
				if (addrCntEnable = '1') and (addrCntEnableLast = '0') then
					addressCounter <= addressCounter + 1;
				end if;
			end if; -- load
		end if; -- clock
	end if; -- reset
end process;


proc_byteSequenceStateMachineRegister:
--==============================================================================================================================================--
-- State machine register
--==============================================================================================================================================--
process(async_nreset,clk)
begin
	if async_nreset = '0' then
		sm_byteSequenceCurrentState <= state_idle;
	elsif rising_edge(clk) then
		if sm_jumpToNextState = '1' then
			sm_byteSequenceCurrentState <= sm_byteSequenceNextState;
		end if; -- clock
	end if; -- reset
end process;

end architecture;
