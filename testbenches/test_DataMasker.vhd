--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   14:57:52 11/09/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_DataMasker.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: DataMasker
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
 
ENTITY test_DataMasker IS
END test_DataMasker;
 
ARCHITECTURE behavior OF test_DataMasker IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT DataMasker
    PORT(
         data_in : IN  std_logic_vector(31 downto 0);
         data_old : in STD_LOGIC_VECTOR (31 downto 0);
         mem_op_code : IN  integer range 0 to 7;
         data_out : OUT  std_logic_vector(31 downto 0)
        );
    END COMPONENT;
    

   --Inputs
   signal data_in : std_logic_vector(31 downto 0) := (others => '0');
   signal data_old : std_logic_vector(31 downto 0) := X"12345678";
   signal mem_op_code : integer range 0 to 7;

 	--Outputs
   signal data_out : std_logic_vector(31 downto 0);
   -- No clocks detected in port list. Replace <clock> below with 
   -- appropriate port name 
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: DataMasker PORT MAP (
          data_in => data_in,
          data_old => data_old,
          mem_op_code => mem_op_code,
          data_out => data_out
        );

   -- Stimulus process
   stim_proc: process
   begin		
		-- hold reset state for 100 ns.
		wait for 100 ns;	
		-- insert stimulus here 
		data_in <= X"0FFFFFFF";
		mem_op_code <= MEM_W;
		wait for 10 ns;
		assert data_out = X"0FFFFFFF" report "MEM_W error" severity error;
		wait for 10 ns;
		mem_op_code <= MEM_BU;
		wait for 10 ns;
		assert data_out = X"000000FF" report "MEM_BU error" severity error;
		wait for 10 ns;
		mem_op_code <= MEM_BS;
		wait for 10 ns;
		assert data_out = X"FFFFFFFF" report "MEM_BS error" severity error;
		wait for 10 ns;
		mem_op_code <= MEM_HU;
		wait for 10 ns;
		assert data_out = X"0000FFFF" report "MEM_BU error" severity error;
		wait for 10 ns;
		mem_op_code <= MEM_HS;
		wait for 10 ns;
		assert data_out = X"FFFFFFFF" report "MEM_BS error" severity error;
		wait for 10 ns;
        data_in <= X"00000000";
        mem_op_code <= MEM_SB;
        wait for 10 ns;
		assert data_out = X"12345600" report "MEM_BS error" severity error;
        wait for 10 ns;
		mem_op_code <= MEM_SH;
        wait for 10 ns;
		assert data_out = X"12340000" report "MEM_BS error" severity error;
		wait;
   end process;

END;
