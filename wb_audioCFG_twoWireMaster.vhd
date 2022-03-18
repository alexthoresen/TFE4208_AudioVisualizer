--==============================================================================================================================================--
-- Title       : 2wMaster
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
-- Description : This is a 2-wire master controller. Current implementation only support writing.
--               
--==============================================================================================================================================--
-- Revisions:
--
-- v0.01 - 4. July 2008
-- initial test version.
--==============================================================================================================================================--



--==============================================================================================================================================--
-- Documentation
--==============================================================================================================================================--
--  2-wire timeing diagram
-- =========================
-- The timeing parameters are set as generic parameter for the component.
--
--
--       ____                     _______________________                         _________________  
-- SDA       \___________________/                   \___ - - - -   _____________/                 \  
--       ___________                    ________                           _______________________________ 
-- CLK              \__________________/        \________ - - - -  _______/                               \ 
--           |      |     |      |     |        |     |                   |      |                 |  
--           |  *1  |  *6 |  *2  |  *3 |   *5   |  *6 |                   |   *7 |    *8           |  
--                  |                  |        |
--                  |        *4        |        |
--                             
-- *1: Start hold time
-- *2: (Remaining time low) = *4 - (*3 +*6)
-- *3: Data setup time
-- *4: SCLK low
-- *5: SCLK high
-- *6: Data hold time
-- *7: Stop hold time
-- *8: min Idle time
--
--
-- About the state machines
--=========================
-- State machine interaction: There are two state machines in this design. One whos job is to keep track of the timeings
-- in the transmission; the "timeingStateMachine". Then there is the "bitSequenceStateMachine". The bitSequenceStateMachine sets the state of 
-- operation for the timeingStateMachine. Each time the timeingStateMachine has completed a cycle, the bitSequenceStateMachine jumps to the 
-- next state. This way, timeing control is controlled by the timeingStateMachine and the sequence of sending bits controlled by the 
-- bitSequenceStateMachine. 
--
-- State change: The state machines are controlled by the timer. Every time the timer hits zero, what is on the timer_countDownTime is latched 
-- into the timer and the "next state" state set as the current state. Since both state machines' states are controlled by the same timer,
-- the timeingStateMachine controls an aditional signal, tsm_sequenceFinnished, that, when is asserted, causes the bitSequenceStateMachine
-- to change state the next time the timer is zero. This signal can also be used to abort a timeing state and jump out of a timeing sequence.
-- In addition, the timeingStateMachine controlls the tsm_skipToNextState signal. Asserting this signal will cause the state machine to emediately
-- act as if the timer should have reached zero. Useing the tsm_skipToNextState will about the current timeing and skip on the next clock. Asserting
-- both tsm_skipToNextState and tsm_sequenceFinnished emediatly aborts the current timeing and make the bitSequenceStateMachine skip to the next state.
-- Note that asserting tsm_skipToNextState will load the timer with the timer_countDownTime and start a new timeing. This can be prevented by 
-- negating the timer_loadNewTime. 
-- 
-- serDes clocking: Since the bitSequenceStateMachine do not contain any timeing, clocking of the serDes occurs inside the 
-- timeingStateMachine. But the bitSequenceStateMachine contains a clock enable signal. By negating this signal the clock signal from the 
-- timeingStateMachine can be supressed.
--
-- timeingStateMachine: The timeingStateMachine logic consists of several procedures, each being called in the correct sequence according to the state
-- of the bitSequenceStateMachine. These procedures sets up all the signals. In addition, there is the state machine register itself. This process
-- consists of a simple register latching at the given condition. For the most part this will be controlled by the timer. The complete procedure is 
-- explained in "state change" above. NOTE: the timeing state machine signals finnishing of a timeing sequence at the entering of  "Remaining time low" 
-- time (see timeing diagram above).
--
-- Ack bit: sampling of the ack bit occurs at the rising flank of SCLK. This may be custumized to be read later. It can be a source of 
-- false ack or nack.
--==============================================================================================================================================--
-- Libraries: 
--==============================================================================================================================================--



library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;
use ieee.math_real.log2;
use ieee.math_real.ceil;
use ieee.math_real.floor;
use ieee.math_real.realmax;
use STD.textio.all;

