----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:51:49 11/09/2015 
-- Design Name: 
-- Module Name:    MEM_WB_Regs - Behavioral 
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

entity MEM_WB_Regs is
    Port (  result_mem : in  STD_LOGIC_VECTOR (31 downto 0);
			result_wb : out  STD_LOGIC_VECTOR (31 downto 0);
			is_reg_write_mem : in  STD_LOGIC;
			is_reg_write_wb : out  STD_LOGIC;
			rd_id_mem : in  integer range 0 to 127;
			rd_id_wb : out  integer range 0 to 127;
			clk : in STD_LOGIC;
			reset : in STD_LOGIC);
end MEM_WB_Regs;

architecture Behavioral of MEM_WB_Regs is

begin
	process(clk, reset)
	begin
		if(reset = '1') then
			is_reg_write_wb <= '0';
		elsif(clk'event and clk = '1') then
			result_wb <= result_mem;
			is_reg_write_wb <= is_reg_write_mem;
			rd_id_wb <= rd_id_mem;
		end if;
	end process;

end Behavioral;

