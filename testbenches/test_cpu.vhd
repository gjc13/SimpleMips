--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   16:15:03 11/10/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/testbenches/test_cpu.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- -- VHDL Test Bench Created by ISE for module: CPUCore
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
ENTITY test_cpu IS
END test_cpu;
 
ARCHITECTURE behavior OF test_cpu IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CPUCore
    PORT(
         clk : IN  std_logic;
         cpu_clk : OUT  std_logic;
         reset : IN  std_logic;
         is_dma_mem : IN  std_logic;
         is_cancel : IN  std_logic;
         is_next_mem : OUT  std_logic;
         r_core : OUT  std_logic;
         w_core : OUT  std_logic;
         addr_core : OUT  std_logic_vector(31 downto 0);
         data_core : OUT  std_logic_vector(31 downto 0);
         data_mem : IN  std_logic_vector(31 downto 0)
        );
    END COMPONENT;

    COMPONENT MemDecoder
    PORT(
         addr : IN  std_logic_vector(31 downto 0);
         r : IN  std_logic;
         w : IN  std_logic;
         data_in : IN  std_logic_vector(31 downto 0);
         data_out : OUT  std_logic_vector(31 downto 0);
         addr_bus : OUT  std_logic_vector(31 downto 0);
         r_bus : OUT  std_logic;
         w_bus : OUT  std_logic;
         data_bus : INOUT  std_logic_vector(31 downto 0);
         reset : IN  std_logic;
         clk : IN  std_logic;
         cpu_clk : IN  std_logic
        );
    END COMPONENT;

	component SerialController 
    Port ( addr_bus : in  STD_LOGIC_VECTOR (31 downto 0);
           r_bus : in  STD_LOGIC;
           w_bus : in  STD_LOGIC;
           addr_serial : out  STD_LOGIC_VECTOR (31 downto 0);
           r_serial : out STD_LOGIC;
           w_serial : out STD_LOGIC);
	end component;

	COMPONENT SRAMController 
    Port ( addr_bus : in  STD_LOGIC_VECTOR (31 downto 0);
           r_bus : in  STD_LOGIC;
           w_bus : in  STD_LOGIC;
           addr_sram : out  STD_LOGIC_VECTOR (19 downto 0);
           r_sram : out  STD_LOGIC;
           w_sram : out  STD_LOGIC);
	end component;

	COMPONENT mem_stub 
    Port (  addr : in  STD_LOGIC_VECTOR (19 downto 0);
			data : inout  STD_LOGIC_VECTOR (31 downto 0);
			r : in STD_LOGIC;
			w : in  STD_LOGIC;
			reset : in STD_LOGIC);
	end component;

	COMPONENT serial_stub
    Port (  addr : in STD_LOGIC_VECTOR(31 downto 0);
			data : inout  STD_LOGIC_VECTOR(31 downto 0);
			intr : in  STD_LOGIC;
			w : in  STD_LOGIC;
			r : in STD_LOGIC;
			clk : in STD_LOGIC;
			reset : in STD_LOGIC);
	end component;
   

	--Inputs
	signal clk : std_logic := '0';
	signal reset : std_logic := '0';
	signal is_dma_mem : std_logic := '0';
	signal is_cancel : std_logic := '0';
	signal data_mem : std_logic_vector(31 downto 0) := (others => '0');

	--Outputs
	signal cpu_clk : std_logic;
	signal is_next_mem : std_logic;
	signal r_core : std_logic;
	signal w_core : std_logic;
	signal addr_core : std_logic_vector(31 downto 0);
	signal data_core : std_logic_vector(31 downto 0);

	signal addr_serial : std_logic_vector(31 downto 0);
	signal addr_sram : std_logic_vector(19 downto 0);

	--BiDirs
	signal data_bus : std_logic_vector(31 downto 0);

	signal addr_bus : std_logic_vector(31 downto 0);
	signal r_bus : std_logic;
	signal w_bus : std_logic;
	signal r_serial : std_logic;
	signal w_serial : std_logic;
	signal r_sram : std_logic;
	signal w_sram : std_logic;
	signal intr : std_logic;


   -- Clock period definitions
   constant clk_period : time := 10 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: CPUCore PORT MAP (
          clk => clk,
		  cpu_clk => cpu_clk,
          reset => reset,
          is_dma_mem => is_dma_mem,
          is_cancel => is_cancel,
          is_next_mem => is_next_mem,
          r_core => r_core,
          w_core => w_core,
          addr_core => addr_core,
          data_core => data_core,
          data_mem => data_mem
        );

	memDecode: MemDecoder PORT MAP (
          addr => addr_core,
          r => r_core,
          w => w_core,
          data_in => data_core,
          data_out => data_mem,
          addr_bus => addr_bus,
          r_bus => r_bus,
          w_bus => w_bus,
          data_bus => data_bus,
          reset => reset,
          clk => clk,
          cpu_clk => cpu_clk
        );

    serial_control : SerialController Port map(
			addr_bus => addr_bus,
			r_bus => r_bus,
			w_bus => w_bus,
			addr_serial => addr_serial,
			r_serial => r_serial,
			w_serial => w_serial );

    sram_control : SRAMController Port map(
			addr_bus => addr_bus,
			r_bus => r_bus,
			w_bus => w_bus,
			addr_sram => addr_sram,
			r_sram => r_sram,
			w_sram => w_sram );

    mem: mem_stub Port map(  
			addr => addr_sram,
         data => data_bus,
			r => r_sram,
         w => w_sram,
			reset => reset );

	serial : serial_stub Port map(
    		addr => addr_serial,
			data => data_bus,
			intr => intr, 
			w => w_serial,
			r => r_serial,
			clk => clk,
			reset => reset);


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
		reset <= '1';
		wait for 100 ns;
		reset <= '0';

		-- hold reset state for 100 ns.
		wait for 5000 ns;	


		-- insert stimulus here 

		wait;
	end process;
END;
