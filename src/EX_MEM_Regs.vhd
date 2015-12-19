----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    09:28:31 11/09/2015 
-- Design Name: 
-- Module Name:    EX_MEM_Regs - Behavioral 
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

entity EX_MEM_Regs is
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
            is_tlb_write_ex : in STD_LOGIC;
            is_tlb_write_mem : out STD_LOGIC;
			clk : in  STD_LOGIC;
			reset : in STD_LOGIC);
end EX_MEM_Regs;

architecture Behavioral of EX_MEM_Regs is

begin
	process(clk, reset)
	begin 
		if(reset = '1') then
			is_reg_write_mem <= '0';
			is_mem_write_mem <= '0';
			is_mem_read_mem <= '0';
		elsif(clk'event and clk = '1') then
			result_mem <= result_ex;
			rt_mem <= rt_ex;
			mem_op_code_mem <= mem_op_code_ex;
			is_mem_write_mem <= is_mem_write_ex;
			is_mem_read_mem <= is_mem_read_ex;
			is_reg_write_mem <= is_reg_write_ex;
			rd_id_mem <= rd_id_ex;
            is_tlb_write_mem <= is_tlb_write_ex;
		end if;
	end process;
end Behavioral;

