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
    Port ( rs : in  STD_LOGIC_VECTOR (31 downto 0);
           rt : in  STD_LOGIC_VECTOR (31 downto 0);
           immediate : in  STD_LOGIC_VECTOR (31 downto 0);
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

begin
	process(rs, rt, immediate, is_reg_inst, branch_opcode)
		variable rhs : std_logic_vector(31 downto 0);
		variable lhs : std_logic_vector(31 downto 0);
	begin
		rhs := rs;
		if(is_reg_inst = '1') then
			lhs := rt;
		else 
			lhs := immediate;
		end if;
		case branch_opcode is
			when B_ALL => compare_result <= '1';
			when B_EQ => compare_result <= to_std_logic(rhs = lhs);
			when B_NE => compare_result <= to_std_logic(rhs /= lhs);
			when B_G => compare_result <= to_std_logic(signed(rhs) > signed(lhs));
			when B_GE => compare_result <= to_std_logic(signed(rhs) >= signed(lhs));
			when B_L => compare_result <= to_std_logic(signed(rhs) < signed(lhs));
			when B_LE => compare_result <= to_std_logic(signed(rhs) <= signed(lhs));
			when others => NULL;
		end case;
	end process;

	process(compare_result, is_branch, is_jump)
	begin
		need_branch <= (is_branch and compare_result) or is_jump;
	end process;

	process(branch_offset, next_pc, is_branch, jump_pc, is_jump, rs, is_jr)
	begin 
		if (is_jr = '1') then
			final_pc <= rs;
		elsif (is_jump = '1') then
			final_pc <= jump_pc;
		else
			final_pc <= std_logic_vector(unsigned(branch_offset) + unsigned(next_pc));
		end if;
	end process;
end Behavioral;

