--megafunction wizard: %Altera SOPC Builder%
--GENERATION: STANDARD
--VERSION: WM1.0


--Legal Notice: (C)2008 Altera Corporation. All rights reserved.  Your
--use of Altera Corporation's design tools, logic functions and other
--software and tools, and its AMPP partner logic functions, and any
--output files any of the foregoing (including device programming or
--simulation files), and any associated documentation or information are
--expressly subject to the terms and conditions of the Altera Program
--License Subscription Agreement or other applicable license agreement,
--including, without limitation, that your use is for the sole purpose
--of programming logic devices manufactured by Altera and sold by Altera
--or its authorized distributors.  Please refer to the applicable
--agreement for further details.


-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity A_reg_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal A_reg_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal A_reg_pio_s1_chipselect : OUT STD_LOGIC;
                 signal A_reg_pio_s1_reset_n : OUT STD_LOGIC;
                 signal A_reg_pio_s1_write_n : OUT STD_LOGIC;
                 signal A_reg_pio_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_data_master_granted_A_reg_pio_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_A_reg_pio_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_A_reg_pio_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_A_reg_pio_s1 : OUT STD_LOGIC;
                 signal d1_A_reg_pio_s1_end_xfer : OUT STD_LOGIC
              );
end entity A_reg_pio_s1_arbitrator;


