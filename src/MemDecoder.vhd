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
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

--cpu_clk should be 4 times slower than clk
entity MemDecoder is
    Port (  addr : in  STD_LOGIC_VECTOR (31 downto 0);
			r : in  STD_LOGIC;
			w : in  STD_LOGIC;
			data_in : in  STD_LOGIC_VECTOR(31 downto 0);
			data_out : out  STD_LOGIC_VECTOR(31 downto 0);
			addr_bus : out  STD_LOGIC_VECTOR (31 downto 0);
			r_bus : out  STD_LOGIC;
			w_bus : out  STD_LOGIC;
			data_bus : inout  STD_LOGIC_VECTOR (31 downto 0);
			reset : in STD_LOGIC;
			clk : in STD_LOGIC;
			cpu_clk : in STD_LOGIC);
end MemDecoder;

architecture Behavioral of MemDecoder is
	type VisitEnum is (ASYNC, SYNC);
	type State is (IDLE, READ1, READ2, READ3, WRITE1, WRITE2, WRITE3, NOP1, NOP2, NOP3);
	
	constant KSEG0_LO : unsigned := X"80000000";
	constant KSEG0_HI : unsigned := X"A0000000";

	signal visit_type : VisitEnum;
	signal reset_latch : std_logic;
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
				when READ1 =>
					if(visit_type = ASYNC) then
						data_out <= data_bus;
					end if;
				when READ2 => 
					if(visit_type = SYNC) then
						data_out <= data_bus;
					end if;
				when others => null;
			end case;
			pr_state <= next_state;
			r_bus <= next_r_bus;
			w_bus <= next_w_bus;
			data_bus <= next_data_bus;
		end if;
	end process;
	
	process(cpu_clk)
	begin
		if(cpu_clk'event and cpu_clk = '1') then
			reset_latch <= reset;
		end if;
	end process;

	-- the address bus and control enable bus drive logic
	process(addr)
	begin
		if (addr = X"bfd003f8" or addr = X"bfd003fc") then
			visit_type <= SYNC;
			addr_bus <= addr;
		elsif (unsigned(addr) >= KSEG0_LO and unsigned(addr) < KSEG0_HI) then
			-- kseg0 we strip off the first bit
			visit_type <= ASYNC;
			addr_bus <= addr and X"7FFFFFFF";
		else
			visit_type <= ASYNC;
			addr_bus <= addr;
		end if;
	end process;

	-- the data and control rw bus drive logic
	process(r, w, data_in, pr_state, reset_latch)
	begin
		case pr_state is 
			when IDLE =>
				if (reset_latch = '1') then
					next_r_bus <= '0';
					next_w_bus <= '0';
					next_data_bus <= (others => 'Z');
				elsif (w = '1') then
					next_r_bus <= '0';
					next_w_bus <= '0';
					next_data_bus <= data_in;
				elsif (r = '1') then
					next_r_bus <= '1';
					next_w_bus <= '0';
					--next_data_bus <= (others => 'Z');
				end if;
			when READ1 =>
				next_r_bus <= '0';
				next_w_bus <= '0';
				--next_data_bus <= (others => 'Z');
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
				next_data_bus <= data_in;
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
	process(r, w, pr_state, reset_latch)
	begin
		if(reset_latch = '1') then
		   next_state <= IDLE;
		else
			case pr_state is
				when IDLE =>
					if(reset_latch = '1') then
						next_state <= NOP1;
					elsif(r = '1' and w = '0') then
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

end Behavioral;

