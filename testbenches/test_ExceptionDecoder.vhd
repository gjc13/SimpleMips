--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   13:25:03 11/27/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_ExceptionDecoder.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- -- VHDL Test Bench Created by ISE for module: ExceptionDecoder -- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
--
-- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
use work.CPUComponent.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_ExceptionDecoder IS
END test_ExceptionDecoder;
 
ARCHITECTURE behavior OF test_ExceptionDecoder IS 

    --Inputs
    signal is_in_slot : std_logic := '0';
    signal victim_addr : std_logic_vector(31 downto 0) := (others => '0');
    signal mem_addr : std_logic_vector(31 downto 0) := (others => '0');
    signal mem_r : std_logic := '0';
    signal mem_w : std_logic := '0';
    signal status_old : std_logic_vector(31 downto 0) := (others => '0');
    signal cause_old : std_logic_vector(31 downto 0) := (others => '0');
    signal epc_old : std_logic_vector(31 downto 0) := (others => '0');
    signal entryhi_old : std_logic_vector(31 downto 0) := (others => '0');
    signal ebase : std_logic_vector(31 downto 0) := (others => '0');
    signal is_intr : std_logic := '0';
    signal syscall_intr : std_logic := '0';
    signal clk_intr : std_logic := '0';
    signal com1_intr : std_logic := '0';
    signal dma_intr : std_logic := '0';
    signal ps2_intr : std_logic := '0';
    signal ri_intr : std_logic := '0';
    signal tlb_intr : std_logic := '0';
    signal ade_intr : std_logic := '0';
    signal is_eret : std_logic := '0';
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    --Outputs
    signal epc_new : std_logic_vector(31 downto 0);
    signal status_new : std_logic_vector(31 downto 0);
    signal cause_new : std_logic_vector(31 downto 0);
    signal badvaddr_new : std_logic_vector(31 downto 0);
    signal entryhi_new : std_logic_vector(31 downto 0);
    signal handler_addr : std_logic_vector(31 downto 0);
    signal is_cancel : std_logic;
    signal force_cp0_write : std_logic;

    --Inputs
    signal rs_id : integer range 0 to 127;
    signal rt_id : integer range 0 to 127;
    signal rd_id : integer range 0 to 127;
    signal is_regwrite : std_logic := '0';
    signal rd_data : std_logic_vector(31 downto 0) := (others => '0');

    --Outputs
    signal rs_data : std_logic_vector(31 downto 0);
    signal rt_data : std_logic_vector(31 downto 0);
    signal count : std_logic_vector(31 downto 0);
    signal compare : std_logic_vector(31 downto 0);

    -- Clock period definitions
    constant clk_intr_period : time := 10 ns;
    constant clk_period : time := 10 ns;

    constant INDEX_I : integer := 32;
    constant ENTRY_LO0_I : integer := 34;
    constant ENTRY_LO1_I : integer := 35;
    constant BADVADDR_I : integer := 40;
    constant COUNT_I : integer := 41;
    constant ENTRYHI_I : integer := 42;
    constant COMPARE_I : integer := 43;
    constant STATUS_I : integer := 44;
    constant CAUSE_I : integer := 45;
    constant EPC_I : integer := 46;
    constant EBASE_I : integer := 47;