architecture europa of A_reg_pio_s1_arbitrator is
                signal A_reg_pio_s1_allgrants :  STD_LOGIC;
                signal A_reg_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal A_reg_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal A_reg_pio_s1_any_continuerequest :  STD_LOGIC;
                signal A_reg_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal A_reg_pio_s1_arb_share_counter :  STD_LOGIC;
                signal A_reg_pio_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal A_reg_pio_s1_arb_share_set_values :  STD_LOGIC;
                signal A_reg_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal A_reg_pio_s1_begins_xfer :  STD_LOGIC;
                signal A_reg_pio_s1_end_xfer :  STD_LOGIC;
                signal A_reg_pio_s1_firsttransfer :  STD_LOGIC;
                signal A_reg_pio_s1_grant_vector :  STD_LOGIC;
                signal A_reg_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal A_reg_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal A_reg_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal A_reg_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal A_reg_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal A_reg_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal A_reg_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal A_reg_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal A_reg_pio_s1_waits_for_read :  STD_LOGIC;
                signal A_reg_pio_s1_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_A_reg_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_A_reg_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_A_reg_pio_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_A_reg_pio_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_A_reg_pio_s1 :  STD_LOGIC;
                signal shifted_address_to_A_reg_pio_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal wait_for_A_reg_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT A_reg_pio_s1_end_xfer;
      end if;
    end if;

  end process;

  A_reg_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_A_reg_pio_s1);
  internal_cpu_data_master_requests_A_reg_pio_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100001000000100000")))) AND ((cpu_data_master_read OR cpu_data_master_write)))) AND cpu_data_master_write;
  --A_reg_pio_s1_arb_share_counter set values, which is an e_mux
  A_reg_pio_s1_arb_share_set_values <= std_logic'('1');
  --A_reg_pio_s1_non_bursting_master_requests mux, which is an e_mux
  A_reg_pio_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_A_reg_pio_s1;
  --A_reg_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  A_reg_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --A_reg_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  A_reg_pio_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(A_reg_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(A_reg_pio_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(A_reg_pio_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(A_reg_pio_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --A_reg_pio_s1_allgrants all slave grants, which is an e_mux
  A_reg_pio_s1_allgrants <= A_reg_pio_s1_grant_vector;
  --A_reg_pio_s1_end_xfer assignment, which is an e_assign
  A_reg_pio_s1_end_xfer <= NOT ((A_reg_pio_s1_waits_for_read OR A_reg_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_A_reg_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_A_reg_pio_s1 <= A_reg_pio_s1_end_xfer AND (((NOT A_reg_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --A_reg_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  A_reg_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_A_reg_pio_s1 AND A_reg_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_A_reg_pio_s1 AND NOT A_reg_pio_s1_non_bursting_master_requests));
  --A_reg_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      A_reg_pio_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(A_reg_pio_s1_arb_counter_enable) = '1' then 
        A_reg_pio_s1_arb_share_counter <= A_reg_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --A_reg_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      A_reg_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((A_reg_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_A_reg_pio_s1)) OR ((end_xfer_arb_share_counter_term_A_reg_pio_s1 AND NOT A_reg_pio_s1_non_bursting_master_requests)))) = '1' then 
        A_reg_pio_s1_slavearbiterlockenable <= A_reg_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master A_reg_pio/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= A_reg_pio_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --A_reg_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  A_reg_pio_s1_slavearbiterlockenable2 <= A_reg_pio_s1_arb_share_counter_next_value;
  --cpu/data_master A_reg_pio/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= A_reg_pio_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --A_reg_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  A_reg_pio_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_A_reg_pio_s1 <= internal_cpu_data_master_requests_A_reg_pio_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --A_reg_pio_s1_writedata mux, which is an e_mux
  A_reg_pio_s1_writedata <= cpu_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_A_reg_pio_s1 <= internal_cpu_data_master_qualified_request_A_reg_pio_s1;
  --cpu/data_master saved-grant A_reg_pio/s1, which is an e_assign
  cpu_data_master_saved_grant_A_reg_pio_s1 <= internal_cpu_data_master_requests_A_reg_pio_s1;
  --allow new arb cycle for A_reg_pio/s1, which is an e_assign
  A_reg_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  A_reg_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  A_reg_pio_s1_master_qreq_vector <= std_logic'('1');
  --A_reg_pio_s1_reset_n assignment, which is an e_assign
  A_reg_pio_s1_reset_n <= reset_n;
  A_reg_pio_s1_chipselect <= internal_cpu_data_master_granted_A_reg_pio_s1;
  --A_reg_pio_s1_firsttransfer first transaction, which is an e_assign
  A_reg_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(A_reg_pio_s1_begins_xfer) = '1'), A_reg_pio_s1_unreg_firsttransfer, A_reg_pio_s1_reg_firsttransfer);
  --A_reg_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  A_reg_pio_s1_unreg_firsttransfer <= NOT ((A_reg_pio_s1_slavearbiterlockenable AND A_reg_pio_s1_any_continuerequest));
  --A_reg_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      A_reg_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(A_reg_pio_s1_begins_xfer) = '1' then 
        A_reg_pio_s1_reg_firsttransfer <= A_reg_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --A_reg_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  A_reg_pio_s1_beginbursttransfer_internal <= A_reg_pio_s1_begins_xfer;
  --~A_reg_pio_s1_write_n assignment, which is an e_mux
  A_reg_pio_s1_write_n <= NOT ((internal_cpu_data_master_granted_A_reg_pio_s1 AND cpu_data_master_write));
  shifted_address_to_A_reg_pio_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --A_reg_pio_s1_address mux, which is an e_mux
  A_reg_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_A_reg_pio_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_A_reg_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_A_reg_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_A_reg_pio_s1_end_xfer <= A_reg_pio_s1_end_xfer;
      end if;
    end if;

  end process;

  --A_reg_pio_s1_waits_for_read in a cycle, which is an e_mux
  A_reg_pio_s1_waits_for_read <= A_reg_pio_s1_in_a_read_cycle AND A_reg_pio_s1_begins_xfer;
  --A_reg_pio_s1_in_a_read_cycle assignment, which is an e_assign
  A_reg_pio_s1_in_a_read_cycle <= internal_cpu_data_master_granted_A_reg_pio_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= A_reg_pio_s1_in_a_read_cycle;
  --A_reg_pio_s1_waits_for_write in a cycle, which is an e_mux
  A_reg_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(A_reg_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --A_reg_pio_s1_in_a_write_cycle assignment, which is an e_assign
  A_reg_pio_s1_in_a_write_cycle <= internal_cpu_data_master_granted_A_reg_pio_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= A_reg_pio_s1_in_a_write_cycle;
  wait_for_A_reg_pio_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_A_reg_pio_s1 <= internal_cpu_data_master_granted_A_reg_pio_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_A_reg_pio_s1 <= internal_cpu_data_master_qualified_request_A_reg_pio_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_A_reg_pio_s1 <= internal_cpu_data_master_requests_A_reg_pio_s1;
--synthesis translate_off
    --A_reg_pio/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity B_reg_pio_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal B_reg_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal B_reg_pio_s1_chipselect : OUT STD_LOGIC;
                 signal B_reg_pio_s1_reset_n : OUT STD_LOGIC;
                 signal B_reg_pio_s1_write_n : OUT STD_LOGIC;
                 signal B_reg_pio_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal cpu_data_master_granted_B_reg_pio_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_B_reg_pio_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_B_reg_pio_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_B_reg_pio_s1 : OUT STD_LOGIC;
                 signal d1_B_reg_pio_s1_end_xfer : OUT STD_LOGIC
              );
end entity B_reg_pio_s1_arbitrator;


architecture europa of B_reg_pio_s1_arbitrator is
                signal B_reg_pio_s1_allgrants :  STD_LOGIC;
                signal B_reg_pio_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal B_reg_pio_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal B_reg_pio_s1_any_continuerequest :  STD_LOGIC;
                signal B_reg_pio_s1_arb_counter_enable :  STD_LOGIC;
                signal B_reg_pio_s1_arb_share_counter :  STD_LOGIC;
                signal B_reg_pio_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal B_reg_pio_s1_arb_share_set_values :  STD_LOGIC;
                signal B_reg_pio_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal B_reg_pio_s1_begins_xfer :  STD_LOGIC;
                signal B_reg_pio_s1_end_xfer :  STD_LOGIC;
                signal B_reg_pio_s1_firsttransfer :  STD_LOGIC;
                signal B_reg_pio_s1_grant_vector :  STD_LOGIC;
                signal B_reg_pio_s1_in_a_read_cycle :  STD_LOGIC;
                signal B_reg_pio_s1_in_a_write_cycle :  STD_LOGIC;
                signal B_reg_pio_s1_master_qreq_vector :  STD_LOGIC;
                signal B_reg_pio_s1_non_bursting_master_requests :  STD_LOGIC;
                signal B_reg_pio_s1_reg_firsttransfer :  STD_LOGIC;
                signal B_reg_pio_s1_slavearbiterlockenable :  STD_LOGIC;
                signal B_reg_pio_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal B_reg_pio_s1_unreg_firsttransfer :  STD_LOGIC;
                signal B_reg_pio_s1_waits_for_read :  STD_LOGIC;
                signal B_reg_pio_s1_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_B_reg_pio_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_B_reg_pio_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_B_reg_pio_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_B_reg_pio_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_B_reg_pio_s1 :  STD_LOGIC;
                signal shifted_address_to_B_reg_pio_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal wait_for_B_reg_pio_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT B_reg_pio_s1_end_xfer;
      end if;
    end if;

  end process;

  B_reg_pio_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_B_reg_pio_s1);
  internal_cpu_data_master_requests_B_reg_pio_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100001000000110000")))) AND ((cpu_data_master_read OR cpu_data_master_write)))) AND cpu_data_master_write;
  --B_reg_pio_s1_arb_share_counter set values, which is an e_mux
  B_reg_pio_s1_arb_share_set_values <= std_logic'('1');
  --B_reg_pio_s1_non_bursting_master_requests mux, which is an e_mux
  B_reg_pio_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_B_reg_pio_s1;
  --B_reg_pio_s1_any_bursting_master_saved_grant mux, which is an e_mux
  B_reg_pio_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --B_reg_pio_s1_arb_share_counter_next_value assignment, which is an e_assign
  B_reg_pio_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(B_reg_pio_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(B_reg_pio_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(B_reg_pio_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(B_reg_pio_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --B_reg_pio_s1_allgrants all slave grants, which is an e_mux
  B_reg_pio_s1_allgrants <= B_reg_pio_s1_grant_vector;
  --B_reg_pio_s1_end_xfer assignment, which is an e_assign
  B_reg_pio_s1_end_xfer <= NOT ((B_reg_pio_s1_waits_for_read OR B_reg_pio_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_B_reg_pio_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_B_reg_pio_s1 <= B_reg_pio_s1_end_xfer AND (((NOT B_reg_pio_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --B_reg_pio_s1_arb_share_counter arbitration counter enable, which is an e_assign
  B_reg_pio_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_B_reg_pio_s1 AND B_reg_pio_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_B_reg_pio_s1 AND NOT B_reg_pio_s1_non_bursting_master_requests));
  --B_reg_pio_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      B_reg_pio_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(B_reg_pio_s1_arb_counter_enable) = '1' then 
        B_reg_pio_s1_arb_share_counter <= B_reg_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --B_reg_pio_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      B_reg_pio_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((B_reg_pio_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_B_reg_pio_s1)) OR ((end_xfer_arb_share_counter_term_B_reg_pio_s1 AND NOT B_reg_pio_s1_non_bursting_master_requests)))) = '1' then 
        B_reg_pio_s1_slavearbiterlockenable <= B_reg_pio_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master B_reg_pio/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= B_reg_pio_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --B_reg_pio_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  B_reg_pio_s1_slavearbiterlockenable2 <= B_reg_pio_s1_arb_share_counter_next_value;
  --cpu/data_master B_reg_pio/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= B_reg_pio_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --B_reg_pio_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  B_reg_pio_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_B_reg_pio_s1 <= internal_cpu_data_master_requests_B_reg_pio_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --B_reg_pio_s1_writedata mux, which is an e_mux
  B_reg_pio_s1_writedata <= cpu_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_B_reg_pio_s1 <= internal_cpu_data_master_qualified_request_B_reg_pio_s1;
  --cpu/data_master saved-grant B_reg_pio/s1, which is an e_assign
  cpu_data_master_saved_grant_B_reg_pio_s1 <= internal_cpu_data_master_requests_B_reg_pio_s1;
  --allow new arb cycle for B_reg_pio/s1, which is an e_assign
  B_reg_pio_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  B_reg_pio_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  B_reg_pio_s1_master_qreq_vector <= std_logic'('1');
  --B_reg_pio_s1_reset_n assignment, which is an e_assign
  B_reg_pio_s1_reset_n <= reset_n;
  B_reg_pio_s1_chipselect <= internal_cpu_data_master_granted_B_reg_pio_s1;
  --B_reg_pio_s1_firsttransfer first transaction, which is an e_assign
  B_reg_pio_s1_firsttransfer <= A_WE_StdLogic((std_logic'(B_reg_pio_s1_begins_xfer) = '1'), B_reg_pio_s1_unreg_firsttransfer, B_reg_pio_s1_reg_firsttransfer);
  --B_reg_pio_s1_unreg_firsttransfer first transaction, which is an e_assign
  B_reg_pio_s1_unreg_firsttransfer <= NOT ((B_reg_pio_s1_slavearbiterlockenable AND B_reg_pio_s1_any_continuerequest));
  --B_reg_pio_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      B_reg_pio_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(B_reg_pio_s1_begins_xfer) = '1' then 
        B_reg_pio_s1_reg_firsttransfer <= B_reg_pio_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --B_reg_pio_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  B_reg_pio_s1_beginbursttransfer_internal <= B_reg_pio_s1_begins_xfer;
  --~B_reg_pio_s1_write_n assignment, which is an e_mux
  B_reg_pio_s1_write_n <= NOT ((internal_cpu_data_master_granted_B_reg_pio_s1 AND cpu_data_master_write));
  shifted_address_to_B_reg_pio_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --B_reg_pio_s1_address mux, which is an e_mux
  B_reg_pio_s1_address <= A_EXT (A_SRL(shifted_address_to_B_reg_pio_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_B_reg_pio_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_B_reg_pio_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_B_reg_pio_s1_end_xfer <= B_reg_pio_s1_end_xfer;
      end if;
    end if;

  end process;

  --B_reg_pio_s1_waits_for_read in a cycle, which is an e_mux
  B_reg_pio_s1_waits_for_read <= B_reg_pio_s1_in_a_read_cycle AND B_reg_pio_s1_begins_xfer;
  --B_reg_pio_s1_in_a_read_cycle assignment, which is an e_assign
  B_reg_pio_s1_in_a_read_cycle <= internal_cpu_data_master_granted_B_reg_pio_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= B_reg_pio_s1_in_a_read_cycle;
  --B_reg_pio_s1_waits_for_write in a cycle, which is an e_mux
  B_reg_pio_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(B_reg_pio_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --B_reg_pio_s1_in_a_write_cycle assignment, which is an e_assign
  B_reg_pio_s1_in_a_write_cycle <= internal_cpu_data_master_granted_B_reg_pio_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= B_reg_pio_s1_in_a_write_cycle;
  wait_for_B_reg_pio_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_B_reg_pio_s1 <= internal_cpu_data_master_granted_B_reg_pio_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_B_reg_pio_s1 <= internal_cpu_data_master_qualified_request_B_reg_pio_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_B_reg_pio_s1 <= internal_cpu_data_master_requests_B_reg_pio_s1;
--synthesis translate_off
    --B_reg_pio/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Dbg_pc_s1_arbitrator is 
        port (
              -- inputs:
                 signal Dbg_pc_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal Dbg_pc_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal Dbg_pc_s1_chipselect : OUT STD_LOGIC;
                 signal Dbg_pc_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal Dbg_pc_s1_reset_n : OUT STD_LOGIC;
                 signal Dbg_pc_s1_write_n : OUT STD_LOGIC;
                 signal Dbg_pc_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal cpu_data_master_granted_Dbg_pc_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_Dbg_pc_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_Dbg_pc_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_Dbg_pc_s1 : OUT STD_LOGIC;
                 signal d1_Dbg_pc_s1_end_xfer : OUT STD_LOGIC
              );
end entity Dbg_pc_s1_arbitrator;


architecture europa of Dbg_pc_s1_arbitrator is
                signal Dbg_pc_s1_allgrants :  STD_LOGIC;
                signal Dbg_pc_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal Dbg_pc_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal Dbg_pc_s1_any_continuerequest :  STD_LOGIC;
                signal Dbg_pc_s1_arb_counter_enable :  STD_LOGIC;
                signal Dbg_pc_s1_arb_share_counter :  STD_LOGIC;
                signal Dbg_pc_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal Dbg_pc_s1_arb_share_set_values :  STD_LOGIC;
                signal Dbg_pc_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal Dbg_pc_s1_begins_xfer :  STD_LOGIC;
                signal Dbg_pc_s1_end_xfer :  STD_LOGIC;
                signal Dbg_pc_s1_firsttransfer :  STD_LOGIC;
                signal Dbg_pc_s1_grant_vector :  STD_LOGIC;
                signal Dbg_pc_s1_in_a_read_cycle :  STD_LOGIC;
                signal Dbg_pc_s1_in_a_write_cycle :  STD_LOGIC;
                signal Dbg_pc_s1_master_qreq_vector :  STD_LOGIC;
                signal Dbg_pc_s1_non_bursting_master_requests :  STD_LOGIC;
                signal Dbg_pc_s1_pretend_byte_enable :  STD_LOGIC;
                signal Dbg_pc_s1_reg_firsttransfer :  STD_LOGIC;
                signal Dbg_pc_s1_slavearbiterlockenable :  STD_LOGIC;
                signal Dbg_pc_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal Dbg_pc_s1_unreg_firsttransfer :  STD_LOGIC;
                signal Dbg_pc_s1_waits_for_read :  STD_LOGIC;
                signal Dbg_pc_s1_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_Dbg_pc_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_Dbg_pc_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_Dbg_pc_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_Dbg_pc_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_Dbg_pc_s1 :  STD_LOGIC;
                signal shifted_address_to_Dbg_pc_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal wait_for_Dbg_pc_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT Dbg_pc_s1_end_xfer;
      end if;
    end if;

  end process;

  Dbg_pc_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_Dbg_pc_s1);
  --assign Dbg_pc_s1_readdata_from_sa = Dbg_pc_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  Dbg_pc_s1_readdata_from_sa <= Dbg_pc_s1_readdata;
  internal_cpu_data_master_requests_Dbg_pc_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100001000001000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --Dbg_pc_s1_arb_share_counter set values, which is an e_mux
  Dbg_pc_s1_arb_share_set_values <= std_logic'('1');
  --Dbg_pc_s1_non_bursting_master_requests mux, which is an e_mux
  Dbg_pc_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_Dbg_pc_s1;
  --Dbg_pc_s1_any_bursting_master_saved_grant mux, which is an e_mux
  Dbg_pc_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --Dbg_pc_s1_arb_share_counter_next_value assignment, which is an e_assign
  Dbg_pc_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(Dbg_pc_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(Dbg_pc_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(Dbg_pc_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(Dbg_pc_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --Dbg_pc_s1_allgrants all slave grants, which is an e_mux
  Dbg_pc_s1_allgrants <= Dbg_pc_s1_grant_vector;
  --Dbg_pc_s1_end_xfer assignment, which is an e_assign
  Dbg_pc_s1_end_xfer <= NOT ((Dbg_pc_s1_waits_for_read OR Dbg_pc_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_Dbg_pc_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_Dbg_pc_s1 <= Dbg_pc_s1_end_xfer AND (((NOT Dbg_pc_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --Dbg_pc_s1_arb_share_counter arbitration counter enable, which is an e_assign
  Dbg_pc_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_Dbg_pc_s1 AND Dbg_pc_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_Dbg_pc_s1 AND NOT Dbg_pc_s1_non_bursting_master_requests));
  --Dbg_pc_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Dbg_pc_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(Dbg_pc_s1_arb_counter_enable) = '1' then 
        Dbg_pc_s1_arb_share_counter <= Dbg_pc_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --Dbg_pc_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Dbg_pc_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((Dbg_pc_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_Dbg_pc_s1)) OR ((end_xfer_arb_share_counter_term_Dbg_pc_s1 AND NOT Dbg_pc_s1_non_bursting_master_requests)))) = '1' then 
        Dbg_pc_s1_slavearbiterlockenable <= Dbg_pc_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master Dbg_pc/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= Dbg_pc_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --Dbg_pc_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  Dbg_pc_s1_slavearbiterlockenable2 <= Dbg_pc_s1_arb_share_counter_next_value;
  --cpu/data_master Dbg_pc/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= Dbg_pc_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --Dbg_pc_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  Dbg_pc_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_Dbg_pc_s1 <= internal_cpu_data_master_requests_Dbg_pc_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --Dbg_pc_s1_writedata mux, which is an e_mux
  Dbg_pc_s1_writedata <= cpu_data_master_writedata (7 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_Dbg_pc_s1 <= internal_cpu_data_master_qualified_request_Dbg_pc_s1;
  --cpu/data_master saved-grant Dbg_pc/s1, which is an e_assign
  cpu_data_master_saved_grant_Dbg_pc_s1 <= internal_cpu_data_master_requests_Dbg_pc_s1;
  --allow new arb cycle for Dbg_pc/s1, which is an e_assign
  Dbg_pc_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  Dbg_pc_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  Dbg_pc_s1_master_qreq_vector <= std_logic'('1');
  --Dbg_pc_s1_reset_n assignment, which is an e_assign
  Dbg_pc_s1_reset_n <= reset_n;
  Dbg_pc_s1_chipselect <= internal_cpu_data_master_granted_Dbg_pc_s1;
  --Dbg_pc_s1_firsttransfer first transaction, which is an e_assign
  Dbg_pc_s1_firsttransfer <= A_WE_StdLogic((std_logic'(Dbg_pc_s1_begins_xfer) = '1'), Dbg_pc_s1_unreg_firsttransfer, Dbg_pc_s1_reg_firsttransfer);
  --Dbg_pc_s1_unreg_firsttransfer first transaction, which is an e_assign
  Dbg_pc_s1_unreg_firsttransfer <= NOT ((Dbg_pc_s1_slavearbiterlockenable AND Dbg_pc_s1_any_continuerequest));
  --Dbg_pc_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Dbg_pc_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(Dbg_pc_s1_begins_xfer) = '1' then 
        Dbg_pc_s1_reg_firsttransfer <= Dbg_pc_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --Dbg_pc_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  Dbg_pc_s1_beginbursttransfer_internal <= Dbg_pc_s1_begins_xfer;
  --~Dbg_pc_s1_write_n assignment, which is an e_mux
  Dbg_pc_s1_write_n <= NOT ((((internal_cpu_data_master_granted_Dbg_pc_s1 AND cpu_data_master_write)) AND Dbg_pc_s1_pretend_byte_enable));
  shifted_address_to_Dbg_pc_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --Dbg_pc_s1_address mux, which is an e_mux
  Dbg_pc_s1_address <= A_EXT (A_SRL(shifted_address_to_Dbg_pc_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_Dbg_pc_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_Dbg_pc_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_Dbg_pc_s1_end_xfer <= Dbg_pc_s1_end_xfer;
      end if;
    end if;

  end process;

  --Dbg_pc_s1_waits_for_read in a cycle, which is an e_mux
  Dbg_pc_s1_waits_for_read <= Dbg_pc_s1_in_a_read_cycle AND Dbg_pc_s1_begins_xfer;
  --Dbg_pc_s1_in_a_read_cycle assignment, which is an e_assign
  Dbg_pc_s1_in_a_read_cycle <= internal_cpu_data_master_granted_Dbg_pc_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= Dbg_pc_s1_in_a_read_cycle;
  --Dbg_pc_s1_waits_for_write in a cycle, which is an e_mux
  Dbg_pc_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(Dbg_pc_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --Dbg_pc_s1_in_a_write_cycle assignment, which is an e_assign
  Dbg_pc_s1_in_a_write_cycle <= internal_cpu_data_master_granted_Dbg_pc_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= Dbg_pc_s1_in_a_write_cycle;
  wait_for_Dbg_pc_s1_counter <= std_logic'('0');
  --Dbg_pc_s1_pretend_byte_enable byte enable port mux, which is an e_mux
  Dbg_pc_s1_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_Dbg_pc_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  --vhdl renameroo for output signals
  cpu_data_master_granted_Dbg_pc_s1 <= internal_cpu_data_master_granted_Dbg_pc_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_Dbg_pc_s1 <= internal_cpu_data_master_qualified_request_Dbg_pc_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_Dbg_pc_s1 <= internal_cpu_data_master_requests_Dbg_pc_s1;
--synthesis translate_off
    --Dbg_pc/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Dbg_reg_s1_arbitrator is 
        port (
              -- inputs:
                 signal Dbg_reg_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal Dbg_reg_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal Dbg_reg_s1_chipselect : OUT STD_LOGIC;
                 signal Dbg_reg_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal Dbg_reg_s1_reset_n : OUT STD_LOGIC;
                 signal Dbg_reg_s1_write_n : OUT STD_LOGIC;
                 signal Dbg_reg_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal cpu_data_master_granted_Dbg_reg_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_Dbg_reg_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_Dbg_reg_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_Dbg_reg_s1 : OUT STD_LOGIC;
                 signal d1_Dbg_reg_s1_end_xfer : OUT STD_LOGIC
              );
end entity Dbg_reg_s1_arbitrator;


architecture europa of Dbg_reg_s1_arbitrator is
                signal Dbg_reg_s1_allgrants :  STD_LOGIC;
                signal Dbg_reg_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal Dbg_reg_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal Dbg_reg_s1_any_continuerequest :  STD_LOGIC;
                signal Dbg_reg_s1_arb_counter_enable :  STD_LOGIC;
                signal Dbg_reg_s1_arb_share_counter :  STD_LOGIC;
                signal Dbg_reg_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal Dbg_reg_s1_arb_share_set_values :  STD_LOGIC;
                signal Dbg_reg_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal Dbg_reg_s1_begins_xfer :  STD_LOGIC;
                signal Dbg_reg_s1_end_xfer :  STD_LOGIC;
                signal Dbg_reg_s1_firsttransfer :  STD_LOGIC;
                signal Dbg_reg_s1_grant_vector :  STD_LOGIC;
                signal Dbg_reg_s1_in_a_read_cycle :  STD_LOGIC;
                signal Dbg_reg_s1_in_a_write_cycle :  STD_LOGIC;
                signal Dbg_reg_s1_master_qreq_vector :  STD_LOGIC;
                signal Dbg_reg_s1_non_bursting_master_requests :  STD_LOGIC;
                signal Dbg_reg_s1_pretend_byte_enable :  STD_LOGIC;
                signal Dbg_reg_s1_reg_firsttransfer :  STD_LOGIC;
                signal Dbg_reg_s1_slavearbiterlockenable :  STD_LOGIC;
                signal Dbg_reg_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal Dbg_reg_s1_unreg_firsttransfer :  STD_LOGIC;
                signal Dbg_reg_s1_waits_for_read :  STD_LOGIC;
                signal Dbg_reg_s1_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_Dbg_reg_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_Dbg_reg_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_Dbg_reg_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_Dbg_reg_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_Dbg_reg_s1 :  STD_LOGIC;
                signal shifted_address_to_Dbg_reg_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal wait_for_Dbg_reg_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT Dbg_reg_s1_end_xfer;
      end if;
    end if;

  end process;

  Dbg_reg_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_Dbg_reg_s1);
  --assign Dbg_reg_s1_readdata_from_sa = Dbg_reg_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  Dbg_reg_s1_readdata_from_sa <= Dbg_reg_s1_readdata;
  internal_cpu_data_master_requests_Dbg_reg_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100001000001010000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --Dbg_reg_s1_arb_share_counter set values, which is an e_mux
  Dbg_reg_s1_arb_share_set_values <= std_logic'('1');
  --Dbg_reg_s1_non_bursting_master_requests mux, which is an e_mux
  Dbg_reg_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_Dbg_reg_s1;
  --Dbg_reg_s1_any_bursting_master_saved_grant mux, which is an e_mux
  Dbg_reg_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --Dbg_reg_s1_arb_share_counter_next_value assignment, which is an e_assign
  Dbg_reg_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(Dbg_reg_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(Dbg_reg_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(Dbg_reg_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(Dbg_reg_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --Dbg_reg_s1_allgrants all slave grants, which is an e_mux
  Dbg_reg_s1_allgrants <= Dbg_reg_s1_grant_vector;
  --Dbg_reg_s1_end_xfer assignment, which is an e_assign
  Dbg_reg_s1_end_xfer <= NOT ((Dbg_reg_s1_waits_for_read OR Dbg_reg_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_Dbg_reg_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_Dbg_reg_s1 <= Dbg_reg_s1_end_xfer AND (((NOT Dbg_reg_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --Dbg_reg_s1_arb_share_counter arbitration counter enable, which is an e_assign
  Dbg_reg_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_Dbg_reg_s1 AND Dbg_reg_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_Dbg_reg_s1 AND NOT Dbg_reg_s1_non_bursting_master_requests));
  --Dbg_reg_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Dbg_reg_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(Dbg_reg_s1_arb_counter_enable) = '1' then 
        Dbg_reg_s1_arb_share_counter <= Dbg_reg_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --Dbg_reg_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Dbg_reg_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((Dbg_reg_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_Dbg_reg_s1)) OR ((end_xfer_arb_share_counter_term_Dbg_reg_s1 AND NOT Dbg_reg_s1_non_bursting_master_requests)))) = '1' then 
        Dbg_reg_s1_slavearbiterlockenable <= Dbg_reg_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master Dbg_reg/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= Dbg_reg_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --Dbg_reg_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  Dbg_reg_s1_slavearbiterlockenable2 <= Dbg_reg_s1_arb_share_counter_next_value;
  --cpu/data_master Dbg_reg/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= Dbg_reg_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --Dbg_reg_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  Dbg_reg_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_Dbg_reg_s1 <= internal_cpu_data_master_requests_Dbg_reg_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --Dbg_reg_s1_writedata mux, which is an e_mux
  Dbg_reg_s1_writedata <= cpu_data_master_writedata (7 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_Dbg_reg_s1 <= internal_cpu_data_master_qualified_request_Dbg_reg_s1;
  --cpu/data_master saved-grant Dbg_reg/s1, which is an e_assign
  cpu_data_master_saved_grant_Dbg_reg_s1 <= internal_cpu_data_master_requests_Dbg_reg_s1;
  --allow new arb cycle for Dbg_reg/s1, which is an e_assign
  Dbg_reg_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  Dbg_reg_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  Dbg_reg_s1_master_qreq_vector <= std_logic'('1');
  --Dbg_reg_s1_reset_n assignment, which is an e_assign
  Dbg_reg_s1_reset_n <= reset_n;
  Dbg_reg_s1_chipselect <= internal_cpu_data_master_granted_Dbg_reg_s1;
  --Dbg_reg_s1_firsttransfer first transaction, which is an e_assign
  Dbg_reg_s1_firsttransfer <= A_WE_StdLogic((std_logic'(Dbg_reg_s1_begins_xfer) = '1'), Dbg_reg_s1_unreg_firsttransfer, Dbg_reg_s1_reg_firsttransfer);
  --Dbg_reg_s1_unreg_firsttransfer first transaction, which is an e_assign
  Dbg_reg_s1_unreg_firsttransfer <= NOT ((Dbg_reg_s1_slavearbiterlockenable AND Dbg_reg_s1_any_continuerequest));
  --Dbg_reg_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Dbg_reg_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(Dbg_reg_s1_begins_xfer) = '1' then 
        Dbg_reg_s1_reg_firsttransfer <= Dbg_reg_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --Dbg_reg_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  Dbg_reg_s1_beginbursttransfer_internal <= Dbg_reg_s1_begins_xfer;
  --~Dbg_reg_s1_write_n assignment, which is an e_mux
  Dbg_reg_s1_write_n <= NOT ((((internal_cpu_data_master_granted_Dbg_reg_s1 AND cpu_data_master_write)) AND Dbg_reg_s1_pretend_byte_enable));
  shifted_address_to_Dbg_reg_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --Dbg_reg_s1_address mux, which is an e_mux
  Dbg_reg_s1_address <= A_EXT (A_SRL(shifted_address_to_Dbg_reg_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_Dbg_reg_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_Dbg_reg_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_Dbg_reg_s1_end_xfer <= Dbg_reg_s1_end_xfer;
      end if;
    end if;

  end process;

  --Dbg_reg_s1_waits_for_read in a cycle, which is an e_mux
  Dbg_reg_s1_waits_for_read <= Dbg_reg_s1_in_a_read_cycle AND Dbg_reg_s1_begins_xfer;
  --Dbg_reg_s1_in_a_read_cycle assignment, which is an e_assign
  Dbg_reg_s1_in_a_read_cycle <= internal_cpu_data_master_granted_Dbg_reg_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= Dbg_reg_s1_in_a_read_cycle;
  --Dbg_reg_s1_waits_for_write in a cycle, which is an e_mux
  Dbg_reg_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(Dbg_reg_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --Dbg_reg_s1_in_a_write_cycle assignment, which is an e_assign
  Dbg_reg_s1_in_a_write_cycle <= internal_cpu_data_master_granted_Dbg_reg_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= Dbg_reg_s1_in_a_write_cycle;
  wait_for_Dbg_reg_s1_counter <= std_logic'('0');
  --Dbg_reg_s1_pretend_byte_enable byte enable port mux, which is an e_mux
  Dbg_reg_s1_pretend_byte_enable <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_Dbg_reg_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))));
  --vhdl renameroo for output signals
  cpu_data_master_granted_Dbg_reg_s1 <= internal_cpu_data_master_granted_Dbg_reg_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_Dbg_reg_s1 <= internal_cpu_data_master_qualified_request_Dbg_reg_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_Dbg_reg_s1 <= internal_cpu_data_master_requests_Dbg_reg_s1;
--synthesis translate_off
    --Dbg_reg/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Dbg_reg_set_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal Dbg_reg_set_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                 signal Dbg_reg_set_s1_chipselect : OUT STD_LOGIC;
                 signal Dbg_reg_set_s1_reset_n : OUT STD_LOGIC;
                 signal Dbg_reg_set_s1_write_n : OUT STD_LOGIC;
                 signal Dbg_reg_set_s1_writedata : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_granted_Dbg_reg_set_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_Dbg_reg_set_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_Dbg_reg_set_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_Dbg_reg_set_s1 : OUT STD_LOGIC;
                 signal d1_Dbg_reg_set_s1_end_xfer : OUT STD_LOGIC
              );
end entity Dbg_reg_set_s1_arbitrator;


architecture europa of Dbg_reg_set_s1_arbitrator is
                signal Dbg_reg_set_s1_allgrants :  STD_LOGIC;
                signal Dbg_reg_set_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal Dbg_reg_set_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal Dbg_reg_set_s1_any_continuerequest :  STD_LOGIC;
                signal Dbg_reg_set_s1_arb_counter_enable :  STD_LOGIC;
                signal Dbg_reg_set_s1_arb_share_counter :  STD_LOGIC;
                signal Dbg_reg_set_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal Dbg_reg_set_s1_arb_share_set_values :  STD_LOGIC;
                signal Dbg_reg_set_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal Dbg_reg_set_s1_begins_xfer :  STD_LOGIC;
                signal Dbg_reg_set_s1_end_xfer :  STD_LOGIC;
                signal Dbg_reg_set_s1_firsttransfer :  STD_LOGIC;
                signal Dbg_reg_set_s1_grant_vector :  STD_LOGIC;
                signal Dbg_reg_set_s1_in_a_read_cycle :  STD_LOGIC;
                signal Dbg_reg_set_s1_in_a_write_cycle :  STD_LOGIC;
                signal Dbg_reg_set_s1_master_qreq_vector :  STD_LOGIC;
                signal Dbg_reg_set_s1_non_bursting_master_requests :  STD_LOGIC;
                signal Dbg_reg_set_s1_reg_firsttransfer :  STD_LOGIC;
                signal Dbg_reg_set_s1_slavearbiterlockenable :  STD_LOGIC;
                signal Dbg_reg_set_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal Dbg_reg_set_s1_unreg_firsttransfer :  STD_LOGIC;
                signal Dbg_reg_set_s1_waits_for_read :  STD_LOGIC;
                signal Dbg_reg_set_s1_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_Dbg_reg_set_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_Dbg_reg_set_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_Dbg_reg_set_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_Dbg_reg_set_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_Dbg_reg_set_s1 :  STD_LOGIC;
                signal shifted_address_to_Dbg_reg_set_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal wait_for_Dbg_reg_set_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT Dbg_reg_set_s1_end_xfer;
      end if;
    end if;

  end process;

  Dbg_reg_set_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_Dbg_reg_set_s1);
  internal_cpu_data_master_requests_Dbg_reg_set_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 4) & std_logic_vector'("0000")) = std_logic_vector'("100001000001100000")))) AND ((cpu_data_master_read OR cpu_data_master_write)))) AND cpu_data_master_write;
  --Dbg_reg_set_s1_arb_share_counter set values, which is an e_mux
  Dbg_reg_set_s1_arb_share_set_values <= std_logic'('1');
  --Dbg_reg_set_s1_non_bursting_master_requests mux, which is an e_mux
  Dbg_reg_set_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_Dbg_reg_set_s1;
  --Dbg_reg_set_s1_any_bursting_master_saved_grant mux, which is an e_mux
  Dbg_reg_set_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --Dbg_reg_set_s1_arb_share_counter_next_value assignment, which is an e_assign
  Dbg_reg_set_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(Dbg_reg_set_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(Dbg_reg_set_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(Dbg_reg_set_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(Dbg_reg_set_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --Dbg_reg_set_s1_allgrants all slave grants, which is an e_mux
  Dbg_reg_set_s1_allgrants <= Dbg_reg_set_s1_grant_vector;
  --Dbg_reg_set_s1_end_xfer assignment, which is an e_assign
  Dbg_reg_set_s1_end_xfer <= NOT ((Dbg_reg_set_s1_waits_for_read OR Dbg_reg_set_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_Dbg_reg_set_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_Dbg_reg_set_s1 <= Dbg_reg_set_s1_end_xfer AND (((NOT Dbg_reg_set_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --Dbg_reg_set_s1_arb_share_counter arbitration counter enable, which is an e_assign
  Dbg_reg_set_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_Dbg_reg_set_s1 AND Dbg_reg_set_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_Dbg_reg_set_s1 AND NOT Dbg_reg_set_s1_non_bursting_master_requests));
  --Dbg_reg_set_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Dbg_reg_set_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(Dbg_reg_set_s1_arb_counter_enable) = '1' then 
        Dbg_reg_set_s1_arb_share_counter <= Dbg_reg_set_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --Dbg_reg_set_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Dbg_reg_set_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((Dbg_reg_set_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_Dbg_reg_set_s1)) OR ((end_xfer_arb_share_counter_term_Dbg_reg_set_s1 AND NOT Dbg_reg_set_s1_non_bursting_master_requests)))) = '1' then 
        Dbg_reg_set_s1_slavearbiterlockenable <= Dbg_reg_set_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master Dbg_reg_set/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= Dbg_reg_set_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --Dbg_reg_set_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  Dbg_reg_set_s1_slavearbiterlockenable2 <= Dbg_reg_set_s1_arb_share_counter_next_value;
  --cpu/data_master Dbg_reg_set/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= Dbg_reg_set_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --Dbg_reg_set_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  Dbg_reg_set_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_Dbg_reg_set_s1 <= internal_cpu_data_master_requests_Dbg_reg_set_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --Dbg_reg_set_s1_writedata mux, which is an e_mux
  Dbg_reg_set_s1_writedata <= cpu_data_master_writedata (3 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_Dbg_reg_set_s1 <= internal_cpu_data_master_qualified_request_Dbg_reg_set_s1;
  --cpu/data_master saved-grant Dbg_reg_set/s1, which is an e_assign
  cpu_data_master_saved_grant_Dbg_reg_set_s1 <= internal_cpu_data_master_requests_Dbg_reg_set_s1;
  --allow new arb cycle for Dbg_reg_set/s1, which is an e_assign
  Dbg_reg_set_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  Dbg_reg_set_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  Dbg_reg_set_s1_master_qreq_vector <= std_logic'('1');
  --Dbg_reg_set_s1_reset_n assignment, which is an e_assign
  Dbg_reg_set_s1_reset_n <= reset_n;
  Dbg_reg_set_s1_chipselect <= internal_cpu_data_master_granted_Dbg_reg_set_s1;
  --Dbg_reg_set_s1_firsttransfer first transaction, which is an e_assign
  Dbg_reg_set_s1_firsttransfer <= A_WE_StdLogic((std_logic'(Dbg_reg_set_s1_begins_xfer) = '1'), Dbg_reg_set_s1_unreg_firsttransfer, Dbg_reg_set_s1_reg_firsttransfer);
  --Dbg_reg_set_s1_unreg_firsttransfer first transaction, which is an e_assign
  Dbg_reg_set_s1_unreg_firsttransfer <= NOT ((Dbg_reg_set_s1_slavearbiterlockenable AND Dbg_reg_set_s1_any_continuerequest));
  --Dbg_reg_set_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      Dbg_reg_set_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(Dbg_reg_set_s1_begins_xfer) = '1' then 
        Dbg_reg_set_s1_reg_firsttransfer <= Dbg_reg_set_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --Dbg_reg_set_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  Dbg_reg_set_s1_beginbursttransfer_internal <= Dbg_reg_set_s1_begins_xfer;
  --~Dbg_reg_set_s1_write_n assignment, which is an e_mux
  Dbg_reg_set_s1_write_n <= NOT ((internal_cpu_data_master_granted_Dbg_reg_set_s1 AND cpu_data_master_write));
  shifted_address_to_Dbg_reg_set_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --Dbg_reg_set_s1_address mux, which is an e_mux
  Dbg_reg_set_s1_address <= A_EXT (A_SRL(shifted_address_to_Dbg_reg_set_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 2);
  --d1_Dbg_reg_set_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_Dbg_reg_set_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_Dbg_reg_set_s1_end_xfer <= Dbg_reg_set_s1_end_xfer;
      end if;
    end if;

  end process;

  --Dbg_reg_set_s1_waits_for_read in a cycle, which is an e_mux
  Dbg_reg_set_s1_waits_for_read <= Dbg_reg_set_s1_in_a_read_cycle AND Dbg_reg_set_s1_begins_xfer;
  --Dbg_reg_set_s1_in_a_read_cycle assignment, which is an e_assign
  Dbg_reg_set_s1_in_a_read_cycle <= internal_cpu_data_master_granted_Dbg_reg_set_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= Dbg_reg_set_s1_in_a_read_cycle;
  --Dbg_reg_set_s1_waits_for_write in a cycle, which is an e_mux
  Dbg_reg_set_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(Dbg_reg_set_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --Dbg_reg_set_s1_in_a_write_cycle assignment, which is an e_assign
  Dbg_reg_set_s1_in_a_write_cycle <= internal_cpu_data_master_granted_Dbg_reg_set_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= Dbg_reg_set_s1_in_a_write_cycle;
  wait_for_Dbg_reg_set_s1_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_Dbg_reg_set_s1 <= internal_cpu_data_master_granted_Dbg_reg_set_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_Dbg_reg_set_s1 <= internal_cpu_data_master_qualified_request_Dbg_reg_set_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_Dbg_reg_set_s1 <= internal_cpu_data_master_requests_Dbg_reg_set_s1;
--synthesis translate_off
    --Dbg_reg_set/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity character_lcd_avalon_lcd_slave_arbitrator is 
        port (
              -- inputs:
                 signal character_lcd_avalon_lcd_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal character_lcd_avalon_lcd_slave_waitrequest : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal character_lcd_avalon_lcd_slave_address : OUT STD_LOGIC;
                 signal character_lcd_avalon_lcd_slave_chipselect : OUT STD_LOGIC;
                 signal character_lcd_avalon_lcd_slave_read : OUT STD_LOGIC;
                 signal character_lcd_avalon_lcd_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal character_lcd_avalon_lcd_slave_waitrequest_from_sa : OUT STD_LOGIC;
                 signal character_lcd_avalon_lcd_slave_write : OUT STD_LOGIC;
                 signal character_lcd_avalon_lcd_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_granted_character_lcd_avalon_lcd_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_character_lcd_avalon_lcd_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_character_lcd_avalon_lcd_slave : OUT STD_LOGIC;
                 signal d1_character_lcd_avalon_lcd_slave_end_xfer : OUT STD_LOGIC
              );
end entity character_lcd_avalon_lcd_slave_arbitrator;


architecture europa of character_lcd_avalon_lcd_slave_arbitrator is
                signal character_lcd_avalon_lcd_slave_allgrants :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_any_continuerequest :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_arb_counter_enable :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_arb_share_counter :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_arb_share_set_values :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_begins_xfer :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_end_xfer :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_firsttransfer :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_grant_vector :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_in_a_read_cycle :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_in_a_write_cycle :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_master_qreq_vector :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_non_bursting_master_requests :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_reg_firsttransfer :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_slavearbiterlockenable :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_unreg_firsttransfer :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_waits_for_read :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_waits_for_write :  STD_LOGIC;
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_character_lcd_avalon_lcd_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_character_lcd_avalon_lcd_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_character_lcd_avalon_lcd_slave_waitrequest_from_sa :  STD_LOGIC;
                signal internal_cpu_data_master_granted_character_lcd_avalon_lcd_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_character_lcd_avalon_lcd_slave :  STD_LOGIC;
                signal shifted_address_to_character_lcd_avalon_lcd_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal wait_for_character_lcd_avalon_lcd_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT character_lcd_avalon_lcd_slave_end_xfer;
      end if;
    end if;

  end process;

  character_lcd_avalon_lcd_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave);
  --assign character_lcd_avalon_lcd_slave_readdata_from_sa = character_lcd_avalon_lcd_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  character_lcd_avalon_lcd_slave_readdata_from_sa <= character_lcd_avalon_lcd_slave_readdata;
  internal_cpu_data_master_requests_character_lcd_avalon_lcd_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("100001000010001000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign character_lcd_avalon_lcd_slave_waitrequest_from_sa = character_lcd_avalon_lcd_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_character_lcd_avalon_lcd_slave_waitrequest_from_sa <= character_lcd_avalon_lcd_slave_waitrequest;
  --character_lcd_avalon_lcd_slave_arb_share_counter set values, which is an e_mux
  character_lcd_avalon_lcd_slave_arb_share_set_values <= std_logic'('1');
  --character_lcd_avalon_lcd_slave_non_bursting_master_requests mux, which is an e_mux
  character_lcd_avalon_lcd_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_character_lcd_avalon_lcd_slave;
  --character_lcd_avalon_lcd_slave_any_bursting_master_saved_grant mux, which is an e_mux
  character_lcd_avalon_lcd_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --character_lcd_avalon_lcd_slave_arb_share_counter_next_value assignment, which is an e_assign
  character_lcd_avalon_lcd_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(character_lcd_avalon_lcd_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(character_lcd_avalon_lcd_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(character_lcd_avalon_lcd_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(character_lcd_avalon_lcd_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --character_lcd_avalon_lcd_slave_allgrants all slave grants, which is an e_mux
  character_lcd_avalon_lcd_slave_allgrants <= character_lcd_avalon_lcd_slave_grant_vector;
  --character_lcd_avalon_lcd_slave_end_xfer assignment, which is an e_assign
  character_lcd_avalon_lcd_slave_end_xfer <= NOT ((character_lcd_avalon_lcd_slave_waits_for_read OR character_lcd_avalon_lcd_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_character_lcd_avalon_lcd_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_character_lcd_avalon_lcd_slave <= character_lcd_avalon_lcd_slave_end_xfer AND (((NOT character_lcd_avalon_lcd_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --character_lcd_avalon_lcd_slave_arb_share_counter arbitration counter enable, which is an e_assign
  character_lcd_avalon_lcd_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_character_lcd_avalon_lcd_slave AND character_lcd_avalon_lcd_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_character_lcd_avalon_lcd_slave AND NOT character_lcd_avalon_lcd_slave_non_bursting_master_requests));
  --character_lcd_avalon_lcd_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      character_lcd_avalon_lcd_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(character_lcd_avalon_lcd_slave_arb_counter_enable) = '1' then 
        character_lcd_avalon_lcd_slave_arb_share_counter <= character_lcd_avalon_lcd_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --character_lcd_avalon_lcd_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      character_lcd_avalon_lcd_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((character_lcd_avalon_lcd_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_character_lcd_avalon_lcd_slave)) OR ((end_xfer_arb_share_counter_term_character_lcd_avalon_lcd_slave AND NOT character_lcd_avalon_lcd_slave_non_bursting_master_requests)))) = '1' then 
        character_lcd_avalon_lcd_slave_slavearbiterlockenable <= character_lcd_avalon_lcd_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master character_lcd/avalon_lcd_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= character_lcd_avalon_lcd_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --character_lcd_avalon_lcd_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  character_lcd_avalon_lcd_slave_slavearbiterlockenable2 <= character_lcd_avalon_lcd_slave_arb_share_counter_next_value;
  --cpu/data_master character_lcd/avalon_lcd_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= character_lcd_avalon_lcd_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --character_lcd_avalon_lcd_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  character_lcd_avalon_lcd_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave <= internal_cpu_data_master_requests_character_lcd_avalon_lcd_slave AND NOT ((((cpu_data_master_read AND (NOT cpu_data_master_waitrequest))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --character_lcd_avalon_lcd_slave_writedata mux, which is an e_mux
  character_lcd_avalon_lcd_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_character_lcd_avalon_lcd_slave <= internal_cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave;
  --cpu/data_master saved-grant character_lcd/avalon_lcd_slave, which is an e_assign
  cpu_data_master_saved_grant_character_lcd_avalon_lcd_slave <= internal_cpu_data_master_requests_character_lcd_avalon_lcd_slave;
  --allow new arb cycle for character_lcd/avalon_lcd_slave, which is an e_assign
  character_lcd_avalon_lcd_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  character_lcd_avalon_lcd_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  character_lcd_avalon_lcd_slave_master_qreq_vector <= std_logic'('1');
  character_lcd_avalon_lcd_slave_chipselect <= internal_cpu_data_master_granted_character_lcd_avalon_lcd_slave;
  --character_lcd_avalon_lcd_slave_firsttransfer first transaction, which is an e_assign
  character_lcd_avalon_lcd_slave_firsttransfer <= A_WE_StdLogic((std_logic'(character_lcd_avalon_lcd_slave_begins_xfer) = '1'), character_lcd_avalon_lcd_slave_unreg_firsttransfer, character_lcd_avalon_lcd_slave_reg_firsttransfer);
  --character_lcd_avalon_lcd_slave_unreg_firsttransfer first transaction, which is an e_assign
  character_lcd_avalon_lcd_slave_unreg_firsttransfer <= NOT ((character_lcd_avalon_lcd_slave_slavearbiterlockenable AND character_lcd_avalon_lcd_slave_any_continuerequest));
  --character_lcd_avalon_lcd_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      character_lcd_avalon_lcd_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(character_lcd_avalon_lcd_slave_begins_xfer) = '1' then 
        character_lcd_avalon_lcd_slave_reg_firsttransfer <= character_lcd_avalon_lcd_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --character_lcd_avalon_lcd_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  character_lcd_avalon_lcd_slave_beginbursttransfer_internal <= character_lcd_avalon_lcd_slave_begins_xfer;
  --character_lcd_avalon_lcd_slave_read assignment, which is an e_mux
  character_lcd_avalon_lcd_slave_read <= internal_cpu_data_master_granted_character_lcd_avalon_lcd_slave AND cpu_data_master_read;
  --character_lcd_avalon_lcd_slave_write assignment, which is an e_mux
  character_lcd_avalon_lcd_slave_write <= internal_cpu_data_master_granted_character_lcd_avalon_lcd_slave AND cpu_data_master_write;
  shifted_address_to_character_lcd_avalon_lcd_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --character_lcd_avalon_lcd_slave_address mux, which is an e_mux
  character_lcd_avalon_lcd_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_character_lcd_avalon_lcd_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
  --d1_character_lcd_avalon_lcd_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_character_lcd_avalon_lcd_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_character_lcd_avalon_lcd_slave_end_xfer <= character_lcd_avalon_lcd_slave_end_xfer;
      end if;
    end if;

  end process;

  --character_lcd_avalon_lcd_slave_waits_for_read in a cycle, which is an e_mux
  character_lcd_avalon_lcd_slave_waits_for_read <= character_lcd_avalon_lcd_slave_in_a_read_cycle AND internal_character_lcd_avalon_lcd_slave_waitrequest_from_sa;
  --character_lcd_avalon_lcd_slave_in_a_read_cycle assignment, which is an e_assign
  character_lcd_avalon_lcd_slave_in_a_read_cycle <= internal_cpu_data_master_granted_character_lcd_avalon_lcd_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= character_lcd_avalon_lcd_slave_in_a_read_cycle;
  --character_lcd_avalon_lcd_slave_waits_for_write in a cycle, which is an e_mux
  character_lcd_avalon_lcd_slave_waits_for_write <= character_lcd_avalon_lcd_slave_in_a_write_cycle AND internal_character_lcd_avalon_lcd_slave_waitrequest_from_sa;
  --character_lcd_avalon_lcd_slave_in_a_write_cycle assignment, which is an e_assign
  character_lcd_avalon_lcd_slave_in_a_write_cycle <= internal_cpu_data_master_granted_character_lcd_avalon_lcd_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= character_lcd_avalon_lcd_slave_in_a_write_cycle;
  wait_for_character_lcd_avalon_lcd_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  character_lcd_avalon_lcd_slave_waitrequest_from_sa <= internal_character_lcd_avalon_lcd_slave_waitrequest_from_sa;
  --vhdl renameroo for output signals
  cpu_data_master_granted_character_lcd_avalon_lcd_slave <= internal_cpu_data_master_granted_character_lcd_avalon_lcd_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave <= internal_cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_character_lcd_avalon_lcd_slave <= internal_cpu_data_master_requests_character_lcd_avalon_lcd_slave;
--synthesis translate_off
    --character_lcd/avalon_lcd_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity wb_NiosProcessor_reset_clk_domain_synch_module is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal data_in : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal data_out : OUT STD_LOGIC
              );
end entity wb_NiosProcessor_reset_clk_domain_synch_module;


architecture europa of wb_NiosProcessor_reset_clk_domain_synch_module is
                signal data_in_d1 :  STD_LOGIC;
attribute ALTERA_ATTRIBUTE : string;
attribute ALTERA_ATTRIBUTE of data_in_d1 : signal is "{-from ""*""} CUT=ON ; PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";
attribute ALTERA_ATTRIBUTE of data_out : signal is "PRESERVE_REGISTER=ON ; SUPPRESS_DA_RULE_INTERNAL=R101";

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_in_d1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_in_d1 <= data_in;
      end if;
    end if;

  end process;

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      data_out <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        data_out <= data_in_d1;
      end if;
    end if;

  end process;


end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity cpu_jtag_debug_module_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_debugaccess : IN STD_LOGIC;
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_data_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_instruction_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                 signal cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_jtag_debug_module_reset : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_write : OUT STD_LOGIC;
                 signal cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC
              );
end entity cpu_jtag_debug_module_arbitrator;


architecture europa of cpu_jtag_debug_module_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_instruction_master_saved_grant_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_jtag_debug_module_allgrants :  STD_LOGIC;
                signal cpu_jtag_debug_module_allow_new_arb_cycle :  STD_LOGIC;
                signal cpu_jtag_debug_module_any_bursting_master_saved_grant :  STD_LOGIC;
                signal cpu_jtag_debug_module_any_continuerequest :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_arb_counter_enable :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_share_counter :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_share_counter_next_value :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_share_set_values :  STD_LOGIC;
                signal cpu_jtag_debug_module_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_arbitration_holdoff_internal :  STD_LOGIC;
                signal cpu_jtag_debug_module_beginbursttransfer_internal :  STD_LOGIC;
                signal cpu_jtag_debug_module_begins_xfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_jtag_debug_module_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_firsttransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_in_a_read_cycle :  STD_LOGIC;
                signal cpu_jtag_debug_module_in_a_write_cycle :  STD_LOGIC;
                signal cpu_jtag_debug_module_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_non_bursting_master_requests :  STD_LOGIC;
                signal cpu_jtag_debug_module_reg_firsttransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal cpu_jtag_debug_module_slavearbiterlockenable :  STD_LOGIC;
                signal cpu_jtag_debug_module_slavearbiterlockenable2 :  STD_LOGIC;
                signal cpu_jtag_debug_module_unreg_firsttransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_waits_for_read :  STD_LOGIC;
                signal cpu_jtag_debug_module_waits_for_write :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_cpu_jtag_debug_module :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_data_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_instruction_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_instruction_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal internal_cpu_jtag_debug_module_reset_n :  STD_LOGIC;
                signal last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module :  STD_LOGIC;
                signal last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module :  STD_LOGIC;
                signal shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal wait_for_cpu_jtag_debug_module_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT cpu_jtag_debug_module_end_xfer;
      end if;
    end if;

  end process;

  cpu_jtag_debug_module_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_data_master_qualified_request_cpu_jtag_debug_module OR internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module));
  --assign cpu_jtag_debug_module_readdata_from_sa = cpu_jtag_debug_module_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_jtag_debug_module_readdata_from_sa <= cpu_jtag_debug_module_readdata;
  internal_cpu_data_master_requests_cpu_jtag_debug_module <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("100000100000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --cpu_jtag_debug_module_arb_share_counter set values, which is an e_mux
  cpu_jtag_debug_module_arb_share_set_values <= std_logic'('1');
  --cpu_jtag_debug_module_non_bursting_master_requests mux, which is an e_mux
  cpu_jtag_debug_module_non_bursting_master_requests <= ((internal_cpu_data_master_requests_cpu_jtag_debug_module OR internal_cpu_instruction_master_requests_cpu_jtag_debug_module) OR internal_cpu_data_master_requests_cpu_jtag_debug_module) OR internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --cpu_jtag_debug_module_any_bursting_master_saved_grant mux, which is an e_mux
  cpu_jtag_debug_module_any_bursting_master_saved_grant <= std_logic'('0');
  --cpu_jtag_debug_module_arb_share_counter_next_value assignment, which is an e_assign
  cpu_jtag_debug_module_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_jtag_debug_module_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(cpu_jtag_debug_module_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --cpu_jtag_debug_module_allgrants all slave grants, which is an e_mux
  cpu_jtag_debug_module_allgrants <= ((or_reduce(cpu_jtag_debug_module_grant_vector) OR or_reduce(cpu_jtag_debug_module_grant_vector)) OR or_reduce(cpu_jtag_debug_module_grant_vector)) OR or_reduce(cpu_jtag_debug_module_grant_vector);
  --cpu_jtag_debug_module_end_xfer assignment, which is an e_assign
  cpu_jtag_debug_module_end_xfer <= NOT ((cpu_jtag_debug_module_waits_for_read OR cpu_jtag_debug_module_waits_for_write));
  --end_xfer_arb_share_counter_term_cpu_jtag_debug_module arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_cpu_jtag_debug_module <= cpu_jtag_debug_module_end_xfer AND (((NOT cpu_jtag_debug_module_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --cpu_jtag_debug_module_arb_share_counter arbitration counter enable, which is an e_assign
  cpu_jtag_debug_module_arb_counter_enable <= ((end_xfer_arb_share_counter_term_cpu_jtag_debug_module AND cpu_jtag_debug_module_allgrants)) OR ((end_xfer_arb_share_counter_term_cpu_jtag_debug_module AND NOT cpu_jtag_debug_module_non_bursting_master_requests));
  --cpu_jtag_debug_module_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_jtag_debug_module_arb_counter_enable) = '1' then 
        cpu_jtag_debug_module_arb_share_counter <= cpu_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu_jtag_debug_module_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(cpu_jtag_debug_module_master_qreq_vector) AND end_xfer_arb_share_counter_term_cpu_jtag_debug_module)) OR ((end_xfer_arb_share_counter_term_cpu_jtag_debug_module AND NOT cpu_jtag_debug_module_non_bursting_master_requests)))) = '1' then 
        cpu_jtag_debug_module_slavearbiterlockenable <= cpu_jtag_debug_module_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master cpu/jtag_debug_module arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= cpu_jtag_debug_module_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --cpu_jtag_debug_module_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  cpu_jtag_debug_module_slavearbiterlockenable2 <= cpu_jtag_debug_module_arb_share_counter_next_value;
  --cpu/data_master cpu/jtag_debug_module arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= cpu_jtag_debug_module_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --cpu/instruction_master cpu/jtag_debug_module arbiterlock, which is an e_assign
  cpu_instruction_master_arbiterlock <= cpu_jtag_debug_module_slavearbiterlockenable AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master cpu/jtag_debug_module arbiterlock2, which is an e_assign
  cpu_instruction_master_arbiterlock2 <= cpu_jtag_debug_module_slavearbiterlockenable2 AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master granted cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_instruction_master_saved_grant_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_cpu_instruction_master_requests_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module))))));
      end if;
    end if;

  end process;

  --cpu_instruction_master_continuerequest continued request, which is an e_mux
  cpu_instruction_master_continuerequest <= last_cycle_cpu_instruction_master_granted_slave_cpu_jtag_debug_module AND internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --cpu_jtag_debug_module_any_continuerequest at least one master continues requesting, which is an e_mux
  cpu_jtag_debug_module_any_continuerequest <= cpu_instruction_master_continuerequest OR cpu_data_master_continuerequest;
  internal_cpu_data_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_data_master_requests_cpu_jtag_debug_module AND NOT (((((NOT cpu_data_master_waitrequest) AND cpu_data_master_write)) OR cpu_instruction_master_arbiterlock));
  --cpu_jtag_debug_module_writedata mux, which is an e_mux
  cpu_jtag_debug_module_writedata <= cpu_data_master_writedata;
  internal_cpu_instruction_master_requests_cpu_jtag_debug_module <= ((to_std_logic(((Std_Logic_Vector'(cpu_instruction_master_address_to_slave(17 DOWNTO 11) & std_logic_vector'("00000000000")) = std_logic_vector'("100000100000000000")))) AND (cpu_instruction_master_read))) AND cpu_instruction_master_read;
  --cpu/data_master granted cpu/jtag_debug_module last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_data_master_saved_grant_cpu_jtag_debug_module) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((cpu_jtag_debug_module_arbitration_holdoff_internal OR NOT internal_cpu_data_master_requests_cpu_jtag_debug_module))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module))))));
      end if;
    end if;

  end process;

  --cpu_data_master_continuerequest continued request, which is an e_mux
  cpu_data_master_continuerequest <= last_cycle_cpu_data_master_granted_slave_cpu_jtag_debug_module AND internal_cpu_data_master_requests_cpu_jtag_debug_module;
  internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_instruction_master_requests_cpu_jtag_debug_module AND NOT ((((cpu_instruction_master_read AND to_std_logic((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_latency_counter))) /= std_logic_vector'("00000000000000000000000000000000")))))) OR cpu_data_master_arbiterlock));
  --local readdatavalid cpu_instruction_master_read_data_valid_cpu_jtag_debug_module, which is an e_mux
  cpu_instruction_master_read_data_valid_cpu_jtag_debug_module <= (internal_cpu_instruction_master_granted_cpu_jtag_debug_module AND cpu_instruction_master_read) AND NOT cpu_jtag_debug_module_waits_for_read;
  --allow new arb cycle for cpu/jtag_debug_module, which is an e_assign
  cpu_jtag_debug_module_allow_new_arb_cycle <= NOT cpu_data_master_arbiterlock AND NOT cpu_instruction_master_arbiterlock;
  --cpu/instruction_master assignment into master qualified-requests vector for cpu/jtag_debug_module, which is an e_assign
  cpu_jtag_debug_module_master_qreq_vector(0) <= internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  --cpu/instruction_master grant cpu/jtag_debug_module, which is an e_assign
  internal_cpu_instruction_master_granted_cpu_jtag_debug_module <= cpu_jtag_debug_module_grant_vector(0);
  --cpu/instruction_master saved-grant cpu/jtag_debug_module, which is an e_assign
  cpu_instruction_master_saved_grant_cpu_jtag_debug_module <= cpu_jtag_debug_module_arb_winner(0) AND internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --cpu/data_master assignment into master qualified-requests vector for cpu/jtag_debug_module, which is an e_assign
  cpu_jtag_debug_module_master_qreq_vector(1) <= internal_cpu_data_master_qualified_request_cpu_jtag_debug_module;
  --cpu/data_master grant cpu/jtag_debug_module, which is an e_assign
  internal_cpu_data_master_granted_cpu_jtag_debug_module <= cpu_jtag_debug_module_grant_vector(1);
  --cpu/data_master saved-grant cpu/jtag_debug_module, which is an e_assign
  cpu_data_master_saved_grant_cpu_jtag_debug_module <= cpu_jtag_debug_module_arb_winner(1) AND internal_cpu_data_master_requests_cpu_jtag_debug_module;
  --cpu/jtag_debug_module chosen-master double-vector, which is an e_assign
  cpu_jtag_debug_module_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((cpu_jtag_debug_module_master_qreq_vector & cpu_jtag_debug_module_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT cpu_jtag_debug_module_master_qreq_vector & NOT cpu_jtag_debug_module_master_qreq_vector))) + (std_logic_vector'("000") & (cpu_jtag_debug_module_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  cpu_jtag_debug_module_arb_winner <= A_WE_StdLogicVector((std_logic'(((cpu_jtag_debug_module_allow_new_arb_cycle AND or_reduce(cpu_jtag_debug_module_grant_vector)))) = '1'), cpu_jtag_debug_module_grant_vector, cpu_jtag_debug_module_saved_chosen_master_vector);
  --saved cpu_jtag_debug_module_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_jtag_debug_module_allow_new_arb_cycle) = '1' then 
        cpu_jtag_debug_module_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(cpu_jtag_debug_module_grant_vector)) = '1'), cpu_jtag_debug_module_grant_vector, cpu_jtag_debug_module_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  cpu_jtag_debug_module_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((cpu_jtag_debug_module_chosen_master_double_vector(1) OR cpu_jtag_debug_module_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((cpu_jtag_debug_module_chosen_master_double_vector(0) OR cpu_jtag_debug_module_chosen_master_double_vector(2)))));
  --cpu/jtag_debug_module chosen master rotated left, which is an e_assign
  cpu_jtag_debug_module_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(cpu_jtag_debug_module_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --cpu/jtag_debug_module's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(cpu_jtag_debug_module_grant_vector)) = '1' then 
        cpu_jtag_debug_module_arb_addend <= A_WE_StdLogicVector((std_logic'(cpu_jtag_debug_module_end_xfer) = '1'), cpu_jtag_debug_module_chosen_master_rot_left, cpu_jtag_debug_module_grant_vector);
      end if;
    end if;

  end process;

  cpu_jtag_debug_module_begintransfer <= cpu_jtag_debug_module_begins_xfer;
  --assign lhs ~cpu_jtag_debug_module_reset of type reset_n to cpu_jtag_debug_module_reset_n, which is an e_assign
  cpu_jtag_debug_module_reset <= NOT internal_cpu_jtag_debug_module_reset_n;
  --cpu_jtag_debug_module_reset_n assignment, which is an e_assign
  internal_cpu_jtag_debug_module_reset_n <= reset_n;
  --assign cpu_jtag_debug_module_resetrequest_from_sa = cpu_jtag_debug_module_resetrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  cpu_jtag_debug_module_resetrequest_from_sa <= cpu_jtag_debug_module_resetrequest;
  cpu_jtag_debug_module_chipselect <= internal_cpu_data_master_granted_cpu_jtag_debug_module OR internal_cpu_instruction_master_granted_cpu_jtag_debug_module;
  --cpu_jtag_debug_module_firsttransfer first transaction, which is an e_assign
  cpu_jtag_debug_module_firsttransfer <= A_WE_StdLogic((std_logic'(cpu_jtag_debug_module_begins_xfer) = '1'), cpu_jtag_debug_module_unreg_firsttransfer, cpu_jtag_debug_module_reg_firsttransfer);
  --cpu_jtag_debug_module_unreg_firsttransfer first transaction, which is an e_assign
  cpu_jtag_debug_module_unreg_firsttransfer <= NOT ((cpu_jtag_debug_module_slavearbiterlockenable AND cpu_jtag_debug_module_any_continuerequest));
  --cpu_jtag_debug_module_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_jtag_debug_module_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(cpu_jtag_debug_module_begins_xfer) = '1' then 
        cpu_jtag_debug_module_reg_firsttransfer <= cpu_jtag_debug_module_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --cpu_jtag_debug_module_beginbursttransfer_internal begin burst transfer, which is an e_assign
  cpu_jtag_debug_module_beginbursttransfer_internal <= cpu_jtag_debug_module_begins_xfer;
  --cpu_jtag_debug_module_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  cpu_jtag_debug_module_arbitration_holdoff_internal <= cpu_jtag_debug_module_begins_xfer AND cpu_jtag_debug_module_firsttransfer;
  --cpu_jtag_debug_module_write assignment, which is an e_mux
  cpu_jtag_debug_module_write <= internal_cpu_data_master_granted_cpu_jtag_debug_module AND cpu_data_master_write;
  shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --cpu_jtag_debug_module_address mux, which is an e_mux
  cpu_jtag_debug_module_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_cpu_jtag_debug_module)) = '1'), (A_SRL(shifted_address_to_cpu_jtag_debug_module_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 9);
  shifted_address_to_cpu_jtag_debug_module_from_cpu_instruction_master <= cpu_instruction_master_address_to_slave;
  --d1_cpu_jtag_debug_module_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_cpu_jtag_debug_module_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_cpu_jtag_debug_module_end_xfer <= cpu_jtag_debug_module_end_xfer;
      end if;
    end if;

  end process;

  --cpu_jtag_debug_module_waits_for_read in a cycle, which is an e_mux
  cpu_jtag_debug_module_waits_for_read <= cpu_jtag_debug_module_in_a_read_cycle AND cpu_jtag_debug_module_begins_xfer;
  --cpu_jtag_debug_module_in_a_read_cycle assignment, which is an e_assign
  cpu_jtag_debug_module_in_a_read_cycle <= ((internal_cpu_data_master_granted_cpu_jtag_debug_module AND cpu_data_master_read)) OR ((internal_cpu_instruction_master_granted_cpu_jtag_debug_module AND cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= cpu_jtag_debug_module_in_a_read_cycle;
  --cpu_jtag_debug_module_waits_for_write in a cycle, which is an e_mux
  cpu_jtag_debug_module_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --cpu_jtag_debug_module_in_a_write_cycle assignment, which is an e_assign
  cpu_jtag_debug_module_in_a_write_cycle <= internal_cpu_data_master_granted_cpu_jtag_debug_module AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= cpu_jtag_debug_module_in_a_write_cycle;
  wait_for_cpu_jtag_debug_module_counter <= std_logic'('0');
  --cpu_jtag_debug_module_byteenable byte enable port mux, which is an e_mux
  cpu_jtag_debug_module_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --debugaccess mux, which is an e_mux
  cpu_jtag_debug_module_debugaccess <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_cpu_jtag_debug_module)) = '1'), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_debugaccess))), std_logic_vector'("00000000000000000000000000000000")));
  --vhdl renameroo for output signals
  cpu_data_master_granted_cpu_jtag_debug_module <= internal_cpu_data_master_granted_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_data_master_qualified_request_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_data_master_requests_cpu_jtag_debug_module <= internal_cpu_data_master_requests_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_instruction_master_granted_cpu_jtag_debug_module <= internal_cpu_instruction_master_granted_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_instruction_master_qualified_request_cpu_jtag_debug_module <= internal_cpu_instruction_master_qualified_request_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_instruction_master_requests_cpu_jtag_debug_module <= internal_cpu_instruction_master_requests_cpu_jtag_debug_module;
  --vhdl renameroo for output signals
  cpu_jtag_debug_module_reset_n <= internal_cpu_jtag_debug_module_reset_n;
--synthesis translate_off
    --cpu/jtag_debug_module enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_data_master_granted_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_instruction_master_granted_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line, now);
          write(write_line, string'(": "));
          write(write_line, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line.all);
          deallocate (write_line);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line1 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_data_master_saved_grant_cpu_jtag_debug_module))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_saved_grant_cpu_jtag_debug_module))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line1, now);
          write(write_line1, string'(": "));
          write(write_line1, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line1.all);
          deallocate (write_line1);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity cpu_data_master_arbitrator is 
        port (
              -- inputs:
                 signal Dbg_pc_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal Dbg_reg_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal character_lcd_avalon_lcd_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal character_lcd_avalon_lcd_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_granted_A_reg_pio_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_B_reg_pio_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_Dbg_pc_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_Dbg_reg_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_Dbg_reg_set_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_character_lcd_avalon_lcd_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave : IN STD_LOGIC;
                 signal cpu_data_master_granted_sys_clk_timer_s1 : IN STD_LOGIC;
                 signal cpu_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_A_reg_pio_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_B_reg_pio_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_Dbg_pc_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_Dbg_reg_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_Dbg_reg_set_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_sys_clk_timer_s1 : IN STD_LOGIC;
                 signal cpu_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_A_reg_pio_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_B_reg_pio_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_Dbg_pc_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_Dbg_reg_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_Dbg_reg_set_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_character_lcd_avalon_lcd_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_sys_clk_timer_s1 : IN STD_LOGIC;
                 signal cpu_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_A_reg_pio_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_B_reg_pio_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_Dbg_pc_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_Dbg_reg_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_Dbg_reg_set_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_character_lcd_avalon_lcd_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave : IN STD_LOGIC;
                 signal cpu_data_master_requests_sys_clk_timer_s1 : IN STD_LOGIC;
                 signal cpu_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_A_reg_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_B_reg_pio_s1_end_xfer : IN STD_LOGIC;
                 signal d1_Dbg_pc_s1_end_xfer : IN STD_LOGIC;
                 signal d1_Dbg_reg_s1_end_xfer : IN STD_LOGIC;
                 signal d1_Dbg_reg_set_s1_end_xfer : IN STD_LOGIC;
                 signal d1_character_lcd_avalon_lcd_slave_end_xfer : IN STD_LOGIC;
                 signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_jtag_uart_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                 signal d1_ps2_keyboard_avalon_PS2_slave_end_xfer : IN STD_LOGIC;
                 signal d1_sys_clk_timer_s1_end_xfer : IN STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ps2_keyboard_avalon_PS2_slave_irq_from_sa : IN STD_LOGIC;
                 signal ps2_keyboard_avalon_PS2_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa : IN STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                 signal registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sys_clk_timer_s1_irq_from_sa : IN STD_LOGIC;
                 signal sys_clk_timer_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_data_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_data_master_arbitrator;


architecture europa of cpu_data_master_arbitrator is
                signal cpu_data_master_run :  STD_LOGIC;
                signal internal_cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal internal_cpu_data_master_waitrequest :  STD_LOGIC;
                signal p1_registered_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal r_0 :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;
                signal r_2 :  STD_LOGIC;
                signal registered_cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --r_0 master_run cascaded wait assignment, which is an e_assign
  r_0 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_A_reg_pio_s1 OR NOT cpu_data_master_requests_A_reg_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_A_reg_pio_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_A_reg_pio_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_B_reg_pio_s1 OR NOT cpu_data_master_requests_B_reg_pio_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_B_reg_pio_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_B_reg_pio_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_Dbg_pc_s1 OR NOT cpu_data_master_requests_Dbg_pc_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_Dbg_pc_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_Dbg_pc_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_Dbg_reg_s1 OR NOT cpu_data_master_requests_Dbg_reg_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_Dbg_reg_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_Dbg_reg_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_Dbg_reg_set_s1 OR NOT cpu_data_master_requests_Dbg_reg_set_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_Dbg_reg_set_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_Dbg_reg_set_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))));
  --cascaded wait assignment, which is an e_assign
  cpu_data_master_run <= (r_0 AND r_1) AND r_2;
  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((((((((((((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave OR NOT cpu_data_master_requests_character_lcd_avalon_lcd_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT character_lcd_avalon_lcd_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT character_lcd_avalon_lcd_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_data_master_requests_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_granted_cpu_jtag_debug_module OR NOT cpu_data_master_qualified_request_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT cpu_data_master_requests_jtag_uart_avalon_jtag_slave)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT jtag_uart_avalon_jtag_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_onchip_mem_s1 OR registered_cpu_data_master_read_data_valid_onchip_mem_s1) OR NOT cpu_data_master_requests_onchip_mem_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_granted_onchip_mem_s1 OR NOT cpu_data_master_qualified_request_onchip_mem_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_data_master_qualified_request_onchip_mem_s1 OR NOT cpu_data_master_read) OR ((registered_cpu_data_master_read_data_valid_onchip_mem_s1 AND cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_onchip_mem_s1 OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave OR registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave) OR NOT cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave)))))));
  --r_2 master_run cascaded wait assignment, which is an e_assign
  r_2 <= Vector_To_Std_Logic((((((((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((((NOT cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave OR NOT cpu_data_master_read) OR ((registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave AND cpu_data_master_read))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave OR NOT ((cpu_data_master_read OR cpu_data_master_write)))))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_read OR cpu_data_master_write)))))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_qualified_request_sys_clk_timer_s1 OR NOT cpu_data_master_requests_sys_clk_timer_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_sys_clk_timer_s1 OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_sys_clk_timer_s1 OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_sysid_control_slave OR NOT cpu_data_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_read)))))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_data_master_qualified_request_sysid_control_slave OR NOT cpu_data_master_write)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_data_master_write)))))))));
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_data_master_address_to_slave <= cpu_data_master_address(17 DOWNTO 0);
  --actual waitrequest port, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT std_logic_vector'("00000000000000000000000000000000"));
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        internal_cpu_data_master_waitrequest <= Vector_To_Std_Logic(NOT (A_WE_StdLogicVector((std_logic'((NOT ((cpu_data_master_read OR cpu_data_master_write)))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_data_master_run AND internal_cpu_data_master_waitrequest))))))));
      end if;
    end if;

  end process;

  --cpu/data_master readdata mux, which is an e_mux
  cpu_data_master_readdata <= (((((((((A_REP(NOT cpu_data_master_requests_Dbg_pc_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (Dbg_pc_s1_readdata_from_sa)))) AND ((A_REP(NOT cpu_data_master_requests_Dbg_reg_s1, 32) OR (std_logic_vector'("000000000000000000000000") & (Dbg_reg_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_data_master_requests_character_lcd_avalon_lcd_slave, 32) OR registered_cpu_data_master_readdata))) AND ((A_REP(NOT cpu_data_master_requests_cpu_jtag_debug_module, 32) OR cpu_jtag_debug_module_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_jtag_uart_avalon_jtag_slave, 32) OR registered_cpu_data_master_readdata))) AND ((A_REP(NOT cpu_data_master_requests_onchip_mem_s1, 32) OR onchip_mem_s1_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave, 32) OR ps2_keyboard_avalon_PS2_slave_readdata_from_sa))) AND ((A_REP(NOT cpu_data_master_requests_sys_clk_timer_s1, 32) OR (std_logic_vector'("0000000000000000") & (sys_clk_timer_s1_readdata_from_sa))))) AND ((A_REP(NOT cpu_data_master_requests_sysid_control_slave, 32) OR sysid_control_slave_readdata_from_sa));
  --unpredictable registered wait state incoming data, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      registered_cpu_data_master_readdata <= std_logic_vector'("00000000000000000000000000000000");
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        registered_cpu_data_master_readdata <= p1_registered_cpu_data_master_readdata;
      end if;
    end if;

  end process;

  --registered readdata mux, which is an e_mux
  p1_registered_cpu_data_master_readdata <= ((A_REP(NOT cpu_data_master_requests_character_lcd_avalon_lcd_slave, 32) OR character_lcd_avalon_lcd_slave_readdata_from_sa)) AND ((A_REP(NOT cpu_data_master_requests_jtag_uart_avalon_jtag_slave, 32) OR jtag_uart_avalon_jtag_slave_readdata_from_sa));
  --irq assign, which is an e_assign
  cpu_data_master_irq <= Std_Logic_Vector'(A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(jtag_uart_avalon_jtag_slave_irq_from_sa) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(ps2_keyboard_avalon_PS2_slave_irq_from_sa) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(std_logic'('0')) & A_ToStdLogicVector(sys_clk_timer_s1_irq_from_sa));
  --vhdl renameroo for output signals
  cpu_data_master_address_to_slave <= internal_cpu_data_master_address_to_slave;
  --vhdl renameroo for output signals
  cpu_data_master_waitrequest <= internal_cpu_data_master_waitrequest;

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity cpu_instruction_master_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_instruction_master_address : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_instruction_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_instruction_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                 signal cpu_instruction_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                 signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                 signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                 signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_instruction_master_latency_counter : OUT STD_LOGIC;
                 signal cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                 signal cpu_instruction_master_waitrequest : OUT STD_LOGIC
              );
end entity cpu_instruction_master_arbitrator;


architecture europa of cpu_instruction_master_arbitrator is
                signal active_and_waiting_last_time :  STD_LOGIC;
                signal cpu_instruction_master_address_last_time :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal cpu_instruction_master_is_granted_some_slave :  STD_LOGIC;
                signal cpu_instruction_master_read_but_no_slave_selected :  STD_LOGIC;
                signal cpu_instruction_master_read_last_time :  STD_LOGIC;
                signal cpu_instruction_master_run :  STD_LOGIC;
                signal internal_cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal internal_cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal internal_cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal latency_load_value :  STD_LOGIC;
                signal p1_cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal pre_flush_cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal r_1 :  STD_LOGIC;

begin

  --r_1 master_run cascaded wait assignment, which is an e_assign
  r_1 <= Vector_To_Std_Logic((((((((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_instruction_master_requests_cpu_jtag_debug_module)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_granted_cpu_jtag_debug_module OR NOT cpu_instruction_master_qualified_request_cpu_jtag_debug_module)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_instruction_master_qualified_request_cpu_jtag_debug_module OR NOT cpu_instruction_master_read)))) OR (((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT d1_cpu_jtag_debug_module_end_xfer)))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_read)))))))) AND std_logic_vector'("00000000000000000000000000000001")) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_qualified_request_onchip_mem_s1 OR NOT cpu_instruction_master_requests_onchip_mem_s1)))))) AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(((cpu_instruction_master_granted_onchip_mem_s1 OR NOT cpu_instruction_master_qualified_request_onchip_mem_s1)))))) AND (((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR((NOT cpu_instruction_master_qualified_request_onchip_mem_s1 OR NOT cpu_instruction_master_read)))) OR ((std_logic_vector'("00000000000000000000000000000001") AND (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_read)))))))));
  --cascaded wait assignment, which is an e_assign
  cpu_instruction_master_run <= r_1;
  --optimize select-logic by passing only those address bits which matter.
  internal_cpu_instruction_master_address_to_slave <= cpu_instruction_master_address(17 DOWNTO 0);
  --cpu_instruction_master_read_but_no_slave_selected assignment, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_instruction_master_read_but_no_slave_selected <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_instruction_master_read_but_no_slave_selected <= (cpu_instruction_master_read AND cpu_instruction_master_run) AND NOT cpu_instruction_master_is_granted_some_slave;
      end if;
    end if;

  end process;

  --some slave is getting selected, which is an e_mux
  cpu_instruction_master_is_granted_some_slave <= cpu_instruction_master_granted_cpu_jtag_debug_module OR cpu_instruction_master_granted_onchip_mem_s1;
  --latent slave read data valids which may be flushed, which is an e_mux
  pre_flush_cpu_instruction_master_readdatavalid <= cpu_instruction_master_read_data_valid_onchip_mem_s1;
  --latent slave read data valid which is not flushed, which is an e_mux
  cpu_instruction_master_readdatavalid <= (((cpu_instruction_master_read_but_no_slave_selected OR pre_flush_cpu_instruction_master_readdatavalid) OR cpu_instruction_master_read_data_valid_cpu_jtag_debug_module) OR cpu_instruction_master_read_but_no_slave_selected) OR pre_flush_cpu_instruction_master_readdatavalid;
  --cpu/instruction_master readdata mux, which is an e_mux
  cpu_instruction_master_readdata <= ((A_REP(NOT ((cpu_instruction_master_qualified_request_cpu_jtag_debug_module AND cpu_instruction_master_read)) , 32) OR cpu_jtag_debug_module_readdata_from_sa)) AND ((A_REP(NOT cpu_instruction_master_read_data_valid_onchip_mem_s1, 32) OR onchip_mem_s1_readdata_from_sa));
  --actual waitrequest port, which is an e_assign
  internal_cpu_instruction_master_waitrequest <= NOT cpu_instruction_master_run;
  --latent max counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      internal_cpu_instruction_master_latency_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        internal_cpu_instruction_master_latency_counter <= p1_cpu_instruction_master_latency_counter;
      end if;
    end if;

  end process;

  --latency counter load mux, which is an e_mux
  p1_cpu_instruction_master_latency_counter <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(((cpu_instruction_master_run AND cpu_instruction_master_read))) = '1'), (std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(latency_load_value))), A_WE_StdLogicVector((std_logic'((internal_cpu_instruction_master_latency_counter)) = '1'), ((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(internal_cpu_instruction_master_latency_counter))) - std_logic_vector'("000000000000000000000000000000001")), std_logic_vector'("000000000000000000000000000000000"))));
  --read latency load values, which is an e_mux
  latency_load_value <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_requests_onchip_mem_s1))) AND std_logic_vector'("00000000000000000000000000000001")));
  --vhdl renameroo for output signals
  cpu_instruction_master_address_to_slave <= internal_cpu_instruction_master_address_to_slave;
  --vhdl renameroo for output signals
  cpu_instruction_master_latency_counter <= internal_cpu_instruction_master_latency_counter;
  --vhdl renameroo for output signals
  cpu_instruction_master_waitrequest <= internal_cpu_instruction_master_waitrequest;
