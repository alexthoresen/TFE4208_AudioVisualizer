--==============================================================================================================================================--
-- Title       : Registerbank
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
-- Description : Set of registers, adressable through two ooutput busses and one input bus.
--               
--==============================================================================================================================================--
-- Revisions:
--
-- v0.01 - 4. July 2008
-- initial test version. 
--==============================================================================================================================================--


--==============================================================================================================================================--
-- Libraries: 
--==============================================================================================================================================--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;



entity wb_audioCFG_CFGctrlRegisterBank is
	generic (
		register_width               : natural := 8;
		register_depth               : natural := 4;
		addr_bus_width               : natural := 2;
		write_enable_active_low      : boolean := false;
		clock_on_rising_flank        : boolean := true;
		reset_active_low             : boolean := true;
		load_file_on_reset           : string  := ""
		);
		
	port (
		async_reset		:  in std_logic;
		rClk			:  in std_logic ; -- Register clock
		dataIn          :  in std_logic_vector(register_width-1 downto 0);
		addrIn          :  in std_logic_vector(addr_bus_width-1 downto 0);
		writeEnable     :  in std_logic;
		dataOutA		: out std_logic_vector(register_width-1 downto 0);
		addrOutA		:  in std_logic_vector(addr_bus_width-1 downto 0);
		dataOutB		: out std_logic_vector(register_width-1 downto 0);
		addrOutB		:  in std_logic_vector(addr_bus_width-1 downto 0)
	);
	
end wb_audioCFG_CFGctrlRegisterBank;



architecture behavior of wb_audioCFG_CFGctrlRegisterBank is
	constant resetAssert: std_logic := '1'; -- reset asserted state. 
	
	  type type_regBank is array (register_depth-1 downto 0) of std_logic_vector(register_width-1 downto 0);
	signal regBank      : type_regBank;
	signal writeEn      : std_logic := '0';
	signal clk          : std_logic := '0';
	signal reset        : std_logic := '0';
	type   type_reset_file is file of text;
	file   reset_file : type_reset_file; 

begin

proc_reset:
--==============================================================================================================================================--
-- Process set the polarity of the reset signal, given from the async_reset and it's polarity reset_active_low, to match the polarity of reset 
-- set by the resetAssert constant. 
--==============================================================================================================================================--
process (async_reset)
begin
	if reset_active_low then
		reset <= async_reset xor resetAssert;
	else
		reset <= (not async_reset) xor resetAssert;
	end if;
end process;

proc_writeEn:
--==============================================================================================================================================--
-- Process the polarity of writeEnable so that writeEn is active high.
--==============================================================================================================================================--
process (writeEnable)
begin
	if write_enable_active_low then
		writeEn <= not writeEnable;
	else
		writeEn <= writeEnable;
	end if;
end process;

proc_clk:
--==============================================================================================================================================--
-- Set the polarity of the clock.
--==============================================================================================================================================--
process (rclk)
begin
	if clock_on_rising_flank then
		clk <= rclk;
	else
		clk <= not(rclk);
	end if;
end process;


proc_registerWriteAndReset:
--==============================================================================================================================================--
-- Write data into the register. Writes outside the register depth are ignored.
--==============================================================================================================================================--
process(clk,reset)
--	variable i:integer;
--	variable L : Line;
begin
	if reset = resetAssert then
		-- resetting all registers
--		if not (load_file_on_reset = "") then
	--		file_open(reset_file,load_file_on_reset,read_mode);
--			for i in register_depth-1 downto 0 loop
				
--				if not endfile(reset_file) then
--					readline(reset_file, L);
--					read(L,regBank(i));
--				else
--					regBank(i) <= (others => '0');
--				end if;
--			end loop;
--			file_close(reset_file);
--		else
			for i in register_depth-1 downto 0 loop
				regBank(i) <= (others => '0');
			end loop;
			regBank(0) <= "100011110"; -- 
			regBank(1) <= "100011110";
			regBank(2) <= "111110000";
			regBank(3) <= "111110000";
			regBank(4) <= "000010001"; -- select ADC as output and enable mic Boost
			regBank(5) <= "000000000"; -- set no de-emphasis 
			regBank(6) <= "000000000"; -- no power saveings
			regBank(7) <= "010010011"; -- 16 bit data, and data available on 2nd clock after DACLRC, slavemode. Invert BCLK
			regBank(8) <= "000100000"; -- set normal mode 256fs, and 44k1 samplefrequency.
			regBank(9) <= "000000001"; -- activate audio interface.
--		end if;

	else
		if rising_edge(clk) then
			if writeEn = '1' then
				if not (conv_integer(addrIn) > register_depth-1) then
					regBank(conv_integer(addrIn)) <= dataIn;
				else
					null; -- ignore writes outside the addressable range
				end if; -- addressable range
			end if; -- writeEn
		end if; -- clock
	end if; -- reset
end process;


proc_dataoutA:
--==============================================================================================================================================--
-- Read data from the register. Reads ouside the register range return '0's
--==============================================================================================================================================--
process(addrOutA,regBank)
begin
	if not (conv_integer(addrOutA) > register_depth-1) then
		dataOutA <= regBank(conv_integer(addrOutA));
	else
		dataOutA <= (others => '0');
	end if; -- addressable range
end process;


proc_dataoutB:
--==============================================================================================================================================--
-- Read data from the register. Reads ouside the register range return '0's
--==============================================================================================================================================--
process(addrOutB,regBank)
begin
	if not (conv_integer(addrOutB) > register_depth-1) then
		dataOutB <= regBank(conv_integer(addrOutB));
	else
		dataOutB <= (others => '0');
	end if; -- addressable range
end process;

end architecture;
