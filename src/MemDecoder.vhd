----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    18:26:26 11/17/2015 
-- Design Name: 
-- Module Name:    sram - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created -- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity MemDecoder is
port(
	addr: in std_logic_vector(31 downto 0);
	r: in std_logic;
	w: in std_logic;
	data_in: in std_logic_vector(31 downto 0);
	data_out: out std_logic_vector(31 downto 0);
	
	--device interface with sram
	sram_data:inout std_logic_vector(31 downto 0);
	sram_addr:out std_logic_vector(19 downto 0);
    ce:out std_logic;
	oe:out std_logic;
	we:out std_logic;
	
	--device interface with serial
	serial_data_out:out std_logic_vector(31 downto 0);
	serial_data_in:in std_logic_vector(31 downto 0);
	serial_r:out std_logic;
	serial_w:out std_logic;
	serial_addr:out std_logic_vector(31 downto 0);

    flash_data_out : out std_logic_vector(31 downto 0);
    flash_data_in : in std_logic_vector(31 downto 0);
    flash_r : out std_logic;
    flash_w : out std_logic;
    flash_addr : out std_logic_vector(31 downto 0);
	
	cpu_clk: in std_logic;
	clk: in std_logic;
    reset : in std_logic
	);
end MemDecoder;

architecture Behavioral of MemDecoder is
	type VisitEnum is (SRAM, SERIAL, FLASH);
	type State is (IDLE, READ1, READ2, READ3, WRITE1, WRITE2, WRITE3, NOP1, NOP2, NOP3);
	
	constant KSEG0_LO : unsigned := X"80000000";
	constant KSEG0_HI : unsigned := X"A0000000";
    constant FLASH_ADDR_START : unsigned := X"bfd00400";
    constant SERIAL_ADDR_START : unsigned := X"bfd003f8";
    constant FLASH_ADDR_END : unsigned := X"bfd00410";

	signal visit_type : VisitEnum;
	signal reset_latch : std_logic;
	signal pr_state : State;
	signal next_state : State;
	signal r_bus : std_logic;
	signal w_bus : std_logic;
	signal next_r_bus : std_logic;
	signal next_w_bus : std_logic;

begin
    ce <= '0';

	process(reset, clk)
	begin
		if (reset = '1') then
			pr_state <= IDLE;
		elsif (clk'event and clk = '1') then
			case pr_state is
				when READ1 =>
					if(visit_type = SRAM) then
						data_out <= sram_data;
					end if;
				when READ2 => 
					if(visit_type = SERIAL) then
						data_out <= serial_data_in;
					end if;
				when others => 
                    null;
			end case;
			pr_state <= next_state;
			r_bus <= next_r_bus;
			w_bus <= next_w_bus;
		end if;
	end process;
	
	process(cpu_clk)
	begin
		if(cpu_clk'event and cpu_clk = '1') then
			reset_latch <= reset;
		end if;
	end process;

	-- the address bus logic
	process(addr)
        variable physical_addr : std_logic_vector(31 downto 0);
        variable flash_addr_new : std_logic_vector(31 downto 0);
        variable serial_addr_new : std_logic_vector(31 downto 0);
	begin
        physical_addr := (others => '0');
        flash_addr_new := (others => '1');
        serial_addr_new := (others => '1');
        if (unsigned(addr) >= FLASH_ADDR_START and unsigned(addr) <= FLASH_ADDR_END) then
            visit_type <= FLASH;
            flash_addr_new := std_logic_vector(unsigned(addr) - FLASH_ADDR_START);
        elsif addr = X"bfd003f8" or addr = X"bfd003fc" then
            visit_type <= SERIAL;
            serial_addr_new := std_logic_vector(unsigned(addr) - FLASH_ADDR_START);
		elsif (unsigned(addr) >= KSEG0_LO and unsigned(addr) < KSEG0_HI) then
			-- kseg0 we strip off the first bit
			visit_type <= SRAM;
			physical_addr := addr and X"7FFFFFFF";
		else
			visit_type <= SRAM;
			physical_addr := addr;
		end if;
        serial_addr <= serial_addr_new;
        flash_addr <= flash_addr_new;
        sram_addr <= physical_addr(21 downto 2);
	end process;

	-- the data and control rw bus drive logic
	process(r, w, data_in, pr_state, reset_latch)
	begin
		case pr_state is 
			when IDLE =>
                if reset_latch = '1' then
                    next_r_bus <= '0';
                    next_w_bus <= '0';
				elsif (w = '1') then
					next_r_bus <= '0';
					next_w_bus <= '1';
				elsif (r = '1') then
					next_r_bus <= '1';
					next_w_bus <= '0';
                else 
                    next_r_bus <= '0';
                    next_w_bus <= '0';
				end if;
			when READ1 =>
				next_r_bus <= '1';
				next_w_bus <= '0';
			when READ2 =>
				next_r_bus <= '0';
				next_w_bus <= '0';
			when READ3 =>
				next_r_bus <= '0';
				next_w_bus <= '0';
			when WRITE1 =>
				next_r_bus <= '0';
				next_w_bus <= '0';
			when WRITE2 =>
				next_r_bus <= '0';
				next_w_bus <= '0';
			when WRITE3 =>
				next_r_bus <= '0';
				next_w_bus <= '0';
			when others => 
				next_r_bus <= '0';
				next_w_bus <= '0';
		end case;
	end process;

	-- the state machine logic
	process(r, w, pr_state, reset_latch)
	begin
		if(reset_latch = '1') then
		   next_state <= IDLE;
		else
			case pr_state is
				when IDLE =>
					if(r = '1' and w = '0') then
						next_state <= READ1;
					elsif(r = '0' and w = '1') then
						next_state <= WRITE1;
					else
						next_state <= NOP1;
					end if;
				when READ1 => next_state <= READ2;
				when READ2 => next_state <= READ3;
				when READ3 => next_state <= IDLE;
				when WRITE1 => next_state <= WRITE2;
				when WRITE2 => next_state <= WRITE3;
				when WRITE3 => next_state <= IDLE;
				when NOP1 => next_state <= NOP2;
				when NOP2 => next_state <= NOP3;
				when NOP3 => next_state <= IDLE;
				when others => NULL;
			end case;
		end if;
	end process;

    -- bus dispatcher
    process(r_bus, w_bus, data_in, visit_type)
    begin
        case visit_type is
            when SRAM =>
                if r_bus = '1' then
                    sram_data <= (others => 'Z');
                elsif w_bus = '1' then
                    sram_data <= data_in;
                else 
                    sram_data <= (others => 'Z');
                end if;
                oe <= not r_bus;
                we <= not w_bus;
                serial_r <= '0';
                serial_w <= '0';
                flash_r <= '0';
                flash_w <= '0';
            when SERIAL =>
                oe <= '1';
                we <= '1';
                sram_data <= (others => 'Z');
                serial_r <= r_bus;
                serial_w <= w_bus;
                flash_r <= '0';
                flash_w <= '0';
            when FLASH =>
                oe <= '1';
                we <= '1';
                sram_data <= (others => 'Z');
                serial_r <= '0';
                serial_w <= '0';
                flash_r <= r_bus;
                flash_w <= w_bus;
            when others =>
                oe <= '1';
                we <= '1';
                sram_data <= (others => 'Z');
                serial_r <= '0';
                serial_w <= '0';
                flash_r <= '0';
                flash_w <= '0';
        end case;
        serial_data_out <= data_in;
    end process;

end Behavioral;


