--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:07:00 11/28/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_TLB.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: TLB
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
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL;
 
ENTITY test_TLB IS
END test_TLB;
 
ARCHITECTURE behavior OF test_TLB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT TLB
    PORT(
         write_index : in  INTEGER range 0 to 31;
         is_tlb_write : IN  std_logic;
         entry_hi : IN  std_logic_vector(31 downto 0);
         entry_lo0 : IN  std_logic_vector(31 downto 0);
         entry_lo1 : IN  std_logic_vector(31 downto 0);
         vaddr : IN  std_logic_vector(31 downto 0);
         paddr : OUT  std_logic_vector(31 downto 0);
         tlb_intr : OUT  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal write_index : integer range 0 to 31 := 0;
   signal is_tlb_write : std_logic := '0';
   signal entry_hi : std_logic_vector(31 downto 0) := (others => '0');
   signal entry_lo0 : std_logic_vector(31 downto 0) := (others => '0');
   signal entry_lo1 : std_logic_vector(31 downto 0) := (others => '0');
   signal vaddr : std_logic_vector(31 downto 0) := (others => '0');
   signal clk : std_logic := '0';
   signal reset : std_logic := '0';

 	--Outputs
   signal paddr : std_logic_vector(31 downto 0);
   signal tlb_intr : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: TLB PORT MAP (
          write_index => write_index,
          is_tlb_write => is_tlb_write,
          entry_hi => entry_hi,
          entry_lo0 => entry_lo0,
          entry_lo1 => entry_lo1,
          vaddr => vaddr,
          paddr => paddr,
          tlb_intr => tlb_intr,
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
        -- hold reset state for 100 ns.
        reset <= '1';
        wait for 100 ns;	
        reset <= '0';
		  report "testing kernel address map";
        vaddr <= X"80000044";
        wait for clk_period;
        assert tlb_intr = '0' report "tlb_intr error" severity error;
        assert paddr = X"80000044" report "paddr error" severity error;
		  
		  report "testing tlbwi";
        write_index <= 15;
        is_tlb_write <= '1';
        entry_hi <= X"00020000";
        entry_lo0 <= X"000abcde";
        entry_lo1 <= X"00012345";
        wait for clk_period;
		  		  
		  report "testing tlbmiss intr";
        is_tlb_write <= '0';
        vaddr <= X"70000000";
        wait for clk_period;
        assert tlb_intr = '1' report "tlb_intr error" severity error;

		  report "testing user addr map ppn0";
        vaddr <= X"40000abc";
        wait for clk_period;
        assert tlb_intr = '0' report "tlb_intr error" severity error;
		  print_hex(paddr);
        assert paddr = X"abcdeabc" report "paddr error" severity error;

	     report "testing user addr map ppn1";
        vaddr <= X"40001abc";
        wait for clk_period;
        assert tlb_intr = '0' report "tlb_intr error" severity error;
        assert paddr = X"12345abc" report "paddr error" severity error;

        wait;
    end process;

END;