entity wb_audioCFG_twoWireMaster is
	generic (
		gClk_speed_MHz               : real := 50.0;  -- The system clock speed
		clock_on_rising_flank        : boolean := true; -- The clock polarity of gClk
		reset_active_low             : boolean := true; -- The reset signal polarity
		write_active_low             : boolean := true; -- The write signal polarity
-- These parameters control the timeing of the 2-wire interface.
		SCLK_min_low_time_ns         : natural :=  600; -- the minimum time of SCLK high. (total low time = low + data_preClockHold)
		SCLK_min_high_time_ns        : natural := 1300; -- the minimum time of SCLK low. 
		dataSetup_min_time_ns        : natural :=  100; -- The min time data is available before SCLK goes high
		dataHold_min_time_ns         : natural :=  100; -- The min time data is held after SCLK goes low
		
		min_start_hold_time_ns       : natural :=  600; -- The minimum hold time for the start condition.
		min_stop_hold_time_ns        : natural :=  600; -- The minimum hold time for the stop condition.
		min_idle_time_ns             : natural :=  600; -- The minimum time between a stop and the next start; "Idle time".
		max_slave_SCLK_hold          : natural := 1200  -- The maximum time the slave is allowed to clock scew, for additional time for data prepare.
		);
		
	port (
		async_nreset	:    in std_logic;
		gClk			:    in std_logic; 
		continueStream  :    in std_logic;
		dataIn          :    in std_logic_vector(7 downto 0);
		dataInRead      :   out std_logic;
		idle            :   out std_logic;
		transErr         :   out std_logic;
		SDA				: inout std_logic;
		SCLK            :   out std_logic

	);
	
end wb_audioCFG_twoWireMaster;

architecture behavior of wb_audioCFG_twoWireMaster is


--==============================================================================================================================================--
-- Constants
--==============================================================================================================================================--

-- Timeing constants
--==================

	constant const_clockPeriodeNs    : real := real(1000)/gClk_speed_MHz;

-- The following const_tick_ variables are calculated from the frequency given as generic, and the different timeings, 
-- to represent the number of clock ticks needed for each timeing condition.
	-- These constants, excluded const_tick_SCLK_low, adds up to one periode of SCLK.
	constant const_tick_SCLK_low     : integer:= integer(ceil(real(SCLK_min_low_time_ns)/const_clockPeriodeNs))-1; -- only
	constant const_tick_dataHold     : integer:= integer(ceil(real(dataHold_min_time_ns)/const_clockPeriodeNs))-1;
	constant const_tick_dataSetup    : integer:= integer(ceil(real(dataSetup_min_time_ns)/const_clockPeriodeNs))-1;
	constant const_tick_SCLK_high    : integer:= integer(ceil(real(SCLK_min_high_time_ns)/const_clockPeriodeNs))-1+1;
	constant const_tick_SCLK_remLow  : integer:= const_tick_SCLK_low - (const_tick_dataSetup + const_tick_dataSetup);
	
	-- These three constants control the start and stop timings
	constant const_tick_startHold    : integer:= integer(ceil(real(min_start_hold_time_ns)/const_clockPeriodeNs))-1;
	constant const_tick_stopHold     : integer:= integer(ceil(real(min_stop_hold_time_ns))/const_clockPeriodeNs)-1;
	constant const_tick_minIdle      : integer:= integer(ceil(real(min_idle_time_ns)/const_clockPeriodeNs))-1;
	constant const_tick_slaveTimeOut : integer:= integer(ceil(real(max_slave_SCLK_hold)/const_clockPeriodeNs))-1;

-- Calculating the max number of ticks the timer has to count. Then the bit width of the timer
	-- The next line simply finds the largest const_tick_ variable of the above.
	constant const_maxTimerCount     : integer := integer(realmax(realmax(realmax(real(const_tick_minIdle),real(const_tick_slaveTimeOut)), real(const_tick_stopHold)), 
	                                                      realmax(realmax(real(const_tick_startHold), real(const_tick_SCLK_remLow)), realmax(real(const_tick_SCLK_high), 
	                                                      realmax(real(const_tick_dataSetup),real(const_tick_dataHold))))));
	-- calculates the bit width needed to hold the number const_maxTimerCount.
	constant const_timerWidth        : integer := (integer(floor(log2(real(const_maxTimerCount))+0.00000000001)) +1) ; 
	constant logtemp                 : real := log2(real(const_maxTimerCount));
	

--==============================================================================================================================================--
-- Internal signals
--==============================================================================================================================================--
	signal clk                     : std_logic := '0'; -- system clock for this design

