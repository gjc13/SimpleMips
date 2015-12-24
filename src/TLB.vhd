----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:42:14 11/28/2015 
-- Design Name: 
-- Module Name:    TLB - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;
use work.utilities.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity TLB is
    Port (  index: in  STD_LOGIC_VECTOR (31 downto 0);
            is_tlb_write : in STD_LOGIC;
            entry_hi : in  STD_LOGIC_VECTOR (31 downto 0);
            entry_lo0 : in  STD_LOGIC_VECTOR (31 downto 0);
            entry_lo1 : in  STD_LOGIC_VECTOR (31 downto 0);
            vaddr : in  STD_LOGIC_VECTOR (31 downto 0);
            paddr : out  STD_LOGIC_VECTOR (31 downto 0);
            tlb_intr : out  STD_LOGIC;
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            en:in STD_LOGIC);
end TLB;

architecture Behavioral of TLB is
    type TLBRegType is array(0 to 31) of std_logic_vector(63 downto 0);
    constant VPN_OFFSET : unsigned(19 downto 0) := X"00001";
	signal write_index : INTEGER range 0 to 31;
    signal tlbEntries : TLBRegType;
begin
	write_index <= to_integer(unsigned(index(4 downto 0)));
    process(clk, reset)
    begin
        if(reset = '1') then
            for i in tlbEntries'range loop
                tlbEntries(i) <= (63 => '1',others => '0');
            end loop;
        elsif(clk'event and clk = '1') then
            if(is_tlb_write = '1') then      
					 --report "tlbwi";
					 --report write_index;
					 --print_hex(index);
					 --print_hex(entry_hi);
					 --print_hex(entry_lo0);
					 --print_hex(entry_lo1);
					 
					 tlbEntries(write_index) <= entry_hi(31 downto 13) & '0' 
                        & entry_lo0(25 downto 6) & '1' 
                        & entry_lo1(25 downto 6) & '1' & "00";
			
				end if;
        end if;
    end process;

    process(vaddr, tlbEntries,en) 
        variable hi : std_logic_vector(31 downto 0);
        variable intr : std_logic;
    begin
        intr := '1';
        if vaddr(31) = '1' then
            paddr <= vaddr;
            intr := '0';
        else
            for i in tlbEntries'range loop
                if vaddr(31 downto 13) = tlbEntries(i)(63 downto 45) and vaddr(12) = '0' then
                    --report "found tlb 0";
					--print_hex(index);
                    paddr <= tlbEntries(i)(43 downto 24) & vaddr(11 downto 0);					  
                    --print_hex(tlbEntries(i)(43 downto 24) & vaddr(11 downto 0));
					intr := '0';
                    exit;
                elsif vaddr(31 downto 13) = tlbEntries(i)(63 downto 45) and vaddr(12) = '1' then
                    --report "found tlb 1";
                    paddr <= tlbEntries(i)(22 downto 3) & vaddr(11 downto 0);					  
                    intr := '0';
                    exit;
                else
                    paddr <= (others => '0');
                end if;
            end loop;
        end if;
		if(en = '1') then
            tlb_intr <= intr;
        else
			tlb_intr<='0';
		end if;
    end process;

end Behavioral;

