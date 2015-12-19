----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    10:51:02 11/25/2015 
-- Design Name: 
-- Module Name:    ExceptionDecoder - Behavioral 
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
use work.Utilities.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ExceptionDecoder is
    Port (  is_in_slot : in  STD_LOGIC;
            victim_addr : in STD_LOGIC_VECTOR (31 downto 0);
            mem_addr : in  STD_LOGIC_VECTOR (31 downto 0);
            mem_r : in  STD_LOGIC;
            mem_w : in  STD_LOGIC;
            status_old : in  STD_LOGIC_VECTOR (31 downto 0);
            cause_old : in  STD_LOGIC_VECTOR (31 downto 0);
            epc_old : in  STD_LOGIC_VECTOR (31 downto 0);
            entryhi_old : in  STD_LOGIC_VECTOR (31 downto 0);
            ebase : in STD_LOGIC_VECTOR (31 downto 0);
            is_intr : in  STD_LOGIC;
            syscall_intr : in  STD_LOGIC;
            clk_intr : in  STD_LOGIC;
            com1_intr : in  STD_LOGIC;
            dma_intr : in  STD_LOGIC;
            ps2_intr : in  STD_LOGIC;
            ri_intr : in  STD_LOGIC;
            tlb_intr : in  STD_LOGIC;
            ade_intr : in  STD_LOGIC;
            is_eret : in  STD_LOGIC;
            epc_new : out  STD_LOGIC_VECTOR (31 downto 0);
            status_new : out  STD_LOGIC_VECTOR (31 downto 0);
            cause_new : out  STD_LOGIC_VECTOR (31 downto 0);
            badvaddr_new : out  STD_LOGIC_VECTOR (31 downto 0);
            entryhi_new : out STD_LOGIC_VECTOR(31 downto 0);
            handler_addr : out  STD_LOGIC_VECTOR (31 downto 0);
            is_cancel : out  STD_LOGIC;
            force_cp0_write : out STD_LOGIC;
            clk : in STD_LOGIC;
            reset : in STD_LOGIC);
end ExceptionDecoder;

architecture Behavioral of ExceptionDecoder is
    type State is (IDLE, CANCEL1, CANCEL2);
    signal pr_state: State;
    signal next_state : State;
    signal is_cancel_fsm : std_logic;
    signal next_is_cancel : std_logic;
    signal need_intr : std_logic;

    constant IE : integer := 0;
    constant EXL : integer := 1;
    subtype KSU is integer range 4 downto 3;
    constant BEV : integer := 22;

    constant BD : integer := 31;
    subtype IP is integer range 15 downto 8;
    subtype EXCCODE is integer range 6 downto 2;

    subtype VPN2 is integer range 31 downto 13;

    constant ROM_EBASE : unsigned := X"BFC00200";
    constant BRANCH_OFFSET : unsigned := X"00000004";

begin 
    need_intr <= is_intr and status_old(IE) and (not status_old(EXL)); 
    force_cp0_write <= need_intr or is_eret; 
    badvaddr_new <= mem_addr;

    process(reset, clk)
    begin
        if (reset = '1') then
            pr_state <= IDLE;
            is_cancel_fsm <= '0';
        elsif (clk'event and clk = '1') then
            pr_state <= next_state;
            is_cancel_fsm <= next_is_cancel;
        end if;
    end process;

    process(need_intr, pr_state)
    begin
        case pr_state is 
            when IDLE =>
                if need_intr = '1' then
                    next_state <= CANCEL1;
                    next_is_cancel <= '1';
                else
                    next_state <= IDLE;
                    next_is_cancel <= '0';
                end if;
            when CANCEL1 =>
                next_state <= CANCEL2;
                next_is_cancel <= '1';
            when CANCEL2 => 
                next_state <= IDLE;
                next_is_cancel <= '0';
            when others =>
                next_state <= IDLE;
                next_is_cancel <= '0';
        end case;
    end process;

    process(need_intr, is_cancel_fsm, pr_state)
    begin
        if pr_state = IDLE then
            is_cancel <= need_intr;
        else
            is_cancel <= is_cancel_fsm;
        end if;
    end process;

    process(need_intr, is_eret, status_old)
        variable status : std_logic_vector(31 downto 0);
    begin
        status := status_old;
        if need_intr = '1' then
            status(EXL) := '1';
        elsif is_eret = '1' then
            status(EXL) := '0';
        end if;
        status_new <= status;
    end process;

    process(need_intr, is_in_slot, syscall_intr, 
            clk_intr, com1_intr, dma_intr, ps2_intr, 
            tlb_intr, ade_intr, mem_r, mem_w,
            cause_old, ri_intr)
        variable cause : std_logic_vector(31 downto 0);
    begin
        cause := cause_old;
        if need_intr = '1' then
            cause(BD) := is_in_slot;
            if tlb_intr = '1' then
                if mem_r = '0' and mem_w = '1' then
                    cause(EXCCODE) := "00011"; --TLBWS
                elsif mem_r = '1' and mem_w = '0' then
                    cause(EXCCODE) := "00010"; --TLBWL
                end if;
            elsif ri_intr = '1' then 
                cause(EXCCODE) := "01010"; --RI
            elsif syscall_intr = '1' then
                cause(EXCCODE) := "01000"; --SYSCALL
            elsif ade_intr = '1' then
                if mem_r = '0' and mem_w = '1' then
                    cause(EXCCODE) := "00101"; --ADEL
                end if;
            elsif clk_intr = '1' then
                cause(EXCCODE) := "00000";
                cause(IP) := "10000000";
            elsif com1_intr = '1' then
                cause(EXCCODE) := "00000";
                cause(IP) := "00010000";
            elsif dma_intr = '1' then
                cause(EXCCODE) := "00000";
                cause(IP) := "00001000";
            elsif ps2_intr = '1' then
                cause(EXCCODE) := "00000";
                cause(IP) := "01000000";
            end if;
        end if;
        cause_new <= cause;
    end process;

    process(need_intr, tlb_intr, mem_r, mem_w, entryhi_old, mem_addr)
        variable entryhi : std_logic_vector(31 downto 0);
    begin
        entryhi := entryhi_old;
        if tlb_intr = '1' then
            entryhi(VPN2) := mem_addr(VPN2);
        end if;
        entryhi_new <= entryhi;
    end process;

    process(status_old, epc_old, ebase, tlb_intr, is_eret)
        variable offset : unsigned(31 downto 0);
    begin
        if tlb_intr = '0' then
            offset := X"00000180";
        else
            offset := X"00000000";
        end if;
        if is_eret = '1' then
            handler_addr <= epc_old;
        elsif status_old(BEV) = '1' then
            handler_addr <= std_logic_vector(offset + ROM_EBASE);
        else
            handler_addr <= std_logic_vector(offset + unsigned(ebase));
        end if;
    end process;

    process(is_in_slot, victim_addr)
    begin
        if is_in_slot = '1' then
            epc_new <= std_logic_vector(unsigned(victim_addr) - BRANCH_OFFSET);
        else
            epc_new <= victim_addr;
        end if;
    end process;

end Behavioral;

