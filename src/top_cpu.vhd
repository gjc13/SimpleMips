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
use work.Peripherals.all;
 
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--USE ieee.numeric_std.ALL; 

ENTITY top_cpu IS
    port(clk:in std_logic;
        step_clk : in std_logic;
        rst : in std_logic;

        --sram
        addr_sram:out std_logic_vector(19 downto 0);
        data_bus:inout std_logic_vector(31 downto 0);
        ce: out std_logic;
        oe: out std_logic;
        we: out std_logic;

        --serial
        RX:in std_logic;
        TX:out std_logic
    );
END top_cpu;


ARCHITECTURE behavior OF top_cpu IS 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT CPUCore
    PORT(
         clk : IN  std_logic;
         cpu_clk : OUT  std_logic;
         reset : IN  std_logic;
         is_dma_mem : IN  std_logic;
--         is_cancel : IN  std_logic;
         is_next_mem : OUT  std_logic;
         r_core : OUT  std_logic;
         w_core : OUT  std_logic;
         addr_core : OUT  std_logic_vector(31 downto 0);
         data_core : OUT  std_logic_vector(31 downto 0);
         data_mem : IN  std_logic_vector(31 downto 0)
        );
    END COMPONENT;

    signal is_dma_mem : std_logic := '0';
    signal is_cancel : std_logic := '0';
    signal data_mem : std_logic_vector(31 downto 0) := (others => '0');

    signal cpu_clk : std_logic;
    signal is_next_mem : std_logic;
    signal r_core : std_logic;
    signal w_core : std_logic;
    signal addr_core : std_logic_vector(31 downto 0);
    signal data_core : std_logic_vector(31 downto 0);

    signal serial_data_out : std_logic_vector(31 downto 0);
    signal serial_data_in : std_logic_vector(31 downto 0);
    signal serial_addr : std_logic_vector(31 downto 0);

    signal serial_r : std_logic;
    signal serial_w : std_logic;
    signal intr : std_logic;
    
    signal reset : std_logic;


    -- Clock period definitions
    constant clk_period : time := 10 ns;
 
BEGIN
    reset <= not rst;
 
    -- Instantiate the Unit Under Test (UUT)
    uut: CPUCore PORT MAP (
        clk => clk,
        cpu_clk => cpu_clk,
        reset => reset,
        is_dma_mem => is_dma_mem,
        --is_cancel => is_cancel,
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
        sram_data => data_bus,
        sram_addr => addr_sram,
        ce => ce,
        oe => oe,
        we => we,
        serial_data_out => serial_data_out,
        serial_data_in => serial_data_in,
        serial_r => serial_r,
        serial_w => serial_w,
        serial_addr => serial_addr,

        clk => clk,
        cpu_clk => cpu_clk,
        reset => reset
    );

    ser: Serial PORT MAP(
        addr => serial_addr,
        clk => clk,
        reset => reset,
        en_r =>serial_r,
        en_w =>serial_w,
        RX => RX,
        TX => TX,
        data_in => serial_data_out,
        data_out =>serial_data_in,
        intr => intr
    );

    is_dma_mem <= '0';
    is_cancel <= '0';

END;
