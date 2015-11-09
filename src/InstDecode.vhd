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
end InstDecode;

architecture Behavioral of InstDecode is
begin

	process(inst, l_is_mem_read, l_is_mem_write)
		variable op_code : integer range 0 to 63;
		variable funct : integer range 0 to 63;
		variable rt_id_inst : integer range 0 to 127;
		variable rd_id_inst : integer range 0 to 127;
		variable shamt : std_logic_vector(4 downto 0);
	begin
		op_code := to_integer(unsigned(inst(31 downto 26)));
		rt_id_inst := to_integer(unsigned(inst(20 downto 16)));
		rd_id_inst := to_integer(unsigned(inst(15 downto 11)));
		funct := to_integer(unsigned(inst(5 downto 0))); 
		if l_is_mem_read = '1' or l_is_mem_write = '1' then
			is_branch <= '0';
			is_reg_inst <= '0';
			is_mem_read <= '0';
			is_mem_write <= '0';
			alu_opcode <= ALU_NONE;
			is_reg_write <= '0';
		else
			case op_code is
				when 0 => 	--nop, jr, jalr, addu, slt, 
					case funct is 
						when 0 => --nop
							is_jump <= '0';
							is_branch <= '0';
							is_reg_inst <= '1';
							is_mem_read <= '0';
							is_mem_write <= '0';
							is_reg_write <= '0';
							is_link <= '0';
							alu_opcode <= ALU_NONE;
						when 8 => --jr
							is_jump <= '1';
							is_jr <= '1';
							is_jl <= '0';
							is_link <= '0';
							is_branch <= '0';
							is_reg_inst <= '1';
							is_mem_read <= '0';
							is_mem_write <= '0';
							is_reg_write <= '0';
							alu_opcode <= ALU_ADD;
						when 9 => --jalr
							is_jump <= '1';
							is_jr <= '1';
							is_jl <= '1';
							is_link <= '1';
							is_branch <= '0';
							is_reg_inst <= '1';
							is_mem_read <= '0';
							is_mem_write <= '0';
							is_reg_write <= '1';
							alu_opcode <= ALU_ADD;
							rd_id <= rd_id_inst;
						when 33 => --addu
							is_jump <= '0';
							is_branch <= '0';
							is_link <= '0';
							is_reg_inst <= '1';
							is_mem_read <= '0';
							is_mem_write <= '0';
							is_reg_write <= '1';
							alu_opcode <= ALU_ADD;
							rd_id <= rd_id_inst;
						when 42 => --slt
							is_jump <= '0';
							is_branch <= '0';
							is_link <= '0';
							is_reg_inst <= '1';
							is_mem_read <= '0';
							is_mem_write <= '0';
							is_reg_write <= '1';
							alu_opcode <= ALU_LS;
							rd_id <= rd_id_inst;
						when others => NULL;
					end case;

				when 1 => --bgez
					is_jump <= '0';
					is_branch <= '1';
					is_link <= '0';
					branch_offset <= std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
					branch_opcode <= B_GE;
					is_reg_inst <= '0';
					is_mem_read <= '0';
					is_mem_write <= '0';
					alu_opcode <= ALU_NONE;
					is_reg_write <= '0';

				when 4 => --beq
					is_jump <= '0';
					is_branch <= '1';
					is_link <= '0';
					branch_offset <= std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
					branch_opcode <= B_EQ;
					is_reg_inst <= '0';
					is_mem_read <= '0';
					is_mem_write <= '0';
					alu_opcode <= ALU_NONE;
					is_reg_write <= '0';

				when 5 => --bne
					is_jump <= '0';
					is_branch <= '1';
					is_link <= '0';
					branch_offset <= std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
					branch_opcode <= B_NE;
					is_reg_inst <= '0';
					is_mem_read <= '0';
					is_mem_write <= '0';
					alu_opcode <= ALU_NONE;
					is_reg_write <= '0';

				when 6 => --blez
					is_jump <= '0';
					is_branch <= '1';
					is_link <= '0';
					branch_offset <= std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
					branch_opcode <= B_LE;
					is_reg_inst <= '0';
					is_mem_read <= '0';
					is_mem_write <= '0';
					alu_opcode <= ALU_NONE;
					is_reg_write <= '0';

				when 7 => --bgtz
					is_jump <= '0';
					is_branch <= '1';
					is_link <= '0';
					branch_offset <= std_logic_vector(resize(signed(inst(15 downto 0) & "00"), branch_offset'length));
					branch_opcode <= B_G;
					is_reg_inst <= '0';
					is_mem_read <= '0';
					is_mem_write <= '0';
					alu_opcode <= ALU_NONE;
					is_reg_write <= '0';

				when 9 => --addiu
					is_jump <= '0';
					is_branch <= '0';
					is_link <= '0';
					is_reg_inst <= '0';
					is_mem_read <= '0';
					is_mem_write <= '0';
					alu_opcode <= ALU_ADD;
					is_reg_write <= '1';
					rd_id <= rt_id_inst;
					immediate <= std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));

				when 12 => --andi
					is_jump <= '0';
					is_branch <= '0';
					is_link <= '0';
					is_reg_inst <= '0';
					is_mem_read <= '0';
					is_mem_write <= '0';
					alu_opcode <= ALU_AND;
					is_reg_write <= '1';
					rd_id <= rt_id_inst;
					immediate <= X"0000" & inst(15 downto 0);

				when 13 => --ori
					is_jump <= '0';
					is_branch <= '0';
					is_link <= '0';
					is_reg_inst <= '0';
					is_mem_read <= '0';
					is_mem_write <= '0';
					alu_opcode <= ALU_OR;
					is_reg_write <= '1';
					rd_id <= rt_id_inst;
					immediate <= X"0000" & inst(15 downto 0);

				when 15 => --lui
					is_jump <= '0';
					is_branch <= '0';
					is_link <= '0';
					is_reg_inst <= '0';
					is_mem_read <= '0';
					is_mem_write <= '0';
					alu_opcode <= ALU_ADD;
					is_reg_write <= '1';
					rd_id <= rt_id_inst;
					immediate <= inst(15 downto 0) & X"0000";

				when 32 => --lb
					is_jump <= '0';
					is_branch <= '0';
					is_link <= '0';
					is_reg_inst <= '0';
					is_mem_read <= '1';
					is_mem_write <= '0';
					alu_opcode <= ALU_ADD;
					is_reg_write <= '1';
					rd_id <= rt_id_inst;
					immediate <= std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));
					mem_opcode <= MEM_BS;

				when 35 => --lw
					is_jump <= '0';
					is_branch <= '0';
					is_link <= '0';
					is_reg_inst <= '0';
					is_mem_read <= '1';
					is_mem_write <= '0';
					alu_opcode <= ALU_ADD;
					is_reg_write <= '1';
					rd_id <= rt_id_inst;
					immediate <= std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));
					mem_opcode <= MEM_W;

				when 43 => --sw
					is_jump <= '0';
					is_branch <= '0';
					is_link <= '0';
					is_reg_inst <= '0';
					is_mem_read <= '0';
					is_mem_write <= '1';
					alu_opcode <= ALU_ADD;
					is_reg_write <= '0';
					immediate <= std_logic_vector(resize(signed(inst(15 downto 0)), immediate'length));
					mem_opcode <= MEM_W;

				when others => NULL;
			end case;
		end if;
	end process;

end Behavioral;

