----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    17:12:45 11/24/2015 
-- Design Name: 
-- Module Name:    victim_finder - Behavioral 
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
use work.Definitions.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity VictimFinder is
    Port (  now_pc : in  STD_LOGIC_VECTOR (31 downto 0);
			is_bubble : in  STD_LOGIC;
			pre_branch : in STD_LOGIC;
			victim_pc : out  STD_LOGIC_VECTOR (31 downto 0);
			is_in_slot : out STD_LOGIC;
			clk : in STD_LOGIC;
			reset : in STD_LOGIC);
end VictimFinder;

architecture Behavioral of VictimFinder is
	signal victim_pc_buf1 : std_logic_vector (31 downto 0);
	signal victim_pc_buf2 : std_logic_vector (31 downto 0);
	signal pre_branch_buf1 : std_logic;
	signal pre_branch_buf2 : std_logic;

begin
	victim_pc <= victim_pc_buf2;
	is_in_slot <= pre_branch_buf2;
	process(clk, reset)
		variable is_in_slot : std_logic;
	begin
		if reset = '1' then
			victim_pc_buf1 <= START_ADDR;
			victim_pc_buf2 <= START_ADDR;
		elsif clk'event and clk = '1' then
			if is_bubble = '1' then
				victim_pc_buf1 <= victim_pc_buf1;
				pre_branch_buf1 <= pre_branch_buf1;
			else
				victim_pc_buf1 <= now_pc;
				pre_branch_buf1 <= pre_branch;
			end if;
			victim_pc_buf2 <= victim_pc_buf1;
			pre_branch_buf2 <= pre_branch_buf1;
		end if;
	end process;
end Behavioral;

