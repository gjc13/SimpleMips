----------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
-- 
-- Create Date:    21:56:48 11/02/2015 
-- Design Name: 
-- Module Name:    MemDecoder - Behavioral 
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
use IEEE.STD_LOGIC_1164.ALL; use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

-- warning: signal reset should hold 1 until the last mem clk cycle of every cpu cycle
entity MemDecoder is
    Port (  addr : in  STD_LOGIC_VECTOR (31 downto 0);
			r : in  STD_LOGIC;
			w : in  STD_LOGIC;
			data_in : in  STD_LOGIC_VECTOR(31 downto 0);
			data_out : out  STD_LOGIC_VECTOR(31 downto 0);
			addr_bus : out  STD_LOGIC_VECTOR (31 downto 0);
			r_bus : out  STD_LOGIC;
			w_bus : out  STD_LOGIC;
			en_serial : out STD_LOGIC;
			en_sram : out STD_LOGIC;
			data_bus : inout  STD_LOGIC_VECTOR (31 downto 0);
			reset : in STD_LOGIC;
			clk : in STD_LOGIC);
end MemDecoder;

architecture Behavioral of MemDecoder is
	type VisitEnum is (SRAM, SERIAL);
	type State is (IDLE, READ1, READ2, READ3, WRITE1, WRITE2, WRITE3, NOP1, NOP2, NOP3);
	
	constant KSEG0_LO : unsigned := X"80000000";
	constant KSEG0_HI : unsigned := X"A0000000";

	signal visit_type : VisitEnum;
	signal visit_type_latch : VisitEnum;
	signal addr_latch : std_logic_vector(31 downto 0);
	signal data_in_latch : std_logic_vector(31 downto 0);
	signal pr_state : State;
	signal next_state : State;
	signal next_r_bus : std_logic;
	signal next_w_bus : std_logic;
	signal next_data_bus : std_logic_vector(31 downto 0);
begin
	process(reset, clk)
	begin
		if (reset = '1') then
			pr_state <= IDLE;
		elsif (clk'event and clk = '1') then
			case pr_state is
				when IDLE =>
					visit_type_latch <= visit_type;
					addr_latch <= addr;
					data_in_latch <= data_in;
				when READ1 =>
					if(visit_type_latch = SRAM) then
						data_out <= data_bus;
					end if;
				when READ2 => 
					if(visit_type_latch = SERIAL) then
						data_out <= data_bus;
					end if;
				when others => null;
			end case;
			if(pr_state = IDLE) then
				visit_type_latch <= visit_type;
			end if;
			pr_state <= next_state;
			r_bus <= next_r_bus;
			w_bus <= next_w_bus;
			data_bus <= next_data_bus;
		end if;
	end process;

	-- the address bus and control enable bus drive logic
	process(addr_latch)
	begin
		if (addr_latch = X"bfd00000" or addr_latch = X"bfd00004") then
			visit_type <= SERIAL;
			if(addr_latch = X"bfd00000") then
				addr_bus <= X"00000000";
			else
				addr_bus <= X"00000004";
			end if;
			en_serial <= '1';
			en_sram <= '0';
		elsif (unsigned(addr_latch) >= KSEG0_LO and unsigned(addr_latch) < KSEG0_HI) then
			-- kseg0 we strip off the first bit
			visit_type <= SRAM;
			addr_bus <= addr_latch and X"7FFFFFFF";
			en_serial <= '0';
			en_sram <= '1';
		else
			visit_type <= SRAM;
			addr_bus <= addr_latch;
			en_serial <= '0';
			en_sram <= '1';
		end if;
	end process;

	-- the data and control rw bus drive logic
	process(r, w, data_in_latch, pr_state)
	begin
		case pr_state is 
			when IDLE =>
				if (w = '1') then
					next_r_bus <= '0';
					next_w_bus <= '0';
					next_data_bus <= data_in_latch;
				elsif (r = '1') then
					next_r_bus <= '1';
					next_w_bus <= '0';
					next_data_bus <= (others => 'Z');
				end if;
			when READ1 =>
				next_r_bus <= '1';
				next_w_bus <= '0';
				next_data_bus <= data_in_latch;
			when READ2 =>
				next_r_bus <= '0';
				next_w_bus <= '0';
				next_data_bus <= (others => 'Z');
			when READ3 =>
				next_r_bus <= '0';
				next_w_bus <= '0';
				next_data_bus <= (others => 'Z');
			when WRITE1 =>
				next_r_bus <= '0';
				next_w_bus <= '1';
				next_data_bus <= data_in_latch;
			when WRITE2 =>
				next_r_bus <= '0';
				next_w_bus <= '0';
				next_data_bus <= (others => 'Z');
			when WRITE3 =>
				next_r_bus <= '0';
				next_w_bus <= '0';
				next_data_bus <= (others => 'Z');
			when others => 
				next_r_bus <= '0';
				next_w_bus <= '0';
				next_data_bus <= (others => 'Z');
		end case;
	end process;

	-- the state machine logic
	process(r, w, data_in_latch, pr_state)
	begin
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
	end process;

end Behavioral;

