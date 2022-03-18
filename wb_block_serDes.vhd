--==============================================================================================================================================--
-- Title       : Simple Serializer/-deserializer
-- Project     : TFE4105 Digital Design and Computer Fundamentals @ NTNU
-- ==============================================================================================================
-- Author      : UTA Ingulf Helland <helland@netpower.no>
-- Company     : Department of Electronics and Telecommunications <www.iet.ntnu.no>
-- Company     : Norwegian University of Science and Technology <www.ntnu.no>
-- Copyright   : 2008
-- License     : Copyright IET - NTNU
-- ==========================================================
-- Created date: 
-- Last update : 
-- Project ver.: 1.00
-- File ver.   : 0.01 
-- Last Rev by : Ingulf Helland <helland@netpower.no>
-- ==========================================================
-- Description : Serial-/and deserializer. Plain and simple. Outputs are the serial shiftregisters, causeing data to change for every shift. 
--==============================================================================================================================================--
-- Revisions:
--
-- v0.01 -
-- initial test version. 
--==============================================================================================================================================--
-- component serDes is
-- 	generic (wordsize : natural);
--  port (clk, async_nreset, le, enable, msb_first, sdi : in std_logic;
--        sdo : out std_logic;
--        d   : in std_logic_vector(wordsize-1 downto 0);
--        q   : out std_logic_vector(wordsize-1 downto 0)
--        );
-- end component serDes;
--

--==============================================================================================================================================--
-- Libraries: 
--==============================================================================================================================================--
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.to_unsigned;


--==============================================================================================================================================--
-- Inputs and outputs decrlarations:
--==============================================================================================================================================--
entity wb_block_serDes is

  generic (
		wordsize                        : natural := 8    -- Shiftregister size.
	 );
  
  port(	
      
		clk              :  in std_logic; -- clocksignal
		async_nreset     :  in std_logic; -- reset
		le               :  in std_logic; -- latch enable
		enable           :  in std_logic; -- global enable
		msb_first        :  in std_logic; -- changes the shift direction according to 
		sdi              :  in std_logic; -- serial data in
		sdo              : out std_logic; -- serial data out
		d                :  in std_logic_vector(wordsize-1 downto 0); -- parallel data in
		q                : out std_logic_vector(wordsize-1 downto 0) -- parallel data out
      );  
end wb_block_serDes;

architecture behavior of wb_block_serDes is

signal shiftRegister: std_logic_vector(wordsize-1 downto 0);

begin

proc_shiftRegister:
process(async_nreset,clk)
begin
	if async_nreset = '0' then
		shiftRegister <= (others => '0');
	elsif rising_edge(clk) then
		if  enable='1' then
			if le = '1' then
				shiftRegister <= d;
			else
				if msb_first = '1' then
						shiftRegister <= shiftRegister(wordsize-2 downto 0) & SDI;
				else
						shiftRegister <= SDI & shiftRegister(wordsize-1 downto 1);
				end if; -- shift direction
			end if; -- latch enable
		end if; -- syncrounous enable
	end if; -- reset and clock
end process proc_shiftRegister;

proc_pdo: q <= shiftRegister;

proc_sdo:
process (shiftRegister,msb_first)
begin
	if msb_first = '1' then
		sdo <= shiftRegister(wordsize-1);
	else
		sdo <= shiftRegister(0);
	end if; --proc_sdo
end process proc_sdo;

end architecture behavior; 