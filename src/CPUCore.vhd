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
            is_cancel : in STD_LOGIC;
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

    signal data_masked : std_logic_vector(31 downto 0);
    signal result_mem_final : std_logic_vector(31 downto 0);

    signal result_wb : std_logic_vector(31 downto 0);
    signal is_reg_write_wb : std_logic;
    signal rd_id_wb : integer range 0 to 127;
    
    constant LINK_OFFSET : unsigned := X"00000004";
begin
    cpu_clk <= inner_cpu_clk;
    --rs_id_id <= to_integer(unsigned(inst_id(25 downto 21)));
    --rt_id_id <= to_integer(unsigned(inst_id(20 downto 16)));
    is_next_mem <= is_mem_write_ex or is_mem_read_ex;
    result_ex <= alu_result when is_link_ex = '0' else std_logic_vector(unsigned(npc_ex) + LINK_OFFSET);
    is_mem_read_ex_final <= is_mem_read_ex and (not is_cancel);
    is_mem_write_ex_final <= is_mem_write_ex and (not is_cancel);
    is_reg_write_ex_final <= is_reg_write_ex and (not is_cancel);
    data_core <= rt_mem;
    result_mem_final <= data_masked when is_mem_read_mem = '1' else result_mem;
    inst_use <= inst_ex when inst_bubble_ex = '1' else inst_id;

    is_bubble_if <= is_bubble or inst_bubble_id;

    if_phase: IFPhase Port Map(
        is_bubble => is_bubble_if,
        need_branch => need_branch,
        branch_pc => branch_pc,
        data_mem => data_masked,
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
        mem_opcode => mem_op_code_id,
        shift_amount => shift_amount_id,
        is_reg_write => is_reg_write_id,
        alu_opcode => alu_op_code_id,
        rd_id => rd_id_id,
        rt_id => rt_id_id,
        rs_id => rs_id_id,
        need_bubble => inst_bubble_id,
        immediate => immediate_id,
        clk => inner_cpu_clk,
        reset => reset
    );

    branch_bypass : BranchByPass Port Map(
        rs => rs_data_id,
        rt => rt_data_id,
        immediate => immediate_id,
        l_result => result_ex,
        ll_result => result_mem,
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
        inst_id => inst_id,
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
        data_old => result_wb,
        mem_op_code => mem_op_code_mem,
        result_mem => result_mem,
        data_out => data_masked
    );

    mem_wb : MEM_WB_Regs Port Map(
        result_mem => result_mem_final,
        result_wb => result_wb,
        is_reg_write_mem => is_reg_write_mem,
        is_reg_write_wb => is_reg_write_wb,
        rd_id_mem => rd_id_mem,
        rd_id_wb => rd_id_wb,
        clk => inner_cpu_clk,
        reset => reset
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

