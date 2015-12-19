--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   11:25:05 12/15/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_FlashCtrl.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: FlashCtrl
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
 
ENTITY test_FlashCtrl IS
END test_FlashCtrl;
 
ARCHITECTURE behavior OF test_FlashCtrl IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT FlashCtrl
    PORT(
         ctrl_addr : IN  std_logic_vector(31 downto 0);
         data_in : IN  std_logic_vector(31 downto 0);
         data_out : OUT  std_logic_vector(31 downto 0);
         intr : OUT  std_logic;
         r : IN  std_logic;
         w : IN  std_logic;
         next_pend : IN  std_logic;
         need_mem : OUT  std_logic;
         flash_ce : OUT  std_logic;
         flash_byte_mode : OUT  std_logic;
         flash_oe : OUT  std_logic;
         flash_we : OUT  std_logic;
         flash_addr : OUT  std_logic_vector(22 downto 0);
         flash_data : INOUT  std_logic_vector(15 downto 0);
         flash_vpen : OUT  std_logic;
         flash_rp : OUT  std_logic;
         mem_addr : OUT  std_logic_vector(31 downto 0);
         mem_data_out : OUT  std_logic_vector(31 downto 0);
         mem_data_in : IN  std_logic_vector(31 downto 0);
         mem_r : OUT  std_logic;
         mem_w : OUT  std_logic;
         clk : IN  std_logic;
         reset : IN  std_logic
        );
    END COMPONENT;
    

    --Inputs
    signal ctrl_addr : std_logic_vector(31 downto 0) := (others => '0');
    signal data_in : std_logic_vector(31 downto 0) := (others => '0');
    signal r : std_logic := '0';
    signal w : std_logic := '0';
    signal next_pend : std_logic := '0';
    signal mem_data_in : std_logic_vector(31 downto 0) := (others => '0');
    signal clk : std_logic := '0';
    signal reset : std_logic := '0';

    --BiDirs
    signal flash_data : std_logic_vector(15 downto 0);

    --Outputs
    signal data_out : std_logic_vector(31 downto 0);
    signal intr : std_logic;
    signal need_mem : std_logic;
    signal flash_ce : std_logic;
    signal flash_byte_mode : std_logic;
    signal flash_oe : std_logic;
    signal flash_we : std_logic;
    signal flash_addr : std_logic_vector(22 downto 0);
    signal flash_vpen : std_logic;
    signal flash_rp : std_logic;
    signal mem_addr : std_logic_vector(31 downto 0);
    signal mem_data_out : std_logic_vector(31 downto 0);
    signal mem_r : std_logic;
    signal mem_w : std_logic;

    -- Clock period definitions
    constant clk_period : time := 10 ns;
    constant CTRL_I : std_logic_vector(31 downto 0) := X"00000000";
    constant STATUS_I : std_logic_vector(31 downto 0) := X"00000004";
    constant FLASH_START_I : std_logic_vector(31 downto 0) := X"00000008";
    constant FLASH_END_I : std_logic_vector(31 downto 0) := X"0000000C";
    --real address
    constant MEM_START_I : std_logic_vector(31 downto 0) := X"00000010";

    constant INST_READ : std_logic_vector(31 downto 0) := X"00000001";
    constant INST_WRITE : std_logic_vector(31 downto 0) := X"00000010";
    constant INST_ERASE : std_logic_vector(31 downto 0) := X"00000100";
    constant INST_CLEAR : std_logic_vector(31 downto 0) := X"00000000";


 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: FlashCtrl PORT MAP (
          ctrl_addr => ctrl_addr,
          data_in => data_in,
          data_out => data_out,
          intr => intr,
          r => r,
          w => w,
          next_pend => next_pend,
          need_mem => need_mem,
          flash_ce => flash_ce,
          flash_byte_mode => flash_byte_mode,
          flash_oe => flash_oe,
          flash_we => flash_we,
          flash_addr => flash_addr,
          flash_data => flash_data,
          flash_vpen => flash_vpen,
          flash_rp => flash_rp,
          mem_addr => mem_addr,
          mem_data_out => mem_data_out,
          mem_data_in => mem_data_in,
          mem_r => mem_r,
          mem_w => mem_w,
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
       mem_data_in <= X"12345678";
       flash_data <= (others => 'Z');
       wait for clk_period;
       ctrl_addr <= FLASH_START_I;
       data_in <= X"00000000";
       r <= '0';
       w <= '1';
       wait for clk_period;
       ctrl_addr <= FLASH_END_I;
       data_in <= X"00000010";
       wait for clk_period;
       ctrl_addr <= MEM_START_I;
       data_in <= X"80000000";
       wait for clk_period;
       ctrl_addr <= CTRL_I;
       data_in <= INST_WRITE;
       wait for clk_period;
       w <= '0';
       wait for 800 ns;


       -- insert stimulus here 

       wait;
   end process;

END;
