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

    COMPONENT mem_stub 
    Port (  addr : in  STD_LOGIC_VECTOR (19 downto 0);
            data : inout  STD_LOGIC_VECTOR (31 downto 0);
            r : in STD_LOGIC;
            w : in  STD_LOGIC;
            reset : in STD_LOGIC);
    end component;

    COMPONENT serial_stub
    Port (  addr : in STD_LOGIC_VECTOR(31 downto 0);
            data_in : in  STD_LOGIC_VECTOR(31 downto 0);
            data_out : out STD_LOGIC_VECTOR(31 downto 0);
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
    signal data_mem : std_logic_vector(31 downto 0) := (others => '0');

    --Outputs
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


    signal ce : std_logic;
    signal oe : std_logic;
    signal we : std_logic;

    signal serial_data_out : std_logic_vector(31 downto 0);
    signal serial_data_in : std_logic_vector(31 downto 0);
    signal serial_addr : std_logic_vector(31 downto 0);
    signal flash_data_out : std_logic_vector(31 downto 0);
    signal flash_data_in : std_logic_vector(31 downto 0);
    signal flash_ctrl_addr : std_logic_vector(31 downto 0);
    signal data_sram : std_logic_vector(31 downto 0);
    signal addr_sram : std_logic_vector(19 downto 0);

    signal serial_r : std_logic;
    signal serial_w : std_logic;
    signal flash_r : std_logic;
    signal flash_w : std_logic;
    signal intr_serial : std_logic;
    signal flash_ce :   STD_LOGIC;
    signal flash_byte_mode :   STD_LOGIC;
    signal flash_oe :   STD_LOGIC;
    signal flash_we :   STD_LOGIC;
    signal flash_addr : STD_LOGIC_VECTOR (22 downto 0);
    signal flash_data : STD_LOGIC_VECTOR (15 downto 0);
    signal flash_vpen : STD_LOGIC;
    signal flash_rp :   STD_LOGIC;
    signal addr_flash : std_logic_vector(31 downto 0);
    signal r_flash : std_logic;
    signal w_flash : std_logic;
    signal intr_flash : std_logic;
    signal data_flash : std_logic_vector(31 downto 0);
    signal flash_mem_addr : std_logic_vector(31 downto 0);

    -- Clock period definitions
    constant clk_period : time := 4 ns;
 
BEGIN
    r_final <= r_core when is_dma_mem = '0' else r_flash;
    w_final <= w_core when is_dma_mem = '0' else w_flash;
    addr_final <= addr_core when is_dma_mem = '0' else flash_mem_addr;
    data_final <= data_core when is_dma_mem = '0' else data_flash;

 
    -- Instantiate the Unit Under Test (UUT)
    uut: CPUCore PORT MAP (
        clk => clk,
        cpu_clk => cpu_clk,
        reset => reset,
        is_dma_mem => is_dma_mem,
        is_next_mem => is_next_mem,
        r_core => r_core,
        w_core => w_core,
        addr_core => addr_core,
        data_core => data_core,
        data_mem => data_mem,
        com_intr => intr_serial
    );

    memDecode: MemDecoder PORT MAP (
        addr => addr_final,
        r => r_final,
        w => w_final,
        data_in => data_final,
        data_out => data_mem,
        sram_data => data_sram,
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
        clk => clk,
        cpu_clk => cpu_clk,
        reset => reset
    );

    mem: mem_stub Port map(  
        addr => addr_sram,
        data => data_sram,
        r => oe,
        w => we,
        reset => reset 
    );

    serial : serial_stub Port map(
        addr => serial_addr,
        data_in => serial_data_out,
        data_out => serial_data_in,
        intr => intr_serial, 
        w => serial_w,
        r => serial_r,
        clk => clk,
        reset => reset
    );
    
    flash : FlashCtrl PORT MAP(
        ctrl_addr => flash_ctrl_addr,
        data_in => flash_data_out,
        data_out => flash_data_in,
        intr => intr_flash,
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
        clk => clk,
        cpu_clk => cpu_clk,
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
        reset <= '1';
        wait for 100 ns;
        reset <= '0';

        -- hold reset state for 100 ns.
        wait for 5000 ns;   


        -- insert stimulus here 

        wait;
    end process;
END;
