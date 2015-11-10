----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:20:29 11/10/2015 
-- Design Name: 
-- Module Name:    MemConflictSolver - Behavioral 
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

entity MemConflictSolver is
    Port (  r_pc : in  STD_LOGIC;
			w_pc : in  STD_LOGIC;
			r_mem : in  STD_LOGIC;
			w_mem : in  STD_LOGIC;
			is_dma_mem : in STD_LOGIC;
			addr_pc : in  STD_LOGIC_VECTOR (31 downto 0);
			addr_mem : in  STD_LOGIC_VECTOR (31 downto 0);
			is_bubble : out  STD_LOGIC;
			addr_core : out  STD_LOGIC_VECTOR (31 downto 0);
			r_core : out  STD_LOGIC;
			w_core : out  STD_LOGIC);
end MemConflictSolver;

architecture Behavioral of MemConflictSolver is
	signal bubble : std_logic;
	signal is_mem : std_logic;
	signal is_pc : std_logic;
begin
	is_mem <= r_mem or w_mem;
	is_pc <= r_pc or w_pc;
	bubble <= (is_mem and is_pc) or is_dma_mem;
	is_bubble <= bubble;
	addr_core <= addr_mem when is_mem = '1' else addr_pc;
	r_core <= r_mem when is_mem = '1' else r_pc;
	w_core <= w_mem when is_mem = '1' else w_pc;
end Behavioral;

