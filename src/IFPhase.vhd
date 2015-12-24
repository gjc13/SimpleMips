----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:11:31 11/05/2015 
-- Design Name: 
-- Module Name:    IFPhase - Behavioral 
-- Project Name: -- Target Devices: 
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
use IEEE.NUMERIC_STD.ALL;
use work.Utilities.all;
use work.Definitions.all;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity IFPhase is
    Port (  is_bubble : in  STD_LOGIC;
			need_intr : in  STD_LOGIC;
            is_eret : in STD_LOGIC;
			handler_addr : in  STD_LOGIC_VECTOR (31 downto 0);
			need_branch : in  STD_LOGIC;
			branch_pc : in STD_LOGIC_VECTOR (31 downto 0);
			data_mem : in  STD_LOGIC_VECTOR (31 downto 0);
			addr_pc : out STD_LOGIC_VECTOR(31 downto 0);
			r_pc : out STD_LOGIC;
			w_pc : out STD_LOGIC;
			inst_if : out  STD_LOGIC_VECTOR (31 downto 0);
			npc_if : out  STD_LOGIC_VECTOR (31 downto 0);
			clk : in STD_LOGIC;
			reset : in STD_LOGIC);
end IFPhase;

architecture Behavioral of IFPhase is
	constant START : std_logic_vector(31 downto 0) := PRE_START_ADDR;
	constant PC_MOVE : unsigned := X"00000004";
	signal pc: std_logic_vector(31 downto 0);
	signal pc_next: std_logic_vector (31 downto 0);

begin

	r_pc <= '1';
	w_pc <= '0';
	
	process(reset, clk)
	begin
		if(reset = '1') then
			pc <= START;
		elsif(clk'event and clk = '1') then
            if(pc_next = X"80000170") then
                report "Checkpoint!";
            end if;
            pc <= pc_next;
		end if;
	end process;

	process(pc) 
	begin
		addr_pc <= pc;
		npc_if <= std_logic_vector(unsigned(pc) + PC_MOVE);
	end process;

	process(pc, branch_pc, is_bubble, 
            need_branch, need_intr, is_eret,
            handler_addr)
	begin
        if need_intr = '1' or is_eret = '1' then
            pc_next <= handler_addr;
		elsif(is_bubble = '1' and need_branch = '1') then
			-- if the branch delay slot cannot be loaded because of structural collision,
			-- we move back and execute the branch instruction again
			pc_next <= std_logic_vector(unsigned(pc) - PC_MOVE);
		elsif(is_bubble = '1') then
			pc_next <= pc;
		elsif(need_branch = '1') then
			pc_next <= branch_pc;
		else
			pc_next <= std_logic_vector(unsigned(pc) + PC_MOVE);
		end if;
	end process;

	process(data_mem, is_bubble, reset, need_intr)
	begin
		if(is_bubble = '1' or reset = '1' or need_intr = '1') then
			inst_if <= X"00000000";
		else
			inst_if <= data_mem;
		end if;
	end process;
end Behavioral;


