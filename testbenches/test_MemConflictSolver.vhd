--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:38:15 11/10/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_MemConflictSolver.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: MemConflictSolver
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
 
ENTITY test_MemConflictSolver IS
END test_MemConflictSolver;
 
ARCHITECTURE behavior OF test_MemConflictSolver IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT MemConflictSolver
    PORT(
         r_pc : IN  std_logic;
         w_pc : IN  std_logic;
         r_mem : IN  std_logic;
         w_mem : IN  std_logic;
         is_dma_mem : IN  std_logic;
         addr_pc : IN  std_logic_vector(31 downto 0);
         addr_mem : in  std_logic_vector(31 downto 0);
         is_bubble : OUT  std_logic;
         addr_core : OUT  std_logic_vector(31 downto 0);
         r_core : OUT  std_logic;
         w_core : OUT  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal r_pc : std_logic := '0';
   signal w_pc : std_logic := '0';
   signal r_mem : std_logic := '0';
   signal w_mem : std_logic := '0';
   signal is_dma_mem : std_logic := '0';
   signal addr_pc : std_logic_vector(31 downto 0) := (others => '0');

	--BiDirs
   signal addr_mem : std_logic_vector(31 downto 0);

 	--Outputs
   signal is_bubble : std_logic;
   signal addr_core : std_logic_vector(31 downto 0);
   signal r_core : std_logic;
   signal w_core : std_logic;
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: MemConflictSolver PORT MAP (
          r_pc => r_pc,
          w_pc => w_pc,
          r_mem => r_mem,
          w_mem => w_mem,
          is_dma_mem => is_dma_mem,
          addr_pc => addr_pc,
          addr_mem => addr_mem,
          is_bubble => is_bubble,
          addr_core => addr_core,
          r_core => r_core,
          w_core => w_core
        );

   -- Stimulus process
	stim_proc: process
	begin		
		-- hold reset state for 100 ns.
		addr_pc <= X"00000008";
		addr_mem <= X"00000000";
		wait for 10 ns;	
		report "test use r_pc";
		r_pc <= '1';
		w_pc <= '0';
		r_mem <= '0';
		w_mem <= '0';
		is_dma_mem <= '0';
		wait for 10 ns;	
		assert r_core = '1' report "r_core error" severity error;
		assert w_core = '0' report "w_core error" severity error;
		assert addr_core = X"00000008" report "addr_core error" severity error;
		assert is_bubble = '0' report "is_bubble error" severity error;
		wait for 10 ns;
		report "test is_dma";
		is_dma_mem <= '1';
		wait for 10 ns;
		assert r_core = '1' report "r_core error" severity error;
		assert w_core = '0' report "w_core error" severity error;
		assert addr_core = X"00000008" report "addr_core error" severity error;
		assert is_bubble = '1' report "is_bubble error" severity error;
		wait for 10 ns;
		report "test w_mem";
		is_dma_mem <= '0';
		r_mem <= '0';
		w_mem <= '1';
		wait for 10 ns;
		assert r_core = '0' report "r_core error" severity error;
		assert w_core = '1' report "w_core error" severity error;
		assert addr_core = X"00000000" report "addr_core error" severity error;
		assert is_bubble = '1' report "is_bubble error" severity error;

		-- insert stimulus here 

		wait;
	end process;

END;