-- Timer signals 
	signal timer_countDownTime     :   integer := 0  ; -- The amount of time to count down.
	signal timer_timeElapsed       : std_logic := '0'; -- This signal somes from the internal timer to signal the state machine that the time ser for the current state has elapsed.
	signal timer_countEnable       : std_logic := '0'; -- Enable the timer counting.
	signal timer_loadNewTime       : std_logic := '0'; -- when assert

-- 2-wire signals
	signal next_SCLK               : std_logic := '0';
	
-- Internal 2-wire signals
	signal twoWire_ACKRegClk       : std_logic := '0'; -- Signle bit register used to read the state of the ack bit in an transmission.
	signal twoWire_ACKRegClkLast   : std_logic := '0'; -- value at last clock.
	signal twoWire_ACKReg          : std_logic := '0'; -- clock for the ACKbit Reg.twoWire_ACKRegClk
	
	signal transErrReg             : std_logic := '0'; -- Single bit register used to read the state of the ack bit in an transmission.
	signal transErrRegUpdate       : std_logic := '0'; -- clock for the ACKbit Reg.

-- State machine signals. TSM = Timeing State Machine. BSM = Bit-sequence State Machine.
	  type states_timeingStateMachine is (state_TSM_idle, state_TSM_startHold, state_TSM_SCLKremLow, state_TSM_dataSetup, state_TSM_SCLKhigh, state_TSM_dataHold, 
	                                      state_TSM_stopHold, state_TSM_idleHold);
	  type states_bitSequenceStateMachine is (state_BSM_sendStart, state_BSM_sendbit0, state_BSM_sendbit1, state_BSM_sendbit2, state_BSM_sendbit3, state_BSM_sendbit4
	                                          , state_BSM_sendbit5, state_BSM_sendbit6, state_BSM_sendbit7, state_BSM_waitAck, state_BSM_sendStop, state_BSM_idle);
	signal sm_timeCurrentState     : states_timeingStateMachine;
	signal sm_timeNextState        : states_timeingStateMachine;
	signal sm_seqCurrentState      : states_bitSequenceStateMachine;
	signal sm_seqNextState         : states_bitSequenceStateMachine;
--attribute ENUM_ENCODING: STRING; 
--attribute ENUM_ENCODING of states_timeingStateMachine:type is "000 001 010 011 100 101 110 111";
--attribute ENUM_ENCODING of states_bitSequenceStateMachine:type is "0000 0001 0010 0011 0100 0101 0110 0111 1000 1001 1010 1011";
	
	signal tsm_sequenceFinnished   : std_logic := '0'; -- Signals that the current timeing state machine is in the last time-step the current step of the bit-sequence state machine.
	signal tsm_skipToNextState     : std_logic := '0'; -- signals the state machine register to ignore the timer and directly skip to next state and reload the timer.

-- serializer/deserializer signals
	signal serDes_SDO              : std_logic := '0'; -- serialiser / deserialiser - serial data out
	signal serDes_SDI              : std_logic := '0'; -- serialiser / deserialiser - serial data in
	signal serDes_CLK              : std_logic := '0'; -- serialiser / deserialiser - serial clock
	signal serDes_LE               : std_logic := '0'; -- serialiser / deserialiser - load enable
	signal serDes_EN               : std_logic := '0'; -- serialiser / deserialiser - seral clock enable
	signal serDes_PDI              : std_logic_vector(7 downto 0) := (others => '0'); -- serialiser / deserialiser - parallel data in
	--signal serDes_PDO              : std_logic_vector(7 downto 0) := (others => '0'); -- serialiser / deserialiser - parallel data out



--==============================================================================================================================================--
-- Components 
--==============================================================================================================================================--
component wb_block_oneShotDownCounter is
	generic (wordsize : natural);
    port (clk, async_nreset, le, ce : in std_logic;
       d    : in std_logic_vector(const_timerWidth-1 downto 0);
       zero : out std_logic);
end component wb_block_oneShotDownCounter;

component wb_block_serDes is
	generic (wordsize : natural);
	port (clk, async_nreset, le, enable, msb_first, sdi : in std_logic;
	      sdo : out std_logic;
	      d   : in std_logic_vector(7 downto 0);
	      q   : out std_logic_vector(7 downto 0));
end component wb_block_serDes;



