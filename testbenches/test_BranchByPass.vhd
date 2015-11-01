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
         rt : IN  std_logic_vector(31 downto 0);
         immediate : IN  std_logic_vector(31 downto 0);
         is_reg_inst : IN  std_logic;
           branch_opcode : in  INTEGER RANGE 0 to 15;
         is_branch : IN  std_logic;
         is_jump : IN  std_logic;
         is_jr : IN  std_logic;
         branch_offset : IN  std_logic_vector(31 downto 0);
         next_pc : IN  std_logic_vector(31 downto 0);
         jump_pc : IN  std_logic_vector(31 downto 0);
         final_pc : OUT  std_logic_vector(31 downto 0);
         need_branch : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rs : std_logic_vector(31 downto 0) := (others => '0');
   signal rt : std_logic_vector(31 downto 0) := (others => '0');
   signal immediate : std_logic_vector(31 downto 0) := (others => '0');
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
