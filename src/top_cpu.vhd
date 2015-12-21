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
        flash_ce : out  STD_LOGIC;
        flash_ce1 : out STD_LOGIC;
        flash_ce2 : out STD_LOGIC;
        flash_byte_mode : out  STD_LOGIC;
        flash_oe : out  STD_LOGIC;
        flash_we : out  STD_LOGIC;
        flash_addr : out  STD_LOGIC_VECTOR (22 downto 0);
        flash_data : inout  STD_LOGIC_VECTOR (15 downto 0);
        flash_vpen : out  STD_LOGIC;
        flash_rp : out  STD_LOGIC;
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
         --is_cancel : IN  std_logic;
         is_next_mem : OUT  std_logic;
         r_core : OUT  std_logic;
         w_core : OUT  std_logic;
         addr_core : OUT  std_logic_vector(31 downto 0);
         data_core : OUT  std_logic_vector(31 downto 0);
         data_mem : IN  std_logic_vector(31 downto 0);
         com_intr : IN std_logic
        );
    END COMPONENT;
    
    component ClkDivider is
        Port ( clk : in  STD_LOGIC;
               clk_div : out  STD_LOGIC);
    end component;

    signal is_dma_mem : std_logic := '0';
    signal data_mem : std_logic_vector(31 downto 0) := (others => '0');

    signal clk_div : std_logic;
    signal cpu_clk : std_logic;
    signal is_next_mem : std_logic;
    signal r_core : std_logic;
    signal w_core : std_logic;
    signal addr_core : std_logic_vector(31 downto 0);
    signal data_core : std_logic_vector(31 downto 0);

    signal r_final : std_logic;
    signal w_final : std_logic;
    signal addr_final : std_logic_vector(31 downto 0);
    signal data_final : std_logic_vector(31 downto 0);

    signal serial_data_out : std_logic_vector(31 downto 0);
    signal serial_data_in : std_logic_vector(31 downto 0);
    signal serial_addr : std_logic_vector(31 downto 0);
    signal serial_r : std_logic;
    signal serial_w : std_logic;
    signal serial_intr : std_logic;
    signal flash_data_out : std_logic_vector(31 downto 0);
    signal flash_data_in : std_logic_vector(31 downto 0);
    signal flash_r : std_logic;
    signal flash_w : std_logic;
    signal flash_intr : std_logic;
    signal flash_ctrl_addr : std_logic_vector(31 downto 0);
    signal flash_mem_addr : std_logic_vector(31 downto 0);
    signal addr_flash : std_logic_vector(31 downto 0);
    signal r_flash : std_logic;
    signal w_flash : std_logic;
    signal intr_flash : std_logic;
    signal data_flash : std_logic_vector(31 downto 0);

    signal reset : std_logic;

    -- Clock period definitions
    constant clk_period : time := 10 ns;
 
BEGIN
    reset <= not rst;
    r_final <= r_core when is_dma_mem = '0' else r_flash;
    w_final <= w_core when is_dma_mem = '0' else w_flash;
    addr_final <= addr_core when is_dma_mem = '0' else flash_mem_addr;
    data_final <= data_core when is_dma_mem = '0' else data_flash;

    flash_ce1 <= '0';
    flash_ce2 <= '0';
    
    div : ClkDivider Port Map (
        clk => clk,
        clk_div => clk_div
    );
 
    -- Instantiate the Unit Under Test (UUT)
    uut: CPUCore PORT MAP (
        clk => clk_div,
        cpu_clk => cpu_clk,
        reset => reset,
        is_dma_mem => is_dma_mem,
        --is_cancel => is_cancel,
        is_next_mem => is_next_mem,
        r_core => r_core,
        w_core => w_core,
        addr_core => addr_core,
        data_core => data_core,
        data_mem => data_mem,
        com_intr => serial_intr
    );

    memDecode: MemDecoder PORT MAP (
        addr => addr_final,
        r => r_final,
        w => w_final,
        data_in => data_final,
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
        flash_data_out => flash_data_out,
        flash_data_in => flash_data_in,
        flash_r => flash_r,
        flash_w => flash_w,
        flash_addr => flash_ctrl_addr,
        clk => clk_div,
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
        intr => serial_intr
    );

    flash : FlashCtrl PORT MAP(
        ctrl_addr => flash_ctrl_addr,
        data_in => flash_data_out,
        data_out => flash_data_in,
        intr => flash_intr,
        r => flash_r,
        w => flash_w,
        next_pend => is_next_mem,
        need_mem => is_dma_mem,
        flash_ce => flash_ce,
        flash_byte_mode => flash_byte_mode,
        flash_oe => flash_oe,
        flash_we => flash_we,
        flash_addr => flash_addr,
        flash_data => flash_data,
        flash_vpen => flash_vpen,
        flash_rp => flash_rp,
        mem_addr => flash_mem_addr,
        mem_data_out => data_flash,
        mem_data_in => data_mem,
        mem_r => r_flash,
        mem_w => w_flash,
        clk => clk_div,
        cpu_clk => cpu_clk,
        reset => reset
    );
    

END;
