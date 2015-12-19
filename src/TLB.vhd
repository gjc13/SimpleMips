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
            reset : in STD_LOGIC);
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
					 report "tlbwi";
					 print_hex(entry_hi);
					 print_hex(entry_lo0);
					 print_hex(entry_lo1);
					 
					 tlbEntries(write_index) <= entry_hi(18 downto 0) & '0' & entry_lo0(19 downto 0) & '1' & entry_lo1(19 downto 0) & '1' & "00";
			
				end if;
        end if;
    end process;

    process(vaddr, tlbEntries) 
        variable hi : std_logic_vector(31 downto 0);
        variable intr : std_logic;
    begin
        intr := '1';
        if (vaddr and X"80000000") /= X"00000000" or vaddr = x"bfd003f8" or vaddr = x"bfd003fc" then
            paddr <= vaddr;
            tlb_intr <= '0';
        else
            for i in tlbEntries'range loop
                if vaddr(31 downto 13) = tlbEntries(i)(63 downto 45) and vaddr(12) = '0' then
                    report "found tlb 0";
						  
                    paddr <= tlbEntries(i)(43 downto 24) & vaddr(11 downto 0);					  
                    print_hex(tlbEntries(i)(43 downto 24) & vaddr(11 downto 0));
						  intr := '0';
                    exit;
                elsif vaddr(31 downto 13) = tlbEntries(i)(63 downto 45) and vaddr(12) = '1' then
                    report "found tlb 1";
                    paddr <= tlbEntries(i)(22 downto 3) & vaddr(11 downto 0);					  
                    intr := '0';
                    exit;
                end if;
            end loop;
            tlb_intr <= intr;
        end if;
    end process;

end Behavioral;

