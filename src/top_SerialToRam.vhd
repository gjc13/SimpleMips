--------------------------------------------------------------------------------
-- Company: 
-- Engineer:
--
-- Create Date:   12:44:55 12/05/2015
-- Design Name:   
-- Module Name:   /home/shs/ucore_mips/cpu0/src/top_SerialTest.vhd
-- Project Name:  cpu0
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: Serial
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
USE ieee.numeric_std.ALL;
 
ENTITY top_SerialToRam IS
    Port(
        clk: in std_logic;
        rst: in std_logic;

        sram_addr : out  std_logic_vector(19 downto 0);
        data_bus : inout std_logic_vector(31 downto 0);
        ce : out std_logic;
        oe : out std_logic;
        we : out std_logic;
        RX : in std_logic;
        TX : out std_logic
    );
END top_SerialToRam;
 
ARCHITECTURE behavior OF top_SerialToRam IS 
 
    --mem decoder interface
    signal visit_addr : std_logic_vector(31 downto 0);
    signal write_addr : std_logic_vector(31 downto 0);
    signal r: std_logic;
    signal w: std_logic;
    signal data_in : std_logic_vector(31 downto 0);
    signal data_out : std_logic_vector(31 downto 0);

    signal serial_data_in : std_logic_vector(31 downto 0);
    signal serial_data_out : std_logic_vector(31 downto 0);
    signal serial_r : std_logic;
    signal serial_w : std_logic;
    signal serial_addr :std_logic_vector(31 downto 0);

    type VisitState is (IDLE, READ_SERIAL, UPDATE_BUF, WRITE_SRAM, CHECK_SERIAL, READ_SRAM, WRITE_SERIAL);
    signal pr_state : VisitState;
    signal next_state : VisitState;

    signal buf_clk : std_logic := '0';
    signal cpu_clk : std_logic;
    signal reset : std_logic; 

    signal num_read : integer range 0 to 3;
    signal num_write : integer range 0 to 3;
    signal databuf : std_logic_vector(31 downto 0);
    signal outputbuf : std_logic_vector(31 downto 0);
    signal intr : std_logic;
    
    constant WRITE_OFFSET : unsigned := X"00000004";
BEGIN
    -- Instantiate the Unit Under Test (UUT)
    uut: Serial PORT MAP (
        addr => serial_addr,
        clk => clk,
        reset => reset,
        en_r => serial_r,
        en_w => serial_w,
        RX => RX,
        TX => TX,
        data_in => serial_data_out,
        data_out => serial_data_in,
        intr => intr
    );

    memDecode : MemDecoder Port map (
        addr => visit_addr,
        r => r,
        w => w,
        data_in => data_in,
        data_out => data_out,
        sram_data => data_bus,
        sram_addr => sram_addr,
        ce => ce,
        oe => oe,
        we => we,
        serial_data_in => serial_data_in,
        serial_data_out => serial_data_out,
        serial_r => serial_r,
        serial_w => serial_w,
        serial_addr => serial_addr,
        cpu_clk => cpu_clk,
        clk => clk,
        reset => reset
    );

    reset <= not rst;

    process(cpu_clk, reset)
    begin
        if reset = '1' then
            r <= '0';
            w <= '0';
            data_in <= (others => '0');
            pr_state <= IDLE;
            visit_addr <= X"80000000";
            write_addr <= X"80000000";
            num_read <= 0;
            num_write <= 0;
        elsif cpu_clk'event and cpu_clk = '1' then
            case pr_state is
                when IDLE =>
                    if intr = '1' then
                        pr_state <= READ_SERIAL;
                        r <= '1';
                        w <= '0';
                        visit_addr <= X"bfd003f8";
                    else
                        pr_state <= IDLE;
                        r <= '0';
                        w <= '0';
                    end if;
                when READ_SERIAL =>
                    if num_read /= 3 then
                        pr_state <= UPDATE_BUF;
                        r <= '0';
                        w <= '0';
                    else
                        pr_state <= WRITE_SRAM;
                        r <= '0';
                        w <= '1';
                        visit_addr <= write_addr;
                        data_in <= data_out(7 downto 0) & databuf(23 downto 0);
                    end if;

                    case num_read is
                        when 0 =>
                            databuf(7 downto 0) <= data_out(7 downto 0);
                        when 1 =>
                            databuf(15 downto 8) <= data_out(7 downto 0);
                        when 2 =>
                            databuf(23 downto 16) <= data_out(7 downto 0);
                        when 3 =>
                            databuf(31 downto 24) <= data_out(7 downto 0);
                        when others =>
                            null;
                    end case;
                    
                    num_read <= num_read + 1;
                when UPDATE_BUF =>
                    pr_state <= IDLE;
                    r <= '0';
                    w <= '0';
                when WRITE_SRAM =>
                    pr_state <= READ_SRAM;
                    r <= '1';
                    w <= '0';
                    visit_addr <= write_addr;
                when READ_SRAM =>
                    outputbuf <= data_out;
                    pr_state <= CHECK_SERIAL;
                    r <= '1';
                    w <= '0';
                    visit_addr <= X"bfd003fc";
                when CHECK_SERIAL =>
                    if data_out(1) = '1' then
                        pr_state <= CHECK_SERIAL;
                        r <= '1';
                        w <= '0';
                        visit_addr <= X"bfd003fc";
                    else
                        pr_state <= WRITE_SERIAL;
                        r <= '0';
                        w <= '1';
                        visit_addr <= X"bfd003f8";
                        data_in <= outputbuf;
                    end if;
                when WRITE_SERIAL =>
                    pr_state <= IDLE;
                    if num_write /= 3 then
                        pr_state <= CHECK_SERIAL;
                        r <= '1';
                        w <= '0';
                        visit_addr <= X"bfd003fc";
                    else
                        pr_state <= IDLE;
                        r <= '0';
                        w <= '0';
                        write_addr <= std_logic_vector(unsigned(write_addr) + WRITE_OFFSET);
                    end if;
                    outputbuf <= X"00" & outputbuf(31 downto 8);
                    num_write <= num_write + 1;
            end case;
        end if;
    end process;

    process(clk, reset)
    begin
        if clk'event and clk = '1' then
            buf_clk <= not buf_clk;
        end if;
    end process;

    process(buf_clk, reset)
    begin
        if buf_clk'event and buf_clk = '1' then
            cpu_clk <= not cpu_clk;
        end if;
    end process;
END;

