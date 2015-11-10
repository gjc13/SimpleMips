--
--	Package File Template
--
--	Purpose: This package defines supplemental types, subtypes, 
--		 constants, and functions 
--
--   To use any of the example code shown below, uncomment the lines and modify as necessary
--

library IEEE;
use IEEE.STD_LOGIC_1164.all;

package CPUComponent is
	component MemDecoder
    port(
         addr : IN  std_logic_vector(31 downto 0);
         r : IN  std_logic;
         w : IN  std_logic;
         data_in : IN  std_logic_vector(31 downto 0);
         data_out : OUT  std_logic_vector(31 downto 0);
         addr_bus : OUT  std_logic_vector(31 downto 0);
         r_bus : OUT  std_logic;
         w_bus : OUT  std_logic;
         data_bus : INOUT  std_logic_vector(31 downto 0);
         reset : IN  std_logic;
         clk : IN  std_logic;
         cpu_clk : IN  std_logic);
	end component;

	component MemConflictSolver
    port (  r_pc : in  STD_LOGIC;
			w_pc : in  STD_LOGIC;
			r_mem : in  STD_LOGIC;
			w_mem : in  STD_LOGIC;
			is_dma_mem : in STD_LOGIC;
			addr_pc : in  STD_LOGIC_VECTOR (31 downto 0);
			addr_mem : in  STD_LOGIC_VECTOR (31 downto 0);
			is_bubble : out  STD_LOGIC;
			addr_core : out  STD_LOGIC_VECTOR (31 downto 0);
			r_core : out  STD_LOGIC;
			w_core : out  STD_LOGIC);
	end component;

	component IFPhase
    port (  is_bubble : in  STD_LOGIC;
			need_branch : in  STD_LOGIC;
			branch_pc : in STD_LOGIC_VECTOR (31 downto 0);
			data_mem : in  STD_LOGIC_VECTOR (31 downto 0);
			addr_pc : out STD_LOGIC_VECTOR(31 downto 0);
			r_pc : out STD_LOGIC;
			w_pc : out STD_LOGIC;
			inst_if : out  STD_LOGIC_VECTOR (31 downto 0);
			npc_if : out  STD_LOGIC_VECTOR (31 downto 0);
			clk : in STD_LOGIC;
			reset : in STD_LOGIC);
	end component;

	component IF_ID_Regs
    Port (  npc_if : in  STD_LOGIC_VECTOR (31 downto 0);
			npc_id : out  STD_LOGIC_VECTOR (31 downto 0);
			inst_if : in  STD_LOGIC_VECTOR (31 downto 0);
			inst_id : out  STD_LOGIC_VECTOR (31 downto 0);
			clk : in STD_LOGIC;
			reset : in STD_LOGIC);
	end component;

	component InstDecode
    Port (  inst : in  STD_LOGIC_VECTOR (31 downto 0);
			l_is_mem_read : in  STD_LOGIC;
			l_is_mem_write : in  STD_LOGIC;
			is_jump : out  STD_LOGIC;
			jump_pc : out  STD_LOGIC_VECTOR (31 downto 0);
			is_jr 	: out  STD_LOGIC;
			is_jl 	: out STD_LOGIC;
			is_link : out STD_LOGIC;
			is_branch : out  STD_LOGIC;
			branch_offset : out  STD_LOGIC_VECTOR (31 downto 0);
			branch_opcode : out INTEGER RANGE 0 to 15;
			is_reg_inst : out  STD_LOGIC;
			is_mem_read : out  STD_LOGIC;
			is_mem_write : out  STD_LOGIC;
			mem_opcode : out INTEGER RANGE 0 to 7;
			shift_amount : out INTEGER RANGE 0 to 31;
			is_reg_write : out  STD_LOGIC;
			alu_opcode : out  INTEGER RANGE 0 to 15;
			rd_id : out  INTEGER RANGE 0 to 127;
			immediate : out STD_LOGIC_VECTOR(31 downto 0));
	end component;

	component BranchByPass
    Port (  rs : in  STD_LOGIC_VECTOR (31 downto 0);
			rt : in  STD_LOGIC_VECTOR (31 downto 0);
			immediate : in  STD_LOGIC_VECTOR (31 downto 0);
			l_result : in STD_LOGIC_VECTOR(31 downto 0);
			ll_result : in STD_LOGIC_VECTOR(31 downto 0);
			lll_result : in STD_LOGIC_VECTOR(31 downto 0);
			rs_id : in INTEGER RANGE 0 to 127;
			rt_id : in INTEGER RANGE 0 to 127;
			l_rd_id : in INTEGER RANGE 0 to 127;
			ll_rd_id : in INTEGER RANGE 0 to 127;
			lll_rd_id : in INTEGER RANGE 0 to 127;
			l_is_reg_write : in STD_LOGIC;
			ll_is_reg_write : in STD_LOGIC;
			lll_is_reg_write : in STD_LOGIC;
			is_reg_inst : in  STD_LOGIC;
			branch_opcode : in  INTEGER RANGE 0 to 15;
			is_branch : in  STD_LOGIC;
			is_jump : in  STD_LOGIC;
			is_jr : in  STD_LOGIC;
			branch_offset : in  STD_LOGIC_VECTOR (31 downto 0);
			next_pc : in  STD_LOGIC_VECTOR (31 downto 0);
			jump_pc : in  STD_LOGIC_VECTOR (31 downto 0);
			final_pc : out  STD_LOGIC_VECTOR (31 downto 0);
			need_branch : out  STD_LOGIC);
	end component;
	
	component RegFile
	Port (  rs_id : in  INTEGER RANGE 0 TO 127;
            rt_id : in  INTEGER RANGE 0 TO 127;
            rd_id : in  INTEGER RANGE 0 TO 127;
            is_regwrite : in  STD_LOGIC;
            rd_data : in  STD_LOGIC_VECTOR (31 downto 0);
            rs_data : out  STD_LOGIC_VECTOR (31 downto 0);
            rt_data : out  STD_LOGIC_VECTOR (31 downto 0);
	   		clk : in STD_LOGIC;
			reset : in STD_LOGIC);
	end component;

	component ID_EX_Regs
    Port (  npc_id : in  STD_LOGIC_VECTOR (31 downto 0);
			npc_ex : out  STD_LOGIC_VECTOR (31 downto 0);
			rs_data_id : in  STD_LOGIC_VECTOR (31 downto 0);
			rs_ex : out  STD_LOGIC_VECTOR (31 downto 0);
			rt_data_id : in  STD_LOGIC_VECTOR (31 downto 0);
			rt_ex : out  STD_LOGIC_VECTOR (31 downto 0);
			immediate_id : in  STD_LOGIC_VECTOR (31 downto 0);
			immediate_ex : out  STD_LOGIC_VECTOR (31 downto 0);
			is_reg_inst_id : in  STD_LOGIC;
			is_reg_inst_ex : out  STD_LOGIC;
			shift_amount_id : integer range 0 to 31;
			shift_amount_ex : integer range 0 to 31;
			alu_op_code_id : integer range 0 to 15;
			alu_op_code_ex : integer range 0 to 15;
			is_link_id : in  STD_LOGIC;
			is_link_ex : out  STD_LOGIC;
			mem_op_code_id : in  integer range 0 to 7;
			mem_op_code_ex : out integer range 0 to 7;
			is_mem_read_id : in  STD_LOGIC;
			is_mem_read_ex : out  STD_LOGIC;
			is_mem_write_id : in  STD_LOGIC;
			is_mem_write_ex : out STD_LOGIC;
			is_reg_write_id : in  STD_LOGIC;
			is_reg_write_ex : out STD_LOGIC;
			rs_id_id : in  integer range 0 to 127;
			rs_id_ex : out integer range 0 to 127;
			rt_id_id : in  integer range 0 to 127;
			rt_id_ex : out integer range 0 to 127;
			rd_id_id : in  integer range 0 to 127;
			rd_id_ex : out integer range 0 to 127;
			clk : in STD_LOGIC;
			reset : in STD_LOGIC);
	end component;

	component DataByPass 
    Port (  rs_id : in  INTEGER RANGE 0 to 127;
			rt_id : in  INTEGER RANGE 0 to 127;
			l_rd_id : in  INTEGER RANGE 0 to 127;
			ll_rd_id : in  INTEGER RANGE 0 to 127;
			l_is_reg_write : in  STD_LOGIC;
			ll_is_reg_write : in  STD_LOGIC;
			is_reg_inst : in  STD_LOGIC;
			rs : in  STD_LOGIC_VECTOR (31 downto 0);
			rt : in  STD_LOGIC_VECTOR (31 downto 0);
			immediate : in  STD_LOGIC_VECTOR (31 downto 0);
			l_result : in  STD_LOGIC_VECTOR (31 downto 0);
			ll_result : in  STD_LOGIC_VECTOR (31 downto 0);
			lhs : out  STD_LOGIC_VECTOR (31 downto 0);
			rhs : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;

	component alu
	Port (  lhs : in  STD_LOGIC_VECTOR (31 downto 0);
			rhs : in  STD_LOGIC_VECTOR (31 downto 0);
			shift_amount : in INTEGER RANGE 0 to 31;
			alu_opcode : in  INTEGER RANGE 0 to 15;
			result : out STD_LOGIC_VECTOR(31 downto 0));
	end component;

	component EX_MEM_Regs
    Port (  result_ex : in  STD_LOGIC_VECTOR (31 downto 0);
			result_mem : out  STD_LOGIC_VECTOR (31 downto 0);
			rt_ex : in  STD_LOGIC_VECTOR (31 downto 0);
			rt_mem : out  STD_LOGIC_VECTOR (31 downto 0);
			mem_op_code_ex : in integer range 0 to 7;
			mem_op_code_mem : out integer range 0 to 7;
			is_mem_read_ex : in  STD_LOGIC;
			is_mem_read_mem : out  STD_LOGIC;
			is_mem_write_ex : in  STD_LOGIC;
			is_mem_write_mem : out  STD_LOGIC;
			is_reg_write_ex : in  STD_LOGIC;
			is_reg_write_mem : out  STD_LOGIC;
			rd_id_ex : in  integer range 0 to 127;
			rd_id_mem : out integer range 0 to 127; 
			clk : in  STD_LOGIC;
			reset : in STD_LOGIC);
	end component;

	component DataMasker
    Port (  data_in : in  STD_LOGIC_VECTOR (31 downto 0);
			mem_op_code : in integer range 0 to 7;
			data_out : out  STD_LOGIC_VECTOR (31 downto 0));
	end component;


	component MEM_WB_Regs
    Port (  result_mem : in  STD_LOGIC_VECTOR (31 downto 0);
			result_wb : out  STD_LOGIC_VECTOR (31 downto 0);
			is_reg_write_mem : in  STD_LOGIC;
			is_reg_write_wb : out  STD_LOGIC;
			rd_id_mem : in  integer range 0 to 127;
			rd_id_wb : out  integer range 0 to 127;
			clk : in STD_LOGIC;
			reset : in STD_LOGIC);
	end component;
end CPUComponent;

package body CPUComponent is

end CPUComponent;