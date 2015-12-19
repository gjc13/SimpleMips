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
-- ---------------------------------------------------------------------------------- library IEEE;
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
            epc_new : in STD_LOGIC_VECTOR (31 downto 0);
            force_cp0_write : in STD_LOGIC:='0';
            status : out STD_LOGIC_VECTOR (31 downto 0);
            cause : out STD_LOGIC_VECTOR (31 downto 0);
            count : out STD_LOGIC_VECTOR (31 downto 0);
            compare : out STD_LOGIC_VECTOR (31 downto 0);
            ebase : out STD_LOGIC_VECTOR (31 downto 0);
            epc : out STD_LOGIC_VECTOR(31 downto 0);
				index : out STD_LOGIC_VECTOR(31 downto 0);
				entryHi : out STD_LOGIC_VECTOR(31 downto 0);
				entryLo0 : out STD_LOGIC_VECTOR(31 downto 0);
				entryLo1 : out STD_LOGIC_VECTOR(31 downto 0);
			clk_intr : out STD_LOGIC;
            clk : in STD_LOGIC;
            reset : in STD_LOGIC);
end RegFile;

architecture Behavioral of RegFile is
    type RegsType is array(0 to 127) of std_logic_vector(31 downto 0);
    signal regs: RegsType;
    signal count_clock: std_logic := '0';
    constant ADD_VAL : unsigned := X"00000001";
    constant INDEX_I : integer := 32;
    constant ENTRY_LO0_I : integer := 34;
    constant ENTRY_LO1_I : integer := 35;
    constant BADVADDR_I : integer := 40;
    constant COUNT_I : integer := 41;
    constant ENTRYHI_I : integer := 42;
    constant COMPARE_I : integer := 43;
    constant STATUS_I : integer := 44;
    constant CAUSE_I : integer := 45;
    constant EPC_I : integer := 46;
    constant EBASE_I : integer := 47;
begin
    count <= regs(COUNT_I);

    process(clk)
    begin
        if(clk'event and clk = '1') then
            count_clock <= not count_clock;
        end if;
    end process;

    process(clk)
    begin
        if(clk'event and clk = '1') then
            if(reset = '1') then
                for i in regs'range loop
                    if i = STATUS_I then
                        -- BEV KSU
                        regs(i) <= X"00400010";
                    else
                        regs(i) <= (others => '0');
                    end if;
                end loop;
            else
                if count_clock = '1' then
                    regs(COUNT_I) <= std_logic_vector(unsigned(regs(COUNT_I)) + ADD_VAL);
                end if;
                if force_cp0_write = '1' then
                    regs(STATUS_I) <= status_new;
                    regs(CAUSE_I) <= cause_new;
                    regs(BADVADDR_I) <= badvaddr_new;
                    regs(ENTRYHI_I) <= entry_hi_new;
                    regs(EPC_I) <= epc_new;
                    if (is_regwrite = '1' and rd_id /= 0 and rd_id < 32) then
                        regs(rd_id) <= rd_data;
                    end if;
                else
                    if (is_regwrite = '1' and rd_id /= 0 and rd_id /= COUNT_I) then
                        regs(rd_id) <= rd_data;
                    end if;
                end if;
            end if;
        end if;
    end process;
    
	process(regs(COUNT_I), regs(COMPARE_I))
	begin
		if (regs(COUNT_I) = regs(COMPARE_I)) then
			clk_intr <= '1';
		else
			clk_intr <= '0';
		end if;
	end process;

    process(rs_id, rt_id, rd_id, is_regwrite, rd_data, regs)
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

    process(rd_id, rd_data, is_regwrite, regs)
    begin
        if(is_regwrite = '1' and rd_id = STATUS_I) then
            status <= rd_data;
        else
            status <= regs(STATUS_I);
        end if;
        if(is_regwrite = '1' and rd_id = CAUSE_I) then
            cause <= rd_data;
        else
            cause <= regs(CAUSE_I);
        end if;
        if(is_regwrite = '1' and rd_id = COMPARE_I) then
            compare <= rd_data;
        else
            compare <= regs(COMPARE_I);
        end if;
        if(is_regwrite = '1' and rd_id = EBASE_I) then
            ebase <= rd_data;
        else
            ebase <= regs(EBASE_I);
        end if;
        if(is_regwrite = '1' and rd_id = EPC_I) then
            epc <= rd_data;
        else
            epc <= regs(EPC_I);
			end if;
		  if(is_regwrite = '1' and rd_id = INDEX_I) then
            index <= rd_data;
        else
            index <= regs(INDEX_I);
			end if;
		  if(is_regwrite = '1' and rd_id = ENTRYHI_I) then
            entryHi <= rd_data;
        else
            entryHi <= regs(ENTRYHI_I);
        end if;
		   if(is_regwrite = '1' and rd_id = ENTRY_LO0_I) then
            entryLo0 <= rd_data;
        else
            entryLo0 <= regs(ENTRY_LO0_I);
        end if;
		   if(is_regwrite = '1' and rd_id = ENTRY_LO1_I) then
            entryLo1 <= rd_data;
        else
            entryLo1 <= regs(ENTRY_LO1_I);
        end if;
    end process;
end Behavioral;

