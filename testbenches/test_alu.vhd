--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   19:18:34 11/02/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_alu.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: alu
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
 
ENTITY test_alu IS
END test_alu;
 
ARCHITECTURE behavior OF test_alu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT alu
    PORT(
         lhs : IN  std_logic_vector(31 downto 0);
         rhs : IN  std_logic_vector(31 downto 0);
         shift_amount : IN  integer range 0 to 31;
         alu_opcode : IN  integer range 0 to 15;
         result : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal lhs : std_logic_vector(31 downto 0) := (others => '0');
   signal rhs : std_logic_vector(31 downto 0) := (others => '0');
   signal shift_amount : integer range 0 to 31;
   signal alu_opcode : integer range 0 to 15;

 	--Outputs
   signal result : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: alu PORT MAP (
          lhs => lhs,
          rhs => rhs,
          shift_amount => shift_amount,
          alu_opcode => alu_opcode,
          result => result
        );
		  
   -- Stimulus process
   stim_proc: process
   begin		
		-- hold reset state for 10 ns.
		wait for 10 ns;	
		lhs <= X"FF0000FF";
		rhs <= X"FFFF0000";

		report "test none";
		alu_opcode <= ALU_NONE;
		wait for 10 ns;	
		assert result = X"00000000" report "none error" severity error;

		report "test add";
		alu_opcode <= ALU_ADD;
		wait for 10 ns;	
		assert result = X"FEFF00FF" report "add error" severity error;

		report "test sub";
		alu_opcode <= ALU_SUB;
		wait for 10 ns;	
		assert result = X"FF0100FF" report "sub error" severity error;

		report "test and";
		alu_opcode <= ALU_AND;
		wait for 10 ns;	
		assert result = X"FF000000" report "and error" severity error;

		report "test or";
		alu_opcode <= ALU_OR;
		wait for 10 ns;	
		assert result = X"FFFF00FF" report "or error" severity error;

		report "test xor";
		alu_opcode <= ALU_XOR;
		wait for 10 ns;	
		assert result = X"00FF00FF" report "xor error" severity error;

		report "test srav";
		alu_opcode <= ALU_SRAV;
		lhs <= X"0000000F";
		rhs <= X"FFFF0000";
		wait for 10 ns;	
		assert result = X"FFFFFFFE" report "srav error" severity error;
      
		report "test ls";
		lhs <= X"FF0000FF";
		rhs <= X"00000000";
		alu_opcode <= ALU_LS;
		wait for 10 ns;	
		assert result = X"00000001" report "ls error" severity error;
		lhs <= X"7FFFFFFF";
		wait for 10 ns;	
		assert result = X"00000000" report "ls error" severity error;

		report "test lu";
		lhs <= X"FFFFFFF0";
		rhs <= X"00000000";
		alu_opcode <= ALU_LU;
		wait for 10 ns;	
		assert result = X"00000000" report "lu error" severity error;
		rhs <= X"FFFFFFFF";
		wait for 10 ns;	
		assert result = X"00000001" report "lu error" severity error;

		report "test sll";
		alu_opcode <= ALU_SLL;
		rhs <= X"FFFF0000";
		shift_amount <= 4;
		wait for 10 ns;	
		assert result = X"FFF00000" report "sll error" severity error;
		
		report "test sllv";
		alu_opcode <= ALU_SLLV;
		rhs <= X"FFFF0000";
		lhs <= X"00000004";
		wait for 10 ns;	
		assert result = X"FFF00000" report "sllv error" severity error;
		
		report "test srlv";
		alu_opcode <= ALU_SRLV;
		rhs <= X"FFFF0000";
		lhs <= X"00000004";
		wait for 10 ns;	
		assert result = X"0FFFF000" report "srlv error" severity error;

		wait;
   end process;

END;