--procedure_sentBit:
--==============================================================================================================================================--
-- This procedure belongs to the timeingStateMachine. This is the procedure for sending a bit. 
--==============================================================================================================================================--
procedure proced_TSM_SentBit is
begin
	case (sm_timeCurrentState) is
	
	when state_TSM_SCLKremLow => 
		-- state machine parameter
		sm_timeNextState <= state_TSM_dataSetup;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_dataSetup;
		
		-- I2C signals 
		SDA <= serDes_SDO;
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
		
	when state_TSM_dataSetup =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_SCLKhigh;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_SCLK_high;
		
		-- I2C signals 
		SDA <= serDes_SDO;
		next_SCLK <= '1';
		
		-- Internal signaling
		serDes_CLK <= '1';  -- clock out the next data.
		twoWire_ACKRegClk <='0';
		
	when state_TSM_SCLKhigh =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_dataHold;	
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_dataHold;
		
		-- I2C signals 
		SDA <= serDes_SDO;
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '1';
		twoWire_ACKRegClk <='0';

	when state_TSM_dataHold =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_SCLKremLow;
		tsm_sequenceFinnished <= '1';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_SCLK_remLow;
		
		-- I2C signals 
		SDA <= serDes_SDO;
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
		
	when others =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_SCLKremLow;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_SCLK_remLow;
		
		-- I2C signals 
		SDA <= serDes_SDO;
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
		
	end case;
end procedure proced_TSM_SentBit;


--==============================================================================================================================================--
-- This procedure belongs to the timeingStateMachine This is the procedure for reading the ack bit. 
--==============================================================================================================================================--
procedure proced_TSM_waitForAcknowlagdeBit is
begin
	case (sm_timeCurrentState) is
  	when state_TSM_SCLKremLow => 
		-- state machine parameter
		sm_timeNextState <= state_TSM_dataSetup;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_dataSetup;
		
		-- I2C signals 
		SDA <= 'Z';
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
		
	when state_TSM_dataSetup =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_SCLKhigh;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_SCLK_high;
		
		-- I2C signals 
		SDA <= 'Z';
		next_SCLK <= '1';
		
		-- Internal signaling
		serDes_CLK <= '0';  -- clock out the next data.
		twoWire_ACKRegClk <='0';
		
		
	when state_TSM_SCLKhigh =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_dataHold;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_dataHold;
		
		-- I2C signals 
		SDA <= 'Z';
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='1';

	when state_TSM_dataHold =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_SCLKremLow;
		tsm_sequenceFinnished <= '1';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_SCLK_remLow;
		
		-- I2C signals 
		SDA <= 'Z';
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
		
	when others =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_SCLKremLow;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_SCLK_remLow;
		
		-- I2C signals 
		SDA <= 'Z';
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
		
	end case;
end procedure proced_TSM_waitForAcknowlagdeBit;

--==============================================================================================================================================--
-- This procedure belongs to the timeingStateMachine This is the procedure for the start sequence of an I2C transmission. 
--==============================================================================================================================================--
procedure proced_TSM_startSequence is
begin
	case (sm_timeCurrentState) is
  	when state_TSM_idle => 
  	
		-- state machine parameter
		sm_timeNextState <= state_TSM_startHold;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';

		-- Timer parameter
		timer_countDownTime <= const_tick_startHold;
		
		-- I2C signals 
		SDA <= '1';
		next_SCLK <= '1';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
	
	
	
	when state_TSM_startHold => 
  	
		-- state machine parameter
		sm_timeNextState <= state_TSM_dataHold;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';

		-- Timer parameter
		timer_countDownTime <= const_tick_dataHold;
		
		-- I2C signals 
		SDA <= '0';
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';


	when state_TSM_dataHold =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_SCLKremLow;
		tsm_sequenceFinnished <= '1';
		tsm_skipToNextState <= '0';

		-- Timer parameter
		timer_countDownTime <= const_tick_SCLK_remLow;
		
		-- I2C signals 
		SDA <= '0';
		next_SCLK<= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
		
	when others =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_idle;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';

		-- Timer parameter
		timer_countDownTime <= const_tick_minIdle;
		
		-- I2C signals 
		SDA <= '1';
		next_SCLK <= '1';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';	
		
	end case;
end procedure proced_TSM_startSequence;


