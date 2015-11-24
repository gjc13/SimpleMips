----------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
-- 
-- Create Date:    09:54:59 11/01/2015 
-- Design Name: 
-- Module Name:    RegFile - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity RegFile is
    Port (  rs_id : in  INTEGER RANGE 0 TO 127;
            rt_id : in  INTEGER RANGE 0 TO 127;
            rd_id : in  INTEGER RANGE 0 TO 127;
            is_regwrite : in  STD_LOGIC;
            rd_data : in  STD_LOGIC_VECTOR (31 downto 0);
            rs_data : out  STD_LOGIC_VECTOR (31 downto 0);
            rt_data : out  STD_LOGIC_VECTOR (31 downto 0);
			status_new : in STD_LOGIC_VECTOR (31 downto 0);
			cause_new : in STD_LOGIC_VECTOR (31 downto 0);
			badvaddr_new : in STD_LOGIC_VECTOR (31 downto 0);
			entry_hi_new : in STD_LOGIC_VECTOR (31 downto 0);
			exception_write : in STD_LOGIC;
			status : out STD_LOGIC_VECTOR (31 downto 0);
			cause : out STD_LOGIC_VECTOR (31 downto 0);
			count : out STD_LOGIC_VECTOR (31 downto 0);
			compare : out STD_LOGIC_VECTOR (31 downto 0);
			ebase : out STD_LOGIC_VECTOR (31 downto 0);
	   		clk : in STD_LOGIC;
			reset : in STD_LOGIC);
end RegFile;

architecture Behavioral of RegFile is
	type RegsType is array(0 to 127) of std_logic_vector(31 downto 0);
	signal regs: RegsType;
	signal count_clock: std_logic := '0';
	constant ADD_VAL : unsigned := X"00000001";
	constant INDEX : integer := 32;
	constant ENTRY_LO0 : integer := 34;
	constant ENTRY_LO1 : integer := 35;
	constant BADVADDR : integer := 41;
	constant COUNT : integer := 42;
	constant ENTRYHI : integer := 43;
	constant COMPARE : integer := 44;
	constant STATUS : integer := 45;
	constant CAUSE : integer := 47;
	constant EPC : integer := 48;
	constant EBASE : integer := 49;
begin
	status <= regs(STATUS);
	cause <= regs(CAUSE);
	count <= regs(COUNT);
	compare <= regs(COMPARE);
	ebase <= regs(EBASE);

	process(clk)
	begin
		if(clk'event and clk = '1') then
			count_clock <= not count_clock;
		end if;
	end process;

	process(count_clock)
	begin
		if(count_clock'event and count_clock = '1') then
			regs(COUNT) <= std_logic_vector(unsigned(count_clock) + ADD_VAL);
		end if;
	end process;

	process(clk)
	begin
		if(clk'event and clk = '1') then
			if(reset = '1') then
				for i in regs'range loop
					regs(i) <= (others => '0');
				end loop;
			else
				if(is_regwrite = '1' and rd_id /= 0 and rd_id /= 42) then
					regs(rd_id) <= rd_data;
				end if;
			end if;
		end if;
	end process;

	process(rs_id, rt_id, rd_id, is_regwrite, rd_data)
	begin
		if(is_regwrite = '1' and rd_id = rt_id) then
			rt_data <= rd_data;
		else
			rt_data <= regs(rt_id);
		end if;
		if(is_regwrite = '1' and rd_id = rs_id) then
			rs_data <= rd_data;
		else
			rs_data <= regs(rs_id);
		end if;
	end process;
	
end Behavioral;

