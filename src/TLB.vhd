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
    Port (  write_index : in  INTEGER range 0 to 31;
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
    type TLBRegType is array(0 to 31) of std_logic_vector(127 downto 0);

    subtype ENTRYHI is integer range 127 downto 96;
    subtype ENTRYLO0 is integer range 63 downto 32;
    subtype ENTRYLO1 is integer range 31 downto 0;

    subtype PAGENUMBER is integer range 31 downto 13;
    subtype PAGEOFFSET is integer range 12 downto 0;

    constant PAGEMASK : std_logic_vector(31 downto 0) := X"00000000";
    constant VPN_OFFSET : unsigned(19 downto 0) := X"00001";

    signal tlbEntries : TLBRegType;

begin
    process(clk, reset)
    begin
        if(reset = '1') then
            for i in tlbEntries'range loop
                tlbEntries(i) <= (127 => '1',others => '0');
            end loop;
        elsif(clk'event and clk = '1') then
            if(is_tlb_write = '1') then
                tlbEntries(write_index) <= entry_hi & PAGEMASK & entry_lo0 & entry_lo1;
            end if;
        end if;
    end process;

    process(vaddr, tlbEntries) 
        variable hi : std_logic_vector(31 downto 0);
        variable intr : std_logic;
    begin
        intr := '1';
        if (vaddr and X"80000000") /= X"00000000" then
            paddr <= vaddr;
            tlb_intr <= '0';
        else
            for i in tlbEntries'range loop
                hi := tlbEntries(i)(ENTRYHI);
                if vaddr(PAGENUMBER) = hi(PAGENUMBER) then
                    report "found tlb 0";
                    print_hex(tlbEntries(i)(ENTRYLO0));
                    print_hex(tlbEntries(i)(ENTRYLO0)(PAGENUMBER) & vaddr(PAGEOFFSET));
                    paddr <= tlbEntries(i)(ENTRYLO0)(PAGENUMBER) & vaddr(PAGEOFFSET);
                    intr := '0';
                    exit;
                elsif vaddr(PAGENUMBER) = std_logic_vector(unsigned(hi(PAGENUMBER)) + VPN_OFFSET) then
                    report "found tlb 1";
                    print_hex(tlbEntries(i)(ENTRYLO1));
                    --paddr <= tlbEntries(i)(ENTRYLO1)(PAGENUMBER) & vaddr(PAGEOFFSET);
                    intr := '0';
                    exit;
                end if;
            end loop;
            tlb_intr <= intr;
        end if;
    end process;

end Behavioral;