BEGIN
 
    -- Instantiate the Unit Under Test (UUT)
   uut: ExceptionDecoder PORT MAP (
          is_in_slot => is_in_slot,
          victim_addr => victim_addr,
          mem_addr => mem_addr,
          mem_r => mem_r,
          mem_w => mem_w,
          status_old => status_old,
          cause_old => cause_old,
          epc_old => epc_old,
          entryhi_old => entryhi_old,
          ebase => ebase,
          is_intr => is_intr,
          syscall_intr => syscall_intr,
          clk_intr => clk_intr,
          com1_intr => com1_intr,
          dma_intr => dma_intr,
          ps2_intr => ps2_intr,
          ri_intr => ri_intr,
          tlb_intr => tlb_intr,
          ade_intr => ade_intr,
          is_eret => is_eret,
          epc_new => epc_new,
          status_new => status_new,
          cause_new => cause_new,
          badvaddr_new => badvaddr_new,
          entryhi_new => entryhi_new,
          handler_addr => handler_addr,
          is_cancel => is_cancel,
          force_cp0_write => force_cp0_write,
          clk => clk,
          reset => reset
        );

   regs: RegFile PORT MAP (
          rs_id => rs_id,
          rt_id => rt_id,
          rd_id => rd_id,
          is_regwrite => is_regwrite,
          rd_data => rd_data,
          rs_data => rs_data,
          rt_data => rt_data,
          status_new => status_new,
          cause_new => cause_new,
          badvaddr_new => badvaddr_new,
          entry_hi_new => entryhi_new,
          force_cp0_write => force_cp0_write,
          status => status_old,
          cause => cause_old,
          count => count,
          compare => compare,
          ebase => ebase,
          epc => epc_old,
          clk => clk,
          reset => reset
        );
 
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;
 

   -- Stimulus process
    stim_proc: process
    begin        
        reset <= '1';
        -- hold reset state for 100 ns.
        wait for 100 ns;  
        reset <= '0';
        wait for clk_period;
        is_intr <= '1';
        syscall_intr <= '1';
        clk_intr <= '0';
        com1_intr <= '0';
        dma_intr <= '0';
        ps2_intr <= '0';
        ri_intr <= '0';
        tlb_intr <= '0';
        ade_intr <= '0';
        is_eret <= '0';
        is_in_slot <= '0';
        wait for clk_period;

        assert is_cancel = '0' report "is cancel error" severity error;
        assert force_cp0_write = '0' report "force_cp0_write error" severity error;
        is_intr <= '0';
        wait for clk_period;

        report "test syscall exception";
        rd_id <= STATUS_I;
        rd_data <= X"00400001";
        is_regwrite <= '1';
        wait for clk_period;
        is_regwrite <= '0';
        is_intr <= '1';
        syscall_intr <= '1';
        clk_intr <= '0';
        com1_intr <= '0';
        dma_intr <= '0';
        ps2_intr <= '0';
        ri_intr <= '0';
        tlb_intr <= '0';
        ade_intr <= '0';
        is_eret <= '0';
        is_in_slot <= '0';
        victim_addr <= X"80001004";
        wait for 1ns;
        assert is_cancel = '1' report "is cancel error" severity error;
        assert force_cp0_write = '1' report "force_cp0_write error" severity error;
        assert status_new = X"00400003"report "status_new error" severity error;
        assert epc_new = X"80001004" report "epc_new error" severity error;
        assert cause_new = X"00000020" report "cause_new error" severity error;
        assert handler_addr = X"BFC00380" report "handler_addr error" severity error;
        wait for 9ns;
        assert is_cancel = '1' report "is cancel error" severity error;
        assert force_cp0_write = '0' report "force_cp0_write error" severity error;
        wait for clk_period;

        rd_id <= STATUS_I;
        rd_data <= X"00000011";
        is_regwrite <= '1';
        is_intr <= '0';
        syscall_intr <= '0';
        assert is_cancel = '1' report "is cancel error" severity error;
        wait for clk_period;

        rd_id <= EBASE_I;
        rd_data <= X"80000000";
        assert is_cancel = '0' report "is cancel error" severity error;
        is_regwrite <= '1';

        wait for clk_period;
        assert is_cancel = '0' report "is cancel error" severity error;
        is_regwrite <= '0';

        wait for clk_period;

        report "test tlbwl intr";
        rd_id <= STATUS_I;
        rd_data <= X"00000001";
        is_regwrite <= '1';
        is_intr <= '0';
        tlb_intr <= '0';
        wait for clk_period;
        rd_id <= CAUSE_I;
        rd_data <= X"00000000";
        is_regwrite <= '1';
        wait for clk_period;
        is_regwrite <= '0';

        wait for 50 ns;
        is_intr <= '1';
        tlb_intr <= '1';
        is_in_slot <= '1';
        mem_w <= '0';
        mem_r <= '1';
        wait for clk_period;
        assert status_new = X"00000003"report "status_new error" severity error;
        assert cause_new = X"80000008" report "cause_new error" severity error;
        assert handler_addr = X"80000000" report "handler_addr error" severity error;
        assert epc_new = X"80001000" report "epc_new error" severity error;

        wait for clk_period;

        report "test tlbws intr";
        rd_id <= STATUS_I;
        rd_data <= X"00000001";
        is_regwrite <= '1';
        is_intr <= '0';
        tlb_intr <= '0';
        wait for clk_period;
        rd_id <= CAUSE_I;
        rd_data <= X"00000000";
        is_regwrite <= '1';
        wait for clk_period;
        is_regwrite <= '0';

        wait for 50 ns;
        is_intr <= '1'; 
        tlb_intr <= '1';
        is_in_slot <= '1';
        mem_w <= '1';
        mem_r <= '0';
        wait for clk_period;
        assert status_new = X"00000003"report "status_new error" severity error;
        assert cause_new = X"8000000c" report "cause_new error" severity error;
        assert handler_addr = X"80000000" report "handler_addr error" severity error;
		  tlb_intr <= '0';
		  is_intr <= '0';
		  is_eret <= '1';
		  wait for 10 ns;
		  is_eret <= '0';
		  wait for 10 ns;

        report "test ri intr";
        rd_id <= STATUS_I;
        rd_data <= X"00000001";
        is_regwrite <= '1';
        is_intr <= '0';
        tlb_intr <= '0';
        wait for clk_period;
        rd_id <= CAUSE_I;
        rd_data <= X"00000000";
        is_regwrite <= '1';
        wait for clk_period;
        is_regwrite <= '0';

        wait for 50 ns;
        is_intr <= '1'; 
        ri_intr <= '1';
        is_in_slot <= '0';
        wait for clk_period;
        assert status_new = X"00000003"report "status_new error" severity error;
        assert cause_new = X"00000028" report "cause_new error" severity error;
        assert handler_addr = X"80000180" report "handler_addr error" severity error;

        report "test clk intr";
        rd_id <= STATUS_I;
        rd_data <= X"00000001";
        is_regwrite <= '1';
        is_intr <= '0';
        ri_intr <= '0';
        wait for clk_period;
        rd_id <= CAUSE_I;
        rd_data <= X"00000000";
        is_regwrite <= '1';
        wait for clk_period;
        is_regwrite <= '0';

        wait for 50 ns;
        is_intr <= '1'; 
        clk_intr <= '1';
        is_in_slot <= '0';
        wait for clk_period;
        assert status_new = X"00000003"report "status_new error" severity error;
        assert cause_new = X"00008000" report "cause_new error" severity error;
        assert handler_addr = X"80000180" report "handler_addr error" severity error;

        report "test com1 intr";
        rd_id <= STATUS_I;
        rd_data <= X"00000001";
        is_regwrite <= '1';
        is_intr <= '0';
        clk_intr <= '0';
        wait for clk_period;
        rd_id <= CAUSE_I;
        rd_data <= X"00000000";
        is_regwrite <= '1';
        wait for clk_period;
        is_regwrite <= '0';

        wait for 50 ns;
        is_intr <= '1'; 
        com1_intr <= '1';
        is_in_slot <= '0';
        wait for clk_period;
        assert status_new = X"00000003"report "status_new error" severity error;
        assert cause_new = X"00001000" report "cause_new error" severity error;
        assert handler_addr = X"80000180" report "handler_addr error" severity error;

        report "test dma intr";
        rd_id <= STATUS_I;
        rd_data <= X"00000011";
        is_regwrite <= '1';
        is_intr <= '0';
        com1_intr <= '0';
        wait for clk_period;
        rd_id <= CAUSE_I;
        rd_data <= X"00000000";
        is_regwrite <= '1';
        wait for clk_period;
        is_regwrite <= '0';

        wait for 50 ns;
        is_intr <= '1'; 
        dma_intr <= '1';
        is_in_slot <= '0';
        wait for clk_period;
        assert status_new = X"00000013"report "status_new error" severity error;
        assert cause_new = X"00000800" report "cause_new error" severity error;
        assert handler_addr = X"80000180" report "handler_addr error" severity error;

        report "test ps2 intr";
        rd_id <= STATUS_I;
        rd_data <= X"00000011";
        is_regwrite <= '1';
        is_intr <= '0';
        dma_intr <= '0';
        wait for clk_period;
        rd_id <= CAUSE_I;
        rd_data <= X"00000000";
        is_regwrite <= '1';
        wait for clk_period;
        is_regwrite <= '0';

        wait for 50 ns;
        is_intr <= '1'; 
        ps2_intr <= '1';
        is_in_slot <= '0';
        wait for clk_period;
        assert status_new = X"00000013"report "status_new error" severity error;
        assert cause_new = X"00004000" report "cause_new error" severity error;
        assert handler_addr = X"80000180" report "handler_addr error" severity error;

        rd_id <= STATUS_I;
        rd_data <= X"00000013";
        is_regwrite <= '1';
        is_intr <= '0';
        com1_intr <= '0';
        wait for clk_period;

        is_intr <= '0';
        wait for 50 ns;
        is_eret <= '1';
		  wait for 10 ns;
        assert status_new = X"0000011" report "status_new error" severity error;
		  
		  wait for 10 ns;
		  report("test intr_state");
		  rd_id <= STATUS_I;
        rd_data <= X"00000011";
        is_regwrite <= '1';
        is_intr <= '0';
        dma_intr <= '0';
        wait for clk_period;
        rd_id <= CAUSE_I;
        rd_data <= X"00000000";
        is_regwrite <= '1';
        wait for clk_period;
        is_regwrite <= '0';
		  ps2_intr <= '0';
		  is_eret <= '0';

        wait for 50 ns;
        is_intr <= '1'; 
		  tlb_intr <= '1';
		  wait for 10 ns;
		  report("tlb");
		  tlb_intr <= '0';
		  is_intr <= '0';
		  is_eret <= '1';
		  wait for 10 ns;
		  report("idle");
		  clk_intr <= '1';
		  is_intr <= '1';
		  is_eret <= '0';
		  wait for 10 ns;
		  report("other_intr");
		  tlb_intr <= '1';
		  wait for 20 ns;
		  report("tlb");
		  tlb_intr <= '0';
		  is_eret <= '1';
		  wait for 10 ns;
		  report("other_intr");
		  is_eret <= '0';
		  wait for 10 ns;
		  clk_intr <= '0';
		  is_intr <= '0';
		  is_eret <= '1';
		  wait for 10 ns;
		  report("idle");
		  
        wait;
    end process;
END;

