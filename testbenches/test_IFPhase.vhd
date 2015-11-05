--------------------------------------------------------------------------------
-- Company: -- Engineer:
--
-- Create Date:   14:58:10 11/05/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_IFPhase.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: IFPhase
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
 
ENTITY test_IFPhase IS
END test_IFPhase;
 
ARCHITECTURE behavior OF test_IFPhase IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT IFPhase
    PORT(
         is_bubble : IN  std_logic;
         need_branch : IN  std_logic;
         branch_pc : IN  std_logic_vector(31 downto 0);
         data_mem : IN  std_logic_vector(31 downto 0);
         addr_pc : OUT  std_logic_vector(31 downto 0);
         r_pc : OUT  std_logic;
         w_pc : OUT  std_logic;
         inst_if : OUT  std_logic_vector(31 downto 0);
         npc_if : OUT  std_logic_vector(31 downto 0);
         clk : IN  std_logic;
         reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal is_bubble : std_logic := '0';
   signal need_branch : std_logic := '0';
   signal data_mem : std_logic_vector(31 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

	--BiDirs
   signal branch_pc : std_logic_vector(31 downto 0);

 	--Outputs
   signal addr_pc : std_logic_vector(31 downto 0);
   signal r_pc : std_logic;
   signal w_pc : std_logic;
   signal inst_if : std_logic_vector(31 downto 0);
   signal npc_if : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: IFPhase PORT MAP (
          is_bubble => is_bubble,
          need_branch => need_branch,
          branch_pc => branch_pc,
          data_mem => data_mem,
          addr_pc => addr_pc,
          r_pc => r_pc,
          w_pc => w_pc,
          inst_if => inst_if,
          npc_if => npc_if,
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
	begin		
		need_branch <= '0';
		is_bubble <= '0';
		branch_pc <= X"80000030";
		data_mem <= X"FFFFFFFF";
		reset <= '1';
		wait for 10 ns;	
		reset <= '0';
		wait for 10 ns;
		report "test initial";
		assert npc_if = X"80000004" report "npc_if error" severity error;
		assert addr_pc = X"80000000" report "addr_pc error" severity error;
		assert inst_if = X"FFFFFFFF" report "inst_if error" severity error;
		assert r_pc = '1' report "r_pc error" severity error;
		assert w_pc = '0' report "w_pc error" severity error;
		wait for 10 ns;
		report "test normal pc move";
		assert npc_if = X"80000008" report "npc_if error" severity error;
		assert addr_pc = X"80000004" report "addr_pc error" severity error;

		is_bubble <= '1';
		need_branch <= '0';
		wait for 10 ns;
		report "test bubble"; 
		assert npc_if = X"80000008" report "npc_if error" severity error;
		assert addr_pc = X"80000004" report "addr_pc error" severity error;
		assert inst_if = X"00000000" report "inst_if error" severity error;
		
		is_bubble <= '0';
		need_branch <= '1';
		wait for 10ns;
		report "test branch";
		assert npc_if = X"80000034" report "npc_if error" severity error;
		assert addr_pc = X"80000030" report "addr_pc error" severity error;

		is_bubble <= '0';
		need_branch <= '0';
		wait for 10 ns;
		report "test move after branch";
		assert npc_if = X"80000038" report "npc_if error" severity error;
		assert addr_pc = X"80000034" report "addr_pc error" severity error;

		is_bubble <= '1';
		need_branch <= '1';
		wait for 10 ns;
		report "test move backward to branch";
		assert npc_if = X"80000034" report "npc_if error" severity error;
		assert addr_pc = X"80000030" report "addr_pc error" severity error;
		assert inst_if = X"00000000" report "inst_if error" severity error;
		wait;
	end process;
END;