--==============================================================================================================================================--
-- This procedure belongs to the timeingStateMachine. This is the procedure of the stop sequence of the I2C bus.
--==============================================================================================================================================--
procedure proced_TSM_stopSequence is
begin
	case (sm_timeCurrentState) is
  	when state_TSM_SCLKremLow => 
		-- state machine parameter
		sm_timeNextState <= state_TSM_dataSetup;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';
		
		-- Timer parameter
		timer_countDownTime <= const_tick_dataSetup;
		
		-- I2C signals 
		SDA <= '0';
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
	
	when state_TSM_dataSetup => 
		-- state machine parameter
		sm_timeNextState <= state_TSM_stopHold;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';

		-- Timer parameter
		timer_countDownTime <= const_tick_stopHold;
		
		-- I2C signals 
		SDA <= '0';
		next_SCLK <= '1';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';

	when state_TSM_stopHold =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_idleHold;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';

		-- Timer parameter
		timer_countDownTime <= const_tick_minIdle;
		
		-- I2C signals 
		SDA <= '0';
		next_SCLK <= '1';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
		
	when state_TSM_idleHold =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_idle;
		tsm_sequenceFinnished <= '1';
		tsm_skipToNextState <= '0';

		-- Timer parameter
		timer_countDownTime <= 0;
		
		-- I2C signals 
		SDA <= '1';
		next_SCLK <= '1';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';
		
	when others =>
		-- state machine parameter
		sm_timeNextState <= state_TSM_SCLKremLow;
		tsm_sequenceFinnished <= '0';
		tsm_skipToNextState <= '0';

		-- Timer parameter
		timer_countDownTime <= const_tick_SCLK_remLow;
		
		-- I2C signals 
		SDA <= '0';
		next_SCLK <= '0';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';	
		
	end case;
end procedure proced_TSM_stopSequence;


--==============================================================================================================================================--
-- This procedure belongs to the timeingStateMachine. This is the procedure for ide.
--==============================================================================================================================================--
procedure proced_TSM_idle is
begin
		-- state machine parameter
		sm_timeNextState <= state_TSM_idle;
		tsm_sequenceFinnished <= '1';
		tsm_skipToNextState <= '0';

		-- Timer parameter
		timer_countDownTime <= 0;
		
		-- I2C signals 
		SDA <= '1';
		next_SCLK <= '1';
		
		-- Internal signaling
		serDes_CLK <= '0';
		twoWire_ACKRegClk <='0';	
end procedure proced_TSM_idle;






begin



comp_timer:
--==============================================================================================================================================--
-- Adding a "down to zero" timer for tracking of timeing of the I2C buss. All steps in the serial transmission uses this timer. Timeings are set 
-- by the generic constants, and calculated to numbers of ticks according to the frequency the system runs at.
--==============================================================================================================================================--
component wb_block_oneShotDownCounter 
	generic map(wordsize => const_timerWidth)
	port map(clk => clk, async_nreset => async_nreset, le => timer_loadNewTime , ce => timer_countEnable, zero => timer_timeElapsed,
	         d => std_logic_vector(to_unsigned(timer_countDownTime,const_timerWidth))
	         );	


comp_serDes: 
--==============================================================================================================================================--
-- Adding the serializer / Deserializer. signals to the serDes are controlled by the state machine. The state machine also controls when the
-- output signal from the serDes is to be put on the I2C bus.
--==============================================================================================================================================--
component wb_block_serDes
	generic map(wordsize => 8)
	port map(clk => serDes_CLK, async_nreset => async_nreset, le => serDes_LE, enable => serDes_EN, msb_first => '1', sdi => serDes_SDI, 
	         sdo => serDes_SDO, d => serDes_PDI, q => open);





--==============================================================================================================================================--
-- Simple logic expressions
--==============================================================================================================================================--	         

proc_clk:                   clk <= gClk;
proc_timer_loadNewTime:     timer_loadNewTime <= tsm_skipToNextState or timer_timeElapsed;
proc_twoWire_ACKRegClkLast: twoWire_ACKRegClkLast <= twoWire_ACKRegClk when (rising_edge(clk));
proc_twoWire_ACKReg:        twoWire_ACKReg <= SDA when (rising_edge(clk) and (twoWire_ACKRegClkLast = '0') and (twoWire_ACKRegClk= '1')); -- Register for the ACK bit of a transmission.
proc_transErr:              transErr <= transErrReg when (rising_edge(clk) and transErrRegUpdate = '1');
proc_serDes_PDI:            serDes_PDI <= dataIn;
proc_serDes_SDI:            serDes_SDI <= '0';
proc_next_SCLK:             SCLK <= next_SCLK when (rising_edge(clk) and timer_timeElapsed = '1');


