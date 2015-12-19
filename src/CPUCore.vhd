----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:16:25 11/09/2015 
-- Design Name: 
-- Module Name:    CPUCore - Behavioral 
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
use work.CPUComponent.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CPUCore is
    Port (  clk : in  STD_LOGIC;
            cpu_clk : out STD_LOGIC;
            reset : in STD_LOGIC;
            is_dma_mem : in STD_LOGIC;
            --is_cancel : in STD_LOGIC;
            is_next_mem : out STD_LOGIC;
            r_core : out  STD_LOGIC;
            w_core : out  STD_LOGIC;
            addr_core : out  STD_LOGIC_VECTOR (31 downto 0);
            data_core : out STD_LOGIC_VECTOR (31 downto 0);
            data_mem : in  STD_LOGIC_VECTOR (31 downto 0));
end CPUCore;

architecture Behavioral of CPUCore is

    signal sub_clk: std_logic := '0';
    signal inner_cpu_clk: std_logic := '0';
    signal is_bubble_if : std_logic;
    signal is_bubble: std_logic;
    signal need_branch: std_logic;
    signal branch_pc: std_logic_vector(31 downto 0);
    signal addr_pc : std_logic_vector(31 downto 0);
    signal w_pc : std_logic;
    signal r_pc : std_logic;
    signal inst_if : std_logic_vector(31 downto 0);
    signal npc_if : std_logic_vector(31 downto 0);
    signal inst_id : std_logic_vector(31 downto 0);
    signal inst_use : std_logic_vector(31 downto 0);
    signal npc_id : std_logic_vector(31 downto 0);

    --first id means id, the second means the instruction decode phase
    signal rs_id_id : integer range 0 to 127;
    signal rt_id_id : integer range 0 to 127;
    signal rs_data_id : std_logic_vector(31 downto 0);
    signal rt_data_id : std_logic_vector(31 downto 0);
    signal is_jump_id : std_logic;
    signal jump_pc_id : std_logic_vector(31 downto 0);
    signal is_jr_id : std_logic;
    signal is_jl_id : std_logic;
    signal is_link_id : std_logic;
    signal is_branch_id : std_logic;
    signal branch_offset_id : std_logic_vector(31 downto 0);
    signal branch_opcode_id : integer range 0 to 15;
    signal is_reg_inst_id : std_logic;
    signal is_mem_read_id : std_logic;
    signal is_mem_write_id : std_logic;
    signal mem_op_code_id : integer range 0 to 7;
    signal shift_amount_id : integer range 0 to 31;
    signal is_reg_write_id : std_logic;
    signal alu_op_code_id : integer range 0 to 15;
    signal rd_id_id : integer range 0 to 127;
    signal immediate_id : std_logic_vector(31 downto 0);
    signal inst_bubble_id : std_logic;
    signal is_tlb_write_id : std_logic;

    signal npc_ex : std_logic_vector(31 downto 0);
    signal inst_ex : std_logic_vector(31 downto 0);
    signal rs_ex : std_logic_vector(31 downto 0);
    signal rt_ex : std_logic_vector(31 downto 0);
    signal immediate_ex : std_logic_vector(31 downto 0);
    signal is_reg_inst_ex : std_logic;
    signal shift_amount_ex : integer range 0 to 31;
    signal alu_op_code_ex : integer range 0 to 15;
    signal is_link_ex : std_logic;
    signal mem_op_code_ex : integer range 0 to 7;
    signal is_mem_read_ex : std_logic;
    signal is_mem_write_ex : std_logic;
    signal is_reg_write_ex : std_logic;
    signal rd_id_ex : integer range 0 to 127;
    signal rs_id_ex : integer range 0 to 127;
    signal rt_id_ex : integer range 0 to 127;
    signal inst_bubble_ex : std_logic;
    signal is_tlb_write_ex : std_logic;

    signal alu_lhs : std_logic_vector(31 downto 0);
    signal alu_rhs : std_logic_vector(31 downto 0);
    signal alu_result : std_logic_vector(31 downto 0);
    signal rt_ex_final : std_logic_vector(31 downto 0);
    signal result_ex : std_logic_vector(31 downto 0);
    --consider is_cancel signal in ex phase
    signal is_mem_read_ex_final : std_logic;
    signal is_mem_write_ex_final : std_logic;
    signal is_reg_write_ex_final : std_logic;

    signal result_mem : std_logic_vector(31 downto 0);
    signal rt_mem : std_logic_vector(31 downto 0);
    signal mem_op_code_mem : integer range 0 to 7;
    signal is_mem_read_mem : std_logic;
    signal is_mem_write_mem : std_logic;
    signal is_reg_write_mem : std_logic;
    signal rd_id_mem : integer range 0 to 127;
    signal is_tlb_write_mem : std_logic;

    signal data_in_masked : std_logic_vector(31 downto 0);
    signal data_out_masked : std_logic_vector(31 downto 0);
    signal result_mem_final : std_logic_vector(31 downto 0);

    signal result_wb : std_logic_vector(31 downto 0);
    signal is_reg_write_wb : std_logic;
    signal rd_id_wb : integer range 0 to 127;
    signal is_tlb_write_wb : std_logic;

    signal status_old : std_logic_vector(31 downto 0);
    signal cause_old : std_logic_vector(31 downto 0);
    signal epc_old : std_logic_vector(31 downto 0);
    --signal entryhi_old : std_logic_vector(31 downto 0);
    signal index_old : std_logic_vector(31 downto 0);
    signal entryHi_old : std_logic_vector(31 downto 0);
    signal entryLo0_old : std_logic_vector(31 downto 0);
    signal entryLo1_old : std_logic_vector(31 downto 0);
	 
	 
    signal ebase : std_logic_vector(31 downto 0);
    signal is_intr : std_logic;
    signal syscall_intr : std_logic;
    signal clk_intr : std_logic;
    signal com1_intr : std_logic;
    signal dma_intr : std_logic;
    signal ps2_intr : std_logic;
    signal ri_intr : std_logic;
    signal tlb_intr : std_logic;
    signal ade_intr : std_logic;
    signal is_eret : std_logic;
    signal epc_new : std_logic_vector(31 downto 0);
    signal status_new : std_logic_vector(31 downto 0);
    signal cause_new : std_logic_vector(31 downto 0);
    signal badvaddr_new : std_logic_vector(31 downto 0);
    signal entryhi_new : std_logic_vector(31 downto 0);
    signal handler_addr : std_logic_vector(31 downto 0);
    signal is_cancel : std_logic;
    signal force_cp0_write : std_logic;
	signal need_intr : std_logic;
	
    signal is_in_slot : std_logic;
    signal victim_pc : std_logic_vector(31 downto 0);
    
	 signal vaddr: std_logic_vector(31 downto 0);
	 
	 signal result_ex_final :std_logic_vector(31 downto 0);
	 signal result_ex_tlb:std_logic_vector(31 downto 0);
	 signal is_mem_ex:std_logic;
    constant LINK_OFFSET : unsigned := X"00000004";
