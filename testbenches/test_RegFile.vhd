--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:29:08 11/01/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_RegFile.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RegFile
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments: -- -- Notes: 
-- This testbench has been automatically generated using types std_logic and
-- std_logic_vector for the ports of the unit under test.  Xilinx recommends
-- that these types always be used for the top-level I/O of a design in order
-- to guarantee that the testbench will bind correctly to the post-implementation 
-- simulation model.
--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
USE ieee.numeric_std.ALL;
USE work.CPUComponent.ALL;
 
ENTITY test_RegFile IS
END test_RegFile;
 
ARCHITECTURE behavior OF test_RegFile IS 
    --Inputs
    signal rs_id : integer range 0 to 127;
    signal rt_id : integer range 0 to 127;
    signal rd_id : integer range 0 to 127;
    signal is_regwrite : std_logic := '0';
    signal rd_data : std_logic_vector(31 downto 0) := (others => '0');
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';
    signal status_new : std_logic_vector(31 downto 0);
    signal cause_new : std_logic_vector(31 downto 0);
    signal badvaddr_new : std_logic_vector(31 downto 0);
    signal entry_hi_new : std_logic_vector(31 downto 0);
    signal force_cp0_write : std_logic := '0';

    --Outputs
    signal rs_data : std_logic_vector(31 downto 0);
    signal rt_data : std_logic_vector(31 downto 0);
    signal status : std_logic_vector(31 downto 0);
    signal cause : std_logic_vector(31 downto 0);
    signal count : std_logic_vector(31 downto 0);
    signal compare : std_logic_vector(31 downto 0);
    signal ebase : std_logic_vector(31 downto 0);
    signal epc : std_logic_vector(31 downto 0);

    -- Clock period definitions
    constant clk_period : time := 10 ns;

    constant INDEX_I : integer := 32;
    constant ENTRY_LO0_I : integer := 34;
    constant ENTRY_LO1_I : integer := 35;
    constant BADVADDR_I : integer := 41;
    constant COUNT_I : integer := 42;
    constant ENTRYHI_I : integer := 43;
    constant COMPARE_I : integer := 44;
    constant STATUS_I : integer := 45;
    constant CAUSE_I : integer := 47;
    constant EPC_I : integer := 48;
    constant EBASE_I : integer := 49;

BEGIN
    -- Instantiate the Unit Under Test (UUT)
   uut: RegFile PORT MAP (
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
          entry_hi_new => entry_hi_new,
          force_cp0_write => force_cp0_write,
          status => status,
          cause => cause,
          count => count,
          compare => compare,
          ebase => ebase,
          epc => epc,
          clk => clk,
          reset => reset
        );

   -- Clock process definitions
   clk_process :process
   begin
        clk <= '0';
        wait for clk_period/2;
        clk <= '1';
        wait for clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
        variable write_data1 : std_logic_vector(31 downto 0); 
        variable write_data2 : std_logic_vector(31 downto 0);
   begin        
        write_data1 := X"12345678";
        write_data2 := X"87654321";
        reset <= '1';
        is_regwrite <= '0';
        -- hold reset state for 100 ns.
        wait for clk_period*10;
        reset <= '0';

      -- test reset state
        report "testing init";
        for i in 0 to 31 loop
            rs_id <= i;
            rt_id <= i;
            wait for clk_period;
            assert rs_data = X"00000000" report "rs init read failed at $" & integer'image(i) severity error;
            assert rt_data = X"00000000" report "rt init read failed at $" & integer'image(i) severity error;
        end loop;

        report "testing write to each reg and read afterwards";
        for i in 0 to 63 loop
            rd_id <= i;
            is_regwrite <= '1';
            rd_data <= std_logic_vector(to_unsigned(i+1, rd_data'length));
            wait for clk_period;
        end loop;

        is_regwrite <= '0';
        rs_id <= 0;
        rt_id <= 0;
        wait for clk_period;
        assert rs_data = X"00000000" report "rs read failed at $0" severity error;
        assert rt_data = X"00000000" report "rt read failed at $0" severity error;

        for i in 1 to 63 loop
            rs_id <= i;
            rt_id <= i;
            wait for clk_period;
            if i /= COUNT_I then
                assert rs_data = std_logic_vector(to_unsigned(i+1, rd_data'length)) 
                    report "rs read failed at $" & integer'image(i) severity error;
                assert rt_data = std_logic_vector(to_unsigned(i+1, rd_data'length)) 
                    report "rt read failed at $" & integer'image(i) severity error;
            end if;
        end loop;
      
        report "testing write and read in the same clk cycle";
        for i in 1 to 63 loop
            rs_id <= i;
            rt_id <= i;
            rd_id <= i;
            rd_data <= write_data2;
            is_regwrite <= '1';
            wait for clk_period;
            if i /= COUNT_I then
                assert rs_data = write_data2 report "rs read failed at $" & integer'image(i) severity error;
                assert rt_data = write_data2 report "rt read failed at $" & integer'image(i) severity error;
            end if;
        end loop;
        wait for clk_period;
        report "testing cp0 registers";
        force_cp0_write <= '1';
        status_new <= X"01234567";
        cause_new <= X"76543210";
        badvaddr_new <= X"ABCDE000";
        entry_hi_new <= X"EDBCA987";
        is_regwrite <= '1';
        rd_data <= X"00000100";
        rd_id <= STATUS_I;
        wait for clk_period;
		  is_regwrite <= '0';
		  wait for clk_period;
        assert status = X"01234567" report "status error";
        assert cause = X"76543210" report "status error";
        wait;
   end process;
END;
