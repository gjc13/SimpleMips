----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    08:51:21 11/09/2015 
-- Design Name: 
-- Module Name:    IF_ID_Regs - Behavioral 
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
use work.Utilities.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IF_ID_Regs is
    Port (  npc_if : in  STD_LOGIC_VECTOR (31 downto 0);
			npc_id : out  STD_LOGIC_VECTOR (31 downto 0);
			inst_if : in  STD_LOGIC_VECTOR (31 downto 0);
			inst_id : out  STD_LOGIC_VECTOR (31 downto 0);
			clk : in STD_LOGIC;
			reset : in STD_LOGIC);
end IF_ID_Regs;

architecture Behavioral of IF_ID_Regs is

begin
	process(clk, reset)
	begin
		if(reset = '1') then
			npc_id <= X"00000000";
			inst_id <= X"00000000";
		elsif(clk'event and clk = '1') then
			--report "inst_id";
			--print_hex(inst_if);
			npc_id <= npc_if;
			inst_id <= inst_if;
		end if;
	end process;

end Behavioral;

