--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   18:40:32 11/24/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_VictimFinder.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: VictimFinder
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
 
ENTITY test_VictimFinder IS
END test_VictimFinder;
 
ARCHITECTURE behavior OF test_VictimFinder IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT VictimFinder
    PORT(
			now_pc : IN  std_logic_vector(31 downto 0);
			is_bubble : IN  std_logic;
			pre_branch : in STD_LOGIC;
			victim_pc : OUT  std_logic_vector(31 downto 0);
			is_in_slot : out STD_LOGIC;
			clk : IN  std_logic;
			reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal now_pc : std_logic_vector(31 downto 0) := (others => '0');
   signal is_bubble : std_logic := '0';
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';
   signal pre_branch : std_logic := '0';

 	--Outputs
   signal victim_pc : std_logic_vector(31 downto 0);
   signal is_in_slot : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
  
 	-- instantiate the unit under test (uut)
    uut: victimfinder port map (
           now_pc => now_pc,
           is_bubble => is_bubble,
		   pre_branch => pre_branch,
           victim_pc => victim_pc,
		   is_in_slot => is_in_slot,
           clk => clk,
           reset => reset
         );
 
    -- clock process definitions
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
		is_bubble <= '0';
		-- hold reset state for 100 ns.
		wait for 100 ns;	
		reset <= '0';
		now_pc <= X"80000010";
		wait for 10 ns;
		now_pc <= X"80000014";
		wait for 10 ns;
		assert victim_pc = X"80000010" report "victim_pc0 error" severity error;
		assert is_in_slot = '0' report "is_in_slot error" severity error;
		now_pc <= X"80000018";
		pre_branch <= '1';
		wait for 10 ns;
		assert victim_pc = X"80000014" report "victim_pc1 error" severity error;
		assert is_in_slot = '0' report "is_in_slot error" severity error;
		now_pc <= X"00000000";
		is_bubble <= '1';
		wait for 10 ns;
		assert victim_pc = X"80000018" report "victim_pc2 error" severity error;
		assert is_in_slot = '1' report "is_in_slot error" severity error;
		wait for 10 ns;
		assert victim_pc = X"80000018" report "victim_pc3 error" severity error;
		assert is_in_slot = '1' report "is_in_slot error" severity error;
		wait for 10 ns;
		assert victim_pc = X"80000018" report "victim_pc4 error" severity error;
		assert is_in_slot = '1' report "is_in_slot error" severity error;


		-- insert stimulus here 

		wait;
	end process;

END;
