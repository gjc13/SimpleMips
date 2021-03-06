----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    15:18:01 12/11/2015 
-- Design Name: 
-- Module Name:    FlashCtrl - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: --
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FlashCtrl is
    Port ( ctrl_addr : in  STD_LOGIC_VECTOR (31 downto 0);
           data_in : in STD_LOGIC_VECTOR(31 downto 0);
           data_out : out  STD_LOGIC_VECTOR (31 downto 0);
           intr : out  STD_LOGIC;
           r : in STD_LOGIC;
           w : in STD_LOGIC;
           next_pend : in  STD_LOGIC;
           need_mem : out  STD_LOGIC;
           flash_ce : out  STD_LOGIC;
           flash_byte_mode : out  STD_LOGIC;
           flash_oe : out  STD_LOGIC;
           flash_we : out  STD_LOGIC;
           flash_addr : out  STD_LOGIC_VECTOR (22 downto 0);
           flash_data : inout  STD_LOGIC_VECTOR (15 downto 0);
           flash_vpen : out  STD_LOGIC;
           flash_rp : out  STD_LOGIC;
           mem_addr : out  STD_LOGIC_VECTOR (31 downto 0);
           mem_data_out : out  STD_LOGIC_VECTOR (31 downto 0);
           mem_data_in : in STD_LOGIC_VECTOR(31 downto 0);
           mem_r : out  STD_LOGIC;
           mem_w : out  STD_LOGIC;
           clk : in  STD_LOGIC;
           cpu_clk : in STD_LOGIC;
           reset : in  STD_LOGIC);
end FlashCtrl;

