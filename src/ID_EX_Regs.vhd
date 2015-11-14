----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:02:45 11/09/2015 
-- Design Name: 
-- Module Name:    ID_EX_Regs - Behavioral 
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
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity ID_EX_Regs is
    Port (  npc_id : in  STD_LOGIC_VECTOR (31 downto 0);
			npc_ex : out  STD_LOGIC_VECTOR (31 downto 0);
			rs_data_id : in  STD_LOGIC_VECTOR (31 downto 0);
			rs_ex : out  STD_LOGIC_VECTOR (31 downto 0);
			rt_data_id : in  STD_LOGIC_VECTOR (31 downto 0);
			rt_ex : out  STD_LOGIC_VECTOR (31 downto 0);
			immediate_id : in  STD_LOGIC_VECTOR(31 downto 0);
			immediate_ex : out  STD_LOGIC_VECTOR(31 downto 0);
			is_reg_inst_id : in  STD_LOGIC;
			is_reg_inst_ex : out  STD_LOGIC;
			shift_amount_id : in  integer range 0 to 31;
			shift_amount_ex : out integer range 0 to 31;
			alu_op_code_id : in integer range 0 to 15;
			alu_op_code_ex : out integer range 0 to 15;
			is_link_id : in  STD_LOGIC;
			is_link_ex : out  STD_LOGIC;
			mem_op_code_id : in  integer range 0 to 7;
			mem_op_code_ex : out integer range 0 to 7;
			is_mem_read_id : in  STD_LOGIC;
			is_mem_read_ex : out  STD_LOGIC;
			is_mem_write_id : in  STD_LOGIC;
			is_mem_write_ex : out  STD_LOGIC;
			is_reg_write_id : in  STD_LOGIC;
			is_reg_write_ex : out  STD_LOGIC;
			rs_id_id : in  integer range 0 to 127;
			rs_id_ex : out integer range 0 to 127;
			rt_id_id : in  integer range 0 to 127;
			rt_id_ex : out integer range 0 to 127;
			rd_id_id : in  integer range 0 to 127;
			rd_id_ex : out integer range 0 to 127;
			clk : in STD_LOGIC;
			reset: in STD_LOGIC);
end ID_EX_Regs;

architecture Behavioral of ID_EX_Regs is

begin
	process(clk, reset)
	begin
		if(reset = '1') then
			is_reg_write_ex <= '0';
			is_mem_write_ex <= '0';
			is_mem_read_ex <= '0';
			is_link_ex <= '0';
		elsif(clk'event and clk = '1') then
			npc_ex <= npc_id;
			rs_ex <= rs_data_id;
			rt_ex <= rt_data_id;
			immediate_ex <= immediate_id;
			is_reg_inst_ex <= is_reg_inst_id;
			shift_amount_ex <= shift_amount_id;
			alu_op_code_ex <= alu_op_code_id;
			is_link_ex <= is_link_id;
			mem_op_code_ex <= mem_op_code_id;
			is_mem_read_ex <= is_mem_read_id;
			is_mem_write_ex <= is_mem_write_id;
			is_reg_write_ex <= is_reg_write_id;
			rs_id_ex <= rs_id_id;
			rt_id_ex <= rt_id_id;
			rd_id_ex <= rd_id_id;
		end if;
	end process;
end Behavioral;

