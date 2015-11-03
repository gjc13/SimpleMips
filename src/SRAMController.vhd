----------------------------------------------------------------------------------
-- Company: 
-- Engineer: gjc13
-- 
-- Create Date:    13:31:19 11/03/2015 
-- Design Name: 
-- Module Name:    SRAMController - Behavioral 
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

entity SRAMController is
    Port ( addr_bus : in  STD_LOGIC_VECTOR (31 downto 0);
           r_bus : in  STD_LOGIC;
           w_bus : in  STD_LOGIC;
           addr_sram : out  STD_LOGIC_VECTOR (31 downto 0);
           r_sram : out  STD_LOGIC;
           w_sram : out  STD_LOGIC);
end SRAMController;

architecture Behavioral of SRAMController is
begin
	process(addr_bus, r_bus, w_bus)
	begin
		addr_sram <= addr_bus;
		if(addr_bus = X"bfd00000" or addr_bus = X"bfd00004") then
			r_sram <= '0';
			w_sram <= '0';
		else 
			r_sram <= r_bus;
			w_sram <= w_bus;
		end if;
	end process;

end Behavioral;

