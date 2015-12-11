--------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
--
-- Create Date:   17:06:55 11/01/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_InstDecode.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: InstDecode
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
use work.Definitions.ALL;
use work.CPUComponent.ALL;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_InstDecode IS
END test_InstDecode;
 
ARCHITECTURE behavior OF test_InstDecode IS 
    

   --Inputs
   signal inst : std_logic_vector(31 downto 0) := (others => '0');
	signal npc : std_logic_vector(31 downto 0);

 	--Outputs
   signal is_jump : std_logic;
   signal jump_pc : std_logic_vector(31 downto 0);
   signal is_jr : std_logic;
   signal is_jl : std_logic;
	signal is_link : std_logic;
   signal is_branch : std_logic;
   signal branch_offset : std_logic_vector(31 downto 0);
   signal branch_opcode : integer range 0 to 15;
   signal is_reg_inst : std_logic;
   signal is_mem_read : std_logic;
   signal is_mem_write : std_logic;
   signal mem_opcode : integer range 0 to 7;
   signal shift_amount : integer range 0 to 31;
   signal is_reg_write : std_logic;
   signal alu_opcode : integer range 0 to 15;
   signal rd_id : integer range 0 to 127;
   signal immediate : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
	-- Instantiate the Unit Under Test (UUT)
   uut: InstDecode PORT MAP (
          inst => inst,
          npc => npc,
          is_jump => is_jump,
          jump_pc => jump_pc,
          is_jr => is_jr,
          is_jl => is_jl,
          is_link => is_link,
          is_branch => is_branch,
          branch_offset => branch_offset,
          branch_opcode => branch_opcode,
          is_reg_inst => is_reg_inst,
          is_mem_read => is_mem_read,
          is_mem_write => is_mem_write,
          mem_opcode => mem_opcode,
          shift_amount => shift_amount,
          is_reg_write => is_reg_write,
          alu_opcode => alu_opcode,
          rd_id => rd_id,
          immediate => immediate
        );

   -- Stimulus process
   stim_proc: process
   begin		
		report "testing nop";

		wait for 20ns;
		inst <= X"00000000";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '0' report "is_reg_write error" severity error;
		assert alu_opcode = ALU_NONE report "alu_opcode error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing jr";
		inst <= X"03e00008";
		wait for 10ns;
		assert is_jump = '1' report "is_jump error" severity error;
		assert is_jr = '1' report "is_jr error" severity error;
		assert is_jl = '0' report "is_jl error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '0' report "is_reg_write error" severity error;
		assert alu_opcode = ALU_ADD report "alu_opcode error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing jalr";
		inst <= X"0320f809";
		wait for 10ns;
		assert is_jump = '1' report "is_jump error" severity error;
		assert is_jr = '1' report "is_jr error" severity error;
		assert is_jl = '1' report "is_jl error" severity error;
		assert is_link = '1' report "is_link error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert is_link = '1' report "is_link error" severity error;
		wait for 10ns;

		report "testing addu";
		inst <= X"03c0e821";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert alu_opcode = ALU_ADD report "alu_opcode error" severity error;
		assert rd_id = 29 report "rd_id error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing slt";
		inst <= X"0109582a";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert alu_opcode = ALU_LS report "alu_opcode error" severity error;
		assert rd_id = 11 report "rd_id error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;
	
		report "testing jal";
		inst <= X"0c000013";
		npc <= X"8000001c";
		wait for 10ns;
		assert is_jump = '1' report "is_jump error" severity error;
		assert is_jr = '0' report "is_jr error" severity error;
		assert is_jl = '1' report "is_jl error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert rd_id = 31 report "rd_id error" severity error;
		assert is_link = '1' report "is_link error" severity error;
		wait for 10ns;

		report "testing bgez";
		inst <= X"0401ffff";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '1' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert branch_offset = X"FFFFFFFC" report "branch_offset error" severity error;
		assert branch_opcode = B_GE report "branch_opcode error" severity error;
		assert immediate = X"00000000" report "immediate error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '0' report "is_reg_write error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing beq";
		inst <= X"1040fff4";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '1' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert branch_offset = X"FFFFFFD0" report "branch_offset error" severity error;
		assert branch_opcode = B_EQ report "branch_opcode error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '0' report "is_reg_write error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing bne";
		inst <= X"1462000c";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_branch = '1' report "is_branch error" severity error;
		assert branch_offset = X"00000030" report "branch_offset error" severity error;
		assert branch_opcode = B_NE report "branch_opcode error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '0' report "is_reg_write error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing blez";
		inst <= X"18800001";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '1' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert branch_offset = X"00000004" report "branch_offset error" severity error;
		assert branch_opcode = B_LE report "branch_opcode error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '0' report "is_reg_write error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing bgtz";
		inst <= X"1d60fffc";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '1' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert branch_offset = X"FFFFFFF0" report "branch_offset error" severity error;
		assert branch_opcode = B_G report "branch_opcode error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '0' report "is_reg_write error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing addiu";
		inst <= X"27bdfff8";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert alu_opcode = ALU_ADD report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert rd_id = 29 report "rd_id error" severity error;
		assert immediate = X"FFFFFFF8" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing ori";
		inst <= X"344203f8";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert alu_opcode = ALU_OR report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert rd_id = 2 report "rd_id error" severity error;
		assert immediate = X"000003f8" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing andi";
		inst <= X"30420001";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert alu_opcode = ALU_AND report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert rd_id = 2 report "rd_id error" severity error;
		assert immediate = X"00000001" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing lui";
		inst <= X"3c03bfd0";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert alu_opcode = ALU_ADD report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert rd_id = 3 report "rd_id error" severity error;
		assert immediate = X"bfd00000" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing lb";
		inst <= X"8000b030";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '1' report "is_mem_read error" severity error;
		assert mem_opcode = MEM_BS report "mem_opcode error" severity error;
		assert alu_opcode = ALU_ADD report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert rd_id = 0 report "rd_id error" severity error;
		assert immediate = X"ffffb030" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing lw";
		inst <= X"8c423040";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '1' report "is_mem_read error" severity error;
		assert mem_opcode = MEM_W report "mem_opcode error" severity error;
		assert alu_opcode = ALU_ADD report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert rd_id = 2 report "rd_id error" severity error;
		assert immediate = X"00003040" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing sw";
		inst <= X"afbe000c";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '1' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert mem_opcode = MEM_W report "mem_opcode error" severity error;
		assert alu_opcode = ALU_ADD report "alu_opcode error" severity error;
		assert is_reg_write = '0' report "is_reg_write error" severity error;
		assert immediate = X"0000000c" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing and";
		inst <= X"03c0e824";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert alu_opcode = ALU_AND report "alu_opcode error" severity error;
		assert rd_id = 29 report "rd_id error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing bltz";
		inst <= X"0400ffff";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '1' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert branch_offset = X"FFFFFFFC" report "branch_offset error" severity error;
		assert branch_opcode = B_L report "branch_opcode error" severity error;
		assert immediate = X"00000000" report "immediate error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '0' report "is_reg_write error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing lbu";
		inst <= X"9000b030";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '1' report "is_mem_read error" severity error;
		assert mem_opcode = MEM_BU report "mem_opcode error" severity error;
		assert alu_opcode = ALU_ADD report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert rd_id = 0 report "rd_id error" severity error;
		assert immediate = X"ffffb030" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing subu";
		inst <= X"03c0e823";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert alu_opcode = ALU_SUB report "alu_opcode error" severity error;
		assert rd_id = 29 report "rd_id error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing sb";
		inst <= X"a3be000c";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '1' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert mem_opcode = MEM_BS report "mem_opcode error" severity error;
		assert alu_opcode = ALU_ADD report "alu_opcode error" severity error;
		assert is_reg_write = '0' report "is_reg_write error" severity error;
		assert immediate = X"0000000c" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing sll";
		inst <= X"0019bcc0";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert mem_opcode = MEM_W report "mem_opcode error" severity error;
		assert alu_opcode = ALU_SLL report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert immediate = X"00000000" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert shift_amount = 19 report "shift_amount error" severity error;
		wait for 10ns;

		report "testing slti";
		inst <= X"28020001";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert alu_opcode = ALU_LS report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert rd_id = 2 report "rd_id error" severity error;
		assert immediate = X"00000001" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing sltiu";
		inst <= X"2c020001";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='0' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert alu_opcode = ALU_LS report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert rd_id = 2 report "rd_id error" severity error;
		assert immediate = X"00000001" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing sltu";
		inst <= X"0109582b";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert alu_opcode = ALU_LU report "alu_opcode error" severity error;
		assert rd_id = 11 report "rd_id error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		wait for 10ns;

		report "testing sra";
		inst <= X"0019bcc3";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert mem_opcode = MEM_W report "mem_opcode error" severity error;
		assert alu_opcode = ALU_SRA report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert immediate = X"00000000" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert shift_amount = 19 report "shift_amount error" severity error;
		wait for 10ns;

		report "testing srl";
		inst <= X"0019bcc2";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert mem_opcode = MEM_W report "mem_opcode error" severity error;
		assert alu_opcode = ALU_SRL report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert immediate = X"00000000" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert shift_amount = 19 report "shift_amount error" severity error;
		wait for 10ns;

		report "testing sllv";
		inst <= X"01495804";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert mem_opcode = MEM_W report "mem_opcode error" severity error;
		assert alu_opcode = ALU_SLLV report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert immediate = X"00000000" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert shift_amount = 0 report "shift_amount error" severity error;
		wait for 10ns;
		
		report "testing srlv";
		inst <= X"01495806";
		wait for 10ns;
		assert is_jump = '0' report "is_jump error" severity error;
		assert is_branch = '0' report "is_branch error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert is_reg_inst ='1' report "is_rega_inst error" severity error;
		assert is_mem_write = '0' report "is_mem_write error" severity error;
		assert is_mem_read = '0' report "is_mem_read error" severity error;
		assert mem_opcode = MEM_W report "mem_opcode error" severity error;
		assert alu_opcode = ALU_SRLV report "alu_opcode error" severity error;
		assert is_reg_write = '1' report "is_reg_write error" severity error;
		assert immediate = X"00000000" report "immediate error" severity error;
		assert is_link = '0' report "is_link error" severity error;
		assert shift_amount = 0 report "shift_amount error" severity error;
		wait for 10ns;

      wait;
   end process;

END;