--synthesis translate_off
    --cpu_instruction_master_address check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_instruction_master_address_last_time <= std_logic_vector'("000000000000000000");
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          cpu_instruction_master_address_last_time <= cpu_instruction_master_address;
        end if;
      end if;

    end process;

    --cpu/instruction_master waited last time, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        active_and_waiting_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          active_and_waiting_last_time <= internal_cpu_instruction_master_waitrequest AND (cpu_instruction_master_read);
        end if;
      end if;

    end process;

    --cpu_instruction_master_address matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line2 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((cpu_instruction_master_address /= cpu_instruction_master_address_last_time))))) = '1' then 
          write(write_line2, now);
          write(write_line2, string'(": "));
          write(write_line2, string'("cpu_instruction_master_address did not heed wait!!!"));
          write(output, write_line2.all);
          deallocate (write_line2);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --cpu_instruction_master_read check against wait, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        cpu_instruction_master_read_last_time <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          cpu_instruction_master_read_last_time <= cpu_instruction_master_read;
        end if;
      end if;

    end process;

    --cpu_instruction_master_read matches last port_name, which is an e_process
    process (clk)
    VARIABLE write_line3 : line;
    begin
      if clk'event and clk = '1' then
        if std_logic'((active_and_waiting_last_time AND to_std_logic(((std_logic'(cpu_instruction_master_read) /= std_logic'(cpu_instruction_master_read_last_time)))))) = '1' then 
          write(write_line3, now);
          write(write_line3, string'(": "));
          write(write_line3, string'("cpu_instruction_master_read did not heed wait!!!"));
          write(output, write_line3.all);
          deallocate (write_line3);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity jtag_uart_avalon_jtag_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                 signal d1_jtag_uart_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_address : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                 signal jtag_uart_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity jtag_uart_avalon_jtag_slave_arbitrator;


architecture europa of jtag_uart_avalon_jtag_slave_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_allgrants :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_any_continuerequest :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_arb_counter_enable :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_arb_share_counter :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_arb_share_set_values :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_begins_xfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_firsttransfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_grant_vector :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_in_a_read_cycle :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_in_a_write_cycle :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_master_qreq_vector :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_non_bursting_master_requests :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_reg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_slavearbiterlockenable :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_unreg_firsttransfer :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waits_for_read :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal wait_for_jtag_uart_avalon_jtag_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT jtag_uart_avalon_jtag_slave_end_xfer;
      end if;
    end if;

  end process;

  jtag_uart_avalon_jtag_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave);
  --assign jtag_uart_avalon_jtag_slave_readdata_from_sa = jtag_uart_avalon_jtag_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_readdata_from_sa <= jtag_uart_avalon_jtag_slave_readdata;
  internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("100001000001110000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign jtag_uart_avalon_jtag_slave_dataavailable_from_sa = jtag_uart_avalon_jtag_slave_dataavailable so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_dataavailable_from_sa <= jtag_uart_avalon_jtag_slave_dataavailable;
  --assign jtag_uart_avalon_jtag_slave_readyfordata_from_sa = jtag_uart_avalon_jtag_slave_readyfordata so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_readyfordata_from_sa <= jtag_uart_avalon_jtag_slave_readyfordata;
  --assign jtag_uart_avalon_jtag_slave_waitrequest_from_sa = jtag_uart_avalon_jtag_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa <= jtag_uart_avalon_jtag_slave_waitrequest;
  --jtag_uart_avalon_jtag_slave_arb_share_counter set values, which is an e_mux
  jtag_uart_avalon_jtag_slave_arb_share_set_values <= std_logic'('1');
  --jtag_uart_avalon_jtag_slave_non_bursting_master_requests mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  --jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --jtag_uart_avalon_jtag_slave_arb_share_counter_next_value assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(jtag_uart_avalon_jtag_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(jtag_uart_avalon_jtag_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(jtag_uart_avalon_jtag_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(jtag_uart_avalon_jtag_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --jtag_uart_avalon_jtag_slave_allgrants all slave grants, which is an e_mux
  jtag_uart_avalon_jtag_slave_allgrants <= jtag_uart_avalon_jtag_slave_grant_vector;
  --jtag_uart_avalon_jtag_slave_end_xfer assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_end_xfer <= NOT ((jtag_uart_avalon_jtag_slave_waits_for_read OR jtag_uart_avalon_jtag_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave <= jtag_uart_avalon_jtag_slave_end_xfer AND (((NOT jtag_uart_avalon_jtag_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --jtag_uart_avalon_jtag_slave_arb_share_counter arbitration counter enable, which is an e_assign
  jtag_uart_avalon_jtag_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave AND jtag_uart_avalon_jtag_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave AND NOT jtag_uart_avalon_jtag_slave_non_bursting_master_requests));
  --jtag_uart_avalon_jtag_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_avalon_jtag_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_avalon_jtag_slave_arb_counter_enable) = '1' then 
        jtag_uart_avalon_jtag_slave_arb_share_counter <= jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --jtag_uart_avalon_jtag_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_avalon_jtag_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((jtag_uart_avalon_jtag_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave)) OR ((end_xfer_arb_share_counter_term_jtag_uart_avalon_jtag_slave AND NOT jtag_uart_avalon_jtag_slave_non_bursting_master_requests)))) = '1' then 
        jtag_uart_avalon_jtag_slave_slavearbiterlockenable <= jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= jtag_uart_avalon_jtag_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 <= jtag_uart_avalon_jtag_slave_arb_share_counter_next_value;
  --cpu/data_master jtag_uart/avalon_jtag_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= jtag_uart_avalon_jtag_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --jtag_uart_avalon_jtag_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  jtag_uart_avalon_jtag_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave AND NOT ((((cpu_data_master_read AND (NOT cpu_data_master_waitrequest))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --jtag_uart_avalon_jtag_slave_writedata mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  --cpu/data_master saved-grant jtag_uart/avalon_jtag_slave, which is an e_assign
  cpu_data_master_saved_grant_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  --allow new arb cycle for jtag_uart/avalon_jtag_slave, which is an e_assign
  jtag_uart_avalon_jtag_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  jtag_uart_avalon_jtag_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  jtag_uart_avalon_jtag_slave_master_qreq_vector <= std_logic'('1');
  --jtag_uart_avalon_jtag_slave_reset_n assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_reset_n <= reset_n;
  jtag_uart_avalon_jtag_slave_chipselect <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  --jtag_uart_avalon_jtag_slave_firsttransfer first transaction, which is an e_assign
  jtag_uart_avalon_jtag_slave_firsttransfer <= A_WE_StdLogic((std_logic'(jtag_uart_avalon_jtag_slave_begins_xfer) = '1'), jtag_uart_avalon_jtag_slave_unreg_firsttransfer, jtag_uart_avalon_jtag_slave_reg_firsttransfer);
  --jtag_uart_avalon_jtag_slave_unreg_firsttransfer first transaction, which is an e_assign
  jtag_uart_avalon_jtag_slave_unreg_firsttransfer <= NOT ((jtag_uart_avalon_jtag_slave_slavearbiterlockenable AND jtag_uart_avalon_jtag_slave_any_continuerequest));
  --jtag_uart_avalon_jtag_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      jtag_uart_avalon_jtag_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(jtag_uart_avalon_jtag_slave_begins_xfer) = '1' then 
        jtag_uart_avalon_jtag_slave_reg_firsttransfer <= jtag_uart_avalon_jtag_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --jtag_uart_avalon_jtag_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  jtag_uart_avalon_jtag_slave_beginbursttransfer_internal <= jtag_uart_avalon_jtag_slave_begins_xfer;
  --~jtag_uart_avalon_jtag_slave_read_n assignment, which is an e_mux
  jtag_uart_avalon_jtag_slave_read_n <= NOT ((internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_read));
  --~jtag_uart_avalon_jtag_slave_write_n assignment, which is an e_mux
  jtag_uart_avalon_jtag_slave_write_n <= NOT ((internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_write));
  shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --jtag_uart_avalon_jtag_slave_address mux, which is an e_mux
  jtag_uart_avalon_jtag_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_jtag_uart_avalon_jtag_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
  --d1_jtag_uart_avalon_jtag_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_jtag_uart_avalon_jtag_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_jtag_uart_avalon_jtag_slave_end_xfer <= jtag_uart_avalon_jtag_slave_end_xfer;
      end if;
    end if;

  end process;

  --jtag_uart_avalon_jtag_slave_waits_for_read in a cycle, which is an e_mux
  jtag_uart_avalon_jtag_slave_waits_for_read <= jtag_uart_avalon_jtag_slave_in_a_read_cycle AND internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_avalon_jtag_slave_in_a_read_cycle assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_in_a_read_cycle <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= jtag_uart_avalon_jtag_slave_in_a_read_cycle;
  --jtag_uart_avalon_jtag_slave_waits_for_write in a cycle, which is an e_mux
  jtag_uart_avalon_jtag_slave_waits_for_write <= jtag_uart_avalon_jtag_slave_in_a_write_cycle AND internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
  --jtag_uart_avalon_jtag_slave_in_a_write_cycle assignment, which is an e_assign
  jtag_uart_avalon_jtag_slave_in_a_write_cycle <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= jtag_uart_avalon_jtag_slave_in_a_write_cycle;
  wait_for_jtag_uart_avalon_jtag_slave_counter <= std_logic'('0');
  --assign jtag_uart_avalon_jtag_slave_irq_from_sa = jtag_uart_avalon_jtag_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  jtag_uart_avalon_jtag_slave_irq_from_sa <= jtag_uart_avalon_jtag_slave_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_granted_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_jtag_uart_avalon_jtag_slave <= internal_cpu_data_master_requests_jtag_uart_avalon_jtag_slave;
  --vhdl renameroo for output signals
  jtag_uart_avalon_jtag_slave_waitrequest_from_sa <= internal_jtag_uart_avalon_jtag_slave_waitrequest_from_sa;
--synthesis translate_off
    --jtag_uart/avalon_jtag_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library std;
use std.textio.all;

entity onchip_mem_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                 signal cpu_instruction_master_read : IN STD_LOGIC;
                 signal onchip_mem_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                 signal cpu_instruction_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                 signal d1_onchip_mem_s1_end_xfer : OUT STD_LOGIC;
                 signal onchip_mem_s1_address : OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
                 signal onchip_mem_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal onchip_mem_s1_chipselect : OUT STD_LOGIC;
                 signal onchip_mem_s1_clken : OUT STD_LOGIC;
                 signal onchip_mem_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal onchip_mem_s1_write : OUT STD_LOGIC;
                 signal onchip_mem_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal registered_cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC
              );
end entity onchip_mem_s1_arbitrator;


architecture europa of onchip_mem_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in :  STD_LOGIC;
                signal cpu_data_master_saved_grant_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock :  STD_LOGIC;
                signal cpu_instruction_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_instruction_master_continuerequest :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in :  STD_LOGIC;
                signal cpu_instruction_master_saved_grant_onchip_mem_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_onchip_mem_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal internal_cpu_instruction_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal internal_cpu_instruction_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal internal_cpu_instruction_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal last_cycle_cpu_data_master_granted_slave_onchip_mem_s1 :  STD_LOGIC;
                signal last_cycle_cpu_instruction_master_granted_slave_onchip_mem_s1 :  STD_LOGIC;
                signal onchip_mem_s1_allgrants :  STD_LOGIC;
                signal onchip_mem_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal onchip_mem_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal onchip_mem_s1_any_continuerequest :  STD_LOGIC;
                signal onchip_mem_s1_arb_addend :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_arb_counter_enable :  STD_LOGIC;
                signal onchip_mem_s1_arb_share_counter :  STD_LOGIC;
                signal onchip_mem_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal onchip_mem_s1_arb_share_set_values :  STD_LOGIC;
                signal onchip_mem_s1_arb_winner :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_arbitration_holdoff_internal :  STD_LOGIC;
                signal onchip_mem_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal onchip_mem_s1_begins_xfer :  STD_LOGIC;
                signal onchip_mem_s1_chosen_master_double_vector :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_mem_s1_chosen_master_rot_left :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_end_xfer :  STD_LOGIC;
                signal onchip_mem_s1_firsttransfer :  STD_LOGIC;
                signal onchip_mem_s1_grant_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_in_a_read_cycle :  STD_LOGIC;
                signal onchip_mem_s1_in_a_write_cycle :  STD_LOGIC;
                signal onchip_mem_s1_master_qreq_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_non_bursting_master_requests :  STD_LOGIC;
                signal onchip_mem_s1_reg_firsttransfer :  STD_LOGIC;
                signal onchip_mem_s1_saved_chosen_master_vector :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal onchip_mem_s1_slavearbiterlockenable :  STD_LOGIC;
                signal onchip_mem_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal onchip_mem_s1_unreg_firsttransfer :  STD_LOGIC;
                signal onchip_mem_s1_waits_for_read :  STD_LOGIC;
                signal onchip_mem_s1_waits_for_write :  STD_LOGIC;
                signal p1_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal p1_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register :  STD_LOGIC;
                signal shifted_address_to_onchip_mem_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal shifted_address_to_onchip_mem_s1_from_cpu_instruction_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal wait_for_onchip_mem_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT onchip_mem_s1_end_xfer;
      end if;
    end if;

  end process;

  onchip_mem_s1_begins_xfer <= NOT d1_reasons_to_wait AND ((internal_cpu_data_master_qualified_request_onchip_mem_s1 OR internal_cpu_instruction_master_qualified_request_onchip_mem_s1));
  --assign onchip_mem_s1_readdata_from_sa = onchip_mem_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  onchip_mem_s1_readdata_from_sa <= onchip_mem_s1_readdata;
  internal_cpu_data_master_requests_onchip_mem_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 16) & std_logic_vector'("0000000000000000")) = std_logic_vector'("010000000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --registered rdv signal_name registered_cpu_data_master_read_data_valid_onchip_mem_s1 assignment, which is an e_assign
  registered_cpu_data_master_read_data_valid_onchip_mem_s1 <= cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in;
  --onchip_mem_s1_arb_share_counter set values, which is an e_mux
  onchip_mem_s1_arb_share_set_values <= std_logic'('1');
  --onchip_mem_s1_non_bursting_master_requests mux, which is an e_mux
  onchip_mem_s1_non_bursting_master_requests <= ((internal_cpu_data_master_requests_onchip_mem_s1 OR internal_cpu_instruction_master_requests_onchip_mem_s1) OR internal_cpu_data_master_requests_onchip_mem_s1) OR internal_cpu_instruction_master_requests_onchip_mem_s1;
  --onchip_mem_s1_any_bursting_master_saved_grant mux, which is an e_mux
  onchip_mem_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --onchip_mem_s1_arb_share_counter_next_value assignment, which is an e_assign
  onchip_mem_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(onchip_mem_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_mem_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(onchip_mem_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_mem_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --onchip_mem_s1_allgrants all slave grants, which is an e_mux
  onchip_mem_s1_allgrants <= ((or_reduce(onchip_mem_s1_grant_vector) OR or_reduce(onchip_mem_s1_grant_vector)) OR or_reduce(onchip_mem_s1_grant_vector)) OR or_reduce(onchip_mem_s1_grant_vector);
  --onchip_mem_s1_end_xfer assignment, which is an e_assign
  onchip_mem_s1_end_xfer <= NOT ((onchip_mem_s1_waits_for_read OR onchip_mem_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_onchip_mem_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_onchip_mem_s1 <= onchip_mem_s1_end_xfer AND (((NOT onchip_mem_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --onchip_mem_s1_arb_share_counter arbitration counter enable, which is an e_assign
  onchip_mem_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_onchip_mem_s1 AND onchip_mem_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_onchip_mem_s1 AND NOT onchip_mem_s1_non_bursting_master_requests));
  --onchip_mem_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_mem_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_mem_s1_arb_counter_enable) = '1' then 
        onchip_mem_s1_arb_share_counter <= onchip_mem_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --onchip_mem_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_mem_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((or_reduce(onchip_mem_s1_master_qreq_vector) AND end_xfer_arb_share_counter_term_onchip_mem_s1)) OR ((end_xfer_arb_share_counter_term_onchip_mem_s1 AND NOT onchip_mem_s1_non_bursting_master_requests)))) = '1' then 
        onchip_mem_s1_slavearbiterlockenable <= onchip_mem_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master onchip_mem/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= onchip_mem_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --onchip_mem_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  onchip_mem_s1_slavearbiterlockenable2 <= onchip_mem_s1_arb_share_counter_next_value;
  --cpu/data_master onchip_mem/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= onchip_mem_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --cpu/instruction_master onchip_mem/s1 arbiterlock, which is an e_assign
  cpu_instruction_master_arbiterlock <= onchip_mem_s1_slavearbiterlockenable AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master onchip_mem/s1 arbiterlock2, which is an e_assign
  cpu_instruction_master_arbiterlock2 <= onchip_mem_s1_slavearbiterlockenable2 AND cpu_instruction_master_continuerequest;
  --cpu/instruction_master granted onchip_mem/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_instruction_master_granted_slave_onchip_mem_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_cpu_instruction_master_granted_slave_onchip_mem_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_instruction_master_saved_grant_onchip_mem_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_mem_s1_arbitration_holdoff_internal OR NOT internal_cpu_instruction_master_requests_onchip_mem_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_instruction_master_granted_slave_onchip_mem_s1))))));
      end if;
    end if;

  end process;

  --cpu_instruction_master_continuerequest continued request, which is an e_mux
  cpu_instruction_master_continuerequest <= last_cycle_cpu_instruction_master_granted_slave_onchip_mem_s1 AND internal_cpu_instruction_master_requests_onchip_mem_s1;
  --onchip_mem_s1_any_continuerequest at least one master continues requesting, which is an e_mux
  onchip_mem_s1_any_continuerequest <= cpu_instruction_master_continuerequest OR cpu_data_master_continuerequest;
  internal_cpu_data_master_qualified_request_onchip_mem_s1 <= internal_cpu_data_master_requests_onchip_mem_s1 AND NOT (((((cpu_data_master_read AND (cpu_data_master_read_data_valid_onchip_mem_s1_shift_register))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))) OR cpu_instruction_master_arbiterlock));
  --cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in <= ((internal_cpu_data_master_granted_onchip_mem_s1 AND cpu_data_master_read) AND NOT onchip_mem_s1_waits_for_read) AND NOT (cpu_data_master_read_data_valid_onchip_mem_s1_shift_register);
  --shift register p1 cpu_data_master_read_data_valid_onchip_mem_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_data_master_read_data_valid_onchip_mem_s1_shift_register) & A_ToStdLogicVector(cpu_data_master_read_data_valid_onchip_mem_s1_shift_register_in)));
  --cpu_data_master_read_data_valid_onchip_mem_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_data_master_read_data_valid_onchip_mem_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_data_master_read_data_valid_onchip_mem_s1_shift_register <= p1_cpu_data_master_read_data_valid_onchip_mem_s1_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid cpu_data_master_read_data_valid_onchip_mem_s1, which is an e_mux
  cpu_data_master_read_data_valid_onchip_mem_s1 <= cpu_data_master_read_data_valid_onchip_mem_s1_shift_register;
  --onchip_mem_s1_writedata mux, which is an e_mux
  onchip_mem_s1_writedata <= cpu_data_master_writedata;
  --mux onchip_mem_s1_clken, which is an e_mux
  onchip_mem_s1_clken <= std_logic'('1');
  internal_cpu_instruction_master_requests_onchip_mem_s1 <= ((to_std_logic(((Std_Logic_Vector'(cpu_instruction_master_address_to_slave(17 DOWNTO 16) & std_logic_vector'("0000000000000000")) = std_logic_vector'("010000000000000000")))) AND (cpu_instruction_master_read))) AND cpu_instruction_master_read;
  --cpu/data_master granted onchip_mem/s1 last time, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      last_cycle_cpu_data_master_granted_slave_onchip_mem_s1 <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        last_cycle_cpu_data_master_granted_slave_onchip_mem_s1 <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(cpu_data_master_saved_grant_onchip_mem_s1) = '1'), std_logic_vector'("00000000000000000000000000000001"), A_WE_StdLogicVector((std_logic'(((onchip_mem_s1_arbitration_holdoff_internal OR NOT internal_cpu_data_master_requests_onchip_mem_s1))) = '1'), std_logic_vector'("00000000000000000000000000000000"), (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(last_cycle_cpu_data_master_granted_slave_onchip_mem_s1))))));
      end if;
    end if;

  end process;

  --cpu_data_master_continuerequest continued request, which is an e_mux
  cpu_data_master_continuerequest <= last_cycle_cpu_data_master_granted_slave_onchip_mem_s1 AND internal_cpu_data_master_requests_onchip_mem_s1;
  internal_cpu_instruction_master_qualified_request_onchip_mem_s1 <= internal_cpu_instruction_master_requests_onchip_mem_s1 AND NOT ((((cpu_instruction_master_read AND to_std_logic(((std_logic_vector'("00000000000000000000000000000001")<(std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_latency_counter)))))))) OR cpu_data_master_arbiterlock));
  --cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in <= (internal_cpu_instruction_master_granted_onchip_mem_s1 AND cpu_instruction_master_read) AND NOT onchip_mem_s1_waits_for_read;
  --shift register p1 cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register) & A_ToStdLogicVector(cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register_in)));
  --cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register <= p1_cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid cpu_instruction_master_read_data_valid_onchip_mem_s1, which is an e_mux
  cpu_instruction_master_read_data_valid_onchip_mem_s1 <= cpu_instruction_master_read_data_valid_onchip_mem_s1_shift_register;
  --allow new arb cycle for onchip_mem/s1, which is an e_assign
  onchip_mem_s1_allow_new_arb_cycle <= NOT cpu_data_master_arbiterlock AND NOT cpu_instruction_master_arbiterlock;
  --cpu/instruction_master assignment into master qualified-requests vector for onchip_mem/s1, which is an e_assign
  onchip_mem_s1_master_qreq_vector(0) <= internal_cpu_instruction_master_qualified_request_onchip_mem_s1;
  --cpu/instruction_master grant onchip_mem/s1, which is an e_assign
  internal_cpu_instruction_master_granted_onchip_mem_s1 <= onchip_mem_s1_grant_vector(0);
  --cpu/instruction_master saved-grant onchip_mem/s1, which is an e_assign
  cpu_instruction_master_saved_grant_onchip_mem_s1 <= onchip_mem_s1_arb_winner(0) AND internal_cpu_instruction_master_requests_onchip_mem_s1;
  --cpu/data_master assignment into master qualified-requests vector for onchip_mem/s1, which is an e_assign
  onchip_mem_s1_master_qreq_vector(1) <= internal_cpu_data_master_qualified_request_onchip_mem_s1;
  --cpu/data_master grant onchip_mem/s1, which is an e_assign
  internal_cpu_data_master_granted_onchip_mem_s1 <= onchip_mem_s1_grant_vector(1);
  --cpu/data_master saved-grant onchip_mem/s1, which is an e_assign
  cpu_data_master_saved_grant_onchip_mem_s1 <= onchip_mem_s1_arb_winner(1) AND internal_cpu_data_master_requests_onchip_mem_s1;
  --onchip_mem/s1 chosen-master double-vector, which is an e_assign
  onchip_mem_s1_chosen_master_double_vector <= A_EXT (((std_logic_vector'("0") & ((onchip_mem_s1_master_qreq_vector & onchip_mem_s1_master_qreq_vector))) AND (((std_logic_vector'("0") & (Std_Logic_Vector'(NOT onchip_mem_s1_master_qreq_vector & NOT onchip_mem_s1_master_qreq_vector))) + (std_logic_vector'("000") & (onchip_mem_s1_arb_addend))))), 4);
  --stable onehot encoding of arb winner
  onchip_mem_s1_arb_winner <= A_WE_StdLogicVector((std_logic'(((onchip_mem_s1_allow_new_arb_cycle AND or_reduce(onchip_mem_s1_grant_vector)))) = '1'), onchip_mem_s1_grant_vector, onchip_mem_s1_saved_chosen_master_vector);
  --saved onchip_mem_s1_grant_vector, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_mem_s1_saved_chosen_master_vector <= std_logic_vector'("00");
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_mem_s1_allow_new_arb_cycle) = '1' then 
        onchip_mem_s1_saved_chosen_master_vector <= A_WE_StdLogicVector((std_logic'(or_reduce(onchip_mem_s1_grant_vector)) = '1'), onchip_mem_s1_grant_vector, onchip_mem_s1_saved_chosen_master_vector);
      end if;
    end if;

  end process;

  --onehot encoding of chosen master
  onchip_mem_s1_grant_vector <= Std_Logic_Vector'(A_ToStdLogicVector(((onchip_mem_s1_chosen_master_double_vector(1) OR onchip_mem_s1_chosen_master_double_vector(3)))) & A_ToStdLogicVector(((onchip_mem_s1_chosen_master_double_vector(0) OR onchip_mem_s1_chosen_master_double_vector(2)))));
  --onchip_mem/s1 chosen master rotated left, which is an e_assign
  onchip_mem_s1_chosen_master_rot_left <= A_EXT (A_WE_StdLogicVector((((A_SLL(onchip_mem_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001")))) /= std_logic_vector'("00")), (std_logic_vector'("000000000000000000000000000000") & ((A_SLL(onchip_mem_s1_arb_winner,std_logic_vector'("00000000000000000000000000000001"))))), std_logic_vector'("00000000000000000000000000000001")), 2);
  --onchip_mem/s1's addend for next-master-grant
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_mem_s1_arb_addend <= std_logic_vector'("01");
    elsif clk'event and clk = '1' then
      if std_logic'(or_reduce(onchip_mem_s1_grant_vector)) = '1' then 
        onchip_mem_s1_arb_addend <= A_WE_StdLogicVector((std_logic'(onchip_mem_s1_end_xfer) = '1'), onchip_mem_s1_chosen_master_rot_left, onchip_mem_s1_grant_vector);
      end if;
    end if;

  end process;

  onchip_mem_s1_chipselect <= internal_cpu_data_master_granted_onchip_mem_s1 OR internal_cpu_instruction_master_granted_onchip_mem_s1;
  --onchip_mem_s1_firsttransfer first transaction, which is an e_assign
  onchip_mem_s1_firsttransfer <= A_WE_StdLogic((std_logic'(onchip_mem_s1_begins_xfer) = '1'), onchip_mem_s1_unreg_firsttransfer, onchip_mem_s1_reg_firsttransfer);
  --onchip_mem_s1_unreg_firsttransfer first transaction, which is an e_assign
  onchip_mem_s1_unreg_firsttransfer <= NOT ((onchip_mem_s1_slavearbiterlockenable AND onchip_mem_s1_any_continuerequest));
  --onchip_mem_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      onchip_mem_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(onchip_mem_s1_begins_xfer) = '1' then 
        onchip_mem_s1_reg_firsttransfer <= onchip_mem_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --onchip_mem_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  onchip_mem_s1_beginbursttransfer_internal <= onchip_mem_s1_begins_xfer;
  --onchip_mem_s1_arbitration_holdoff_internal arbitration_holdoff, which is an e_assign
  onchip_mem_s1_arbitration_holdoff_internal <= onchip_mem_s1_begins_xfer AND onchip_mem_s1_firsttransfer;
  --onchip_mem_s1_write assignment, which is an e_mux
  onchip_mem_s1_write <= internal_cpu_data_master_granted_onchip_mem_s1 AND cpu_data_master_write;
  shifted_address_to_onchip_mem_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --onchip_mem_s1_address mux, which is an e_mux
  onchip_mem_s1_address <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_onchip_mem_s1)) = '1'), (A_SRL(shifted_address_to_onchip_mem_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010"))), (A_SRL(shifted_address_to_onchip_mem_s1_from_cpu_instruction_master,std_logic_vector'("00000000000000000000000000000010")))), 14);
  shifted_address_to_onchip_mem_s1_from_cpu_instruction_master <= cpu_instruction_master_address_to_slave;
  --d1_onchip_mem_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_onchip_mem_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_onchip_mem_s1_end_xfer <= onchip_mem_s1_end_xfer;
      end if;
    end if;

  end process;

  --onchip_mem_s1_waits_for_read in a cycle, which is an e_mux
  onchip_mem_s1_waits_for_read <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_mem_s1_in_a_read_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_mem_s1_in_a_read_cycle assignment, which is an e_assign
  onchip_mem_s1_in_a_read_cycle <= ((internal_cpu_data_master_granted_onchip_mem_s1 AND cpu_data_master_read)) OR ((internal_cpu_instruction_master_granted_onchip_mem_s1 AND cpu_instruction_master_read));
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= onchip_mem_s1_in_a_read_cycle;
  --onchip_mem_s1_waits_for_write in a cycle, which is an e_mux
  onchip_mem_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(onchip_mem_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --onchip_mem_s1_in_a_write_cycle assignment, which is an e_assign
  onchip_mem_s1_in_a_write_cycle <= internal_cpu_data_master_granted_onchip_mem_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= onchip_mem_s1_in_a_write_cycle;
  wait_for_onchip_mem_s1_counter <= std_logic'('0');
  --onchip_mem_s1_byteenable byte enable port mux, which is an e_mux
  onchip_mem_s1_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_onchip_mem_s1)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --vhdl renameroo for output signals
  cpu_data_master_granted_onchip_mem_s1 <= internal_cpu_data_master_granted_onchip_mem_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_onchip_mem_s1 <= internal_cpu_data_master_qualified_request_onchip_mem_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_onchip_mem_s1 <= internal_cpu_data_master_requests_onchip_mem_s1;
  --vhdl renameroo for output signals
  cpu_instruction_master_granted_onchip_mem_s1 <= internal_cpu_instruction_master_granted_onchip_mem_s1;
  --vhdl renameroo for output signals
  cpu_instruction_master_qualified_request_onchip_mem_s1 <= internal_cpu_instruction_master_qualified_request_onchip_mem_s1;
  --vhdl renameroo for output signals
  cpu_instruction_master_requests_onchip_mem_s1 <= internal_cpu_instruction_master_requests_onchip_mem_s1;
--synthesis translate_off
    --onchip_mem/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

    --grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line4 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_data_master_granted_onchip_mem_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(internal_cpu_instruction_master_granted_onchip_mem_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line4, now);
          write(write_line4, string'(": "));
          write(write_line4, string'("> 1 of grant signals are active simultaneously"));
          write(output, write_line4.all);
          deallocate (write_line4);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

    --saved_grant signals are active simultaneously, which is an e_process
    process (clk)
    VARIABLE write_line5 : line;
    begin
      if clk'event and clk = '1' then
        if (std_logic_vector'("000000000000000000000000000000") & (((std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_data_master_saved_grant_onchip_mem_s1))) + (std_logic_vector'("0") & (A_TOSTDLOGICVECTOR(cpu_instruction_master_saved_grant_onchip_mem_s1))))))>std_logic_vector'("00000000000000000000000000000001") then 
          write(write_line5, now);
          write(write_line5, string'(": "));
          write(write_line5, string'("> 1 of saved_grant signals are active simultaneously"));
          write(output, write_line5.all);
          deallocate (write_line5);
          assert false report "VHDL STOP" severity failure;
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ps2_keyboard_avalon_PS2_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ps2_keyboard_avalon_PS2_slave_irq : IN STD_LOGIC;
                 signal ps2_keyboard_avalon_PS2_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ps2_keyboard_avalon_PS2_slave_waitrequest : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- outputs:
                 signal cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave : OUT STD_LOGIC;
                 signal d1_ps2_keyboard_avalon_PS2_slave_end_xfer : OUT STD_LOGIC;
                 signal ps2_keyboard_avalon_PS2_slave_address : OUT STD_LOGIC;
                 signal ps2_keyboard_avalon_PS2_slave_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                 signal ps2_keyboard_avalon_PS2_slave_chipselect : OUT STD_LOGIC;
                 signal ps2_keyboard_avalon_PS2_slave_irq_from_sa : OUT STD_LOGIC;
                 signal ps2_keyboard_avalon_PS2_slave_read : OUT STD_LOGIC;
                 signal ps2_keyboard_avalon_PS2_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa : OUT STD_LOGIC;
                 signal ps2_keyboard_avalon_PS2_slave_write : OUT STD_LOGIC;
                 signal ps2_keyboard_avalon_PS2_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave : OUT STD_LOGIC
              );
end entity ps2_keyboard_avalon_PS2_slave_arbitrator;


architecture europa of ps2_keyboard_avalon_PS2_slave_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register_in :  STD_LOGIC;
                signal cpu_data_master_saved_grant_ps2_keyboard_avalon_PS2_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_ps2_keyboard_avalon_PS2_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave :  STD_LOGIC;
                signal internal_ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa :  STD_LOGIC;
                signal p1_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_allgrants :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_any_continuerequest :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_arb_counter_enable :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_arb_share_counter :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_arb_share_set_values :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_begins_xfer :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_end_xfer :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_firsttransfer :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_grant_vector :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_in_a_read_cycle :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_in_a_write_cycle :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_master_qreq_vector :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_non_bursting_master_requests :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_reg_firsttransfer :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_slavearbiterlockenable :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_unreg_firsttransfer :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_waits_for_read :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_waits_for_write :  STD_LOGIC;
                signal shifted_address_to_ps2_keyboard_avalon_PS2_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal wait_for_ps2_keyboard_avalon_PS2_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT ps2_keyboard_avalon_PS2_slave_end_xfer;
      end if;
    end if;

  end process;

  ps2_keyboard_avalon_PS2_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave);
  --assign ps2_keyboard_avalon_PS2_slave_readdata_from_sa = ps2_keyboard_avalon_PS2_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_readdata_from_sa <= ps2_keyboard_avalon_PS2_slave_readdata;
  internal_cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("100001000010000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --assign ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa = ps2_keyboard_avalon_PS2_slave_waitrequest so that symbol knows where to group signals which may go to master only, which is an e_assign
  internal_ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa <= ps2_keyboard_avalon_PS2_slave_waitrequest;
  --registered rdv signal_name registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave assignment, which is an e_assign
  registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave <= cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register_in;
  --ps2_keyboard_avalon_PS2_slave_arb_share_counter set values, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_arb_share_set_values <= std_logic'('1');
  --ps2_keyboard_avalon_PS2_slave_non_bursting_master_requests mux, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave;
  --ps2_keyboard_avalon_PS2_slave_any_bursting_master_saved_grant mux, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --ps2_keyboard_avalon_PS2_slave_arb_share_counter_next_value assignment, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(ps2_keyboard_avalon_PS2_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ps2_keyboard_avalon_PS2_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(ps2_keyboard_avalon_PS2_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(ps2_keyboard_avalon_PS2_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --ps2_keyboard_avalon_PS2_slave_allgrants all slave grants, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_allgrants <= ps2_keyboard_avalon_PS2_slave_grant_vector;
  --ps2_keyboard_avalon_PS2_slave_end_xfer assignment, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_end_xfer <= NOT ((ps2_keyboard_avalon_PS2_slave_waits_for_read OR ps2_keyboard_avalon_PS2_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_ps2_keyboard_avalon_PS2_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_ps2_keyboard_avalon_PS2_slave <= ps2_keyboard_avalon_PS2_slave_end_xfer AND (((NOT ps2_keyboard_avalon_PS2_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --ps2_keyboard_avalon_PS2_slave_arb_share_counter arbitration counter enable, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_ps2_keyboard_avalon_PS2_slave AND ps2_keyboard_avalon_PS2_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_ps2_keyboard_avalon_PS2_slave AND NOT ps2_keyboard_avalon_PS2_slave_non_bursting_master_requests));
  --ps2_keyboard_avalon_PS2_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ps2_keyboard_avalon_PS2_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(ps2_keyboard_avalon_PS2_slave_arb_counter_enable) = '1' then 
        ps2_keyboard_avalon_PS2_slave_arb_share_counter <= ps2_keyboard_avalon_PS2_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --ps2_keyboard_avalon_PS2_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ps2_keyboard_avalon_PS2_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((ps2_keyboard_avalon_PS2_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_ps2_keyboard_avalon_PS2_slave)) OR ((end_xfer_arb_share_counter_term_ps2_keyboard_avalon_PS2_slave AND NOT ps2_keyboard_avalon_PS2_slave_non_bursting_master_requests)))) = '1' then 
        ps2_keyboard_avalon_PS2_slave_slavearbiterlockenable <= ps2_keyboard_avalon_PS2_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master ps2_keyboard/avalon_PS2_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= ps2_keyboard_avalon_PS2_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --ps2_keyboard_avalon_PS2_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_slavearbiterlockenable2 <= ps2_keyboard_avalon_PS2_slave_arb_share_counter_next_value;
  --cpu/data_master ps2_keyboard/avalon_PS2_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= ps2_keyboard_avalon_PS2_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --ps2_keyboard_avalon_PS2_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave <= internal_cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave AND NOT ((((cpu_data_master_read AND (cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register))) OR (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write))));
  --cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register_in mux for readlatency shift register, which is an e_mux
  cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register_in <= ((internal_cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave AND cpu_data_master_read) AND NOT ps2_keyboard_avalon_PS2_slave_waits_for_read) AND NOT (cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register);
  --shift register p1 cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register in if flush, otherwise shift left, which is an e_mux
  p1_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register <= Vector_To_Std_Logic(Std_Logic_Vector'(A_ToStdLogicVector(cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register) & A_ToStdLogicVector(cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register_in)));
  --cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register for remembering which master asked for a fixed latency read, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register <= p1_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register;
      end if;
    end if;

  end process;

  --local readdatavalid cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave, which is an e_mux
  cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave <= cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave_shift_register;
  --ps2_keyboard_avalon_PS2_slave_writedata mux, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_writedata <= cpu_data_master_writedata;
  --master is always granted when requested
  internal_cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave <= internal_cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave;
  --cpu/data_master saved-grant ps2_keyboard/avalon_PS2_slave, which is an e_assign
  cpu_data_master_saved_grant_ps2_keyboard_avalon_PS2_slave <= internal_cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave;
  --allow new arb cycle for ps2_keyboard/avalon_PS2_slave, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  ps2_keyboard_avalon_PS2_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  ps2_keyboard_avalon_PS2_slave_master_qreq_vector <= std_logic'('1');
  ps2_keyboard_avalon_PS2_slave_chipselect <= internal_cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave;
  --ps2_keyboard_avalon_PS2_slave_firsttransfer first transaction, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_firsttransfer <= A_WE_StdLogic((std_logic'(ps2_keyboard_avalon_PS2_slave_begins_xfer) = '1'), ps2_keyboard_avalon_PS2_slave_unreg_firsttransfer, ps2_keyboard_avalon_PS2_slave_reg_firsttransfer);
  --ps2_keyboard_avalon_PS2_slave_unreg_firsttransfer first transaction, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_unreg_firsttransfer <= NOT ((ps2_keyboard_avalon_PS2_slave_slavearbiterlockenable AND ps2_keyboard_avalon_PS2_slave_any_continuerequest));
  --ps2_keyboard_avalon_PS2_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      ps2_keyboard_avalon_PS2_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(ps2_keyboard_avalon_PS2_slave_begins_xfer) = '1' then 
        ps2_keyboard_avalon_PS2_slave_reg_firsttransfer <= ps2_keyboard_avalon_PS2_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --ps2_keyboard_avalon_PS2_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_beginbursttransfer_internal <= ps2_keyboard_avalon_PS2_slave_begins_xfer;
  --ps2_keyboard_avalon_PS2_slave_read assignment, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_read <= internal_cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave AND cpu_data_master_read;
  --ps2_keyboard_avalon_PS2_slave_write assignment, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_write <= internal_cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave AND cpu_data_master_write;
  shifted_address_to_ps2_keyboard_avalon_PS2_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --ps2_keyboard_avalon_PS2_slave_address mux, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_ps2_keyboard_avalon_PS2_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
  --d1_ps2_keyboard_avalon_PS2_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_ps2_keyboard_avalon_PS2_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_ps2_keyboard_avalon_PS2_slave_end_xfer <= ps2_keyboard_avalon_PS2_slave_end_xfer;
      end if;
    end if;

  end process;

  --ps2_keyboard_avalon_PS2_slave_waits_for_read in a cycle, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_waits_for_read <= ps2_keyboard_avalon_PS2_slave_in_a_read_cycle AND internal_ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa;
  --ps2_keyboard_avalon_PS2_slave_in_a_read_cycle assignment, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_in_a_read_cycle <= internal_cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= ps2_keyboard_avalon_PS2_slave_in_a_read_cycle;
  --ps2_keyboard_avalon_PS2_slave_waits_for_write in a cycle, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_waits_for_write <= ps2_keyboard_avalon_PS2_slave_in_a_write_cycle AND internal_ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa;
  --ps2_keyboard_avalon_PS2_slave_in_a_write_cycle assignment, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_in_a_write_cycle <= internal_cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= ps2_keyboard_avalon_PS2_slave_in_a_write_cycle;
  wait_for_ps2_keyboard_avalon_PS2_slave_counter <= std_logic'('0');
  --ps2_keyboard_avalon_PS2_slave_byteenable byte enable port mux, which is an e_mux
  ps2_keyboard_avalon_PS2_slave_byteenable <= A_EXT (A_WE_StdLogicVector((std_logic'((internal_cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave)) = '1'), (std_logic_vector'("0000000000000000000000000000") & (cpu_data_master_byteenable)), -SIGNED(std_logic_vector'("00000000000000000000000000000001"))), 4);
  --assign ps2_keyboard_avalon_PS2_slave_irq_from_sa = ps2_keyboard_avalon_PS2_slave_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  ps2_keyboard_avalon_PS2_slave_irq_from_sa <= ps2_keyboard_avalon_PS2_slave_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave <= internal_cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave <= internal_cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave <= internal_cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave;
  --vhdl renameroo for output signals
  ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa <= internal_ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa;
--synthesis translate_off
    --ps2_keyboard/avalon_PS2_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sys_clk_timer_s1_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_waitrequest : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                 signal reset_n : IN STD_LOGIC;
                 signal sys_clk_timer_s1_irq : IN STD_LOGIC;
                 signal sys_clk_timer_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- outputs:
                 signal cpu_data_master_granted_sys_clk_timer_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_sys_clk_timer_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_sys_clk_timer_s1 : OUT STD_LOGIC;
                 signal cpu_data_master_requests_sys_clk_timer_s1 : OUT STD_LOGIC;
                 signal d1_sys_clk_timer_s1_end_xfer : OUT STD_LOGIC;
                 signal sys_clk_timer_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                 signal sys_clk_timer_s1_chipselect : OUT STD_LOGIC;
                 signal sys_clk_timer_s1_irq_from_sa : OUT STD_LOGIC;
                 signal sys_clk_timer_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                 signal sys_clk_timer_s1_reset_n : OUT STD_LOGIC;
                 signal sys_clk_timer_s1_write_n : OUT STD_LOGIC;
                 signal sys_clk_timer_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
              );
end entity sys_clk_timer_s1_arbitrator;


architecture europa of sys_clk_timer_s1_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_sys_clk_timer_s1 :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sys_clk_timer_s1 :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_sys_clk_timer_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_sys_clk_timer_s1 :  STD_LOGIC;
                signal internal_cpu_data_master_requests_sys_clk_timer_s1 :  STD_LOGIC;
                signal shifted_address_to_sys_clk_timer_s1_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal sys_clk_timer_s1_allgrants :  STD_LOGIC;
                signal sys_clk_timer_s1_allow_new_arb_cycle :  STD_LOGIC;
                signal sys_clk_timer_s1_any_bursting_master_saved_grant :  STD_LOGIC;
                signal sys_clk_timer_s1_any_continuerequest :  STD_LOGIC;
                signal sys_clk_timer_s1_arb_counter_enable :  STD_LOGIC;
                signal sys_clk_timer_s1_arb_share_counter :  STD_LOGIC;
                signal sys_clk_timer_s1_arb_share_counter_next_value :  STD_LOGIC;
                signal sys_clk_timer_s1_arb_share_set_values :  STD_LOGIC;
                signal sys_clk_timer_s1_beginbursttransfer_internal :  STD_LOGIC;
                signal sys_clk_timer_s1_begins_xfer :  STD_LOGIC;
                signal sys_clk_timer_s1_end_xfer :  STD_LOGIC;
                signal sys_clk_timer_s1_firsttransfer :  STD_LOGIC;
                signal sys_clk_timer_s1_grant_vector :  STD_LOGIC;
                signal sys_clk_timer_s1_in_a_read_cycle :  STD_LOGIC;
                signal sys_clk_timer_s1_in_a_write_cycle :  STD_LOGIC;
                signal sys_clk_timer_s1_master_qreq_vector :  STD_LOGIC;
                signal sys_clk_timer_s1_non_bursting_master_requests :  STD_LOGIC;
                signal sys_clk_timer_s1_reg_firsttransfer :  STD_LOGIC;
                signal sys_clk_timer_s1_slavearbiterlockenable :  STD_LOGIC;
                signal sys_clk_timer_s1_slavearbiterlockenable2 :  STD_LOGIC;
                signal sys_clk_timer_s1_unreg_firsttransfer :  STD_LOGIC;
                signal sys_clk_timer_s1_waits_for_read :  STD_LOGIC;
                signal sys_clk_timer_s1_waits_for_write :  STD_LOGIC;
                signal wait_for_sys_clk_timer_s1_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT sys_clk_timer_s1_end_xfer;
      end if;
    end if;

  end process;

  sys_clk_timer_s1_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_sys_clk_timer_s1);
  --assign sys_clk_timer_s1_readdata_from_sa = sys_clk_timer_s1_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sys_clk_timer_s1_readdata_from_sa <= sys_clk_timer_s1_readdata;
  internal_cpu_data_master_requests_sys_clk_timer_s1 <= to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 5) & std_logic_vector'("00000")) = std_logic_vector'("100001000000000000")))) AND ((cpu_data_master_read OR cpu_data_master_write));
  --sys_clk_timer_s1_arb_share_counter set values, which is an e_mux
  sys_clk_timer_s1_arb_share_set_values <= std_logic'('1');
  --sys_clk_timer_s1_non_bursting_master_requests mux, which is an e_mux
  sys_clk_timer_s1_non_bursting_master_requests <= internal_cpu_data_master_requests_sys_clk_timer_s1;
  --sys_clk_timer_s1_any_bursting_master_saved_grant mux, which is an e_mux
  sys_clk_timer_s1_any_bursting_master_saved_grant <= std_logic'('0');
  --sys_clk_timer_s1_arb_share_counter_next_value assignment, which is an e_assign
  sys_clk_timer_s1_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(sys_clk_timer_s1_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sys_clk_timer_s1_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(sys_clk_timer_s1_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sys_clk_timer_s1_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --sys_clk_timer_s1_allgrants all slave grants, which is an e_mux
  sys_clk_timer_s1_allgrants <= sys_clk_timer_s1_grant_vector;
  --sys_clk_timer_s1_end_xfer assignment, which is an e_assign
  sys_clk_timer_s1_end_xfer <= NOT ((sys_clk_timer_s1_waits_for_read OR sys_clk_timer_s1_waits_for_write));
  --end_xfer_arb_share_counter_term_sys_clk_timer_s1 arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_sys_clk_timer_s1 <= sys_clk_timer_s1_end_xfer AND (((NOT sys_clk_timer_s1_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --sys_clk_timer_s1_arb_share_counter arbitration counter enable, which is an e_assign
  sys_clk_timer_s1_arb_counter_enable <= ((end_xfer_arb_share_counter_term_sys_clk_timer_s1 AND sys_clk_timer_s1_allgrants)) OR ((end_xfer_arb_share_counter_term_sys_clk_timer_s1 AND NOT sys_clk_timer_s1_non_bursting_master_requests));
  --sys_clk_timer_s1_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sys_clk_timer_s1_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(sys_clk_timer_s1_arb_counter_enable) = '1' then 
        sys_clk_timer_s1_arb_share_counter <= sys_clk_timer_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --sys_clk_timer_s1_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sys_clk_timer_s1_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((sys_clk_timer_s1_master_qreq_vector AND end_xfer_arb_share_counter_term_sys_clk_timer_s1)) OR ((end_xfer_arb_share_counter_term_sys_clk_timer_s1 AND NOT sys_clk_timer_s1_non_bursting_master_requests)))) = '1' then 
        sys_clk_timer_s1_slavearbiterlockenable <= sys_clk_timer_s1_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master sys_clk_timer/s1 arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= sys_clk_timer_s1_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --sys_clk_timer_s1_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sys_clk_timer_s1_slavearbiterlockenable2 <= sys_clk_timer_s1_arb_share_counter_next_value;
  --cpu/data_master sys_clk_timer/s1 arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= sys_clk_timer_s1_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --sys_clk_timer_s1_any_continuerequest at least one master continues requesting, which is an e_assign
  sys_clk_timer_s1_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_sys_clk_timer_s1 <= internal_cpu_data_master_requests_sys_clk_timer_s1 AND NOT (((NOT cpu_data_master_waitrequest) AND cpu_data_master_write));
  --sys_clk_timer_s1_writedata mux, which is an e_mux
  sys_clk_timer_s1_writedata <= cpu_data_master_writedata (15 DOWNTO 0);
  --master is always granted when requested
  internal_cpu_data_master_granted_sys_clk_timer_s1 <= internal_cpu_data_master_qualified_request_sys_clk_timer_s1;
  --cpu/data_master saved-grant sys_clk_timer/s1, which is an e_assign
  cpu_data_master_saved_grant_sys_clk_timer_s1 <= internal_cpu_data_master_requests_sys_clk_timer_s1;
  --allow new arb cycle for sys_clk_timer/s1, which is an e_assign
  sys_clk_timer_s1_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  sys_clk_timer_s1_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  sys_clk_timer_s1_master_qreq_vector <= std_logic'('1');
  --sys_clk_timer_s1_reset_n assignment, which is an e_assign
  sys_clk_timer_s1_reset_n <= reset_n;
  sys_clk_timer_s1_chipselect <= internal_cpu_data_master_granted_sys_clk_timer_s1;
  --sys_clk_timer_s1_firsttransfer first transaction, which is an e_assign
  sys_clk_timer_s1_firsttransfer <= A_WE_StdLogic((std_logic'(sys_clk_timer_s1_begins_xfer) = '1'), sys_clk_timer_s1_unreg_firsttransfer, sys_clk_timer_s1_reg_firsttransfer);
  --sys_clk_timer_s1_unreg_firsttransfer first transaction, which is an e_assign
  sys_clk_timer_s1_unreg_firsttransfer <= NOT ((sys_clk_timer_s1_slavearbiterlockenable AND sys_clk_timer_s1_any_continuerequest));
  --sys_clk_timer_s1_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sys_clk_timer_s1_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(sys_clk_timer_s1_begins_xfer) = '1' then 
        sys_clk_timer_s1_reg_firsttransfer <= sys_clk_timer_s1_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --sys_clk_timer_s1_beginbursttransfer_internal begin burst transfer, which is an e_assign
  sys_clk_timer_s1_beginbursttransfer_internal <= sys_clk_timer_s1_begins_xfer;
  --~sys_clk_timer_s1_write_n assignment, which is an e_mux
  sys_clk_timer_s1_write_n <= NOT ((internal_cpu_data_master_granted_sys_clk_timer_s1 AND cpu_data_master_write));
  shifted_address_to_sys_clk_timer_s1_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --sys_clk_timer_s1_address mux, which is an e_mux
  sys_clk_timer_s1_address <= A_EXT (A_SRL(shifted_address_to_sys_clk_timer_s1_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")), 3);
  --d1_sys_clk_timer_s1_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_sys_clk_timer_s1_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_sys_clk_timer_s1_end_xfer <= sys_clk_timer_s1_end_xfer;
      end if;
    end if;

  end process;

  --sys_clk_timer_s1_waits_for_read in a cycle, which is an e_mux
  sys_clk_timer_s1_waits_for_read <= sys_clk_timer_s1_in_a_read_cycle AND sys_clk_timer_s1_begins_xfer;
  --sys_clk_timer_s1_in_a_read_cycle assignment, which is an e_assign
  sys_clk_timer_s1_in_a_read_cycle <= internal_cpu_data_master_granted_sys_clk_timer_s1 AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sys_clk_timer_s1_in_a_read_cycle;
  --sys_clk_timer_s1_waits_for_write in a cycle, which is an e_mux
  sys_clk_timer_s1_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sys_clk_timer_s1_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --sys_clk_timer_s1_in_a_write_cycle assignment, which is an e_assign
  sys_clk_timer_s1_in_a_write_cycle <= internal_cpu_data_master_granted_sys_clk_timer_s1 AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sys_clk_timer_s1_in_a_write_cycle;
  wait_for_sys_clk_timer_s1_counter <= std_logic'('0');
  --assign sys_clk_timer_s1_irq_from_sa = sys_clk_timer_s1_irq so that symbol knows where to group signals which may go to master only, which is an e_assign
  sys_clk_timer_s1_irq_from_sa <= sys_clk_timer_s1_irq;
  --vhdl renameroo for output signals
  cpu_data_master_granted_sys_clk_timer_s1 <= internal_cpu_data_master_granted_sys_clk_timer_s1;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_sys_clk_timer_s1 <= internal_cpu_data_master_qualified_request_sys_clk_timer_s1;
  --vhdl renameroo for output signals
  cpu_data_master_requests_sys_clk_timer_s1 <= internal_cpu_data_master_requests_sys_clk_timer_s1;
--synthesis translate_off
    --sys_clk_timer/s1 enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity sysid_control_slave_arbitrator is 
        port (
              -- inputs:
                 signal clk : IN STD_LOGIC;
                 signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                 signal cpu_data_master_read : IN STD_LOGIC;
                 signal cpu_data_master_write : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;
                 signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

              -- outputs:
                 signal cpu_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                 signal cpu_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                 signal cpu_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                 signal cpu_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
                 signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                 signal sysid_control_slave_address : OUT STD_LOGIC;
                 signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
              );
end entity sysid_control_slave_arbitrator;


architecture europa of sysid_control_slave_arbitrator is
                signal cpu_data_master_arbiterlock :  STD_LOGIC;
                signal cpu_data_master_arbiterlock2 :  STD_LOGIC;
                signal cpu_data_master_continuerequest :  STD_LOGIC;
                signal cpu_data_master_saved_grant_sysid_control_slave :  STD_LOGIC;
                signal d1_reasons_to_wait :  STD_LOGIC;
                signal enable_nonzero_assertions :  STD_LOGIC;
                signal end_xfer_arb_share_counter_term_sysid_control_slave :  STD_LOGIC;
                signal in_a_read_cycle :  STD_LOGIC;
                signal in_a_write_cycle :  STD_LOGIC;
                signal internal_cpu_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal internal_cpu_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal internal_cpu_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal shifted_address_to_sysid_control_slave_from_cpu_data_master :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal sysid_control_slave_allgrants :  STD_LOGIC;
                signal sysid_control_slave_allow_new_arb_cycle :  STD_LOGIC;
                signal sysid_control_slave_any_bursting_master_saved_grant :  STD_LOGIC;
                signal sysid_control_slave_any_continuerequest :  STD_LOGIC;
                signal sysid_control_slave_arb_counter_enable :  STD_LOGIC;
                signal sysid_control_slave_arb_share_counter :  STD_LOGIC;
                signal sysid_control_slave_arb_share_counter_next_value :  STD_LOGIC;
                signal sysid_control_slave_arb_share_set_values :  STD_LOGIC;
                signal sysid_control_slave_beginbursttransfer_internal :  STD_LOGIC;
                signal sysid_control_slave_begins_xfer :  STD_LOGIC;
                signal sysid_control_slave_end_xfer :  STD_LOGIC;
                signal sysid_control_slave_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_grant_vector :  STD_LOGIC;
                signal sysid_control_slave_in_a_read_cycle :  STD_LOGIC;
                signal sysid_control_slave_in_a_write_cycle :  STD_LOGIC;
                signal sysid_control_slave_master_qreq_vector :  STD_LOGIC;
                signal sysid_control_slave_non_bursting_master_requests :  STD_LOGIC;
                signal sysid_control_slave_reg_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_slavearbiterlockenable :  STD_LOGIC;
                signal sysid_control_slave_slavearbiterlockenable2 :  STD_LOGIC;
                signal sysid_control_slave_unreg_firsttransfer :  STD_LOGIC;
                signal sysid_control_slave_waits_for_read :  STD_LOGIC;
                signal sysid_control_slave_waits_for_write :  STD_LOGIC;
                signal wait_for_sysid_control_slave_counter :  STD_LOGIC;

begin

  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_reasons_to_wait <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_reasons_to_wait <= NOT sysid_control_slave_end_xfer;
      end if;
    end if;

  end process;

  sysid_control_slave_begins_xfer <= NOT d1_reasons_to_wait AND (internal_cpu_data_master_qualified_request_sysid_control_slave);
  --assign sysid_control_slave_readdata_from_sa = sysid_control_slave_readdata so that symbol knows where to group signals which may go to master only, which is an e_assign
  sysid_control_slave_readdata_from_sa <= sysid_control_slave_readdata;
  internal_cpu_data_master_requests_sysid_control_slave <= ((to_std_logic(((Std_Logic_Vector'(cpu_data_master_address_to_slave(17 DOWNTO 3) & std_logic_vector'("000")) = std_logic_vector'("100001000001111000")))) AND ((cpu_data_master_read OR cpu_data_master_write)))) AND cpu_data_master_read;
  --sysid_control_slave_arb_share_counter set values, which is an e_mux
  sysid_control_slave_arb_share_set_values <= std_logic'('1');
  --sysid_control_slave_non_bursting_master_requests mux, which is an e_mux
  sysid_control_slave_non_bursting_master_requests <= internal_cpu_data_master_requests_sysid_control_slave;
  --sysid_control_slave_any_bursting_master_saved_grant mux, which is an e_mux
  sysid_control_slave_any_bursting_master_saved_grant <= std_logic'('0');
  --sysid_control_slave_arb_share_counter_next_value assignment, which is an e_assign
  sysid_control_slave_arb_share_counter_next_value <= Vector_To_Std_Logic(A_WE_StdLogicVector((std_logic'(sysid_control_slave_firsttransfer) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_arb_share_set_values))) - std_logic_vector'("000000000000000000000000000000001"))), A_WE_StdLogicVector((std_logic'(sysid_control_slave_arb_share_counter) = '1'), (((std_logic_vector'("00000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_arb_share_counter))) - std_logic_vector'("000000000000000000000000000000001"))), std_logic_vector'("000000000000000000000000000000000"))));
  --sysid_control_slave_allgrants all slave grants, which is an e_mux
  sysid_control_slave_allgrants <= sysid_control_slave_grant_vector;
  --sysid_control_slave_end_xfer assignment, which is an e_assign
  sysid_control_slave_end_xfer <= NOT ((sysid_control_slave_waits_for_read OR sysid_control_slave_waits_for_write));
  --end_xfer_arb_share_counter_term_sysid_control_slave arb share counter enable term, which is an e_assign
  end_xfer_arb_share_counter_term_sysid_control_slave <= sysid_control_slave_end_xfer AND (((NOT sysid_control_slave_any_bursting_master_saved_grant OR in_a_read_cycle) OR in_a_write_cycle));
  --sysid_control_slave_arb_share_counter arbitration counter enable, which is an e_assign
  sysid_control_slave_arb_counter_enable <= ((end_xfer_arb_share_counter_term_sysid_control_slave AND sysid_control_slave_allgrants)) OR ((end_xfer_arb_share_counter_term_sysid_control_slave AND NOT sysid_control_slave_non_bursting_master_requests));
  --sysid_control_slave_arb_share_counter counter, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_arb_share_counter <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'(sysid_control_slave_arb_counter_enable) = '1' then 
        sysid_control_slave_arb_share_counter <= sysid_control_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --sysid_control_slave_slavearbiterlockenable slave enables arbiterlock, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_slavearbiterlockenable <= std_logic'('0');
    elsif clk'event and clk = '1' then
      if std_logic'((((sysid_control_slave_master_qreq_vector AND end_xfer_arb_share_counter_term_sysid_control_slave)) OR ((end_xfer_arb_share_counter_term_sysid_control_slave AND NOT sysid_control_slave_non_bursting_master_requests)))) = '1' then 
        sysid_control_slave_slavearbiterlockenable <= sysid_control_slave_arb_share_counter_next_value;
      end if;
    end if;

  end process;

  --cpu/data_master sysid/control_slave arbiterlock, which is an e_assign
  cpu_data_master_arbiterlock <= sysid_control_slave_slavearbiterlockenable AND cpu_data_master_continuerequest;
  --sysid_control_slave_slavearbiterlockenable2 slave enables arbiterlock2, which is an e_assign
  sysid_control_slave_slavearbiterlockenable2 <= sysid_control_slave_arb_share_counter_next_value;
  --cpu/data_master sysid/control_slave arbiterlock2, which is an e_assign
  cpu_data_master_arbiterlock2 <= sysid_control_slave_slavearbiterlockenable2 AND cpu_data_master_continuerequest;
  --sysid_control_slave_any_continuerequest at least one master continues requesting, which is an e_assign
  sysid_control_slave_any_continuerequest <= std_logic'('1');
  --cpu_data_master_continuerequest continued request, which is an e_assign
  cpu_data_master_continuerequest <= std_logic'('1');
  internal_cpu_data_master_qualified_request_sysid_control_slave <= internal_cpu_data_master_requests_sysid_control_slave;
  --master is always granted when requested
  internal_cpu_data_master_granted_sysid_control_slave <= internal_cpu_data_master_qualified_request_sysid_control_slave;
  --cpu/data_master saved-grant sysid/control_slave, which is an e_assign
  cpu_data_master_saved_grant_sysid_control_slave <= internal_cpu_data_master_requests_sysid_control_slave;
  --allow new arb cycle for sysid/control_slave, which is an e_assign
  sysid_control_slave_allow_new_arb_cycle <= std_logic'('1');
  --placeholder chosen master
  sysid_control_slave_grant_vector <= std_logic'('1');
  --placeholder vector of master qualified-requests
  sysid_control_slave_master_qreq_vector <= std_logic'('1');
  --sysid_control_slave_firsttransfer first transaction, which is an e_assign
  sysid_control_slave_firsttransfer <= A_WE_StdLogic((std_logic'(sysid_control_slave_begins_xfer) = '1'), sysid_control_slave_unreg_firsttransfer, sysid_control_slave_reg_firsttransfer);
  --sysid_control_slave_unreg_firsttransfer first transaction, which is an e_assign
  sysid_control_slave_unreg_firsttransfer <= NOT ((sysid_control_slave_slavearbiterlockenable AND sysid_control_slave_any_continuerequest));
  --sysid_control_slave_reg_firsttransfer first transaction, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      sysid_control_slave_reg_firsttransfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if std_logic'(sysid_control_slave_begins_xfer) = '1' then 
        sysid_control_slave_reg_firsttransfer <= sysid_control_slave_unreg_firsttransfer;
      end if;
    end if;

  end process;

  --sysid_control_slave_beginbursttransfer_internal begin burst transfer, which is an e_assign
  sysid_control_slave_beginbursttransfer_internal <= sysid_control_slave_begins_xfer;
  shifted_address_to_sysid_control_slave_from_cpu_data_master <= cpu_data_master_address_to_slave;
  --sysid_control_slave_address mux, which is an e_mux
  sysid_control_slave_address <= Vector_To_Std_Logic(A_SRL(shifted_address_to_sysid_control_slave_from_cpu_data_master,std_logic_vector'("00000000000000000000000000000010")));
  --d1_sysid_control_slave_end_xfer register, which is an e_register
  process (clk, reset_n)
  begin
    if reset_n = '0' then
      d1_sysid_control_slave_end_xfer <= std_logic'('1');
    elsif clk'event and clk = '1' then
      if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
        d1_sysid_control_slave_end_xfer <= sysid_control_slave_end_xfer;
      end if;
    end if;

  end process;

  --sysid_control_slave_waits_for_read in a cycle, which is an e_mux
  sysid_control_slave_waits_for_read <= sysid_control_slave_in_a_read_cycle AND sysid_control_slave_begins_xfer;
  --sysid_control_slave_in_a_read_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_read_cycle <= internal_cpu_data_master_granted_sysid_control_slave AND cpu_data_master_read;
  --in_a_read_cycle assignment, which is an e_mux
  in_a_read_cycle <= sysid_control_slave_in_a_read_cycle;
  --sysid_control_slave_waits_for_write in a cycle, which is an e_mux
  sysid_control_slave_waits_for_write <= Vector_To_Std_Logic(((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(sysid_control_slave_in_a_write_cycle))) AND std_logic_vector'("00000000000000000000000000000000")));
  --sysid_control_slave_in_a_write_cycle assignment, which is an e_assign
  sysid_control_slave_in_a_write_cycle <= internal_cpu_data_master_granted_sysid_control_slave AND cpu_data_master_write;
  --in_a_write_cycle assignment, which is an e_mux
  in_a_write_cycle <= sysid_control_slave_in_a_write_cycle;
  wait_for_sysid_control_slave_counter <= std_logic'('0');
  --vhdl renameroo for output signals
  cpu_data_master_granted_sysid_control_slave <= internal_cpu_data_master_granted_sysid_control_slave;
  --vhdl renameroo for output signals
  cpu_data_master_qualified_request_sysid_control_slave <= internal_cpu_data_master_qualified_request_sysid_control_slave;
  --vhdl renameroo for output signals
  cpu_data_master_requests_sysid_control_slave <= internal_cpu_data_master_requests_sysid_control_slave;
--synthesis translate_off
    --sysid/control_slave enable non-zero assertions, which is an e_register
    process (clk, reset_n)
    begin
      if reset_n = '0' then
        enable_nonzero_assertions <= std_logic'('0');
      elsif clk'event and clk = '1' then
        if (std_logic_vector'("00000000000000000000000000000001")) /= std_logic_vector'("00000000000000000000000000000000") then 
          enable_nonzero_assertions <= std_logic'('1');
        end if;
      end if;

    end process;

--synthesis translate_on

end europa;



-- turn off superfluous VHDL processor warnings 
-- altera message_level Level1 
-- altera message_off 10034 10035 10036 10037 10230 10240 10030 

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity wb_NiosProcessor is 
        port (
              -- 1) global signals:
                 signal clk : IN STD_LOGIC;
                 signal reset_n : IN STD_LOGIC;

              -- the_A_reg_pio
                 signal out_port_from_the_A_reg_pio : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- the_B_reg_pio
                 signal out_port_from_the_B_reg_pio : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

              -- the_Dbg_pc
                 signal in_port_to_the_Dbg_pc : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_Dbg_reg
                 signal in_port_to_the_Dbg_reg : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

              -- the_Dbg_reg_set
                 signal out_port_from_the_Dbg_reg_set : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

              -- the_character_lcd
                 signal LCD_BLON_from_the_character_lcd : OUT STD_LOGIC;
                 signal LCD_DATA_to_and_from_the_character_lcd : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                 signal LCD_EN_from_the_character_lcd : OUT STD_LOGIC;
                 signal LCD_ON_from_the_character_lcd : OUT STD_LOGIC;
                 signal LCD_RS_from_the_character_lcd : OUT STD_LOGIC;
                 signal LCD_RW_from_the_character_lcd : OUT STD_LOGIC;

              -- the_ps2_keyboard
                 signal PS2_CLK_to_and_from_the_ps2_keyboard : INOUT STD_LOGIC;
                 signal PS2_DAT_to_and_from_the_ps2_keyboard : INOUT STD_LOGIC
              );
end entity wb_NiosProcessor;


architecture europa of wb_NiosProcessor is
component A_reg_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal A_reg_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal A_reg_pio_s1_chipselect : OUT STD_LOGIC;
                    signal A_reg_pio_s1_reset_n : OUT STD_LOGIC;
                    signal A_reg_pio_s1_write_n : OUT STD_LOGIC;
                    signal A_reg_pio_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_data_master_granted_A_reg_pio_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_A_reg_pio_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_A_reg_pio_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_A_reg_pio_s1 : OUT STD_LOGIC;
                    signal d1_A_reg_pio_s1_end_xfer : OUT STD_LOGIC
                 );
end component A_reg_pio_s1_arbitrator;

component A_reg_pio is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component A_reg_pio;

component B_reg_pio_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal B_reg_pio_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal B_reg_pio_s1_chipselect : OUT STD_LOGIC;
                    signal B_reg_pio_s1_reset_n : OUT STD_LOGIC;
                    signal B_reg_pio_s1_write_n : OUT STD_LOGIC;
                    signal B_reg_pio_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal cpu_data_master_granted_B_reg_pio_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_B_reg_pio_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_B_reg_pio_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_B_reg_pio_s1 : OUT STD_LOGIC;
                    signal d1_B_reg_pio_s1_end_xfer : OUT STD_LOGIC
                 );
end component B_reg_pio_s1_arbitrator;

component B_reg_pio is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component B_reg_pio;

component Dbg_pc_s1_arbitrator is 
           port (
                 -- inputs:
                    signal Dbg_pc_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal Dbg_pc_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal Dbg_pc_s1_chipselect : OUT STD_LOGIC;
                    signal Dbg_pc_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal Dbg_pc_s1_reset_n : OUT STD_LOGIC;
                    signal Dbg_pc_s1_write_n : OUT STD_LOGIC;
                    signal Dbg_pc_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal cpu_data_master_granted_Dbg_pc_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_Dbg_pc_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_Dbg_pc_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_Dbg_pc_s1 : OUT STD_LOGIC;
                    signal d1_Dbg_pc_s1_end_xfer : OUT STD_LOGIC
                 );
end component Dbg_pc_s1_arbitrator;

component Dbg_pc is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component Dbg_pc;

component Dbg_reg_s1_arbitrator is 
           port (
                 -- inputs:
                    signal Dbg_reg_s1_readdata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal Dbg_reg_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal Dbg_reg_s1_chipselect : OUT STD_LOGIC;
                    signal Dbg_reg_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal Dbg_reg_s1_reset_n : OUT STD_LOGIC;
                    signal Dbg_reg_s1_write_n : OUT STD_LOGIC;
                    signal Dbg_reg_s1_writedata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal cpu_data_master_granted_Dbg_reg_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_Dbg_reg_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_Dbg_reg_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_Dbg_reg_s1 : OUT STD_LOGIC;
                    signal d1_Dbg_reg_s1_end_xfer : OUT STD_LOGIC
                 );
end component Dbg_reg_s1_arbitrator;

component Dbg_reg is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal in_port : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
                 );
end component Dbg_reg;

component Dbg_reg_set_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal Dbg_reg_set_s1_address : OUT STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal Dbg_reg_set_s1_chipselect : OUT STD_LOGIC;
                    signal Dbg_reg_set_s1_reset_n : OUT STD_LOGIC;
                    signal Dbg_reg_set_s1_write_n : OUT STD_LOGIC;
                    signal Dbg_reg_set_s1_writedata : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_granted_Dbg_reg_set_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_Dbg_reg_set_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_Dbg_reg_set_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_Dbg_reg_set_s1 : OUT STD_LOGIC;
                    signal d1_Dbg_reg_set_s1_end_xfer : OUT STD_LOGIC
                 );
end component Dbg_reg_set_s1_arbitrator;

component Dbg_reg_set is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (1 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (3 DOWNTO 0);

                 -- outputs:
                    signal out_port : OUT STD_LOGIC_VECTOR (3 DOWNTO 0)
                 );
end component Dbg_reg_set;

component character_lcd_avalon_lcd_slave_arbitrator is 
           port (
                 -- inputs:
                    signal character_lcd_avalon_lcd_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal character_lcd_avalon_lcd_slave_waitrequest : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal character_lcd_avalon_lcd_slave_address : OUT STD_LOGIC;
                    signal character_lcd_avalon_lcd_slave_chipselect : OUT STD_LOGIC;
                    signal character_lcd_avalon_lcd_slave_read : OUT STD_LOGIC;
                    signal character_lcd_avalon_lcd_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal character_lcd_avalon_lcd_slave_waitrequest_from_sa : OUT STD_LOGIC;
                    signal character_lcd_avalon_lcd_slave_write : OUT STD_LOGIC;
                    signal character_lcd_avalon_lcd_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_granted_character_lcd_avalon_lcd_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_character_lcd_avalon_lcd_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_character_lcd_avalon_lcd_slave : OUT STD_LOGIC;
                    signal d1_character_lcd_avalon_lcd_slave_end_xfer : OUT STD_LOGIC
                 );
end component character_lcd_avalon_lcd_slave_arbitrator;

component wb_NiosProcessor_reset_clk_domain_synch_module is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal data_in : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal data_out : OUT STD_LOGIC
                 );
end component wb_NiosProcessor_reset_clk_domain_synch_module;

component character_lcd is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC;
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal LCD_BLON : OUT STD_LOGIC;
                    signal LCD_DATA : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal LCD_EN : OUT STD_LOGIC;
                    signal LCD_ON : OUT STD_LOGIC;
                    signal LCD_RS : OUT STD_LOGIC;
                    signal LCD_RW : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal waitrequest : OUT STD_LOGIC
                 );
end component character_lcd;

component cpu_jtag_debug_module_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_debugaccess : IN STD_LOGIC;
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_jtag_debug_module_resetrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_data_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_granted_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_instruction_master_requests_cpu_jtag_debug_module : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_address : OUT STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal cpu_jtag_debug_module_begintransfer : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_jtag_debug_module_chipselect : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_debugaccess : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_jtag_debug_module_reset : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_reset_n : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_resetrequest_from_sa : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_write : OUT STD_LOGIC;
                    signal cpu_jtag_debug_module_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_cpu_jtag_debug_module_end_xfer : OUT STD_LOGIC
                 );
end component cpu_jtag_debug_module_arbitrator;

component cpu_data_master_arbitrator is 
           port (
                 -- inputs:
                    signal Dbg_pc_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal Dbg_reg_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal character_lcd_avalon_lcd_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal character_lcd_avalon_lcd_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_granted_A_reg_pio_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_B_reg_pio_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_Dbg_pc_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_Dbg_reg_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_Dbg_reg_set_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_character_lcd_avalon_lcd_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave : IN STD_LOGIC;
                    signal cpu_data_master_granted_sys_clk_timer_s1 : IN STD_LOGIC;
                    signal cpu_data_master_granted_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_A_reg_pio_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_B_reg_pio_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_Dbg_pc_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_Dbg_reg_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_Dbg_reg_set_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_sys_clk_timer_s1 : IN STD_LOGIC;
                    signal cpu_data_master_qualified_request_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_A_reg_pio_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_B_reg_pio_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_Dbg_pc_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_Dbg_reg_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_Dbg_reg_set_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_character_lcd_avalon_lcd_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_sys_clk_timer_s1 : IN STD_LOGIC;
                    signal cpu_data_master_read_data_valid_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_A_reg_pio_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_B_reg_pio_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_Dbg_pc_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_Dbg_reg_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_Dbg_reg_set_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_character_lcd_avalon_lcd_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave : IN STD_LOGIC;
                    signal cpu_data_master_requests_sys_clk_timer_s1 : IN STD_LOGIC;
                    signal cpu_data_master_requests_sysid_control_slave : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_A_reg_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_B_reg_pio_s1_end_xfer : IN STD_LOGIC;
                    signal d1_Dbg_pc_s1_end_xfer : IN STD_LOGIC;
                    signal d1_Dbg_reg_s1_end_xfer : IN STD_LOGIC;
                    signal d1_Dbg_reg_set_s1_end_xfer : IN STD_LOGIC;
                    signal d1_character_lcd_avalon_lcd_slave_end_xfer : IN STD_LOGIC;
                    signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_jtag_uart_avalon_jtag_slave_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                    signal d1_ps2_keyboard_avalon_PS2_slave_end_xfer : IN STD_LOGIC;
                    signal d1_sys_clk_timer_s1_end_xfer : IN STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq_from_sa : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ps2_keyboard_avalon_PS2_slave_irq_from_sa : IN STD_LOGIC;
                    signal ps2_keyboard_avalon_PS2_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa : IN STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                    signal registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sys_clk_timer_s1_irq_from_sa : IN STD_LOGIC;
                    signal sys_clk_timer_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal sysid_control_slave_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal cpu_data_master_address_to_slave : OUT STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_irq : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_data_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_data_master_arbitrator;

component cpu_instruction_master_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_instruction_master_address : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_instruction_master_granted_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_granted_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_instruction_master_requests_cpu_jtag_debug_module : IN STD_LOGIC;
                    signal cpu_instruction_master_requests_onchip_mem_s1 : IN STD_LOGIC;
                    signal cpu_jtag_debug_module_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d1_cpu_jtag_debug_module_end_xfer : IN STD_LOGIC;
                    signal d1_onchip_mem_s1_end_xfer : IN STD_LOGIC;
                    signal onchip_mem_s1_readdata_from_sa : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_instruction_master_address_to_slave : OUT STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_instruction_master_latency_counter : OUT STD_LOGIC;
                    signal cpu_instruction_master_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_instruction_master_readdatavalid : OUT STD_LOGIC;
                    signal cpu_instruction_master_waitrequest : OUT STD_LOGIC
                 );
end component cpu_instruction_master_arbitrator;

component cpu is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal d_irq : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal d_waitrequest : IN STD_LOGIC;
                    signal i_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_readdatavalid : IN STD_LOGIC;
                    signal i_waitrequest : IN STD_LOGIC;
                    signal jtag_debug_module_address : IN STD_LOGIC_VECTOR (8 DOWNTO 0);
                    signal jtag_debug_module_begintransfer : IN STD_LOGIC;
                    signal jtag_debug_module_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal jtag_debug_module_clk : IN STD_LOGIC;
                    signal jtag_debug_module_debugaccess : IN STD_LOGIC;
                    signal jtag_debug_module_reset : IN STD_LOGIC;
                    signal jtag_debug_module_select : IN STD_LOGIC;
                    signal jtag_debug_module_write : IN STD_LOGIC;
                    signal jtag_debug_module_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal d_address : OUT STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal d_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal d_read : OUT STD_LOGIC;
                    signal d_write : OUT STD_LOGIC;
                    signal d_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal i_address : OUT STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal i_read : OUT STD_LOGIC;
                    signal jtag_debug_module_debugaccess_to_roms : OUT STD_LOGIC;
                    signal jtag_debug_module_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_debug_module_resetrequest : OUT STD_LOGIC
                 );
end component cpu;

component jtag_uart_avalon_jtag_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_dataavailable : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_readyfordata : IN STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave : OUT STD_LOGIC;
                    signal d1_jtag_uart_avalon_jtag_slave_end_xfer : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_address : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_chipselect : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_irq_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_read_n : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_reset_n : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_write_n : OUT STD_LOGIC;
                    signal jtag_uart_avalon_jtag_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component jtag_uart_avalon_jtag_slave_arbitrator;

component jtag_uart is 
           port (
                 -- inputs:
                    signal av_address : IN STD_LOGIC;
                    signal av_chipselect : IN STD_LOGIC;
                    signal av_read_n : IN STD_LOGIC;
                    signal av_write_n : IN STD_LOGIC;
                    signal av_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal clk : IN STD_LOGIC;
                    signal rst_n : IN STD_LOGIC;

                 -- outputs:
                    signal av_irq : OUT STD_LOGIC;
                    signal av_readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal av_waitrequest : OUT STD_LOGIC;
                    signal dataavailable : OUT STD_LOGIC;
                    signal readyfordata : OUT STD_LOGIC
                 );
end component jtag_uart;

component onchip_mem_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal cpu_instruction_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_instruction_master_latency_counter : IN STD_LOGIC;
                    signal cpu_instruction_master_read : IN STD_LOGIC;
                    signal onchip_mem_s1_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_granted_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_qualified_request_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC;
                    signal cpu_instruction_master_requests_onchip_mem_s1 : OUT STD_LOGIC;
                    signal d1_onchip_mem_s1_end_xfer : OUT STD_LOGIC;
                    signal onchip_mem_s1_address : OUT STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal onchip_mem_s1_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal onchip_mem_s1_chipselect : OUT STD_LOGIC;
                    signal onchip_mem_s1_clken : OUT STD_LOGIC;
                    signal onchip_mem_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal onchip_mem_s1_write : OUT STD_LOGIC;
                    signal onchip_mem_s1_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal registered_cpu_data_master_read_data_valid_onchip_mem_s1 : OUT STD_LOGIC
                 );
end component onchip_mem_s1_arbitrator;

component onchip_mem is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (13 DOWNTO 0);
                    signal byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal clken : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component onchip_mem;

component ps2_keyboard_avalon_PS2_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ps2_keyboard_avalon_PS2_slave_irq : IN STD_LOGIC;
                    signal ps2_keyboard_avalon_PS2_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ps2_keyboard_avalon_PS2_slave_waitrequest : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- outputs:
                    signal cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave : OUT STD_LOGIC;
                    signal d1_ps2_keyboard_avalon_PS2_slave_end_xfer : OUT STD_LOGIC;
                    signal ps2_keyboard_avalon_PS2_slave_address : OUT STD_LOGIC;
                    signal ps2_keyboard_avalon_PS2_slave_byteenable : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal ps2_keyboard_avalon_PS2_slave_chipselect : OUT STD_LOGIC;
                    signal ps2_keyboard_avalon_PS2_slave_irq_from_sa : OUT STD_LOGIC;
                    signal ps2_keyboard_avalon_PS2_slave_read : OUT STD_LOGIC;
                    signal ps2_keyboard_avalon_PS2_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa : OUT STD_LOGIC;
                    signal ps2_keyboard_avalon_PS2_slave_write : OUT STD_LOGIC;
                    signal ps2_keyboard_avalon_PS2_slave_writedata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave : OUT STD_LOGIC
                 );
end component ps2_keyboard_avalon_PS2_slave_arbitrator;

component ps2_keyboard is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC;
                    signal byteenable : IN STD_LOGIC_VECTOR (3 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal read : IN STD_LOGIC;
                    signal reset : IN STD_LOGIC;
                    signal write : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal PS2_CLK : INOUT STD_LOGIC;
                    signal PS2_DAT : INOUT STD_LOGIC;
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal waitrequest : OUT STD_LOGIC
                 );
end component ps2_keyboard;

component sys_clk_timer_s1_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_waitrequest : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal cpu_data_master_writedata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);
                    signal reset_n : IN STD_LOGIC;
                    signal sys_clk_timer_s1_irq : IN STD_LOGIC;
                    signal sys_clk_timer_s1_readdata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal cpu_data_master_granted_sys_clk_timer_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_sys_clk_timer_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_sys_clk_timer_s1 : OUT STD_LOGIC;
                    signal cpu_data_master_requests_sys_clk_timer_s1 : OUT STD_LOGIC;
                    signal d1_sys_clk_timer_s1_end_xfer : OUT STD_LOGIC;
                    signal sys_clk_timer_s1_address : OUT STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal sys_clk_timer_s1_chipselect : OUT STD_LOGIC;
                    signal sys_clk_timer_s1_irq_from_sa : OUT STD_LOGIC;
                    signal sys_clk_timer_s1_readdata_from_sa : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
                    signal sys_clk_timer_s1_reset_n : OUT STD_LOGIC;
                    signal sys_clk_timer_s1_write_n : OUT STD_LOGIC;
                    signal sys_clk_timer_s1_writedata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component sys_clk_timer_s1_arbitrator;

component sys_clk_timer is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC_VECTOR (2 DOWNTO 0);
                    signal chipselect : IN STD_LOGIC;
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal write_n : IN STD_LOGIC;
                    signal writedata : IN STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- outputs:
                    signal irq : OUT STD_LOGIC;
                    signal readdata : OUT STD_LOGIC_VECTOR (15 DOWNTO 0)
                 );
end component sys_clk_timer;

component sysid_control_slave_arbitrator is 
           port (
                 -- inputs:
                    signal clk : IN STD_LOGIC;
                    signal cpu_data_master_address_to_slave : IN STD_LOGIC_VECTOR (17 DOWNTO 0);
                    signal cpu_data_master_read : IN STD_LOGIC;
                    signal cpu_data_master_write : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;
                    signal sysid_control_slave_readdata : IN STD_LOGIC_VECTOR (31 DOWNTO 0);

                 -- outputs:
                    signal cpu_data_master_granted_sysid_control_slave : OUT STD_LOGIC;
                    signal cpu_data_master_qualified_request_sysid_control_slave : OUT STD_LOGIC;
                    signal cpu_data_master_read_data_valid_sysid_control_slave : OUT STD_LOGIC;
                    signal cpu_data_master_requests_sysid_control_slave : OUT STD_LOGIC;
                    signal d1_sysid_control_slave_end_xfer : OUT STD_LOGIC;
                    signal sysid_control_slave_address : OUT STD_LOGIC;
                    signal sysid_control_slave_readdata_from_sa : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component sysid_control_slave_arbitrator;

component sysid is 
           port (
                 -- inputs:
                    signal address : IN STD_LOGIC;

                 -- outputs:
                    signal readdata : OUT STD_LOGIC_VECTOR (31 DOWNTO 0)
                 );
end component sysid;

                signal A_reg_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal A_reg_pio_s1_chipselect :  STD_LOGIC;
                signal A_reg_pio_s1_reset_n :  STD_LOGIC;
                signal A_reg_pio_s1_write_n :  STD_LOGIC;
                signal A_reg_pio_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal B_reg_pio_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal B_reg_pio_s1_chipselect :  STD_LOGIC;
                signal B_reg_pio_s1_reset_n :  STD_LOGIC;
                signal B_reg_pio_s1_write_n :  STD_LOGIC;
                signal B_reg_pio_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal Dbg_pc_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Dbg_pc_s1_chipselect :  STD_LOGIC;
                signal Dbg_pc_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal Dbg_pc_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal Dbg_pc_s1_reset_n :  STD_LOGIC;
                signal Dbg_pc_s1_write_n :  STD_LOGIC;
                signal Dbg_pc_s1_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal Dbg_reg_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Dbg_reg_s1_chipselect :  STD_LOGIC;
                signal Dbg_reg_s1_readdata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal Dbg_reg_s1_readdata_from_sa :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal Dbg_reg_s1_reset_n :  STD_LOGIC;
                signal Dbg_reg_s1_write_n :  STD_LOGIC;
                signal Dbg_reg_s1_writedata :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal Dbg_reg_set_s1_address :  STD_LOGIC_VECTOR (1 DOWNTO 0);
                signal Dbg_reg_set_s1_chipselect :  STD_LOGIC;
                signal Dbg_reg_set_s1_reset_n :  STD_LOGIC;
                signal Dbg_reg_set_s1_write_n :  STD_LOGIC;
                signal Dbg_reg_set_s1_writedata :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal character_lcd_avalon_lcd_slave_address :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_chipselect :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_read :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal character_lcd_avalon_lcd_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal character_lcd_avalon_lcd_slave_waitrequest :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_waitrequest_from_sa :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_write :  STD_LOGIC;
                signal character_lcd_avalon_lcd_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal clk_reset :  STD_LOGIC;
                signal clk_reset_n :  STD_LOGIC;
                signal cpu_data_master_address :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal cpu_data_master_address_to_slave :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal cpu_data_master_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_data_master_debugaccess :  STD_LOGIC;
                signal cpu_data_master_granted_A_reg_pio_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_B_reg_pio_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_Dbg_pc_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_Dbg_reg_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_Dbg_reg_set_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_character_lcd_avalon_lcd_slave :  STD_LOGIC;
                signal cpu_data_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_granted_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave :  STD_LOGIC;
                signal cpu_data_master_granted_sys_clk_timer_s1 :  STD_LOGIC;
                signal cpu_data_master_granted_sysid_control_slave :  STD_LOGIC;
                signal cpu_data_master_irq :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_data_master_qualified_request_A_reg_pio_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_B_reg_pio_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_Dbg_pc_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_Dbg_reg_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_Dbg_reg_set_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave :  STD_LOGIC;
                signal cpu_data_master_qualified_request_sys_clk_timer_s1 :  STD_LOGIC;
                signal cpu_data_master_qualified_request_sysid_control_slave :  STD_LOGIC;
                signal cpu_data_master_read :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_A_reg_pio_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_B_reg_pio_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_Dbg_pc_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_Dbg_reg_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_Dbg_reg_set_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_character_lcd_avalon_lcd_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_sys_clk_timer_s1 :  STD_LOGIC;
                signal cpu_data_master_read_data_valid_sysid_control_slave :  STD_LOGIC;
                signal cpu_data_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_data_master_requests_A_reg_pio_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_B_reg_pio_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_Dbg_pc_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_Dbg_reg_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_Dbg_reg_set_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_character_lcd_avalon_lcd_slave :  STD_LOGIC;
                signal cpu_data_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_data_master_requests_jtag_uart_avalon_jtag_slave :  STD_LOGIC;
                signal cpu_data_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave :  STD_LOGIC;
                signal cpu_data_master_requests_sys_clk_timer_s1 :  STD_LOGIC;
                signal cpu_data_master_requests_sysid_control_slave :  STD_LOGIC;
                signal cpu_data_master_waitrequest :  STD_LOGIC;
                signal cpu_data_master_write :  STD_LOGIC;
                signal cpu_data_master_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_instruction_master_address :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal cpu_instruction_master_address_to_slave :  STD_LOGIC_VECTOR (17 DOWNTO 0);
                signal cpu_instruction_master_granted_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_granted_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_instruction_master_latency_counter :  STD_LOGIC;
                signal cpu_instruction_master_qualified_request_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_qualified_request_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_instruction_master_read :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_read_data_valid_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_instruction_master_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_instruction_master_readdatavalid :  STD_LOGIC;
                signal cpu_instruction_master_requests_cpu_jtag_debug_module :  STD_LOGIC;
                signal cpu_instruction_master_requests_onchip_mem_s1 :  STD_LOGIC;
                signal cpu_instruction_master_waitrequest :  STD_LOGIC;
                signal cpu_jtag_debug_module_address :  STD_LOGIC_VECTOR (8 DOWNTO 0);
                signal cpu_jtag_debug_module_begintransfer :  STD_LOGIC;
                signal cpu_jtag_debug_module_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal cpu_jtag_debug_module_chipselect :  STD_LOGIC;
                signal cpu_jtag_debug_module_debugaccess :  STD_LOGIC;
                signal cpu_jtag_debug_module_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_jtag_debug_module_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal cpu_jtag_debug_module_reset :  STD_LOGIC;
                signal cpu_jtag_debug_module_reset_n :  STD_LOGIC;
                signal cpu_jtag_debug_module_resetrequest :  STD_LOGIC;
                signal cpu_jtag_debug_module_resetrequest_from_sa :  STD_LOGIC;
                signal cpu_jtag_debug_module_write :  STD_LOGIC;
                signal cpu_jtag_debug_module_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal d1_A_reg_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_B_reg_pio_s1_end_xfer :  STD_LOGIC;
                signal d1_Dbg_pc_s1_end_xfer :  STD_LOGIC;
                signal d1_Dbg_reg_s1_end_xfer :  STD_LOGIC;
                signal d1_Dbg_reg_set_s1_end_xfer :  STD_LOGIC;
                signal d1_character_lcd_avalon_lcd_slave_end_xfer :  STD_LOGIC;
                signal d1_cpu_jtag_debug_module_end_xfer :  STD_LOGIC;
                signal d1_jtag_uart_avalon_jtag_slave_end_xfer :  STD_LOGIC;
                signal d1_onchip_mem_s1_end_xfer :  STD_LOGIC;
                signal d1_ps2_keyboard_avalon_PS2_slave_end_xfer :  STD_LOGIC;
                signal d1_sys_clk_timer_s1_end_xfer :  STD_LOGIC;
                signal d1_sysid_control_slave_end_xfer :  STD_LOGIC;
                signal internal_LCD_BLON_from_the_character_lcd :  STD_LOGIC;
                signal internal_LCD_EN_from_the_character_lcd :  STD_LOGIC;
                signal internal_LCD_ON_from_the_character_lcd :  STD_LOGIC;
                signal internal_LCD_RS_from_the_character_lcd :  STD_LOGIC;
                signal internal_LCD_RW_from_the_character_lcd :  STD_LOGIC;
                signal internal_out_port_from_the_A_reg_pio :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_out_port_from_the_B_reg_pio :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal internal_out_port_from_the_Dbg_reg_set :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_address :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_chipselect :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_dataavailable :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_irq :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_irq_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_read_n :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_readyfordata :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_reset_n :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waitrequest :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_waitrequest_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_write_n :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal module_input :  STD_LOGIC;
                signal onchip_mem_s1_address :  STD_LOGIC_VECTOR (13 DOWNTO 0);
                signal onchip_mem_s1_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal onchip_mem_s1_chipselect :  STD_LOGIC;
                signal onchip_mem_s1_clken :  STD_LOGIC;
                signal onchip_mem_s1_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_mem_s1_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal onchip_mem_s1_write :  STD_LOGIC;
                signal onchip_mem_s1_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ps2_keyboard_avalon_PS2_slave_address :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_byteenable :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal ps2_keyboard_avalon_PS2_slave_chipselect :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_irq :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_irq_from_sa :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_read :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ps2_keyboard_avalon_PS2_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal ps2_keyboard_avalon_PS2_slave_waitrequest :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_write :  STD_LOGIC;
                signal ps2_keyboard_avalon_PS2_slave_writedata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal registered_cpu_data_master_read_data_valid_onchip_mem_s1 :  STD_LOGIC;
                signal registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave :  STD_LOGIC;
                signal reset_n_sources :  STD_LOGIC;
                signal sys_clk_timer_s1_address :  STD_LOGIC_VECTOR (2 DOWNTO 0);
                signal sys_clk_timer_s1_chipselect :  STD_LOGIC;
                signal sys_clk_timer_s1_irq :  STD_LOGIC;
                signal sys_clk_timer_s1_irq_from_sa :  STD_LOGIC;
                signal sys_clk_timer_s1_readdata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal sys_clk_timer_s1_readdata_from_sa :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal sys_clk_timer_s1_reset_n :  STD_LOGIC;
                signal sys_clk_timer_s1_write_n :  STD_LOGIC;
                signal sys_clk_timer_s1_writedata :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal sysid_control_slave_address :  STD_LOGIC;
                signal sysid_control_slave_readdata :  STD_LOGIC_VECTOR (31 DOWNTO 0);
                signal sysid_control_slave_readdata_from_sa :  STD_LOGIC_VECTOR (31 DOWNTO 0);

begin

  --the_A_reg_pio_s1, which is an e_instance
  the_A_reg_pio_s1 : A_reg_pio_s1_arbitrator
    port map(
      A_reg_pio_s1_address => A_reg_pio_s1_address,
      A_reg_pio_s1_chipselect => A_reg_pio_s1_chipselect,
      A_reg_pio_s1_reset_n => A_reg_pio_s1_reset_n,
      A_reg_pio_s1_write_n => A_reg_pio_s1_write_n,
      A_reg_pio_s1_writedata => A_reg_pio_s1_writedata,
      cpu_data_master_granted_A_reg_pio_s1 => cpu_data_master_granted_A_reg_pio_s1,
      cpu_data_master_qualified_request_A_reg_pio_s1 => cpu_data_master_qualified_request_A_reg_pio_s1,
      cpu_data_master_read_data_valid_A_reg_pio_s1 => cpu_data_master_read_data_valid_A_reg_pio_s1,
      cpu_data_master_requests_A_reg_pio_s1 => cpu_data_master_requests_A_reg_pio_s1,
      d1_A_reg_pio_s1_end_xfer => d1_A_reg_pio_s1_end_xfer,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_reset_n
    );


  --the_A_reg_pio, which is an e_ptf_instance
  the_A_reg_pio : A_reg_pio
    port map(
      out_port => internal_out_port_from_the_A_reg_pio,
      address => A_reg_pio_s1_address,
      chipselect => A_reg_pio_s1_chipselect,
      clk => clk,
      reset_n => A_reg_pio_s1_reset_n,
      write_n => A_reg_pio_s1_write_n,
      writedata => A_reg_pio_s1_writedata
    );


  --the_B_reg_pio_s1, which is an e_instance
  the_B_reg_pio_s1 : B_reg_pio_s1_arbitrator
    port map(
      B_reg_pio_s1_address => B_reg_pio_s1_address,
      B_reg_pio_s1_chipselect => B_reg_pio_s1_chipselect,
      B_reg_pio_s1_reset_n => B_reg_pio_s1_reset_n,
      B_reg_pio_s1_write_n => B_reg_pio_s1_write_n,
      B_reg_pio_s1_writedata => B_reg_pio_s1_writedata,
      cpu_data_master_granted_B_reg_pio_s1 => cpu_data_master_granted_B_reg_pio_s1,
      cpu_data_master_qualified_request_B_reg_pio_s1 => cpu_data_master_qualified_request_B_reg_pio_s1,
      cpu_data_master_read_data_valid_B_reg_pio_s1 => cpu_data_master_read_data_valid_B_reg_pio_s1,
      cpu_data_master_requests_B_reg_pio_s1 => cpu_data_master_requests_B_reg_pio_s1,
      d1_B_reg_pio_s1_end_xfer => d1_B_reg_pio_s1_end_xfer,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_reset_n
    );


  --the_B_reg_pio, which is an e_ptf_instance
  the_B_reg_pio : B_reg_pio
    port map(
      out_port => internal_out_port_from_the_B_reg_pio,
      address => B_reg_pio_s1_address,
      chipselect => B_reg_pio_s1_chipselect,
      clk => clk,
      reset_n => B_reg_pio_s1_reset_n,
      write_n => B_reg_pio_s1_write_n,
      writedata => B_reg_pio_s1_writedata
    );


  --the_Dbg_pc_s1, which is an e_instance
  the_Dbg_pc_s1 : Dbg_pc_s1_arbitrator
    port map(
      Dbg_pc_s1_address => Dbg_pc_s1_address,
      Dbg_pc_s1_chipselect => Dbg_pc_s1_chipselect,
      Dbg_pc_s1_readdata_from_sa => Dbg_pc_s1_readdata_from_sa,
      Dbg_pc_s1_reset_n => Dbg_pc_s1_reset_n,
      Dbg_pc_s1_write_n => Dbg_pc_s1_write_n,
      Dbg_pc_s1_writedata => Dbg_pc_s1_writedata,
      cpu_data_master_granted_Dbg_pc_s1 => cpu_data_master_granted_Dbg_pc_s1,
      cpu_data_master_qualified_request_Dbg_pc_s1 => cpu_data_master_qualified_request_Dbg_pc_s1,
      cpu_data_master_read_data_valid_Dbg_pc_s1 => cpu_data_master_read_data_valid_Dbg_pc_s1,
      cpu_data_master_requests_Dbg_pc_s1 => cpu_data_master_requests_Dbg_pc_s1,
      d1_Dbg_pc_s1_end_xfer => d1_Dbg_pc_s1_end_xfer,
      Dbg_pc_s1_readdata => Dbg_pc_s1_readdata,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_reset_n
    );


  --the_Dbg_pc, which is an e_ptf_instance
  the_Dbg_pc : Dbg_pc
    port map(
      readdata => Dbg_pc_s1_readdata,
      address => Dbg_pc_s1_address,
      chipselect => Dbg_pc_s1_chipselect,
      clk => clk,
      in_port => in_port_to_the_Dbg_pc,
      reset_n => Dbg_pc_s1_reset_n,
      write_n => Dbg_pc_s1_write_n,
      writedata => Dbg_pc_s1_writedata
    );


  --the_Dbg_reg_s1, which is an e_instance
  the_Dbg_reg_s1 : Dbg_reg_s1_arbitrator
    port map(
      Dbg_reg_s1_address => Dbg_reg_s1_address,
      Dbg_reg_s1_chipselect => Dbg_reg_s1_chipselect,
      Dbg_reg_s1_readdata_from_sa => Dbg_reg_s1_readdata_from_sa,
      Dbg_reg_s1_reset_n => Dbg_reg_s1_reset_n,
      Dbg_reg_s1_write_n => Dbg_reg_s1_write_n,
      Dbg_reg_s1_writedata => Dbg_reg_s1_writedata,
      cpu_data_master_granted_Dbg_reg_s1 => cpu_data_master_granted_Dbg_reg_s1,
      cpu_data_master_qualified_request_Dbg_reg_s1 => cpu_data_master_qualified_request_Dbg_reg_s1,
      cpu_data_master_read_data_valid_Dbg_reg_s1 => cpu_data_master_read_data_valid_Dbg_reg_s1,
      cpu_data_master_requests_Dbg_reg_s1 => cpu_data_master_requests_Dbg_reg_s1,
      d1_Dbg_reg_s1_end_xfer => d1_Dbg_reg_s1_end_xfer,
      Dbg_reg_s1_readdata => Dbg_reg_s1_readdata,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_reset_n
    );


  --the_Dbg_reg, which is an e_ptf_instance
  the_Dbg_reg : Dbg_reg
    port map(
      readdata => Dbg_reg_s1_readdata,
      address => Dbg_reg_s1_address,
      chipselect => Dbg_reg_s1_chipselect,
      clk => clk,
      in_port => in_port_to_the_Dbg_reg,
      reset_n => Dbg_reg_s1_reset_n,
      write_n => Dbg_reg_s1_write_n,
      writedata => Dbg_reg_s1_writedata
    );


  --the_Dbg_reg_set_s1, which is an e_instance
  the_Dbg_reg_set_s1 : Dbg_reg_set_s1_arbitrator
    port map(
      Dbg_reg_set_s1_address => Dbg_reg_set_s1_address,
      Dbg_reg_set_s1_chipselect => Dbg_reg_set_s1_chipselect,
      Dbg_reg_set_s1_reset_n => Dbg_reg_set_s1_reset_n,
      Dbg_reg_set_s1_write_n => Dbg_reg_set_s1_write_n,
      Dbg_reg_set_s1_writedata => Dbg_reg_set_s1_writedata,
      cpu_data_master_granted_Dbg_reg_set_s1 => cpu_data_master_granted_Dbg_reg_set_s1,
      cpu_data_master_qualified_request_Dbg_reg_set_s1 => cpu_data_master_qualified_request_Dbg_reg_set_s1,
      cpu_data_master_read_data_valid_Dbg_reg_set_s1 => cpu_data_master_read_data_valid_Dbg_reg_set_s1,
      cpu_data_master_requests_Dbg_reg_set_s1 => cpu_data_master_requests_Dbg_reg_set_s1,
      d1_Dbg_reg_set_s1_end_xfer => d1_Dbg_reg_set_s1_end_xfer,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_reset_n
    );


  --the_Dbg_reg_set, which is an e_ptf_instance
  the_Dbg_reg_set : Dbg_reg_set
    port map(
      out_port => internal_out_port_from_the_Dbg_reg_set,
      address => Dbg_reg_set_s1_address,
      chipselect => Dbg_reg_set_s1_chipselect,
      clk => clk,
      reset_n => Dbg_reg_set_s1_reset_n,
      write_n => Dbg_reg_set_s1_write_n,
      writedata => Dbg_reg_set_s1_writedata
    );


  --the_character_lcd_avalon_lcd_slave, which is an e_instance
  the_character_lcd_avalon_lcd_slave : character_lcd_avalon_lcd_slave_arbitrator
    port map(
      character_lcd_avalon_lcd_slave_address => character_lcd_avalon_lcd_slave_address,
      character_lcd_avalon_lcd_slave_chipselect => character_lcd_avalon_lcd_slave_chipselect,
      character_lcd_avalon_lcd_slave_read => character_lcd_avalon_lcd_slave_read,
      character_lcd_avalon_lcd_slave_readdata_from_sa => character_lcd_avalon_lcd_slave_readdata_from_sa,
      character_lcd_avalon_lcd_slave_waitrequest_from_sa => character_lcd_avalon_lcd_slave_waitrequest_from_sa,
      character_lcd_avalon_lcd_slave_write => character_lcd_avalon_lcd_slave_write,
      character_lcd_avalon_lcd_slave_writedata => character_lcd_avalon_lcd_slave_writedata,
      cpu_data_master_granted_character_lcd_avalon_lcd_slave => cpu_data_master_granted_character_lcd_avalon_lcd_slave,
      cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave => cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave,
      cpu_data_master_read_data_valid_character_lcd_avalon_lcd_slave => cpu_data_master_read_data_valid_character_lcd_avalon_lcd_slave,
      cpu_data_master_requests_character_lcd_avalon_lcd_slave => cpu_data_master_requests_character_lcd_avalon_lcd_slave,
      d1_character_lcd_avalon_lcd_slave_end_xfer => d1_character_lcd_avalon_lcd_slave_end_xfer,
      character_lcd_avalon_lcd_slave_readdata => character_lcd_avalon_lcd_slave_readdata,
      character_lcd_avalon_lcd_slave_waitrequest => character_lcd_avalon_lcd_slave_waitrequest,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_reset_n
    );


  --complemented clk_reset_n, which is an e_assign
  clk_reset <= NOT clk_reset_n;
  --reset is asserted asynchronously and deasserted synchronously
  wb_NiosProcessor_reset_clk_domain_synch : wb_NiosProcessor_reset_clk_domain_synch_module
    port map(
      data_out => clk_reset_n,
      clk => clk,
      data_in => module_input,
      reset_n => reset_n_sources
    );

  module_input <= std_logic'('1');

  --reset sources mux, which is an e_mux
  reset_n_sources <= Vector_To_Std_Logic(NOT (((((std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(NOT reset_n))) OR std_logic_vector'("00000000000000000000000000000000")) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_resetrequest_from_sa)))) OR (std_logic_vector'("0000000000000000000000000000000") & (A_TOSTDLOGICVECTOR(cpu_jtag_debug_module_resetrequest_from_sa))))));
  --the_character_lcd, which is an e_ptf_instance
  the_character_lcd : character_lcd
    port map(
      LCD_BLON => internal_LCD_BLON_from_the_character_lcd,
      LCD_DATA => LCD_DATA_to_and_from_the_character_lcd,
      LCD_EN => internal_LCD_EN_from_the_character_lcd,
      LCD_ON => internal_LCD_ON_from_the_character_lcd,
      LCD_RS => internal_LCD_RS_from_the_character_lcd,
      LCD_RW => internal_LCD_RW_from_the_character_lcd,
      readdata => character_lcd_avalon_lcd_slave_readdata,
      waitrequest => character_lcd_avalon_lcd_slave_waitrequest,
      address => character_lcd_avalon_lcd_slave_address,
      chipselect => character_lcd_avalon_lcd_slave_chipselect,
      clk => clk,
      read => character_lcd_avalon_lcd_slave_read,
      reset => clk_reset,
      write => character_lcd_avalon_lcd_slave_write,
      writedata => character_lcd_avalon_lcd_slave_writedata
    );


  --the_cpu_jtag_debug_module, which is an e_instance
  the_cpu_jtag_debug_module : cpu_jtag_debug_module_arbitrator
    port map(
      cpu_data_master_granted_cpu_jtag_debug_module => cpu_data_master_granted_cpu_jtag_debug_module,
      cpu_data_master_qualified_request_cpu_jtag_debug_module => cpu_data_master_qualified_request_cpu_jtag_debug_module,
      cpu_data_master_read_data_valid_cpu_jtag_debug_module => cpu_data_master_read_data_valid_cpu_jtag_debug_module,
      cpu_data_master_requests_cpu_jtag_debug_module => cpu_data_master_requests_cpu_jtag_debug_module,
      cpu_instruction_master_granted_cpu_jtag_debug_module => cpu_instruction_master_granted_cpu_jtag_debug_module,
      cpu_instruction_master_qualified_request_cpu_jtag_debug_module => cpu_instruction_master_qualified_request_cpu_jtag_debug_module,
      cpu_instruction_master_read_data_valid_cpu_jtag_debug_module => cpu_instruction_master_read_data_valid_cpu_jtag_debug_module,
      cpu_instruction_master_requests_cpu_jtag_debug_module => cpu_instruction_master_requests_cpu_jtag_debug_module,
      cpu_jtag_debug_module_address => cpu_jtag_debug_module_address,
      cpu_jtag_debug_module_begintransfer => cpu_jtag_debug_module_begintransfer,
      cpu_jtag_debug_module_byteenable => cpu_jtag_debug_module_byteenable,
      cpu_jtag_debug_module_chipselect => cpu_jtag_debug_module_chipselect,
      cpu_jtag_debug_module_debugaccess => cpu_jtag_debug_module_debugaccess,
      cpu_jtag_debug_module_readdata_from_sa => cpu_jtag_debug_module_readdata_from_sa,
      cpu_jtag_debug_module_reset => cpu_jtag_debug_module_reset,
      cpu_jtag_debug_module_reset_n => cpu_jtag_debug_module_reset_n,
      cpu_jtag_debug_module_resetrequest_from_sa => cpu_jtag_debug_module_resetrequest_from_sa,
      cpu_jtag_debug_module_write => cpu_jtag_debug_module_write,
      cpu_jtag_debug_module_writedata => cpu_jtag_debug_module_writedata,
      d1_cpu_jtag_debug_module_end_xfer => d1_cpu_jtag_debug_module_end_xfer,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_debugaccess => cpu_data_master_debugaccess,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_latency_counter => cpu_instruction_master_latency_counter,
      cpu_instruction_master_read => cpu_instruction_master_read,
      cpu_jtag_debug_module_readdata => cpu_jtag_debug_module_readdata,
      cpu_jtag_debug_module_resetrequest => cpu_jtag_debug_module_resetrequest,
      reset_n => clk_reset_n
    );


  --the_cpu_data_master, which is an e_instance
  the_cpu_data_master : cpu_data_master_arbitrator
    port map(
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_irq => cpu_data_master_irq,
      cpu_data_master_readdata => cpu_data_master_readdata,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      Dbg_pc_s1_readdata_from_sa => Dbg_pc_s1_readdata_from_sa,
      Dbg_reg_s1_readdata_from_sa => Dbg_reg_s1_readdata_from_sa,
      character_lcd_avalon_lcd_slave_readdata_from_sa => character_lcd_avalon_lcd_slave_readdata_from_sa,
      character_lcd_avalon_lcd_slave_waitrequest_from_sa => character_lcd_avalon_lcd_slave_waitrequest_from_sa,
      clk => clk,
      cpu_data_master_address => cpu_data_master_address,
      cpu_data_master_granted_A_reg_pio_s1 => cpu_data_master_granted_A_reg_pio_s1,
      cpu_data_master_granted_B_reg_pio_s1 => cpu_data_master_granted_B_reg_pio_s1,
      cpu_data_master_granted_Dbg_pc_s1 => cpu_data_master_granted_Dbg_pc_s1,
      cpu_data_master_granted_Dbg_reg_s1 => cpu_data_master_granted_Dbg_reg_s1,
      cpu_data_master_granted_Dbg_reg_set_s1 => cpu_data_master_granted_Dbg_reg_set_s1,
      cpu_data_master_granted_character_lcd_avalon_lcd_slave => cpu_data_master_granted_character_lcd_avalon_lcd_slave,
      cpu_data_master_granted_cpu_jtag_debug_module => cpu_data_master_granted_cpu_jtag_debug_module,
      cpu_data_master_granted_jtag_uart_avalon_jtag_slave => cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
      cpu_data_master_granted_onchip_mem_s1 => cpu_data_master_granted_onchip_mem_s1,
      cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave => cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave,
      cpu_data_master_granted_sys_clk_timer_s1 => cpu_data_master_granted_sys_clk_timer_s1,
      cpu_data_master_granted_sysid_control_slave => cpu_data_master_granted_sysid_control_slave,
      cpu_data_master_qualified_request_A_reg_pio_s1 => cpu_data_master_qualified_request_A_reg_pio_s1,
      cpu_data_master_qualified_request_B_reg_pio_s1 => cpu_data_master_qualified_request_B_reg_pio_s1,
      cpu_data_master_qualified_request_Dbg_pc_s1 => cpu_data_master_qualified_request_Dbg_pc_s1,
      cpu_data_master_qualified_request_Dbg_reg_s1 => cpu_data_master_qualified_request_Dbg_reg_s1,
      cpu_data_master_qualified_request_Dbg_reg_set_s1 => cpu_data_master_qualified_request_Dbg_reg_set_s1,
      cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave => cpu_data_master_qualified_request_character_lcd_avalon_lcd_slave,
      cpu_data_master_qualified_request_cpu_jtag_debug_module => cpu_data_master_qualified_request_cpu_jtag_debug_module,
      cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave => cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
      cpu_data_master_qualified_request_onchip_mem_s1 => cpu_data_master_qualified_request_onchip_mem_s1,
      cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave => cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave,
      cpu_data_master_qualified_request_sys_clk_timer_s1 => cpu_data_master_qualified_request_sys_clk_timer_s1,
      cpu_data_master_qualified_request_sysid_control_slave => cpu_data_master_qualified_request_sysid_control_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_read_data_valid_A_reg_pio_s1 => cpu_data_master_read_data_valid_A_reg_pio_s1,
      cpu_data_master_read_data_valid_B_reg_pio_s1 => cpu_data_master_read_data_valid_B_reg_pio_s1,
      cpu_data_master_read_data_valid_Dbg_pc_s1 => cpu_data_master_read_data_valid_Dbg_pc_s1,
      cpu_data_master_read_data_valid_Dbg_reg_s1 => cpu_data_master_read_data_valid_Dbg_reg_s1,
      cpu_data_master_read_data_valid_Dbg_reg_set_s1 => cpu_data_master_read_data_valid_Dbg_reg_set_s1,
      cpu_data_master_read_data_valid_character_lcd_avalon_lcd_slave => cpu_data_master_read_data_valid_character_lcd_avalon_lcd_slave,
      cpu_data_master_read_data_valid_cpu_jtag_debug_module => cpu_data_master_read_data_valid_cpu_jtag_debug_module,
      cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave => cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
      cpu_data_master_read_data_valid_onchip_mem_s1 => cpu_data_master_read_data_valid_onchip_mem_s1,
      cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave => cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave,
      cpu_data_master_read_data_valid_sys_clk_timer_s1 => cpu_data_master_read_data_valid_sys_clk_timer_s1,
      cpu_data_master_read_data_valid_sysid_control_slave => cpu_data_master_read_data_valid_sysid_control_slave,
      cpu_data_master_requests_A_reg_pio_s1 => cpu_data_master_requests_A_reg_pio_s1,
      cpu_data_master_requests_B_reg_pio_s1 => cpu_data_master_requests_B_reg_pio_s1,
      cpu_data_master_requests_Dbg_pc_s1 => cpu_data_master_requests_Dbg_pc_s1,
      cpu_data_master_requests_Dbg_reg_s1 => cpu_data_master_requests_Dbg_reg_s1,
      cpu_data_master_requests_Dbg_reg_set_s1 => cpu_data_master_requests_Dbg_reg_set_s1,
      cpu_data_master_requests_character_lcd_avalon_lcd_slave => cpu_data_master_requests_character_lcd_avalon_lcd_slave,
      cpu_data_master_requests_cpu_jtag_debug_module => cpu_data_master_requests_cpu_jtag_debug_module,
      cpu_data_master_requests_jtag_uart_avalon_jtag_slave => cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
      cpu_data_master_requests_onchip_mem_s1 => cpu_data_master_requests_onchip_mem_s1,
      cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave => cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave,
      cpu_data_master_requests_sys_clk_timer_s1 => cpu_data_master_requests_sys_clk_timer_s1,
      cpu_data_master_requests_sysid_control_slave => cpu_data_master_requests_sysid_control_slave,
      cpu_data_master_write => cpu_data_master_write,
      cpu_jtag_debug_module_readdata_from_sa => cpu_jtag_debug_module_readdata_from_sa,
      d1_A_reg_pio_s1_end_xfer => d1_A_reg_pio_s1_end_xfer,
      d1_B_reg_pio_s1_end_xfer => d1_B_reg_pio_s1_end_xfer,
      d1_Dbg_pc_s1_end_xfer => d1_Dbg_pc_s1_end_xfer,
      d1_Dbg_reg_s1_end_xfer => d1_Dbg_reg_s1_end_xfer,
      d1_Dbg_reg_set_s1_end_xfer => d1_Dbg_reg_set_s1_end_xfer,
      d1_character_lcd_avalon_lcd_slave_end_xfer => d1_character_lcd_avalon_lcd_slave_end_xfer,
      d1_cpu_jtag_debug_module_end_xfer => d1_cpu_jtag_debug_module_end_xfer,
      d1_jtag_uart_avalon_jtag_slave_end_xfer => d1_jtag_uart_avalon_jtag_slave_end_xfer,
      d1_onchip_mem_s1_end_xfer => d1_onchip_mem_s1_end_xfer,
      d1_ps2_keyboard_avalon_PS2_slave_end_xfer => d1_ps2_keyboard_avalon_PS2_slave_end_xfer,
      d1_sys_clk_timer_s1_end_xfer => d1_sys_clk_timer_s1_end_xfer,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      jtag_uart_avalon_jtag_slave_irq_from_sa => jtag_uart_avalon_jtag_slave_irq_from_sa,
      jtag_uart_avalon_jtag_slave_readdata_from_sa => jtag_uart_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
      onchip_mem_s1_readdata_from_sa => onchip_mem_s1_readdata_from_sa,
      ps2_keyboard_avalon_PS2_slave_irq_from_sa => ps2_keyboard_avalon_PS2_slave_irq_from_sa,
      ps2_keyboard_avalon_PS2_slave_readdata_from_sa => ps2_keyboard_avalon_PS2_slave_readdata_from_sa,
      ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa => ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa,
      registered_cpu_data_master_read_data_valid_onchip_mem_s1 => registered_cpu_data_master_read_data_valid_onchip_mem_s1,
      registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave => registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave,
      reset_n => clk_reset_n,
      sys_clk_timer_s1_irq_from_sa => sys_clk_timer_s1_irq_from_sa,
      sys_clk_timer_s1_readdata_from_sa => sys_clk_timer_s1_readdata_from_sa,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa
    );


  --the_cpu_instruction_master, which is an e_instance
  the_cpu_instruction_master : cpu_instruction_master_arbitrator
    port map(
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_latency_counter => cpu_instruction_master_latency_counter,
      cpu_instruction_master_readdata => cpu_instruction_master_readdata,
      cpu_instruction_master_readdatavalid => cpu_instruction_master_readdatavalid,
      cpu_instruction_master_waitrequest => cpu_instruction_master_waitrequest,
      clk => clk,
      cpu_instruction_master_address => cpu_instruction_master_address,
      cpu_instruction_master_granted_cpu_jtag_debug_module => cpu_instruction_master_granted_cpu_jtag_debug_module,
      cpu_instruction_master_granted_onchip_mem_s1 => cpu_instruction_master_granted_onchip_mem_s1,
      cpu_instruction_master_qualified_request_cpu_jtag_debug_module => cpu_instruction_master_qualified_request_cpu_jtag_debug_module,
      cpu_instruction_master_qualified_request_onchip_mem_s1 => cpu_instruction_master_qualified_request_onchip_mem_s1,
      cpu_instruction_master_read => cpu_instruction_master_read,
      cpu_instruction_master_read_data_valid_cpu_jtag_debug_module => cpu_instruction_master_read_data_valid_cpu_jtag_debug_module,
      cpu_instruction_master_read_data_valid_onchip_mem_s1 => cpu_instruction_master_read_data_valid_onchip_mem_s1,
      cpu_instruction_master_requests_cpu_jtag_debug_module => cpu_instruction_master_requests_cpu_jtag_debug_module,
      cpu_instruction_master_requests_onchip_mem_s1 => cpu_instruction_master_requests_onchip_mem_s1,
      cpu_jtag_debug_module_readdata_from_sa => cpu_jtag_debug_module_readdata_from_sa,
      d1_cpu_jtag_debug_module_end_xfer => d1_cpu_jtag_debug_module_end_xfer,
      d1_onchip_mem_s1_end_xfer => d1_onchip_mem_s1_end_xfer,
      onchip_mem_s1_readdata_from_sa => onchip_mem_s1_readdata_from_sa,
      reset_n => clk_reset_n
    );


  --the_cpu, which is an e_ptf_instance
  the_cpu : cpu
    port map(
      d_address => cpu_data_master_address,
      d_byteenable => cpu_data_master_byteenable,
      d_read => cpu_data_master_read,
      d_write => cpu_data_master_write,
      d_writedata => cpu_data_master_writedata,
      i_address => cpu_instruction_master_address,
      i_read => cpu_instruction_master_read,
      jtag_debug_module_debugaccess_to_roms => cpu_data_master_debugaccess,
      jtag_debug_module_readdata => cpu_jtag_debug_module_readdata,
      jtag_debug_module_resetrequest => cpu_jtag_debug_module_resetrequest,
      clk => clk,
      d_irq => cpu_data_master_irq,
      d_readdata => cpu_data_master_readdata,
      d_waitrequest => cpu_data_master_waitrequest,
      i_readdata => cpu_instruction_master_readdata,
      i_readdatavalid => cpu_instruction_master_readdatavalid,
      i_waitrequest => cpu_instruction_master_waitrequest,
      jtag_debug_module_address => cpu_jtag_debug_module_address,
      jtag_debug_module_begintransfer => cpu_jtag_debug_module_begintransfer,
      jtag_debug_module_byteenable => cpu_jtag_debug_module_byteenable,
      jtag_debug_module_clk => clk,
      jtag_debug_module_debugaccess => cpu_jtag_debug_module_debugaccess,
      jtag_debug_module_reset => cpu_jtag_debug_module_reset,
      jtag_debug_module_select => cpu_jtag_debug_module_chipselect,
      jtag_debug_module_write => cpu_jtag_debug_module_write,
      jtag_debug_module_writedata => cpu_jtag_debug_module_writedata,
      reset_n => cpu_jtag_debug_module_reset_n
    );


  --the_jtag_uart_avalon_jtag_slave, which is an e_instance
  the_jtag_uart_avalon_jtag_slave : jtag_uart_avalon_jtag_slave_arbitrator
    port map(
      cpu_data_master_granted_jtag_uart_avalon_jtag_slave => cpu_data_master_granted_jtag_uart_avalon_jtag_slave,
      cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave => cpu_data_master_qualified_request_jtag_uart_avalon_jtag_slave,
      cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave => cpu_data_master_read_data_valid_jtag_uart_avalon_jtag_slave,
      cpu_data_master_requests_jtag_uart_avalon_jtag_slave => cpu_data_master_requests_jtag_uart_avalon_jtag_slave,
      d1_jtag_uart_avalon_jtag_slave_end_xfer => d1_jtag_uart_avalon_jtag_slave_end_xfer,
      jtag_uart_avalon_jtag_slave_address => jtag_uart_avalon_jtag_slave_address,
      jtag_uart_avalon_jtag_slave_chipselect => jtag_uart_avalon_jtag_slave_chipselect,
      jtag_uart_avalon_jtag_slave_dataavailable_from_sa => jtag_uart_avalon_jtag_slave_dataavailable_from_sa,
      jtag_uart_avalon_jtag_slave_irq_from_sa => jtag_uart_avalon_jtag_slave_irq_from_sa,
      jtag_uart_avalon_jtag_slave_read_n => jtag_uart_avalon_jtag_slave_read_n,
      jtag_uart_avalon_jtag_slave_readdata_from_sa => jtag_uart_avalon_jtag_slave_readdata_from_sa,
      jtag_uart_avalon_jtag_slave_readyfordata_from_sa => jtag_uart_avalon_jtag_slave_readyfordata_from_sa,
      jtag_uart_avalon_jtag_slave_reset_n => jtag_uart_avalon_jtag_slave_reset_n,
      jtag_uart_avalon_jtag_slave_waitrequest_from_sa => jtag_uart_avalon_jtag_slave_waitrequest_from_sa,
      jtag_uart_avalon_jtag_slave_write_n => jtag_uart_avalon_jtag_slave_write_n,
      jtag_uart_avalon_jtag_slave_writedata => jtag_uart_avalon_jtag_slave_writedata,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      jtag_uart_avalon_jtag_slave_dataavailable => jtag_uart_avalon_jtag_slave_dataavailable,
      jtag_uart_avalon_jtag_slave_irq => jtag_uart_avalon_jtag_slave_irq,
      jtag_uart_avalon_jtag_slave_readdata => jtag_uart_avalon_jtag_slave_readdata,
      jtag_uart_avalon_jtag_slave_readyfordata => jtag_uart_avalon_jtag_slave_readyfordata,
      jtag_uart_avalon_jtag_slave_waitrequest => jtag_uart_avalon_jtag_slave_waitrequest,
      reset_n => clk_reset_n
    );


  --the_jtag_uart, which is an e_ptf_instance
  the_jtag_uart : jtag_uart
    port map(
      av_irq => jtag_uart_avalon_jtag_slave_irq,
      av_readdata => jtag_uart_avalon_jtag_slave_readdata,
      av_waitrequest => jtag_uart_avalon_jtag_slave_waitrequest,
      dataavailable => jtag_uart_avalon_jtag_slave_dataavailable,
      readyfordata => jtag_uart_avalon_jtag_slave_readyfordata,
      av_address => jtag_uart_avalon_jtag_slave_address,
      av_chipselect => jtag_uart_avalon_jtag_slave_chipselect,
      av_read_n => jtag_uart_avalon_jtag_slave_read_n,
      av_write_n => jtag_uart_avalon_jtag_slave_write_n,
      av_writedata => jtag_uart_avalon_jtag_slave_writedata,
      clk => clk,
      rst_n => jtag_uart_avalon_jtag_slave_reset_n
    );


  --the_onchip_mem_s1, which is an e_instance
  the_onchip_mem_s1 : onchip_mem_s1_arbitrator
    port map(
      cpu_data_master_granted_onchip_mem_s1 => cpu_data_master_granted_onchip_mem_s1,
      cpu_data_master_qualified_request_onchip_mem_s1 => cpu_data_master_qualified_request_onchip_mem_s1,
      cpu_data_master_read_data_valid_onchip_mem_s1 => cpu_data_master_read_data_valid_onchip_mem_s1,
      cpu_data_master_requests_onchip_mem_s1 => cpu_data_master_requests_onchip_mem_s1,
      cpu_instruction_master_granted_onchip_mem_s1 => cpu_instruction_master_granted_onchip_mem_s1,
      cpu_instruction_master_qualified_request_onchip_mem_s1 => cpu_instruction_master_qualified_request_onchip_mem_s1,
      cpu_instruction_master_read_data_valid_onchip_mem_s1 => cpu_instruction_master_read_data_valid_onchip_mem_s1,
      cpu_instruction_master_requests_onchip_mem_s1 => cpu_instruction_master_requests_onchip_mem_s1,
      d1_onchip_mem_s1_end_xfer => d1_onchip_mem_s1_end_xfer,
      onchip_mem_s1_address => onchip_mem_s1_address,
      onchip_mem_s1_byteenable => onchip_mem_s1_byteenable,
      onchip_mem_s1_chipselect => onchip_mem_s1_chipselect,
      onchip_mem_s1_clken => onchip_mem_s1_clken,
      onchip_mem_s1_readdata_from_sa => onchip_mem_s1_readdata_from_sa,
      onchip_mem_s1_write => onchip_mem_s1_write,
      onchip_mem_s1_writedata => onchip_mem_s1_writedata,
      registered_cpu_data_master_read_data_valid_onchip_mem_s1 => registered_cpu_data_master_read_data_valid_onchip_mem_s1,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      cpu_instruction_master_address_to_slave => cpu_instruction_master_address_to_slave,
      cpu_instruction_master_latency_counter => cpu_instruction_master_latency_counter,
      cpu_instruction_master_read => cpu_instruction_master_read,
      onchip_mem_s1_readdata => onchip_mem_s1_readdata,
      reset_n => clk_reset_n
    );


  --the_onchip_mem, which is an e_ptf_instance
  the_onchip_mem : onchip_mem
    port map(
      readdata => onchip_mem_s1_readdata,
      address => onchip_mem_s1_address,
      byteenable => onchip_mem_s1_byteenable,
      chipselect => onchip_mem_s1_chipselect,
      clk => clk,
      clken => onchip_mem_s1_clken,
      write => onchip_mem_s1_write,
      writedata => onchip_mem_s1_writedata
    );


  --the_ps2_keyboard_avalon_PS2_slave, which is an e_instance
  the_ps2_keyboard_avalon_PS2_slave : ps2_keyboard_avalon_PS2_slave_arbitrator
    port map(
      cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave => cpu_data_master_granted_ps2_keyboard_avalon_PS2_slave,
      cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave => cpu_data_master_qualified_request_ps2_keyboard_avalon_PS2_slave,
      cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave => cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave,
      cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave => cpu_data_master_requests_ps2_keyboard_avalon_PS2_slave,
      d1_ps2_keyboard_avalon_PS2_slave_end_xfer => d1_ps2_keyboard_avalon_PS2_slave_end_xfer,
      ps2_keyboard_avalon_PS2_slave_address => ps2_keyboard_avalon_PS2_slave_address,
      ps2_keyboard_avalon_PS2_slave_byteenable => ps2_keyboard_avalon_PS2_slave_byteenable,
      ps2_keyboard_avalon_PS2_slave_chipselect => ps2_keyboard_avalon_PS2_slave_chipselect,
      ps2_keyboard_avalon_PS2_slave_irq_from_sa => ps2_keyboard_avalon_PS2_slave_irq_from_sa,
      ps2_keyboard_avalon_PS2_slave_read => ps2_keyboard_avalon_PS2_slave_read,
      ps2_keyboard_avalon_PS2_slave_readdata_from_sa => ps2_keyboard_avalon_PS2_slave_readdata_from_sa,
      ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa => ps2_keyboard_avalon_PS2_slave_waitrequest_from_sa,
      ps2_keyboard_avalon_PS2_slave_write => ps2_keyboard_avalon_PS2_slave_write,
      ps2_keyboard_avalon_PS2_slave_writedata => ps2_keyboard_avalon_PS2_slave_writedata,
      registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave => registered_cpu_data_master_read_data_valid_ps2_keyboard_avalon_PS2_slave,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_byteenable => cpu_data_master_byteenable,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      ps2_keyboard_avalon_PS2_slave_irq => ps2_keyboard_avalon_PS2_slave_irq,
      ps2_keyboard_avalon_PS2_slave_readdata => ps2_keyboard_avalon_PS2_slave_readdata,
      ps2_keyboard_avalon_PS2_slave_waitrequest => ps2_keyboard_avalon_PS2_slave_waitrequest,
      reset_n => clk_reset_n
    );


  --the_ps2_keyboard, which is an e_ptf_instance
  the_ps2_keyboard : ps2_keyboard
    port map(
      PS2_CLK => PS2_CLK_to_and_from_the_ps2_keyboard,
      PS2_DAT => PS2_DAT_to_and_from_the_ps2_keyboard,
      irq => ps2_keyboard_avalon_PS2_slave_irq,
      readdata => ps2_keyboard_avalon_PS2_slave_readdata,
      waitrequest => ps2_keyboard_avalon_PS2_slave_waitrequest,
      address => ps2_keyboard_avalon_PS2_slave_address,
      byteenable => ps2_keyboard_avalon_PS2_slave_byteenable,
      chipselect => ps2_keyboard_avalon_PS2_slave_chipselect,
      clk => clk,
      read => ps2_keyboard_avalon_PS2_slave_read,
      reset => clk_reset,
      write => ps2_keyboard_avalon_PS2_slave_write,
      writedata => ps2_keyboard_avalon_PS2_slave_writedata
    );


  --the_sys_clk_timer_s1, which is an e_instance
  the_sys_clk_timer_s1 : sys_clk_timer_s1_arbitrator
    port map(
      cpu_data_master_granted_sys_clk_timer_s1 => cpu_data_master_granted_sys_clk_timer_s1,
      cpu_data_master_qualified_request_sys_clk_timer_s1 => cpu_data_master_qualified_request_sys_clk_timer_s1,
      cpu_data_master_read_data_valid_sys_clk_timer_s1 => cpu_data_master_read_data_valid_sys_clk_timer_s1,
      cpu_data_master_requests_sys_clk_timer_s1 => cpu_data_master_requests_sys_clk_timer_s1,
      d1_sys_clk_timer_s1_end_xfer => d1_sys_clk_timer_s1_end_xfer,
      sys_clk_timer_s1_address => sys_clk_timer_s1_address,
      sys_clk_timer_s1_chipselect => sys_clk_timer_s1_chipselect,
      sys_clk_timer_s1_irq_from_sa => sys_clk_timer_s1_irq_from_sa,
      sys_clk_timer_s1_readdata_from_sa => sys_clk_timer_s1_readdata_from_sa,
      sys_clk_timer_s1_reset_n => sys_clk_timer_s1_reset_n,
      sys_clk_timer_s1_write_n => sys_clk_timer_s1_write_n,
      sys_clk_timer_s1_writedata => sys_clk_timer_s1_writedata,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_waitrequest => cpu_data_master_waitrequest,
      cpu_data_master_write => cpu_data_master_write,
      cpu_data_master_writedata => cpu_data_master_writedata,
      reset_n => clk_reset_n,
      sys_clk_timer_s1_irq => sys_clk_timer_s1_irq,
      sys_clk_timer_s1_readdata => sys_clk_timer_s1_readdata
    );


  --the_sys_clk_timer, which is an e_ptf_instance
  the_sys_clk_timer : sys_clk_timer
    port map(
      irq => sys_clk_timer_s1_irq,
      readdata => sys_clk_timer_s1_readdata,
      address => sys_clk_timer_s1_address,
      chipselect => sys_clk_timer_s1_chipselect,
      clk => clk,
      reset_n => sys_clk_timer_s1_reset_n,
      write_n => sys_clk_timer_s1_write_n,
      writedata => sys_clk_timer_s1_writedata
    );


  --the_sysid_control_slave, which is an e_instance
  the_sysid_control_slave : sysid_control_slave_arbitrator
    port map(
      cpu_data_master_granted_sysid_control_slave => cpu_data_master_granted_sysid_control_slave,
      cpu_data_master_qualified_request_sysid_control_slave => cpu_data_master_qualified_request_sysid_control_slave,
      cpu_data_master_read_data_valid_sysid_control_slave => cpu_data_master_read_data_valid_sysid_control_slave,
      cpu_data_master_requests_sysid_control_slave => cpu_data_master_requests_sysid_control_slave,
      d1_sysid_control_slave_end_xfer => d1_sysid_control_slave_end_xfer,
      sysid_control_slave_address => sysid_control_slave_address,
      sysid_control_slave_readdata_from_sa => sysid_control_slave_readdata_from_sa,
      clk => clk,
      cpu_data_master_address_to_slave => cpu_data_master_address_to_slave,
      cpu_data_master_read => cpu_data_master_read,
      cpu_data_master_write => cpu_data_master_write,
      reset_n => clk_reset_n,
      sysid_control_slave_readdata => sysid_control_slave_readdata
    );


  --the_sysid, which is an e_ptf_instance
  the_sysid : sysid
    port map(
      readdata => sysid_control_slave_readdata,
      address => sysid_control_slave_address
    );


  --vhdl renameroo for output signals
  LCD_BLON_from_the_character_lcd <= internal_LCD_BLON_from_the_character_lcd;
  --vhdl renameroo for output signals
  LCD_EN_from_the_character_lcd <= internal_LCD_EN_from_the_character_lcd;
  --vhdl renameroo for output signals
  LCD_ON_from_the_character_lcd <= internal_LCD_ON_from_the_character_lcd;
  --vhdl renameroo for output signals
  LCD_RS_from_the_character_lcd <= internal_LCD_RS_from_the_character_lcd;
  --vhdl renameroo for output signals
  LCD_RW_from_the_character_lcd <= internal_LCD_RW_from_the_character_lcd;
  --vhdl renameroo for output signals
  out_port_from_the_A_reg_pio <= internal_out_port_from_the_A_reg_pio;
  --vhdl renameroo for output signals
  out_port_from_the_B_reg_pio <= internal_out_port_from_the_B_reg_pio;
  --vhdl renameroo for output signals
  out_port_from_the_Dbg_reg_set <= internal_out_port_from_the_Dbg_reg_set;

end europa;


--synthesis translate_off

library altera;
use altera.altera_europa_support_lib.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;



-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your libraries here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>

entity test_bench is 
end entity test_bench;


architecture europa of test_bench is
component wb_NiosProcessor is 
           port (
                 -- 1) global signals:
                    signal clk : IN STD_LOGIC;
                    signal reset_n : IN STD_LOGIC;

                 -- the_A_reg_pio
                    signal out_port_from_the_A_reg_pio : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- the_B_reg_pio
                    signal out_port_from_the_B_reg_pio : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);

                 -- the_Dbg_pc
                    signal in_port_to_the_Dbg_pc : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_Dbg_reg
                    signal in_port_to_the_Dbg_reg : IN STD_LOGIC_VECTOR (7 DOWNTO 0);

                 -- the_Dbg_reg_set
                    signal out_port_from_the_Dbg_reg_set : OUT STD_LOGIC_VECTOR (3 DOWNTO 0);

                 -- the_character_lcd
                    signal LCD_BLON_from_the_character_lcd : OUT STD_LOGIC;
                    signal LCD_DATA_to_and_from_the_character_lcd : INOUT STD_LOGIC_VECTOR (7 DOWNTO 0);
                    signal LCD_EN_from_the_character_lcd : OUT STD_LOGIC;
                    signal LCD_ON_from_the_character_lcd : OUT STD_LOGIC;
                    signal LCD_RS_from_the_character_lcd : OUT STD_LOGIC;
                    signal LCD_RW_from_the_character_lcd : OUT STD_LOGIC;

                 -- the_ps2_keyboard
                    signal PS2_CLK_to_and_from_the_ps2_keyboard : INOUT STD_LOGIC;
                    signal PS2_DAT_to_and_from_the_ps2_keyboard : INOUT STD_LOGIC
                 );
end component wb_NiosProcessor;

                signal LCD_BLON_from_the_character_lcd :  STD_LOGIC;
                signal LCD_DATA_to_and_from_the_character_lcd :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal LCD_EN_from_the_character_lcd :  STD_LOGIC;
                signal LCD_ON_from_the_character_lcd :  STD_LOGIC;
                signal LCD_RS_from_the_character_lcd :  STD_LOGIC;
                signal LCD_RW_from_the_character_lcd :  STD_LOGIC;
                signal PS2_CLK_to_and_from_the_ps2_keyboard :  STD_LOGIC;
                signal PS2_DAT_to_and_from_the_ps2_keyboard :  STD_LOGIC;
                signal clk :  STD_LOGIC;
                signal in_port_to_the_Dbg_pc :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal in_port_to_the_Dbg_reg :  STD_LOGIC_VECTOR (7 DOWNTO 0);
                signal jtag_uart_avalon_jtag_slave_dataavailable_from_sa :  STD_LOGIC;
                signal jtag_uart_avalon_jtag_slave_readyfordata_from_sa :  STD_LOGIC;
                signal out_port_from_the_A_reg_pio :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal out_port_from_the_B_reg_pio :  STD_LOGIC_VECTOR (15 DOWNTO 0);
                signal out_port_from_the_Dbg_reg_set :  STD_LOGIC_VECTOR (3 DOWNTO 0);
                signal reset_n :  STD_LOGIC;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add your component and signal declaration here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


begin

  --Set us up the Dut
  DUT : wb_NiosProcessor
    port map(
      LCD_BLON_from_the_character_lcd => LCD_BLON_from_the_character_lcd,
      LCD_DATA_to_and_from_the_character_lcd => LCD_DATA_to_and_from_the_character_lcd,
      LCD_EN_from_the_character_lcd => LCD_EN_from_the_character_lcd,
      LCD_ON_from_the_character_lcd => LCD_ON_from_the_character_lcd,
      LCD_RS_from_the_character_lcd => LCD_RS_from_the_character_lcd,
      LCD_RW_from_the_character_lcd => LCD_RW_from_the_character_lcd,
      PS2_CLK_to_and_from_the_ps2_keyboard => PS2_CLK_to_and_from_the_ps2_keyboard,
      PS2_DAT_to_and_from_the_ps2_keyboard => PS2_DAT_to_and_from_the_ps2_keyboard,
      out_port_from_the_A_reg_pio => out_port_from_the_A_reg_pio,
      out_port_from_the_B_reg_pio => out_port_from_the_B_reg_pio,
      out_port_from_the_Dbg_reg_set => out_port_from_the_Dbg_reg_set,
      clk => clk,
      in_port_to_the_Dbg_pc => in_port_to_the_Dbg_pc,
      in_port_to_the_Dbg_reg => in_port_to_the_Dbg_reg,
      reset_n => reset_n
    );


  process
  begin
    clk <= '0';
    loop
       wait for 10 ns;
       clk <= not clk;
    end loop;
  end process;
  PROCESS
    BEGIN
       reset_n <= '0';
       wait for 200 ns;
       reset_n <= '1'; 
    WAIT;
  END PROCESS;


-- <ALTERA_NOTE> CODE INSERTED BETWEEN HERE
--add additional architecture here
-- AND HERE WILL BE PRESERVED </ALTERA_NOTE>


end europa;



--synthesis translate_on
