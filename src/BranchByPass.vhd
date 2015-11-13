----------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
-- 
-- Create Date:    21:23:26 11/01/2015 
-- Design Name: 
-- Module Name:    BranchByPass - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: -- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.Definitions.ALL;
use work.Utilities.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity BranchByPass is
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
end BranchByPass;

architecture Behavioral of BranchByPass is
	signal compare_result : std_logic;
	signal selected_rt : std_logic_vector(31 downto 0);
	signal rhs : std_logic_vector(31 downto 0);
	signal lhs : std_logic_vector(31 downto 0);
begin
	process (rs_id, l_is_reg_write, ll_is_reg_write, lll_is_reg_write, l_rd_id, ll_rd_id, lll_rd_id, rs, l_result, ll_result, lll_result)
	begin
		if (l_is_reg_write = '1' and l_rd_id /= 0 and l_rd_id = rs_id) then
			lhs <= l_result;
		elsif (ll_is_reg_write = '1' and ll_rd_id /= 0 and ll_rd_id = rs_id) then
			lhs <= ll_result;
		elsif (lll_is_reg_write = '1' and ll_rd_id /= 0 and ll_rd_id = rs_id) then
			lhs <= lll_result;
		else
			lhs <= rs;
		end if;
	end process;

	process (rt_id, l_is_reg_write, ll_is_reg_write, lll_is_reg_write, l_rd_id, ll_rd_id, lll_rd_id, rt, l_result, ll_result, lll_result)
	begin
		if (l_is_reg_write = '1' and l_rd_id /= 0 and l_rd_id = rt_id) then
			selected_rt <= l_result;
		elsif (ll_is_reg_write = '1' and ll_rd_id /= 0 and ll_rd_id = rt_id) then
			selected_rt <= ll_result;
		elsif (lll_is_reg_write = '1' and ll_rd_id /= 0 and ll_rd_id = rt_id) then
			selected_rt <= lll_result;
		else
			selected_rt <= rt;
		end if;
	end process;

	process (selected_rt, immediate, is_reg_inst)
	begin
		if (is_reg_inst = '1') then
			rhs <= selected_rt;
		else 
			rhs <= immediate;
		end if;
	end process;

	process(lhs, rhs, is_reg_inst, branch_opcode)
	begin
		case branch_opcode is
			when B_ALL => compare_result <= '1';
			when B_EQ => compare_result <= to_std_logic(rhs = lhs);
			when B_NE => compare_result <= to_std_logic(rhs /= lhs);
			when B_G => compare_result <= to_std_logic(signed(lhs) > signed(rhs));
			when B_GE => compare_result <= to_std_logic(signed(lhs) >= signed(rhs));
			when B_L => compare_result <= to_std_logic(signed(lhs) < signed(rhs));
			when B_LE => compare_result <= to_std_logic(signed(lhs) <= signed(rhs));
			when others => NULL;
		end case;
	end process;

	process(compare_result, is_branch, is_jump)
	begin
		need_branch <= (is_branch and compare_result) or is_jump;
	end process;

	process(branch_offset, next_pc, is_branch, jump_pc, is_jump, is_jr, lhs)
	begin 
		if (is_branch = '1' and is_jump = '0') then
			final_pc <= std_logic_vector(unsigned(branch_offset) + unsigned(next_pc));
		elsif (is_jump = '1' and is_jr = '0') then
			final_pc <= jump_pc;
		elsif (is_jr = '1') then
			final_pc <= lhs;
		else
			final_pc <= X"00000000";
		end if;
	end process;
end Behavioral;

