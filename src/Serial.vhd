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
    constant BAUD_RATE              : positive := 19200; --115200;
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

    type State is (idle, start_read, read_data, start_write, write_data);
    signal pr_state : State := idle;
    signal data : std_logic_vector(31 downto 0);
    signal data_ready : std_logic := '0';
	signal status : std_logic_vector(31 downto 0);       --01 when data ready to read, 10 when busy
begin
     -- UART instantiation
    UART_instance : UART
    generic map (
            BAUD_RATE           => BAUD_RATE,
            CLOCK_FREQUENCY     => CLOCK_FREQUENCY
    )
    port map    (  
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

    process (clk) 
    variable next_state : State;
    begin
        if rising_edge(clk) then
            if reset = '1' then
                uart_in_stb        <= '0';
                uart_out_ack       <= '0';
                uart_data_in       <= (others => '0');
                next_state         := idle;
                data_out <= X"00000000";
                status <= X"00000000";
                data_ready <= '0';
            else
                status(1) <= uart_writing;
                status(0) <= data_ready;

                if en_r = '1' then
                    if addr = X"00000000" then
                        data_out <= data;
                        data_ready <= '0';
                    elsif addr = X"00000004" then
                        data_out <= status;
                    end if;
                end if;
                     
                case pr_state is
                    when idle =>
                        uart_in_stb        <= '0';
                        uart_out_ack       <= '0';
                        if en_w = '1' and addr = X"00000000" then
                            next_state := start_write;
                            uart_data_in <= data_in(7 downto 0);
                        elsif uart_out_stb = '1' and data_ready = '0' then
                            next_state := start_read;
                        else 
                            next_state := idle;
                        end if;
                                
                    when start_write =>
                        next_state := write_data;
                        uart_in_stb <= '1';
                         
                    when write_data => 
                        next_state := idle;
                            
                    when start_read =>
                        next_state := read_data;
                        data(7 downto 0) <= uart_data_out(7 downto 0);
                        data(31 downto 8) <= (others => '0');
                          
                    when read_data => 
                        next_state := idle;
                        data_ready <= '1';
                        uart_out_ack <= '1';
                    
                    when others => null;
                end case;
                pr_state <= next_state;
            end if;
        end if;
    end process;

end Behavioral;