architecture Behavioral of FlashCtrl is
    type State is (IDLE, CMD_START, CMD_WRITE, CMD_END, 
        READ_EN, READ_START, READ_LATCH, READ_MEM, READ_WAIT_MEM,
        CHECK_START, CHECK_CMD, CHECK_READ, CHECK_END,
        WRITE_WAIT_MEM, WRITE_MEM, WRITE_EN, WRITE_DATA, WRITE_WAIT);
    type Phase is (NOP, READ, ERASE1, ERASE2, CHECK, WRITE1, WRITE2);
    
    constant CTRL_I : std_logic_vector(31 downto 0) := X"00000000";
    constant STATUS_I : std_logic_vector(31 downto 0) := X"00000004";
    constant FLASH_START_I : std_logic_vector(31 downto 0) := X"00000008";
    constant FLASH_END_I : std_logic_vector(31 downto 0) := X"0000000C";
    --real address
    constant MEM_START_I : std_logic_vector(31 downto 0) := X"00000010";

    constant INST_READ : std_logic_vector(31 downto 0) := X"00000001";
    constant INST_WRITE : std_logic_vector(31 downto 0) := X"00000010";
    constant INST_ERASE : std_logic_vector(31 downto 0) := X"00000100";
    constant INST_CLEAR : std_logic_vector(31 downto 0) := X"00000000";

    constant FLASH_ADDER : unsigned := resize(X"2" , flash_addr'length);
    constant MEM_ADDER : unsigned := X"00000004";


    signal ctrl_reg : std_logic_vector(31 downto 0);
    signal flash_start_reg : std_logic_vector(31 downto 0);
    signal flash_end_reg : std_logic_vector(31 downto 0);
    signal mem_start_reg : std_logic_vector(31 downto 0);
    signal status_reg : std_logic_vector(31 downto 0);

    signal next_flash_addr: std_logic_vector(22 downto 0);
    signal next_flash_data: std_logic_vector(15 downto 0);
    signal next_mem_addr : std_logic_vector(31 downto 0);
    signal next_mem_data : std_logic_vector(31 downto 0);

    signal next_flash_we : std_logic;
    signal next_flash_oe : std_logic;
    signal next_mem_r : std_logic;
    signal next_mem_w : std_logic;

    signal flash_now_addr : std_logic_vector(22 downto 0);
    signal flash_next_addr : std_logic_vector(22 downto 0);
    signal mem_now_addr : std_logic_vector(31 downto 0);
    signal mem_next_addr : std_logic_vector(31 downto 0);
    signal databuf : std_logic_vector(31 downto 0);

    signal pr_state : State;
    signal next_state : State;
    signal pr_phase : Phase;
    signal next_phase : Phase;

    signal cmd : std_logic_vector(15 downto 0);

    signal need_latch : std_logic;
    signal latch_hi : std_logic;
    signal finished : std_logic;
    
    signal next_need_flash_z : std_logic;
    
begin
    flash_ce <= '0';
    flash_rp <= '1';
    flash_vpen <= '1';
    flash_byte_mode <= '1';
    mem_addr <= mem_now_addr;
    flash_addr <= flash_now_addr;
    intr <= status_reg(0);

    process(clk, reset)
    begin
        if reset = '1' then
            ctrl_reg <= (others => '0');
            flash_start_reg <= (others => '0');
            flash_end_reg <= (others => '0');
            mem_start_reg <= (others => '0');
        elsif clk'event and clk = '1' then
            if w = '1' and r = '0' then
                case ctrl_addr is
                    when CTRL_I =>
                        ctrl_reg <= data_in;
                    when FLASH_START_I =>
                        flash_start_reg <= data_in;
                    when FLASH_END_I =>
                        flash_end_reg <= data_in;
                    when MEM_START_I =>
                        mem_start_reg <= data_in;
                    when others =>
                        null;
                end case;
            end if;
        end if;
    end process;


    process(clk, reset)
    begin
        if reset = '1' then
            status_reg <= (others => '0');
        elsif clk'event and clk = '1' then
            if finished = '1' then
                status_reg(0) <= '1';
            elsif ctrl_addr = CTRL_I and w = '1' and mem_data_in = INST_CLEAR then
                status_reg(0) <= '0';
            end if;
        end if;
    end process;

    process(clk)
    begin
        if clk'event and clk = '1' then
            if r = '1' and w = '0' and ctrl_addr = STATUS_I then
                data_out <= status_reg;
            end if;
        end if;
    end process;


    process(cpu_clk, reset)
    begin 
        if(reset = '1') then
            flash_now_addr <= (others => '0');
            flash_data <= (others => 'Z');
            mem_now_addr <= (others => '0');
            mem_data_out <= (others => '0');
            flash_oe <= '1';
            flash_we <= '1';
            mem_r <= '0';
            mem_w <= '0';
            pr_state <= IDLE;
            pr_phase <= NOP;
        elsif (cpu_clk'event and cpu_clk = '1') then
            if next_need_flash_z = '1' then
                flash_data <= (others => 'Z');
            else
                flash_data <= next_flash_data;
            end if;
            mem_now_addr <= next_mem_addr;
            mem_data_out <= next_mem_data;
            flash_oe <= next_flash_oe;
            flash_we <= next_flash_we;
            mem_r <= next_mem_r;
            mem_w <= next_mem_w;
            pr_phase <= next_phase;
            pr_state <= next_state;
            flash_now_addr <= next_flash_addr;
            mem_now_addr <= next_mem_addr;
        end if;
    end process;


    process(ctrl_reg, pr_state, pr_phase, 
        flash_data, flash_now_addr, flash_end_reg, 
        mem_now_addr, cmd, databuf, status_reg, 
        next_pend, mem_data_in,
        mem_start_reg, flash_start_reg)
        variable flash_addr_new : std_logic_vector(22 downto 0);
        variable flash_data_new : std_logic_vector(15 downto 0);
        variable mem_addr_new : std_logic_vector(31 downto 0);
        variable mem_data_new : std_logic_vector(31 downto 0);
        variable flash_oe_new : std_logic;
        variable flash_we_new : std_logic;
        variable mem_r_new : std_logic;
        variable mem_w_new : std_logic;
        variable need_latch_new : std_logic;
        variable finished_new : std_logic;
        variable phase_new : Phase;
        variable need_mem_new : std_logic;
        variable need_flash_z_new : std_logic;
    begin
        flash_addr_new := flash_now_addr;
        flash_data_new := (others => '0');
        mem_addr_new := mem_now_addr;
        mem_data_new := (others => '0');
        flash_oe_new := '1';
        flash_we_new := '1';
        mem_r_new := '0';
        mem_w_new := '0';
        need_latch_new := '0';
        phase_new := pr_phase;
        finished_new := '0';
        need_mem_new := '0';
        need_flash_z_new := '1';
        case pr_state is
            when IDLE =>
                if ctrl_reg = INST_READ and status_reg(0) = '0' then
                    next_state <= CMD_START;
                    phase_new := READ;
                    flash_we_new := '0';
                    flash_data_new := cmd;
                    need_flash_z_new := '0';
                elsif ctrl_reg = INST_WRITE and status_reg(0) = '0' then
                    next_state <= CMD_START;
                    phase_new := WRITE1;
                    flash_we_new := '0';
                    flash_data_new := cmd;
                    need_flash_z_new := '0';
                elsif ctrl_reg = INST_ERASE and status_reg(0) = '0' then
                    next_state <= CMD_START;
                    phase_new := ERASE1;
                    flash_we_new := '0';
                    flash_data_new := cmd;
                    need_flash_z_new := '0';
                else
                    next_state <= IDLE;
                end if;
                mem_addr_new := mem_start_reg;
                flash_addr_new := flash_start_reg(22 downto 0);
            when CMD_START =>
                next_state <= CMD_WRITE;
                flash_we_new := '0';
                flash_data_new := cmd;
                need_flash_z_new := '0';
            when CMD_WRITE =>
                next_state <= CMD_END;
                flash_data_new := cmd;
                need_flash_z_new := '0';
                flash_we_new := '1';
            when CMD_END =>
                case pr_phase is 
                    when READ =>
                        next_state <= READ_EN;
                    when WRITE1 => 
                        if next_pend = '1' then
                            next_state <= WRITE_WAIT_MEM;
                        else
                            next_state <= WRITE_MEM;
                            mem_r_new := '1';
                            mem_addr_new := mem_now_addr;
                        end if;
                    when WRITE2 =>
                        next_state <= WRITE_EN;
                        flash_data_new := databuf(31 downto 16);
                        need_flash_z_new := '0';
                        flash_we_new := '0';
                    when ERASE1 =>
                        next_state <= CMD_START;
                        flash_we_new := '0';
                        phase_new := ERASE2;
                    when ERASE2 =>
                        next_state <= CHECK_START;
                        flash_we_new := '0';
                        phase_new := CHECK;
                    when CHECK =>
                        next_state <= CHECK_START;
                        flash_we_new := '0';
                    when others =>
                        next_state <= IDLE;
                end case;
            when READ_EN =>
                flash_oe_new := '0';
                next_state <= READ_START;
            when READ_START =>
                next_state <= READ_LATCH;
                flash_oe_new := '0';
                need_latch_new := '1';
            when READ_LATCH =>
                need_latch_new := '0';
                flash_oe_new := '0';
                flash_addr_new := std_logic_vector(unsigned(flash_now_addr) + FLASH_ADDER);
                if flash_now_addr(1) = '1' and next_pend = '0' then
                    next_state <= READ_MEM;
                    mem_r_new := '0';
                    mem_w_new := '1';
                    mem_data_new :=  flash_data & databuf(15 downto 0);
                elsif flash_now_addr(1) = '1' and next_pend = '1' then
                    next_state <= READ_WAIT_MEM;
                else
                    next_state <= READ_START;
                end if;
            when READ_WAIT_MEM =>
                if next_pend = '0' then
                    next_state <= READ_MEM;
                    mem_r_new := '0';
                    mem_w_new := '1';
                    mem_data_new :=  databuf;
                else
                    next_state <= READ_WAIT_MEM;
                end if;
            when READ_MEM =>
                mem_addr_new := std_logic_vector(unsigned(mem_now_addr) + MEM_ADDER);
                if flash_now_addr = flash_end_reg(22 downto 0) then
                    next_state <= IDLE;
                    finished_new := '1';
                    phase_new := NOP;
                elsif flash_now_addr(2) = '0' then 
                    next_state <= CMD_START;
                    flash_we_new := '0';
                    flash_data_new := cmd;
                    need_flash_z_new := '0';
                elsif flash_now_addr(2) = '1' then
                    next_state <= READ_START;
                    flash_oe_new :=  '0';
                end if;
                need_mem_new := '1';
            when CHECK_START => 
                flash_we_new := '0';
                flash_data_new := cmd;
                need_flash_z_new := '0';
                next_state <= CHECK_CMD;
            when CHECK_CMD =>
                next_state <= CHECK_READ;
                flash_data_new := cmd;
                need_flash_z_new := '0';
            when CHECK_READ => 
                next_state <= CHECK_END;
                flash_oe_new := '0';
            when CHECK_END =>
                if flash_data(7) = '1' then 
                    case pr_phase is 
                        when WRITE1 | WRITE2 =>
                            next_state <= WRITE_WAIT;
                        when others =>
                            next_state <= IDLE;
                            phase_new := NOP;
                            finished_new := '1';
                    end case;
                else
                    case pr_phase is 
                        when WRITE1 | WRITE2 =>
                            next_state <= WRITE_DATA;
                        when others =>
                            next_state <= CMD_END;
                    end case;
                end if;
            when WRITE_WAIT_MEM =>
                if next_pend = '1' then
                    next_state <= WRITE_WAIT_MEM;
                else 
                    next_state <= WRITE_MEM;
                    next_mem_r <= '1';
                end if;
            when WRITE_MEM =>
                next_state <= WRITE_EN;
                flash_data_new := mem_data_in(15 downto 0);
                need_flash_z_new := '0';
                flash_we_new := '0';
                need_mem_new := '1';
            when WRITE_EN =>
                next_state <= WRITE_DATA;
                flash_data_new := flash_data;
                need_flash_z_new := '0';
                flash_we_new := '0';
            when WRITE_DATA =>
                next_state <= CHECK_READ;
            when WRITE_WAIT =>
                flash_addr_new := std_logic_vector(unsigned(flash_now_addr) + FLASH_ADDER);
                if flash_addr_new = flash_end_reg(22 downto 0) then
                    next_state <= IDLE;
                    finished_new := '1';
                    phase_new := NOP;
                else
                    next_state <= CMD_START;
                    flash_we_new := '0';
                    flash_data_new := cmd;
                    need_flash_z_new := '0';
                end if;
                if pr_phase = WRITE1 then
                    phase_new := WRITE2;
                else
                    phase_new := WRITE1;
                    mem_addr_new := std_logic_vector(unsigned(mem_now_addr) + MEM_ADDER);
                end if;
        end case;
        next_flash_addr <= flash_addr_new;
        next_flash_data <= flash_data_new;
        next_mem_addr <= mem_addr_new;
        next_mem_data <= mem_data_new;
        next_flash_oe <= flash_oe_new;
        next_flash_we <= flash_we_new;
        next_mem_r <= mem_r_new;
        next_mem_w <= mem_w_new;
        next_phase <= phase_new;
        finished <= finished_new;
        need_mem <= need_mem_new;
        need_latch <= need_latch_new;
        next_need_flash_z <= need_flash_z_new;
    end process;

    process(cpu_clk)
    begin
        if cpu_clk'event and cpu_clk = '1' then
            if need_latch = '1' and flash_now_addr(1) = '0' then
                databuf(15 downto 0) <= flash_data;
            elsif need_latch = '1' then
                databuf(31 downto 16) <= flash_data;
            elsif pr_state = WRITE_MEM then
                databuf <= mem_data_in;
            end if;
        end if;
    end process;

    process(pr_phase)
    begin
        case pr_phase is
            when READ =>
                cmd <= X"00ff";
            when WRITE1 =>
                cmd <= X"0040";
            when WRITE2 =>
                cmd <= X"0040";
            when ERASE1 =>
                cmd <= X"0020";
            when ERASE2 =>
                cmd <= X"00D0";
            when CHECK =>
                cmd <= X"0070";
            when others =>
                cmd <= X"0000";
        end case;
    end process;


end Behavioral;


