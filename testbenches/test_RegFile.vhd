--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   10:29:08 11/01/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_RegFile.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: RegFile
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
USE ieee.numeric_std.ALL;
 
ENTITY test_RegFile IS
END test_RegFile;
 
ARCHITECTURE behavior OF test_RegFile IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT RegFile
    PORT(
         rs_id : IN  integer range 0 to 127;
         rt_id : IN  integer range 0 to 127;
         rd_id : IN  integer range 0 to 127;
         is_regwrite : IN  std_logic;
         rd_data : IN  std_logic_vector(31 downto 0);
         rs_data : OUT  std_logic_vector(31 downto 0);
         rt_data : OUT  std_logic_vector(31 downto 0);
         clk : IN  std_logic;
			reset : IN std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rs_id : integer range 0 to 127;
   signal rt_id : integer range 0 to 127;
   signal rd_id : integer range 0 to 127;
   signal is_regwrite : std_logic := '0';
   signal rd_data : std_logic_vector(31 downto 0) := (others => '0');
   signal clk : std_logic := '0';
	signal reset : std_logic := '0';

 	--Outputs
   signal rs_data : std_logic_vector(31 downto 0);
   signal rt_data : std_logic_vector(31 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: RegFile PORT MAP (
          rs_id => rs_id,
          rt_id => rt_id,
          rd_id => rd_id,
          is_regwrite => is_regwrite,
          rd_data => rd_data,
          rs_data => rs_data,
          rt_data => rt_data,
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
	   variable write_data1 : std_logic_vector(31 downto 0); 
	   variable write_data2 : std_logic_vector(31 downto 0);
   begin		
	   write_data1 := X"12345678";
	   write_data2 := X"87654321";
		reset <= '1';
		is_regwrite <= '0';
      -- hold reset state for 100 ns.
      wait for clk_period*10;
		reset <= '0';

	  -- test reset state
		report "testing init";
		for i in 0 to 31 loop
			rs_id <= i;
			rt_id <= i;
			wait for clk_period;
			assert rs_data = X"00000000" report "rs init read failed at $" & integer'image(i) severity error;
			assert rt_data = X"00000000" report "rt init read failed at $" & integer'image(i) severity error;
		end loop;

		report "testing write to each reg and read afterwards";
		for i in 0 to 31 loop
			rd_id <= i;
			is_regwrite <= '1';
			rd_data <= std_logic_vector(to_unsigned(i+1, rd_data'length));
			wait for clk_period;
		end loop;

		is_regwrite <= '0';
		rs_id <= 0;
		rt_id <= 0;
		wait for clk_period;
		assert rs_data = X"00000000" report "rs read failed at $0" severity error;
		assert rt_data = X"00000000" report "rt read failed at $0" severity error;

		for i in 1 to 31 loop
			rs_id <= i;
			rt_id <= i;
			wait for clk_period;
			assert rs_data = std_logic_vector(to_unsigned(i+1, rd_data'length)) 
				report "rs read failed at $" & integer'image(i) severity error;
			assert rt_data = std_logic_vector(to_unsigned(i+1, rd_data'length)) 
				report "rt read failed at $" & integer'image(i) severity error;
		end loop;
	  
		report "testing write and read in the same clk cycle";
		for i in 1 to 31 loop
			rs_id <= i;
			rt_id <= i;
			rd_id <= i;
			rd_data <= write_data2;
			is_regwrite <= '1';
			wait for clk_period;
			assert rs_data = write_data2 report "rs read failed at $" & integer'image(i) severity error;
			assert rt_data = write_data2 report "rt read failed at $" & integer'image(i) severity error;
		end loop;

      wait;
   end process;

END;