begin
    cpu_clk <= inner_cpu_clk;
    is_mem_ex<= is_mem_read_ex or is_mem_write_ex;
	 is_next_mem <= is_mem_write_ex or is_mem_read_ex;
	 result_ex_final <= result_ex_tlb when is_mem_ex = '1' else result_ex;
    result_ex <= alu_result when is_link_ex = '0' else std_logic_vector(unsigned(npc_ex) + LINK_OFFSET);
    is_mem_read_ex_final <= is_mem_read_ex and (not is_cancel);
    is_mem_write_ex_final <= is_mem_write_ex and (not is_cancel);
    is_reg_write_ex_final <= is_reg_write_ex and (not is_cancel);
    data_core <= data_out_masked;
    result_mem_final <= data_in_masked when is_mem_read_mem = '1' else result_mem;
    inst_use <= inst_ex when inst_bubble_ex = '1' else inst_id;

    is_bubble_if <= is_bubble or inst_bubble_id or is_dma_mem;

    is_intr <= syscall_intr or clk_intr or com1_intr or dma_intr or ps2_intr or ri_intr or tlb_intr or ade_intr;
    com1_intr <= '0';
    dma_intr <= '0';
    ps2_intr <= '0';
    ri_intr <= '0';
    ade_intr <= '0';

    if_phase: IFPhase Port Map(
        is_bubble => is_bubble_if,
		need_intr => need_intr,
        is_eret => is_eret,
		handler_addr => handler_addr,
        need_branch => need_branch,
        branch_pc => branch_pc,
        data_mem => data_mem,
        addr_pc => addr_pc,
        r_pc => r_pc,
        w_pc => w_pc,
        inst_if => inst_if,
        npc_if => npc_if,
        clk => inner_cpu_clk,
        reset => reset
    );

    if_id : IF_ID_Regs Port Map(
        npc_if => npc_if,
        npc_id => npc_id,
        inst_if => inst_if,
        inst_id => inst_id,
        clk => inner_cpu_clk,
        reset => reset
    );

    inst_decoder : InstDecode Port Map(
        inst => inst_use,
        npc => npc_id,
        is_jump => is_jump_id,
        jump_pc => jump_pc_id,
        is_jr   => is_jr_id,
        is_jl   => is_jl_id,
        is_link => is_link_id,
        is_branch => is_branch_id,
        branch_offset => branch_offset_id,
        branch_opcode => branch_opcode_id,
        is_reg_inst => is_reg_inst_id,
        is_mem_read => is_mem_read_id,
        is_mem_write => is_mem_write_id,
		l_is_mem_read=>is_mem_read_ex,
        mem_opcode => mem_op_code_id,
        shift_amount => shift_amount_id,
        is_reg_write => is_reg_write_id,
        alu_opcode => alu_op_code_id,
        rd_id => rd_id_id,
        rt_id => rt_id_id,
        rs_id => rs_id_id,
        need_bubble => inst_bubble_id,
        immediate => immediate_id,
        is_eret => is_eret,
        is_tlb_write => is_tlb_write_id,
        is_syscall => syscall_intr,
        clk => inner_cpu_clk,
        reset => reset
    );

    branch_bypass : BranchByPass Port Map(
        rs => rs_data_id,
        rt => rt_data_id,
        immediate => immediate_id,
        l_result => result_ex,
        ll_result => result_mem_final,
        lll_result => result_wb,
        rs_id => rs_id_id,
        rt_id => rt_id_id,
        l_rd_id => rd_id_ex,
        ll_rd_id => rd_id_mem,
        lll_rd_id => rd_id_wb,
        l_is_reg_write => is_reg_write_ex,
        ll_is_reg_write => is_reg_write_mem,
        lll_is_reg_write => is_reg_write_wb,
        is_reg_inst => is_reg_inst_id,
        branch_opcode => branch_opcode_id,
        is_branch => is_branch_id,
        is_jump => is_jump_id,
        is_jr => is_jr_id,
        branch_offset => branch_offset_id,
        next_pc => npc_id,
        jump_pc => jump_pc_id,
        final_pc => branch_pc,
        need_branch => need_branch
    );

    id_ex : ID_EX_Regs Port Map(
        inst_id => inst_use,
        inst_ex => inst_ex,
        npc_id => npc_id,
        npc_ex => npc_ex,
        rs_data_id => rs_data_id,
        rs_ex => rs_ex,
        rt_data_id => rt_data_id,
        rt_ex => rt_ex,
        immediate_id => immediate_id,
        immediate_ex => immediate_ex,
        is_reg_inst_id => is_reg_inst_id,
        is_reg_inst_ex => is_reg_inst_ex,
        shift_amount_id => shift_amount_id,
        shift_amount_ex => shift_amount_ex,
        alu_op_code_id => alu_op_code_id,
        alu_op_code_ex => alu_op_code_ex,
        is_link_id => is_link_id,
        is_link_ex => is_link_ex,
        mem_op_code_id => mem_op_code_id,
        mem_op_code_ex => mem_op_code_ex,
        is_mem_read_id => is_mem_read_id,
        is_mem_read_ex => is_mem_read_ex,
        is_mem_write_id => is_mem_write_id,
        is_mem_write_ex => is_mem_write_ex,
        is_reg_write_id => is_reg_write_id,
        is_reg_write_ex => is_reg_write_ex,
        rs_id_id => rs_id_id,
        rs_id_ex => rs_id_ex,
        rt_id_id => rt_id_id,
        rt_id_ex => rt_id_ex,
        rd_id_id => rd_id_id,
        rd_id_ex => rd_id_ex,
        inst_bubble_id => inst_bubble_id,
        inst_bubble_ex => inst_bubble_ex,
        is_tlb_write_id => is_tlb_write_id,
        is_tlb_write_ex => is_tlb_write_ex,
        clk => inner_cpu_clk,
        reset => reset
    );

    data_bypass : DataByPass Port Map(
        rs_id => rs_id_ex,
        rt_id => rt_id_ex,
        l_rd_id => rd_id_mem,
        ll_rd_id => rd_id_wb,
        l_is_reg_write => is_reg_write_mem,
        ll_is_reg_write => is_reg_write_wb,
        is_reg_inst => is_reg_inst_ex,
        rs => rs_ex,
        rt => rt_ex,
        immediate => immediate_ex,
        l_result => result_mem_final,
        ll_result => result_wb,
        lhs => alu_lhs,
        rhs => alu_rhs,
        rt_final => rt_ex_final
    );

    reg : RegFile Port Map(
        rs_id => rs_id_id,
        rt_id => rt_id_id,
        rd_id => rd_id_wb,
        is_regwrite => is_reg_write_wb,
        rd_data => result_wb,
        rs_data => rs_data_id,
        rt_data => rt_data_id,
        status_new => status_new,
        cause_new => cause_new,
        badvaddr_new => badvaddr_new,
        entry_hi_new => entryhi_new,
        epc_new => epc_new,
        force_cp0_write => force_cp0_write,
        status => status_old,
        cause => cause_old,
		  index => index_old,
		  entryHi => entryHi_old,
		  entryLo0 => entryLo0_old,
		  entryLo1 => entryLo1_old,
        --count => count_old,
        --compare => compare_old,
        ebase => ebase,
        epc => epc_old,
        clk_intr => clk_intr,
        clk => inner_cpu_clk,
        reset => reset
    );

    alu_ex : alu Port Map(
        lhs => alu_lhs,
        rhs => alu_rhs,
        shift_amount => shift_amount_ex,
        alu_opcode => alu_op_code_ex,
        result => alu_result
    );

    ex_mem : EX_MEM_Regs Port Map(
        result_ex => result_ex,
        result_mem => result_mem,
        rt_ex => rt_ex_final,
        rt_mem => rt_mem,
        mem_op_code_ex => mem_op_code_ex,
        mem_op_code_mem => mem_op_code_mem,
        is_mem_read_ex => is_mem_read_ex_final,
        is_mem_read_mem => is_mem_read_mem,
        is_mem_write_ex => is_mem_write_ex_final,
        is_mem_write_mem => is_mem_write_mem,
        is_reg_write_ex => is_reg_write_ex_final,
        is_reg_write_mem => is_reg_write_mem,
        rd_id_ex => rd_id_ex,
        rd_id_mem => rd_id_mem,
        is_tlb_write_ex => is_tlb_write_ex,
        is_tlb_write_mem => is_tlb_write_mem,
        clk => inner_cpu_clk,
        reset => reset
    );

    mem_conflict_solver: MemConflictSolver Port Map(
        r_pc => r_pc,
        w_pc => w_pc,
        r_mem => is_mem_read_mem,
        w_mem => is_mem_write_mem,
        is_dma_mem => is_dma_mem,
        addr_pc => addr_pc,
        addr_mem => result_mem,
        is_bubble => is_bubble,
        addr_core => addr_core,
        r_core => r_core,
        w_core => w_core
    );

    data_mask : DataMasker Port Map(
        data_in => data_mem,
		data_in_masked => data_in_masked,
        data_old => result_wb,
		data_out => rt_mem,
		data_out_masked => data_out_masked,
        mem_op_code => mem_op_code_mem,
        addr => result_mem
    );

    mem_wb : MEM_WB_Regs Port Map(
        result_mem => result_mem_final,
        result_wb => result_wb,
        is_reg_write_mem => is_reg_write_mem,
        is_reg_write_wb => is_reg_write_wb,
        rd_id_mem => rd_id_mem,
        rd_id_wb => rd_id_wb,
        is_tlb_write_mem => is_tlb_write_mem,
        is_tlb_write_wb => is_tlb_write_wb,
        clk => inner_cpu_clk,
        reset => reset
    );

    exception_decoder : ExceptionDecoder Port Map(
        is_in_slot => is_in_slot,
		need_intr_out => need_intr,
        victim_addr => victim_pc,
		  --??
        mem_addr => result_ex,
        mem_r => is_mem_read_ex,
        mem_w => is_mem_write_ex,
        status_old => status_old,
        cause_old => cause_old,
        epc_old => epc_old,
        entryhi_old => entryHi_old,
        ebase => ebase,
        is_intr => is_intr,
        syscall_intr => syscall_intr,
        clk_intr => clk_intr,
        com1_intr => com1_intr,
        dma_intr => dma_intr,
        ps2_intr => ps2_intr,
        ri_intr => ri_intr,
        tlb_intr => tlb_intr,
        ade_intr => ade_intr,
        is_eret => is_eret,
        epc_new => epc_new,
        status_new => status_new,
        cause_new => cause_new,
        badvaddr_new => badvaddr_new,
        entryhi_new => entryhi_new,
        handler_addr => handler_addr,
        is_cancel => is_cancel,
        force_cp0_write => force_cp0_write,
        clk => inner_cpu_clk,
        reset => reset
    );

    victim_finder : VictimFinder Port Map(
        now_pc => addr_pc,
        is_bubble => is_bubble,
        pre_branch => is_branch_id,
        victim_pc => victim_pc,
        is_in_slot => is_in_slot,
        clk => inner_cpu_clk,
        reset => reset
    );

	 TLB_uut: tlb Port Map(
		index => index_old,
		is_tlb_write => is_tlb_write_wb,
		entry_hi =>entryHi_old,
        entry_lo0 =>entryLo0_old,
        entry_lo1 =>entryLo1_old,
		vaddr => result_ex,
        paddr => result_ex_tlb,
		tlb_intr =>tlb_intr,
		clk => inner_cpu_clk,
		reset => reset,
		en =>is_mem_ex
	 );

    --clk dividers
    sub_clk_process :process(clk)
    begin
        if clk'event and clk = '1' then
            sub_clk <= not sub_clk;
        end if;
    end process;

    cpu_clk_process :process(sub_clk)
    begin
       if sub_clk'event and sub_clk = '1' then
            inner_cpu_clk <= not inner_cpu_clk;
        end if;
    end process;

end Behavioral;

