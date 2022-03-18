--==============================================================================================================================================--
-- Title       : n-m_decoder
-- Project     : TFE4105 Digital Design and Computer Fundamentals @ NTNU
-- ==============================================================================================================
-- Author      : UTA Ingulf Helland <helland@netpower.no>
-- Company     : Department of Electronics and Telecommunications <www.iet.ntnu.no>
-- Company     : Norwegian University of Science and Technology <www.ntnu.no>
-- Copyright   : 2008
-- License     : Copyright IET - NTNU
-- ==========================================================
-- Created date: 15. Sept 2008
-- Last update : 
-- Project ver.: 1.00
-- File ver.   : 0.01 
-- Last Rev by : Ingulf Helland <helland@netpower.no>
-- ==========================================================
-- Description : N to M decoder (3-8,4-16, etc.))
--               
--==============================================================================================================================================--
-- Revisions:
--
-- v0.01 - 15. Sept 2008
-- initial test version. 
--==============================================================================================================================================--


--==============================================================================================================================================--
-- Libraries: 
--==============================================================================================================================================--
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;



entity wb_block_decoder is
	generic (
		widthIn              : integer := 2;
		widthOut             : integer := 4
		);
		
	port (
		A       :  in std_logic_vector(widthIn-1 downto 0);
		Y       :  out std_logic_vector(widthOut-1 downto 0);
		en      :  in std_logic
	);
	
end wb_block_decoder;


architecture behavior of wb_block_decoder is
begin
process(A, en)
	variable temp: std_logic_vector(widthOut-1 downto 0):=(others => '0');
	
begin
	if en = '0' then
		temp := (others => '0');
	else
		for i in 0 to widthOut-1 loop
			if (i = A) then
				temp(i) := '1';
			else
				temp(i) := '0';
			end if;
		end loop;
	end if;
	Y <= temp;
end process;


end architecture;
