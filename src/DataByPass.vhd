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
use work.Definitions.ALL;

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
           l_is_hi_lo : in  STD_LOGIC;
           ll_is_hi_lo : in  STD_LOGIC;
           l_is_reg_write : in  STD_LOGIC;
           ll_is_reg_write : in  STD_LOGIC;
           is_reg_inst : in  STD_LOGIC;
           rs : in  STD_LOGIC_VECTOR (31 downto 0);
           rt : in  STD_LOGIC_VECTOR (31 downto 0);
           immediate : in  STD_LOGIC_VECTOR (31 downto 0);
           l_result : in  STD_LOGIC_VECTOR (31 downto 0);
           ll_result : in  STD_LOGIC_VECTOR (31 downto 0);
           l_hi_lo : in  STD_LOGIC_VECTOR (63 downto 0);
           ll_hi_lo : in  STD_LOGIC_VECTOR (63 downto 0);
           lhs : out  STD_LOGIC_VECTOR (31 downto 0);
           rhs : out  STD_LOGIC_VECTOR (31 downto 0);
           rt_final : out STD_LOGIC_VECTOR (31 downto 0));
end DataByPass;

architecture Behavioral of DataByPass is
	signal selected_rt : std_logic_vector(31 downto 0);
begin
	rt_final <= selected_rt;
	process (rs_id, l_is_reg_write, ll_is_reg_write, 
            l_rd_id, ll_rd_id, rs, l_result, ll_result,
            l_is_hi_lo, l_hi_lo, ll_is_hi_lo, ll_hi_lo)
	begin
		if (l_is_reg_write = '1' and l_rd_id /= 0 and (l_rd_id = rs_id or (l_is_hi_lo = '1' and rs_id = REG_LO))) then
			if (rs_id = REG_HI) then
				lhs <= l_hi_lo(63 downto 32);
			elsif (rs_id = REG_LO) then
				lhs <= l_hi_lo(31 downto 0);
			else			
				lhs <= l_result;
			end if;
		elsif (ll_is_reg_write = '1' and ll_rd_id /= 0 and (ll_rd_id = rs_id or (ll_is_hi_lo = '1' and rs_id = REG_LO))) then
			if (rs_id = REG_HI) then
				lhs <= ll_hi_lo(63 downto 32);
			elsif (rs_id = REG_LO) then
				lhs <= ll_hi_lo(31 downto 0);
			else			
				lhs <= ll_result;
			end if;
		else
			lhs <= rs;
		end if;
	end process;

	process (rt_id, l_is_reg_write, ll_is_reg_write, 
            l_rd_id, ll_rd_id, rt, l_result, ll_result,
            l_is_hi_lo, l_hi_lo, ll_is_hi_lo, ll_hi_lo)
	begin
		if (l_is_reg_write = '1' and l_rd_id /= 0 and (l_rd_id = rt_id or (l_is_hi_lo = '1' and rt_id = REG_LO))) then
			if (rt_id = REG_HI) then
				selected_rt <= l_hi_lo(63 downto 32);
			elsif (rt_id = REG_LO) then
				selected_rt <= l_hi_lo(31 downto 0);
			else			
				selected_rt <= l_result;
			end if;
		elsif (ll_is_reg_write = '1' and ll_rd_id /= 0 and (ll_rd_id = rt_id or (ll_is_hi_lo = '1' and rt_id = REG_LO))) then
			if (rt_id = REG_HI) then
				selected_rt <= ll_hi_lo(63 downto 32);
			elsif (rt_id = REG_LO) then
				selected_rt <= ll_hi_lo(31 downto 0);
			else			
				selected_rt <= ll_result;
			end if;
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

