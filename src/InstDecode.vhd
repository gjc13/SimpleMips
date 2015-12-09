----------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
-- 
-- Create Date:    12:36:38 11/01/2015 
-- Design Name: 
-- Module Name:    InstDecode - Behavioral 
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
use work.Definitions.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity InstDecode is
    Port (  inst : in  STD_LOGIC_VECTOR (31 downto 0);
            npc : in STD_LOGIC_VECTOR (31 downto 0);
            is_jump : out  STD_LOGIC;
            jump_pc : out  STD_LOGIC_VECTOR (31 downto 0);
            is_jr   : out  STD_LOGIC;
            is_jl   : out STD_LOGIC;
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
end InstDecode;

architecture Behavioral of InstDecode is
begin

    process(inst, npc)
        variable op_code : integer range 0 to 63;
        variable funct : integer range 0 to 63;
        variable rt_id_inst : integer range 0 to 127;
        variable rd_id_inst : integer range 0 to 127;
        variable shamt : std_logic_vector(4 downto 0);
        variable npc_masked : std_logic_vector(31 downto 0);
        variable shift : integer range 0 to 31;
        
        variable is_jump_new : std_logic; 
        variable jump_pc_new : std_logic_vector(31 downto 0); 
        variable is_jr_new : std_logic;  
        variable is_jl_new : std_logic;
        variable is_link_new : std_logic;
        variable is_branch_new : std_logic;
        variable branch_offset_new : std_logic_vector (31 downto 0);
        variable branch_opcode_new : integer RANGE 0 to 15;
        variable is_reg_inst_new : std_logic;
        variable is_mem_read_new : std_logic;
        variable is_mem_write_new : std_logic;
        variable mem_opcode_new : integer RANGE 0 to 7;
        variable shift_amount_new : integer RANGE 0 to 31;
        variable is_reg_write_new : std_logic;
        variable alu_opcode_new : integer RANGE 0 to 15;
        variable rd_id_new : integer RANGE 0 to 127;
        variable immediate_new : std_logic_vector(31 downto 0);

    begin
        op_code := to_integer(unsigned(inst(31 downto 26)));
        rt_id_inst := to_integer(unsigned(inst(20 downto 16)));
        rd_id_inst := to_integer(unsigned(inst(15 downto 11)));
        shift := to_integer(unsigned(inst(10 downto 6)));
        funct := to_integer(unsigned(inst(5 downto 0))); 
        npc_masked := npc and X"F0000000";

        is_jump_new := '0';
        jump_pc_new := X"00000000";
        is_jr_new := '0';
        is_jl_new := '0';
        is_link_new := '0';
        is_branch_new := '0';
        branch_offset_new := X"00000000";
        branch_opcode_new := B_ALL;
        is_reg_inst_new := '0';
        is_mem_read_new := '0';
        is_mem_write_new := '0';
        mem_opcode_new := MEM_W;
        shift_amount_new := 0;
        is_reg_write_new := '0';
        alu_opcode_new := ALU_NONE;
        rd_id_new := 0;
        immediate_new := X"00000000";

        case op_code is
            when 0 =>   --nop, jr, jalr, addu, slt, and, subu, sltu, sra, srl
                case funct is 
                    when 0 => --nop, sll
                        is_reg_inst_new := '1';
                        shift_amount_new := shift;
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_SLL;
                        rd_id_new := rd_id_inst;
                    when 2 => --srl
                        is_reg_inst_new := '1';
                        shift_amount_new := shift;
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_SRL;
                        rd_id_new := rd_id_inst;
                    when 3 => --sra
                        is_reg_inst_new := '1';
                        shift_amount_new := shift;
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_SRA;
                        rd_id_new := rd_id_inst;
							when 4 => --sllv
								is_reg_inst_new := '1';
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_SLLV;
                        rd_id_new := rd_id_inst;
							when 6 => --srlv
								is_reg_inst_new := '1';
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_SRLV;
                        rd_id_new := rd_id_inst;
                    when 8 => --jr
                        is_jump_new := '1';
                        is_jr_new := '1';
                        is_reg_inst_new := '1';
                        alu_opcode_new := ALU_ADD;
                    when 9 => --jalr
                        is_jump_new := '1';
                        is_jr_new := '1';
                        is_jl_new := '1';
                        is_link_new := '1';
                        is_reg_inst_new := '1';
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_ADD;
                        rd_id_new := rd_id_inst;
                    when 33 => --addu
                        is_reg_inst_new := '1';
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_ADD;
                        rd_id_new := rd_id_inst;
                    when 35 => --subu
                        is_reg_inst_new := '1';
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_SUB;
                        rd_id_new := rd_id_inst;
                    when 36 => --and
                        is_reg_inst_new := '1';
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_AND;
                        rd_id_new := rd_id_inst;
                    when 42 => --slt
                        is_reg_inst_new := '1';
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_LS;
                        rd_id_new := rd_id_inst;
                    when 43 => --sltu
                        is_reg_inst_new := '1';
                        is_reg_write_new := '1';
                        alu_opcode_new := ALU_LU;
                        rd_id_new := rd_id_inst;
                    when others => NULL;
                end case;

            when 1 => --bgez, bltz
                case rt_id_inst is
                when 0 =>
                    is_branch_new := '1';
                    branch_offset_new := std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
                    branch_opcode_new := B_L;
                    alu_opcode_new := ALU_NONE;
                when 1 =>
                    is_branch_new := '1';
                    branch_offset_new := std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
                    branch_opcode_new := B_GE;
                    alu_opcode_new := ALU_NONE;
                when others => NULL;
                end case;
            when 3 => --jal
                is_jump_new := '1';
                is_jl_new := '1';
                is_link_new := '1';
                is_reg_write_new := '1';
                alu_opcode_new := ALU_ADD;
                jump_pc_new := npc_masked or std_logic_vector(resize(unsigned(inst(25 downto 0) & "00"), jump_pc'length));
                rd_id_new := 31;
                
            when 4 => --beq
                is_branch_new := '1';
                branch_offset_new := std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
                branch_opcode_new := B_EQ;
                is_reg_inst_new := '1';

            when 5 => --bne
                is_branch_new := '1';
                branch_offset_new := std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
                branch_opcode_new := B_NE;
                is_reg_inst_new := '1';

            when 6 => --blez
                is_branch_new := '1';
                branch_offset_new := std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
                branch_opcode_new := B_LE;
                is_reg_inst_new := '1';

            when 7 => --bgtz
                is_branch_new := '1';
                branch_offset_new := std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
                branch_opcode_new := B_G;
                is_reg_inst_new := '1';

            when 9 => --addiu
                alu_opcode_new := ALU_ADD;
                is_reg_write_new := '1';
                rd_id_new := rt_id_inst;
                immediate_new := std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));

            when 10 => --slti
                is_reg_write_new := '1';
                alu_opcode_new := ALU_LS;
                rd_id_new := rt_id_inst;
                immediate_new := std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));

            when 11 => --sltiu
                is_reg_write_new := '1';
                alu_opcode_new := ALU_LS;
                rd_id_new := rt_id_inst;
                immediate_new := X"0000" & inst(15 downto 0);

            when 12 => --andi
                alu_opcode_new := ALU_AND;
                is_reg_write_new := '1';
                rd_id_new := rt_id_inst;
                immediate_new := X"0000" & inst(15 downto 0);

            when 13 => --ori
                alu_opcode_new := ALU_OR;
                is_reg_write_new := '1';
                rd_id_new := rt_id_inst;
                immediate_new := X"0000" & inst(15 downto 0);

            when 15 => --lui
                alu_opcode_new := ALU_ADD;
                is_reg_write_new := '1';
                rd_id_new := rt_id_inst;
                immediate_new := inst(15 downto 0) & X"0000";

            when 32 => --lb
                is_mem_read_new := '1';
                alu_opcode_new := ALU_ADD;
                is_reg_write_new := '1';
                rd_id_new := rt_id_inst;
                immediate_new := std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));
                mem_opcode_new := MEM_BS;

            when 35 => --lw
                is_mem_read_new := '1';
                alu_opcode_new := ALU_ADD;
                is_reg_write_new := '1';
                rd_id_new := rt_id_inst;
                immediate_new := std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));
                mem_opcode_new := MEM_W;

            when 36 => --lbu
                is_mem_read_new := '1';
                alu_opcode_new := ALU_ADD;
                is_reg_write_new := '1';
                rd_id_new := rt_id_inst;
                immediate_new := std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));
                mem_opcode_new := MEM_BU;

            when 40 => --sb
                is_mem_write_new := '1';
                alu_opcode_new := ALU_ADD;
                immediate_new := std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));
                mem_opcode_new := MEM_BS;

            when 43 => --sw
                is_mem_write_new := '1';
                alu_opcode_new := ALU_ADD;
                immediate_new := std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));
                mem_opcode_new := MEM_W;

            when others => NULL;
        end case;

        is_jump <= is_jump_new;
        jump_pc <= jump_pc_new;
        is_jr <= is_jr_new;
        is_jl <= is_jl_new;
        is_link <= is_link_new;
        is_branch <= is_branch_new;
        branch_offset <= branch_offset_new;
        branch_opcode <= branch_opcode_new;
        is_reg_inst <= is_reg_inst_new;
        is_mem_read <= is_mem_read_new;
        is_mem_write <= is_mem_write_new;
        mem_opcode <= mem_opcode_new;
        shift_amount <= shift_amount_new;
        is_reg_write <= is_reg_write_new;
        alu_opcode <= alu_opcode_new;
        rd_id <= rd_id_new;
        immediate <= immediate_new;
    end process;

end Behavioral;

