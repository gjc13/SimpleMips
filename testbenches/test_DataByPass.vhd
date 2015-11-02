--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:06:05 11/02/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/test_DataByPass.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DataByPass
-- 
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
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_DataByPass IS
END test_DataByPass;
 
ARCHITECTURE behavior OF test_DataByPass IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DataByPass
    PORT(
         rs_id : in  INTEGER RANGE 0 to 127;
         rt_id : in  INTEGER RANGE 0 to 127;
         l_rd_id : in  INTEGER RANGE 0 to 127;
         ll_rd_id : in  INTEGER RANGE 0 to 127;
         l_is_reg_write : IN  std_logic;
         ll_is_reg_write : IN  std_logic;
         is_reg_inst : IN  std_logic;
         rs : IN  std_logic_vector(31 downto 0);
         rt : IN  std_logic_vector(31 downto 0);
         immediate : IN  std_logic_vector(31 downto 0);
         l_result : IN  std_logic_vector(31 downto 0);
         ll_result : IN  std_logic_vector(31 downto 0);
         lhs : OUT  std_logic_vector(31 downto 0);
         rhs : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal rs_id : integer range 0 to 127;
   signal rt_id : integer range 0 to 127;
   signal l_rd_id : integer range 0 to 127;
   signal ll_rd_id : integer range 0 to 127;
   signal l_is_reg_write : std_logic := '0';
   signal ll_is_reg_write : std_logic := '0';
   signal is_reg_inst : std_logic := '0';
   signal rs : std_logic_vector(31 downto 0) := (others => '0');
   signal rt : std_logic_vector(31 downto 0) := (others => '0');
   signal immediate : std_logic_vector(31 downto 0) := (others => '0');
   signal l_result : std_logic_vector(31 downto 0) := (others => '0');
   signal ll_result : std_logic_vector(31 downto 0) := (others => '0');

 	--Outputs
   signal lhs : std_logic_vector(31 downto 0);
   signal rhs : std_logic_vector(31 downto 0);
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DataByPass PORT MAP (
          rs_id => rs_id,
          rt_id => rt_id,
          l_rd_id => l_rd_id,
          ll_rd_id => ll_rd_id,
          l_is_reg_write => l_is_reg_write,
          ll_is_reg_write => ll_is_reg_write,
          is_reg_inst => is_reg_inst,
          rs => rs,
          rt => rt,
          immediate => immediate,
          l_result => l_result,
          ll_result => ll_result,
          lhs => lhs,
          rhs => rhs
        );
   -- Stimulus process
   stim_proc: process
   begin		
		rs <= X"00000000";
		rt <= X"00000001";
		immediate <= X"00000002";
		l_result <= X"00000003";
		ll_result <= X"00000004";
		wait for 10 ns;

		report "test use rs and rt";
		report "    test not reg_write";
		l_is_reg_write <= '0';
		ll_is_reg_write <= '0';
		l_rd_id <= 2;
		ll_rd_id <= 2;
		rs_id <= 2;
		rt_id <= 2;
		is_reg_inst <= '1';
		wait for 10 ns;
		assert lhs = X"00000000" report "lhs error" severity error;
		assert rhs = X"00000001" report "rhs error" severity error;

		report "    test not same regid";
		l_is_reg_write <= '1';
		ll_is_reg_write <= '1';
		l_rd_id <= 3;
		ll_rd_id <= 3;
		wait for 10 ns;
		assert lhs = X"00000000" report "lhs error" severity error;
		assert rhs = X"00000001" report "rhs error" severity error;

		report "    test avoid $0 l_result";
		l_rd_id <= 0;
		ll_rd_id <= 0;
		rs_id <= 0;
		rt_id <= 0;
		wait for 10 ns;
		assert lhs = X"00000000" report "lhs error" severity error;
		assert rhs = X"00000001" report "rhs error" severity error;

		report "test use rs and immediate";
		is_reg_inst <= '0';
		wait for 10 ns;
		assert lhs = X"00000000" report "lhs error" severity error;
		assert rhs = X"00000002" report "rhs error" severity error;

		report "test use l_result and immediate";
		l_is_reg_write <= '1';
		ll_is_reg_write <= '0';
		l_rd_id <= 31;
		rs_id <= 31;
		rt_id <= 31;
		is_reg_inst <= '0';
		wait for 10 ns;
		assert lhs = X"00000003" report "lhs error" severity error;
		assert rhs = X"00000002" report "rhs error" severity error;

		report "test use l_result and l_result";
		is_reg_inst <= '1';
		wait for 10 ns;
		assert lhs = X"00000003" report "lhs error" severity error;
		assert rhs = X"00000003" report "rhs error" severity error;

		report "test priority of l_result and ll_result";
		ll_is_reg_write <= '1';
		ll_rd_id <= 31;
		wait for 10 ns;
		assert lhs = X"00000003" report "lhs error" severity error;
		assert rhs = X"00000003" report "rhs error" severity error;

		report "test use ll_result and rt";
		l_is_reg_write <= '0';
		ll_is_reg_write <= '1';
		ll_rd_id <= 3;
		rs_id <= 3;
		rt_id <= 5;
		is_reg_inst <= '1';
		wait for 10 ns;
		assert lhs = X"00000004" report "lhs error" severity error;
		assert rhs = X"00000001" report "rhs error" severity error;

		report "test use l_result and ll_result";
		l_is_reg_write <= '1';
		ll_is_reg_write <= '1';
		l_rd_id <= 2;
		rs_id <= 2;
		ll_rd_id <= 3;
		rt_id <= 3;
		is_reg_inst <= '1';
		wait for 10 ns;
		assert lhs = X"00000003" report "lhs error" severity error;
		assert rhs = X"00000004" report "rhs error" severity error;

		wait;
   end process;

END;
