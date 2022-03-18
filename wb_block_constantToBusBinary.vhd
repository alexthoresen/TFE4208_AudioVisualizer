--==============================================================================================================================================--
-- Title       : wb_gen_constantToBusBinary.
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
-- Description : 
--==============================================================================================================================================--
-- Revisions:
--
-- v0.01 - 4. July 2008
-- initial test version.
--==============================================================================================================================================--

--


--==============================================================================================================================================--
-- Libraries: 
--==============================================================================================================================================--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use ieee.numeric_std.all;


--==============================================================================================================================================--
-- Inputs and outputs decrlarations:
--==============================================================================================================================================--
entity wb_block_constantToBusBinary is

  generic (
		wordsize         : natural := 8 ;   -- Shiftregister size.
		constantValue    : integer := 0
	 );
  
  port(	
		q                : out std_logic_vector(wordsize-1 downto 0) -- parallel data in
      );  
end entity wb_block_constantToBusBinary;

architecture behavior of wb_block_constantToBusBinary is

	signal temp: std_logic_vector(wordsize-1 downto 0) := (others => '0');

begin

	temp <= std_logic_vector(to_unsigned(constantValue,integer(wordsize)));
	q <= temp;

end architecture;