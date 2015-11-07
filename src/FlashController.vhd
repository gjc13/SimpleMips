----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    14:06:31 11/07/2015 
-- Design Name: 
-- Module Name:    FlashController - Behavioral 
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

entity FlashController is
    Port (  addr_bus : inout  STD_LOGIC_VECTOR (31 downto 0);
			data_bus : inout  STD_LOGIC_VECTOR (31 downto 0);
			r_bus : inout  STD_LOGIC;
			w_bus : inout  STD_LOGIC;
			flash_addr : out  STD_LOGIC_VECTOR (22 downto 0);
			flash_data : out  STD_LOGIC_VECTOR (15 downto 0);
			mem_bus_use : in STD_LOGIC;
			flash_bus_use : out STD_LOGIC;
			intr : out STD_LOGIC);
end FlashController;

architecture Behavioral of FlashController is

begin


end Behavioral;

