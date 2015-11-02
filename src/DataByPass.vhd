----------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
-- 
-- Create Date:    13:49:46 11/02/2015 
-- Design Name: 
-- Module Name:    DataByPass - Behavioral 
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

entity DataByPass is
    Port ( rs_id : in  INTEGER RANGE 0 to 127;
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
end DataByPass;

architecture Behavioral of DataByPass is
	signal selected_rt : std_logic_vector(31 downto 0);
begin
	process (rs_id, l_is_reg_write, ll_is_reg_write, l_rd_id, ll_rd_id, rs, l_result, ll_result)
	begin
		if (l_is_reg_write = '1' and l_rd_id /= 0 and l_rd_id = rs_id) then
			lhs <= l_result;
		elsif (ll_is_reg_write = '1' and ll_rd_id /= 0 and ll_rd_id = rs_id) then
			lhs <= ll_result;
		else
			lhs <= rs;
		end if;
	end process;

	process (rt_id, l_is_reg_write, ll_is_reg_write, l_rd_id, ll_rd_id, rt, l_result, ll_result)
	begin
		if (l_is_reg_write = '1' and l_rd_id /= 0 and l_rd_id = rt_id) then
			selected_rt <= l_result;
		elsif (ll_is_reg_write = '1' and ll_rd_id /= 0 and ll_rd_id = rt_id) then
			selected_rt <= ll_result;
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
end Behavioral;