proc_bitSequenceStateMachineRegister:
--==============================================================================================================================================--
-- The bit sequence state machine register.
--==============================================================================================================================================--
process(async_nreset,clk)
begin
	if async_nreset = '0' then
		sm_seqCurrentState <= state_BSM_idle;
	elsif rising_edge(clk) then
		if(timer_timeElapsed='1' or tsm_skipToNextState = '1') and tsm_sequenceFinnished = '1' then
			sm_seqCurrentState <= sm_seqNextState;
		end if; -- clock
	end if; -- reset
end process; -- proc_bitSequenceStateMachineRegister:


proc_timeingStateMachineRegister:
--==============================================================================================================================================--
-- The timeing state machine.
--==============================================================================================================================================--
process(async_nreset,clk,timer_timeElapsed,tsm_skipToNextState)
begin
	if async_nreset = '0' then
		sm_timeCurrentState <= state_TSM_idle;
	elsif rising_edge(clk) then
		if (timer_timeElapsed='1' or tsm_skipToNextState = '1') then
			sm_timeCurrentState <= sm_timeNextState;
		end if; -- clock
	end if; -- reset
end process; -- proc_timeingStateMachineRegister:




proc_bitSequenceStateMachineLogic:
--==============================================================================================================================================--
-- The bit sequence state machine logic. This statemachine controls the sequence of sending one byte. Each step awaits the finnishing of a sequence
-- of the timeing state machine.
--==============================================================================================================================================--
process(continueStream,sm_seqCurrentState,twoWire_ACKReg,tsm_sequenceFinnished,sm_timeCurrentState)
begin
	-- Permanent values
	timer_countEnable <= '1';
	serDes_EN <= '1';
	
	-- default values
	dataInRead <= '0';
	serDes_LE <= '0';
	transErrRegUpdate <= '0';
	transErrReg <= '0';
	idle <= '0';
	
  	case (sm_seqCurrentState) is
  	when state_BSM_idle =>
		if continueStream = '1' then
			sm_seqNextState <= state_BSM_sendStart;
		else
			sm_seqNextState <= state_BSM_idle;
			idle <= '1';
		end if;
		proced_TSM_idle;
		
  	when state_BSM_sendStart => 
		sm_seqNextState <= state_BSM_sendbit7;
		proced_TSM_startSequence; -- procedure
		transErrRegUpdate <= tsm_sequenceFinnished;
		transErrReg <= '0';
		
	when state_BSM_sendbit7 =>
		sm_seqNextState <= state_BSM_sendbit6;
		proced_TSM_SentBit; -- procedure
		serDes_LE <= '1';
		
	when state_BSM_sendbit6 =>
		sm_seqNextState <= state_BSM_sendbit5;
		proced_TSM_SentBit; -- procedure
		dataInRead <= '1';
		
	when state_BSM_sendbit5 =>
		sm_seqNextState <= state_BSM_sendbit4;
		proced_TSM_SentBit; -- procedure
		
	when state_BSM_sendbit4 =>
		sm_seqNextState <= state_BSM_sendbit3;
		proced_TSM_SentBit; -- procedure
		
	when state_BSM_sendbit3 =>
		sm_seqNextState <= state_BSM_sendbit2;
		proced_TSM_SentBit; -- procedure
		
	when state_BSM_sendbit2 =>
		sm_seqNextState <= state_BSM_sendbit1;
		proced_TSM_SentBit; -- procedure
		
	when state_BSM_sendbit1 =>
		sm_seqNextState <= state_BSM_sendbit0;
		proced_TSM_SentBit; -- procedure
		
	when state_BSM_sendbit0 =>
		sm_seqNextState <= state_BSM_waitAck;
		proced_TSM_SentBit; -- procedure
		
	when state_BSM_waitAck =>
		if twoWire_ACKReg = '0' and continueStream = '1' then
			sm_seqNextState <= state_BSM_sendbit7;
		else
			sm_seqNextState <= state_BSM_sendStop;
		end if;
		proced_TSM_waitForAcknowlagdeBit; -- procedure
		transErrRegUpdate <= tsm_sequenceFinnished;
		transErrReg <= twoWire_ACKReg;
		
  	when state_BSM_sendStop =>
		sm_seqNextState <= state_BSM_idle;
		proced_TSM_stopSequence; -- procedure

		
  	end case;
end process; -- proc_bitSequenceStateMachineLogic


end architecture;
