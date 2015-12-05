--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   21:05:53 12/05/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_SerialToRam.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: top_SerialToRam
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
 
ENTITY test_SerialToRam IS
END test_SerialToRam;
 
ARCHITECTURE behavior OF test_SerialToRam IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT top_SerialToRam
    PORT(
         clk : IN  std_logic;
         rst : IN  std_logic;
         sram_addr : OUT  std_logic_vector(19 downto 0);
         data_bus : INOUT  std_logic_vector(31 downto 0);
         ce : OUT  std_logic;
         oe : OUT  std_logic;
         we : OUT  std_logic;
         RX : IN  std_logic;
         TX : OUT  std_logic;
         intr : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal clk : std_logic := '0';
   signal rst : std_logic := '0';
   signal RX : std_logic := '0';
   signal intr : std_logic := '0';

	--BiDirs
   signal data_bus : std_logic_vector(31 downto 0);

 	--Outputs
   signal sram_addr : std_logic_vector(19 downto 0);
   signal ce : std_logic;
   signal oe : std_logic;
   signal we : std_logic;
   signal TX : std_logic;

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: top_SerialToRam PORT MAP (
          clk => clk,
          rst => rst,
          sram_addr => sram_addr,
          data_bus => data_bus,
          ce => ce,
          oe => oe,
          we => we,
          RX => RX,
          TX => TX,
          intr => intr
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
      rst <= '0';
      -- hold reset state for 100 ns.
      wait for 100 ns;	
      rst <= '1';
      wait for clk_period*10;
      intr <= '1';
      -- insert stimulus here 

      wait;
   end process;

END;
