--------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
--
-- Create Date:   00:00:13 11/02/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_BranchByPass.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: BranchByPass
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
use work.Definitions.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_BranchByPass IS
END test_BranchByPass;
 
ARCHITECTURE behavior OF test_BranchByPass IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT BranchByPass
    PORT(
			rs : IN  std_logic_vector(31 downto 0);
			rt : in  STD_LOGIC_VECTOR (31 downto 0);
			immediate : in  STD_LOGIC_VECTOR (31 downto 0);
			l_result : in STD_LOGIC_VECTOR(31 downto 0);
			ll_result : in STD_LOGIC_VECTOR(31 downto 0);
			lll_result : in STD_LOGIC_VECTOR(31 downto 0);
			rs_id : in INTEGER RANGE 0 to 127;
			rt_id : in INTEGER RANGE 0 to 127;
			l_rd_id : in INTEGER RANGE 0 to 127;
			ll_rd_id : in INTEGER RANGE 0 to 127;
			lll_rd_id : in INTEGER RANGE 0 to 127;
			l_is_reg_write : in STD_LOGIC;
			ll_is_reg_write : in STD_LOGIC;
			lll_is_reg_write : in STD_LOGIC;
			is_reg_inst : in  STD_LOGIC;
			branch_opcode : in  INTEGER RANGE 0 to 15;
			is_branch : in  STD_LOGIC;
			is_jump : in  STD_LOGIC;
			is_jr : in  STD_LOGIC;
			branch_offset : in  STD_LOGIC_VECTOR (31 downto 0);
			next_pc : in  STD_LOGIC_VECTOR (31 downto 0);
			jump_pc : in  STD_LOGIC_VECTOR (31 downto 0);
			final_pc : out  STD_LOGIC_VECTOR (31 downto 0);
			need_branch : out  STD_LOGIC);
       END COMPONENT;
    
   --Inputs
	signal rs : std_logic_vector(31 downto 0) := (others => '0');
	signal rt : std_logic_vector(31 downto 0) := (others => '0');
	signal immediate : std_logic_vector(31 downto 0) := (others => '0');
	signal l_result : STD_LOGIC_VECTOR(31 downto 0);
	signal ll_result : STD_LOGIC_VECTOR(31 downto 0);
	signal lll_result : STD_LOGIC_VECTOR(31 downto 0);
	signal rs_id : INTEGER RANGE 0 to 127;
	signal rt_id : INTEGER RANGE 0 to 127;
	signal l_rd_id : INTEGER RANGE 0 to 127;
	signal ll_rd_id : INTEGER RANGE 0 to 127;
	signal lll_rd_id : INTEGER RANGE 0 to 127;
	signal l_is_reg_write : STD_LOGIC;
	signal ll_is_reg_write : STD_LOGIC;
	signal lll_is_reg_write : STD_LOGIC;

	signal is_reg_inst : std_logic := '0';
	signal branch_opcode : integer range 0 to 15;
	signal is_branch : std_logic := '0';
	signal is_jump : std_logic := '0';
	signal is_jr : std_logic := '0';
	signal branch_offset : std_logic_vector(31 downto 0) := (others => '0');
	signal next_pc : std_logic_vector(31 downto 0) := (others => '0');
	signal jump_pc : std_logic_vector(31 downto 0) := (others => '0');

	--Outputs
	signal final_pc : std_logic_vector(31 downto 0);
	signal need_branch : std_logic;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: BranchByPass PORT MAP (
          rs => rs,
          rt => rt,
          immediate => immediate,
		  l_result => l_result,
		  ll_result => ll_result,
		  lll_result => lll_result,
		  rs_id => rs_id,
		  rt_id => rt_id,
		  l_rd_id => l_rd_id,
		  ll_rd_id => ll_rd_id,
		  lll_rd_id => lll_rd_id,
		  l_is_reg_write => l_is_reg_write,
		  ll_is_reg_write => ll_is_reg_write,
		  lll_is_reg_write => lll_is_reg_write,
          is_reg_inst => is_reg_inst,
          branch_opcode => branch_opcode,
          is_branch => is_branch,
          is_jump => is_jump,
          is_jr => is_jr,
          branch_offset => branch_offset,
          next_pc => next_pc,
          jump_pc => jump_pc,
          final_pc => final_pc,
          need_branch => need_branch
        );
 

   -- Stimulus process
   stim_proc: process
   begin		
      -- hold reset state for 100 ns.
		wait for 10 ns;

		l_is_reg_write <= '0';
		ll_is_reg_write <= '0';
		lll_is_reg_write <= '0';
		is_branch <= '1';
		
		report "test b_all";
		branch_opcode <= B_ALL;
		next_pc <= X"FFFFFFFC";
		branch_offset <= X"FFFFFFFC";
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;
		assert final_pc = X"FFFFFFF8" report " final_pc error" severity error;

		report "test b_eq hit";
		branch_opcode <= B_EQ;
		rs <= X"12345678";
		rt <= X"12345678";
		is_reg_inst <= '1';
		next_pc <= X"00000000";
		branch_offset <= X"FFFFFFFC";
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;
		assert final_pc = X"FFFFFFFC" report " final_pc error" severity error;

		report "test b_eq miss";
		branch_opcode <= B_EQ;
		rs <= X"12345678";
		immediate <= X"12345677";
		is_reg_inst <= '0';
		wait for 10 ns;
		assert need_branch = '0' report "need branch error" severity error;

		report "test b_ne hit";
		branch_opcode <= B_NE;
		rs <= X"12345678";
		immediate <= X"12345679";
		is_reg_inst <= '0';
		next_pc <= X"FFFFFFF0";
		branch_offset <= X"00000000";
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;
		assert final_pc = X"FFFFFFF0" report " final_pc error" severity error;

		report "test b_ne miss";
		branch_opcode <= B_NE;
		rs <= X"12345678";
		rt <= X"12345678";
		is_reg_inst <= '1';
		wait for 10 ns;
		assert need_branch = '0' report "need branch error" severity error;

		report "test b_g hit";
		branch_opcode <= B_G;
		rs <= X"12345679";
		immediate <= X"00000000";
		is_reg_inst <= '0';
		next_pc <= X"10000000";
		branch_offset <= X"FFFFFFFC";
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;
		assert final_pc = X"0FFFFFFC" report " final_pc error" severity error;

		report "test b_g miss";
		branch_opcode <= B_G;
		rs <= X"00000000";
		immediate <= X"00000000";
		is_reg_inst <= '0';
		wait for 10 ns;
		assert need_branch = '0' report "need branch error" severity error;

		report "test b_ge hit";
		branch_opcode <= B_GE;
		rs <= X"12345679";
		rt <= X"00000000";
		is_reg_inst <= '1';
		next_pc <= X"10000000";
		branch_offset <= X"00000004";
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;
		assert final_pc = X"10000004" report " final_pc error" severity error;

		report "test b_ge miss";
		branch_opcode <= B_GE;
		rs <= X"FFFFFFFF";
		rt <= X"00000000";
		is_reg_inst <= '1';
		wait for 10 ns;
		assert need_branch = '0' report "need branch error" severity error;

		report "test b_l hit";
		branch_opcode <= B_L;
		rs <= X"80000000";
		immediate <= X"00000000";
		is_reg_inst <= '0';
		next_pc <= X"00000000";
		branch_offset <= X"00000000";
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;
		assert final_pc = X"00000000" report " final_pc error" severity error;

		report "test b_l miss";
		branch_opcode <= B_L;
		rs <= X"00000001";
		immediate <= X"00000000";
		is_reg_inst <= '0';
		wait for 10 ns;
		assert need_branch = '0' report "need branch error" severity error;

		report "test b_le hit";
		branch_opcode <= B_LE;
		rs <= X"00000000";
		immediate <= X"00000000";
		is_reg_inst <= '0';
		next_pc <= X"00000000";
		branch_offset <= X"00000000";
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;
		assert final_pc = X"00000000" report " final_pc error" severity error;

		report "test b_le miss";
		branch_opcode <= B_LE;
		rs <= X"7FFFFFFF";
		immediate <= X"00000000";
		is_reg_inst <= '0';
		wait for 10 ns;
		assert need_branch = '0' report "need branch error" severity error;

		report "test avoid $0 bypass";
		branch_opcode <= B_EQ;
		rs <= X"00000000";
		rt <= X"00000000";
		l_result <= X"00000001";
		ll_result <= X"00000002";
		lll_result <= X"00000003";
		rs_id <= 0;
		rt_id <= 2;
		l_rd_id <= 0;
		ll_rd_id <= 0;
		lll_rd_id <= 0;
		l_is_reg_write <= '1';
		ll_is_reg_write <= '1';
		lll_is_reg_write <= '1';
		is_reg_inst <= '1';
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;

		report "test l_result priority";
		rt <= X"00000001";
		rs_id <= 1;
		l_rd_id <= 1;
		ll_rd_id <= 1;
		lll_rd_id <= 1;
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;

		report "test ll_result priority";
		rs <= X"00000002";
		rs_id <= 2;
		rt_id <= 1;
		l_is_reg_write <= '0';
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;

		report "test use lll_result";
		immediate <= X"00000003";
		rs_id <= 1;
		is_reg_inst <= '0';
		ll_is_reg_write <= '0';
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;

		report "test jr";
		is_jr <= '1';
		is_jump <= '1';
		rs <= X"01234560";
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;
		assert final_pc = X"01234560" report " final_pc error" severity error;

		report "test j";
		is_jr <= '0';
		jump_pc <= X"00000004";
		wait for 10 ns;
		assert need_branch = '1' report "need branch error" severity error;
		assert final_pc = X"00000004" report " final_pc error" severity error;


		report "test finish"; 

		wait;
   end process;
END;
