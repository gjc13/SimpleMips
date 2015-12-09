----------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
-- 
-- Create Date:    18:32:18 11/02/2015 
-- Design Name: 
-- Module Name:    alu - Behavioral 
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
use work.Definitions.ALL;
use work.Utilities.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu is
	Port (  lhs : in  STD_LOGIC_VECTOR (31 downto 0);
			rhs : in  STD_LOGIC_VECTOR (31 downto 0);
			shift_amount : in INTEGER RANGE 0 to 31;
			alu_opcode : in  INTEGER RANGE 0 to 15;
			result : out STD_LOGIC_VECTOR(31 downto 0)
		);
end alu;

architecture Behavioral of alu is

begin
	process(lhs, rhs, shift_amount, alu_opcode)
	begin
		case alu_opcode is
			when ALU_NONE =>
				result <= X"00000000";
			when ALU_ADD =>
				result <= std_logic_vector(unsigned(lhs) + unsigned(rhs));
			when ALU_SUB =>
				result <= std_logic_vector(unsigned(lhs) - unsigned(rhs));
			when ALU_AND =>
				result <= lhs and rhs;
			when ALU_OR =>
				result <= lhs or rhs;
			when ALU_NOT =>
				result <= not lhs;
			when ALU_SHL => 
				result <= std_logic_vector(shift_left(unsigned(lhs), shift_amount));
			when ALU_SLL =>
				result <= std_logic_vector(shift_left(unsigned(rhs), shift_amount));
			when ALU_SHR =>
				result <= std_logic_vector(shift_right(unsigned(lhs), shift_amount));
			when ALU_SRA =>
				result <= std_logic_vector(shift_right(signed(rhs), shift_amount));
			when ALU_SRL =>
				result <= std_logic_vector(shift_right(unsigned(rhs), shift_amount));
			when ALU_LS =>
				result <= (0 => to_std_logic(signed(lhs) < signed(rhs)), others => '0');
			when ALU_LU =>
				result <= (0 => to_std_logic(unsigned(lhs) < unsigned(rhs)), others => '0');
			when ALU_SLLV =>
				result <= std_logic_vector(shift_left(unsigned(rhs), to_integer(unsigned(lhs))));
			when ALU_SRLV =>
				result <= std_logic_vector(shift_right(unsigned(rhs), to_integer(unsigned(lhs))));
			when others =>
				result <= X"00000000";
		end case;
	end process;
end Behavioral;

