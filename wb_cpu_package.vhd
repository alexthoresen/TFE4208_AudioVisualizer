-------------------------------------------------------------------------------
-- Title      : wb_cpu_package
-- Project    : Lab5 Digdat
-------------------------------------------------------------------------------
-- File       : wb_cpu_package.vhd
-- Author     : Asbjørn Djupdal  <asbjoern@djupdal.org>
-- Company    : 
-- Last update: 2008-06-13
-- Platform   : BenERA, Virtex 1000E
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2003/08/05  1.0      djupdal	Created
-- 2008/09/26  1.1      grannas Adapted to DigDat
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

package wb_cpu_package is

  -----------------------------------------------------------------------------
  -- constants

  -- number of bits in instruction memory address bus
  constant IADDR_BUS : integer := 8;                  -- do not change this
  -- number of bits in instruction memory data bus (= instr. word size)
  constant IDATA_BUS : integer := 32;
  -- number of bits in databus and registers
  constant DDATA_BUS : integer := 8;

  -- number of bits in funct bus
  constant FUNCT_BUS  : integer := 4;
  -- number of bits in status register
  constant STATUS_BUS : integer := 3;

  -- number of words in instruction memory
  constant IMEM_SIZE : integer := 2 ** IADDR_BUS;
  -- number of bits used for selecting registers from regfile
  constant REG_ADDR_BUS   : integer := 4;             -- do not change this
  -- total number of registers in register file
  constant REGISTERS : integer := 2 ** REG_ADDR_BUS;  -- do not change this
  
  -- Memory address bus:
  constant MEM_ADDR_BUS : integer := 8;
  -- Memory data bus (size of instructions)
  constant MEM_DATA_BUS : integer := 32;


  -----------------------------------------------------------------------------
  -- types

  -- datatype used for an array containing all register values
  type regfile_type is
    array (REGISTERS - 1 downto 0) of std_logic_vector(DDATA_BUS - 1 downto 0);

end wb_cpu_package;
