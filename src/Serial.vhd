----------------------------------------------------------------------------------
-- Company: 
-- Engineer:    ylchen
-- 
-- Create Date:    15:45:12 11/04/2015 
-- Design Name: 
-- Module Name:    serial - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Serial is
    Port (  addr : in STD_LOGIC_VECTOR(31 downto 0);
            clk : in  STD_LOGIC;
            reset : in  STD_LOGIC; 
            en_r : in STD_LOGIC;
            en_w : in STD_LOGIC;
            RX : in  STD_LOGIC;
            TX : out  STD_LOGIC;
            data_in : in  STD_LOGIC_VECTOR(31 downto 0);
            data_out : out  STD_LOGIC_VECTOR(31 downto 0);
            intr : out  STD_LOGIC
        );
end Serial;

architecture Behavioral of Serial is
    ----------------------------------------------------------------------------
    -- UART constants
    ----------------------------------------------------------------------------
    constant BAUD_RATE              : positive := 115200; --115200;
    constant CLOCK_FREQUENCY        : positive := 50000000; --100000000;
    ----------------------------------------------------------------------------
    -- Component declarations
    ----------------------------------------------------------------------------
    component UART is
        generic (
                BAUD_RATE           : positive;
                CLOCK_FREQUENCY     : positive
            );
        port (  -- General
                CLOCK               :   in      std_logic;
                RESET               :   in      std_logic;    
                DATA_STREAM_IN      :   in      std_logic_vector(7 downto 0);
                DATA_STREAM_IN_STB  :   in      std_logic;
                DATA_STREAM_IN_ACK  :   out     std_logic;
                DATA_STREAM_OUT     :   out     std_logic_vector(7 downto 0);
                DATA_STREAM_OUT_STB :   out     std_logic;
                DATA_STREAM_OUT_ACK :   in      std_logic;
                TX                  :   out     std_logic;
                RX                  :   in      std_logic;
                WRITING             :   out     std_logic
             );
    end component UART;
    ----------------------------------------------------------------------------
    -- UART signals
    ----------------------------------------------------------------------------
    signal uart_data_in        : std_logic_vector(7 downto 0);
    signal uart_data_out       : std_logic_vector(7 downto 0);
    signal uart_in_stb         : std_logic;
    signal uart_in_ack         : std_logic;
    signal uart_out_stb        : std_logic;
    signal uart_out_ack        : std_logic;
    signal uart_writing        : std_logic;

    type ReadSate is (read_idle, read_data, set_read);
    type WriteState is (write_idle, set_data, set_write);


    signal pr_r_state : ReadSate := read_idle;
    signal next_r_state : ReadSate := read_idle;
    signal pr_w_state : WriteState := write_idle;
    signal next_w_state : WriteState := write_idle;
    signal data : std_logic_vector(31 downto 0);
    signal next_data : std_logic_vector(31 downto 0);
    signal data_ready : std_logic := '0';
    signal next_data_ready : std_logic := '0';
	signal status : std_logic_vector(31 downto 0);--01 when data ready to read, 10 when busy
	signal next_status : std_logic_vector(31 downto 0);--01 when data ready to read, 10 when busy
    signal next_uart_in_stb : std_logic := '0';
    signal next_uart_data_in : std_logic_vector(7 downto 0);
    signal next_uart_out_ack : std_logic := '0';
    signal is_new_data : std_logic;
begin
     -- UART instantiation
    UART_instance : UART
    generic map (
            BAUD_RATE           => BAUD_RATE,
            CLOCK_FREQUENCY     => CLOCK_FREQUENCY
    )
    port map (  
            -- General
            CLOCK               => clk,
            RESET               => reset,
            DATA_STREAM_IN      => uart_data_in,
            DATA_STREAM_IN_STB  => uart_in_stb,
            DATA_STREAM_IN_ACK  => uart_in_ack,
            DATA_STREAM_OUT     => uart_data_out,
            DATA_STREAM_OUT_STB => uart_out_stb,
            DATA_STREAM_OUT_ACK => uart_out_ack,
            TX                  => TX,
            RX                  => RX,
            WRITING             => uart_writing
    );

    intr <= data_ready;
    next_status(1) <= uart_writing;
    next_status(0) <= data_ready;
     
    process (clk, reset)
    begin
        if reset = '1' then
            pr_r_state <= read_idle;
            pr_w_state <= write_idle;
            data_ready <= '0';
            data <= (others => '0');
            status <= (others => '0');
            data_ready <= '0';
            uart_in_stb <= '0';
            uart_data_in <= (others => '0');
            uart_out_ack <= '0';
        elsif clk'event and clk = '1' then
            pr_r_state <= next_r_state;
            pr_w_state <= next_w_state;
            data <= next_data;
            data_ready <= next_data_ready;
            status <= next_status;
            uart_in_stb <= next_uart_in_stb;
            uart_data_in <= next_uart_data_in;
            uart_out_ack <= next_uart_out_ack;
        end if;
    end process;

    process (pr_w_state, en_w, addr, uart_in_ack, data_in, uart_data_in)
    begin
        case pr_w_state is
            when write_idle => 
                if en_w = '1' and addr = X"00000000" then
                    next_w_state <= set_data;
                    next_uart_in_stb <= '0';
                    next_uart_data_in <= data_in(7 downto 0);
                else
                    next_w_state <= write_idle;
                    next_uart_in_stb <= '0';
                    next_uart_data_in <= X"00";
                end if;
            when set_data =>
                next_w_state <= set_write;
                next_uart_in_stb <= '1';
                next_uart_data_in <= uart_data_in;
            when set_write =>
                if uart_in_ack = '1' then
                    next_w_state <= write_idle;
                    next_uart_in_stb <= '0';
                    next_uart_data_in <= X"00";
                else
                    next_w_state <= set_write;
                    next_uart_in_stb <= '1';
                    next_uart_data_in <= uart_data_in;
                end if;
            when others =>
                next_w_state <= write_idle;
                next_uart_in_stb <= '0';
                next_uart_data_in <= X"00";
        end case;
    end process;

    process (pr_r_state, uart_out_stb, data, uart_data_out)
    begin
        case pr_r_state is
            when read_idle =>
                if uart_out_stb = '1' then
                    next_r_state <= read_data;
                    next_uart_out_ack <= '0';
                else
                    next_r_state <= read_idle;
                    next_uart_out_ack <= '0';
                end if;
                is_new_data <= '0';
                next_data <= data;
            when read_data =>
                next_r_state <= set_read;
                next_uart_out_ack <= '1';
                next_data <= data(31 downto 8) & uart_data_out;
                is_new_data <= '1';
            when set_read =>
                if uart_out_stb = '1' then
                    next_r_state <= set_read;
                    next_uart_out_ack <= '1';
                else
                    next_r_state <= read_idle;
                    next_uart_out_ack <= '0';
                end if;
                is_new_data <= '0';
                next_data <= data;
            when others =>
                next_r_state <= read_idle;
                next_uart_out_ack <= '0';
                is_new_data <= '0';
                next_data <= data;
        end case;
    end process;

    process (data_ready, is_new_data, addr, en_r)
    begin
        if is_new_data = '1' then
            next_data_ready <= '1';
        elsif addr = X"00000000" and en_r = '1' then
            next_data_ready <= '0';
        else
            next_data_ready <= data_ready;
        end if;
    end process;

    process (addr, en_r, data, status)
    begin
        if addr = X"00000000" and en_r = '1' then
            data_out <= data;
        elsif addr = X"00000004" and en_r = '1' then
            data_out <= status;
        else
            data_out <= (others => '0');
        end if;
    end process;
end Behavioral;

